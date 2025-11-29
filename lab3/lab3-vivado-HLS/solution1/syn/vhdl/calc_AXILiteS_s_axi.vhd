-- ==============================================================
-- Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.1 (64-bit)
-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- ==============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity calc_AXILiteS_s_axi is
generic (
    C_S_AXI_ADDR_WIDTH    : INTEGER := 10;
    C_S_AXI_DATA_WIDTH    : INTEGER := 32);
port (
    ACLK                  :in   STD_LOGIC;
    ARESET                :in   STD_LOGIC;
    ACLK_EN               :in   STD_LOGIC;
    AWADDR                :in   STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
    AWVALID               :in   STD_LOGIC;
    AWREADY               :out  STD_LOGIC;
    WDATA                 :in   STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
    WSTRB                 :in   STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH/8-1 downto 0);
    WVALID                :in   STD_LOGIC;
    WREADY                :out  STD_LOGIC;
    BRESP                 :out  STD_LOGIC_VECTOR(1 downto 0);
    BVALID                :out  STD_LOGIC;
    BREADY                :in   STD_LOGIC;
    ARADDR                :in   STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
    ARVALID               :in   STD_LOGIC;
    ARREADY               :out  STD_LOGIC;
    RDATA                 :out  STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
    RRESP                 :out  STD_LOGIC_VECTOR(1 downto 0);
    RVALID                :out  STD_LOGIC;
    RREADY                :in   STD_LOGIC;
    interrupt             :out  STD_LOGIC;
    ap_start              :out  STD_LOGIC;
    ap_done               :in   STD_LOGIC;
    ap_ready              :in   STD_LOGIC;
    ap_idle               :in   STD_LOGIC;
    A_address0            :in   STD_LOGIC_VECTOR(5 downto 0);
    A_ce0                 :in   STD_LOGIC;
    A_q0                  :out  STD_LOGIC_VECTOR(31 downto 0);
    B_address0            :in   STD_LOGIC_VECTOR(5 downto 0);
    B_ce0                 :in   STD_LOGIC;
    B_q0                  :out  STD_LOGIC_VECTOR(31 downto 0);
    result_address0       :in   STD_LOGIC_VECTOR(5 downto 0);
    result_ce0            :in   STD_LOGIC;
    result_we0            :in   STD_LOGIC;
    result_d0             :in   STD_LOGIC_VECTOR(31 downto 0)
);
end entity calc_AXILiteS_s_axi;

-- ------------------------Address Info-------------------
-- 0x000 : Control signals
--         bit 0  - ap_start (Read/Write/COH)
--         bit 1  - ap_done (Read/COR)
--         bit 2  - ap_idle (Read)
--         bit 3  - ap_ready (Read)
--         bit 7  - auto_restart (Read/Write)
--         others - reserved
-- 0x004 : Global Interrupt Enable Register
--         bit 0  - Global Interrupt Enable (Read/Write)
--         others - reserved
-- 0x008 : IP Interrupt Enable Register (Read/Write)
--         bit 0  - Channel 0 (ap_done)
--         bit 1  - Channel 1 (ap_ready)
--         others - reserved
-- 0x00c : IP Interrupt Status Register (Read/TOW)
--         bit 0  - Channel 0 (ap_done)
--         bit 1  - Channel 1 (ap_ready)
--         others - reserved
-- 0x100 ~
-- 0x1ff : Memory 'A' (64 * 32b)
--         Word n : bit [31:0] - A[n]
-- 0x200 ~
-- 0x2ff : Memory 'B' (64 * 32b)
--         Word n : bit [31:0] - B[n]
-- 0x300 ~
-- 0x3ff : Memory 'result' (64 * 32b)
--         Word n : bit [31:0] - result[n]
-- (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

architecture behave of calc_AXILiteS_s_axi is
    type states is (wridle, wrdata, wrresp, wrreset, rdidle, rddata, rdreset);  -- read and write fsm states
    signal wstate  : states := wrreset;
    signal rstate  : states := rdreset;
    signal wnext, rnext: states;
    constant ADDR_AP_CTRL     : INTEGER := 16#000#;
    constant ADDR_GIE         : INTEGER := 16#004#;
    constant ADDR_IER         : INTEGER := 16#008#;
    constant ADDR_ISR         : INTEGER := 16#00c#;
    constant ADDR_A_BASE      : INTEGER := 16#100#;
    constant ADDR_A_HIGH      : INTEGER := 16#1ff#;
    constant ADDR_B_BASE      : INTEGER := 16#200#;
    constant ADDR_B_HIGH      : INTEGER := 16#2ff#;
    constant ADDR_RESULT_BASE : INTEGER := 16#300#;
    constant ADDR_RESULT_HIGH : INTEGER := 16#3ff#;
    constant ADDR_BITS         : INTEGER := 10;

    signal waddr               : UNSIGNED(ADDR_BITS-1 downto 0);
    signal wmask               : UNSIGNED(31 downto 0);
    signal aw_hs               : STD_LOGIC;
    signal w_hs                : STD_LOGIC;
    signal rdata_data          : UNSIGNED(31 downto 0);
    signal ar_hs               : STD_LOGIC;
    signal raddr               : UNSIGNED(ADDR_BITS-1 downto 0);
    signal AWREADY_t           : STD_LOGIC;
    signal WREADY_t            : STD_LOGIC;
    signal ARREADY_t           : STD_LOGIC;
    signal RVALID_t            : STD_LOGIC;
    -- internal registers
    signal int_ap_idle         : STD_LOGIC;
    signal int_ap_ready        : STD_LOGIC;
    signal int_ap_done         : STD_LOGIC := '0';
    signal int_ap_start        : STD_LOGIC := '0';
    signal int_auto_restart    : STD_LOGIC := '0';
    signal int_gie             : STD_LOGIC := '0';
    signal int_ier             : UNSIGNED(1 downto 0) := (others => '0');
    signal int_isr             : UNSIGNED(1 downto 0) := (others => '0');
    -- memory signals
    signal int_A_address0      : UNSIGNED(5 downto 0);
    signal int_A_ce0           : STD_LOGIC;
    signal int_A_we0           : STD_LOGIC;
    signal int_A_be0           : UNSIGNED(3 downto 0);
    signal int_A_d0            : UNSIGNED(31 downto 0);
    signal int_A_q0            : UNSIGNED(31 downto 0);
    signal int_A_address1      : UNSIGNED(5 downto 0);
    signal int_A_ce1           : STD_LOGIC;
    signal int_A_we1           : STD_LOGIC;
    signal int_A_be1           : UNSIGNED(3 downto 0);
    signal int_A_d1            : UNSIGNED(31 downto 0);
    signal int_A_q1            : UNSIGNED(31 downto 0);
    signal int_A_read          : STD_LOGIC;
    signal int_A_write         : STD_LOGIC;
    signal int_B_address0      : UNSIGNED(5 downto 0);
    signal int_B_ce0           : STD_LOGIC;
    signal int_B_we0           : STD_LOGIC;
    signal int_B_be0           : UNSIGNED(3 downto 0);
    signal int_B_d0            : UNSIGNED(31 downto 0);
    signal int_B_q0            : UNSIGNED(31 downto 0);
    signal int_B_address1      : UNSIGNED(5 downto 0);
    signal int_B_ce1           : STD_LOGIC;
    signal int_B_we1           : STD_LOGIC;
    signal int_B_be1           : UNSIGNED(3 downto 0);
    signal int_B_d1            : UNSIGNED(31 downto 0);
    signal int_B_q1            : UNSIGNED(31 downto 0);
    signal int_B_read          : STD_LOGIC;
    signal int_B_write         : STD_LOGIC;
    signal int_result_address0 : UNSIGNED(5 downto 0);
    signal int_result_ce0      : STD_LOGIC;
    signal int_result_we0      : STD_LOGIC;
    signal int_result_be0      : UNSIGNED(3 downto 0);
    signal int_result_d0       : UNSIGNED(31 downto 0);
    signal int_result_q0       : UNSIGNED(31 downto 0);
    signal int_result_address1 : UNSIGNED(5 downto 0);
    signal int_result_ce1      : STD_LOGIC;
    signal int_result_we1      : STD_LOGIC;
    signal int_result_be1      : UNSIGNED(3 downto 0);
    signal int_result_d1       : UNSIGNED(31 downto 0);
    signal int_result_q1       : UNSIGNED(31 downto 0);
    signal int_result_read     : STD_LOGIC;
    signal int_result_write    : STD_LOGIC;

    component calc_AXILiteS_s_axi_ram is
        generic (
            BYTES   : INTEGER :=4;
            DEPTH   : INTEGER :=256;
            AWIDTH  : INTEGER :=8);
        port (
            clk0    : in  STD_LOGIC;
            address0: in  UNSIGNED(AWIDTH-1 downto 0);
            ce0     : in  STD_LOGIC;
            we0     : in  STD_LOGIC;
            be0     : in  UNSIGNED(BYTES-1 downto 0);
            d0      : in  UNSIGNED(BYTES*8-1 downto 0);
            q0      : out UNSIGNED(BYTES*8-1 downto 0);
            clk1    : in  STD_LOGIC;
            address1: in  UNSIGNED(AWIDTH-1 downto 0);
            ce1     : in  STD_LOGIC;
            we1     : in  STD_LOGIC;
            be1     : in  UNSIGNED(BYTES-1 downto 0);
            d1      : in  UNSIGNED(BYTES*8-1 downto 0);
            q1      : out UNSIGNED(BYTES*8-1 downto 0));
    end component calc_AXILiteS_s_axi_ram;

    function log2 (x : INTEGER) return INTEGER is
        variable n, m : INTEGER;
    begin
        n := 1;
        m := 2;
        while m < x loop
            n := n + 1;
            m := m * 2;
        end loop;
        return n;
    end function log2;

begin
-- ----------------------- Instantiation------------------
-- int_A
int_A : calc_AXILiteS_s_axi_ram
generic map (
     BYTES    => 4,
     DEPTH    => 64,
     AWIDTH   => log2(64))
port map (
     clk0     => ACLK,
     address0 => int_A_address0,
     ce0      => int_A_ce0,
     we0      => int_A_we0,
     be0      => int_A_be0,
     d0       => int_A_d0,
     q0       => int_A_q0,
     clk1     => ACLK,
     address1 => int_A_address1,
     ce1      => int_A_ce1,
     we1      => int_A_we1,
     be1      => int_A_be1,
     d1       => int_A_d1,
     q1       => int_A_q1);
-- int_B
int_B : calc_AXILiteS_s_axi_ram
generic map (
     BYTES    => 4,
     DEPTH    => 64,
     AWIDTH   => log2(64))
port map (
     clk0     => ACLK,
     address0 => int_B_address0,
     ce0      => int_B_ce0,
     we0      => int_B_we0,
     be0      => int_B_be0,
     d0       => int_B_d0,
     q0       => int_B_q0,
     clk1     => ACLK,
     address1 => int_B_address1,
     ce1      => int_B_ce1,
     we1      => int_B_we1,
     be1      => int_B_be1,
     d1       => int_B_d1,
     q1       => int_B_q1);
-- int_result
int_result : calc_AXILiteS_s_axi_ram
generic map (
     BYTES    => 4,
     DEPTH    => 64,
     AWIDTH   => log2(64))
port map (
     clk0     => ACLK,
     address0 => int_result_address0,
     ce0      => int_result_ce0,
     we0      => int_result_we0,
     be0      => int_result_be0,
     d0       => int_result_d0,
     q0       => int_result_q0,
     clk1     => ACLK,
     address1 => int_result_address1,
     ce1      => int_result_ce1,
     we1      => int_result_we1,
     be1      => int_result_be1,
     d1       => int_result_d1,
     q1       => int_result_q1);

-- ----------------------- AXI WRITE ---------------------
    AWREADY_t <=  '1' when wstate = wridle else '0';
    AWREADY   <=  AWREADY_t;
    WREADY_t  <=  '1' when wstate = wrdata else '0';
    WREADY    <=  WREADY_t;
    BRESP     <=  "00";  -- OKAY
    BVALID    <=  '1' when wstate = wrresp else '0';
    wmask     <=  (31 downto 24 => WSTRB(3), 23 downto 16 => WSTRB(2), 15 downto 8 => WSTRB(1), 7 downto 0 => WSTRB(0));
    aw_hs     <=  AWVALID and AWREADY_t;
    w_hs      <=  WVALID and WREADY_t;

    -- write FSM
    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                wstate <= wrreset;
            elsif (ACLK_EN = '1') then
                wstate <= wnext;
            end if;
        end if;
    end process;

    process (wstate, AWVALID, WVALID, BREADY)
    begin
        case (wstate) is
        when wridle =>
            if (AWVALID = '1') then
                wnext <= wrdata;
            else
                wnext <= wridle;
            end if;
        when wrdata =>
            if (WVALID = '1') then
                wnext <= wrresp;
            else
                wnext <= wrdata;
            end if;
        when wrresp =>
            if (BREADY = '1') then
                wnext <= wridle;
            else
                wnext <= wrresp;
            end if;
        when others =>
            wnext <= wridle;
        end case;
    end process;

    waddr_proc : process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ACLK_EN = '1') then
                if (aw_hs = '1') then
                    waddr <= UNSIGNED(AWADDR(ADDR_BITS-1 downto 0));
                end if;
            end if;
        end if;
    end process;

-- ----------------------- AXI READ ----------------------
    ARREADY_t <= '1' when (rstate = rdidle) else '0';
    ARREADY <= ARREADY_t;
    RDATA   <= STD_LOGIC_VECTOR(rdata_data);
    RRESP   <= "00";  -- OKAY
    RVALID_t  <= '1' when (rstate = rddata) and (int_A_read = '0') and (int_B_read = '0') and (int_result_read = '0') else '0';
    RVALID    <= RVALID_t;
    ar_hs   <= ARVALID and ARREADY_t;
    raddr   <= UNSIGNED(ARADDR(ADDR_BITS-1 downto 0));

    -- read FSM
    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                rstate <= rdreset;
            elsif (ACLK_EN = '1') then
                rstate <= rnext;
            end if;
        end if;
    end process;

    process (rstate, ARVALID, RREADY, RVALID_t)
    begin
        case (rstate) is
        when rdidle =>
            if (ARVALID = '1') then
                rnext <= rddata;
            else
                rnext <= rdidle;
            end if;
        when rddata =>
            if (RREADY = '1' and RVALID_t = '1') then
                rnext <= rdidle;
            else
                rnext <= rddata;
            end if;
        when others =>
            rnext <= rdidle;
        end case;
    end process;

    rdata_proc : process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ACLK_EN = '1') then
                if (ar_hs = '1') then
                    case (TO_INTEGER(raddr)) is
                    when ADDR_AP_CTRL =>
                        rdata_data <= (7 => int_auto_restart, 3 => int_ap_ready, 2 => int_ap_idle, 1 => int_ap_done, 0 => int_ap_start, others => '0');
                    when ADDR_GIE =>
                        rdata_data <= (0 => int_gie, others => '0');
                    when ADDR_IER =>
                        rdata_data <= (1 => int_ier(1), 0 => int_ier(0), others => '0');
                    when ADDR_ISR =>
                        rdata_data <= (1 => int_isr(1), 0 => int_isr(0), others => '0');
                    when others =>
                        rdata_data <= (others => '0');
                    end case;
                elsif (int_A_read = '1') then
                    rdata_data <= int_A_q1;
                elsif (int_B_read = '1') then
                    rdata_data <= int_B_q1;
                elsif (int_result_read = '1') then
                    rdata_data <= int_result_q1;
                end if;
            end if;
        end if;
    end process;

-- ----------------------- Register logic ----------------
    interrupt            <= int_gie and (int_isr(0) or int_isr(1));
    ap_start             <= int_ap_start;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_ap_start <= '0';
            elsif (ACLK_EN = '1') then
                if (w_hs = '1' and waddr = ADDR_AP_CTRL and WSTRB(0) = '1' and WDATA(0) = '1') then
                    int_ap_start <= '1';
                elsif (ap_ready = '1') then
                    int_ap_start <= int_auto_restart; -- clear on handshake/auto restart
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_ap_done <= '0';
            elsif (ACLK_EN = '1') then
                if (ap_done = '1') then
                    int_ap_done <= '1';
                elsif (ar_hs = '1' and raddr = ADDR_AP_CTRL) then
                    int_ap_done <= '0'; -- clear on read
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_ap_idle <= '0';
            elsif (ACLK_EN = '1') then
                if (true) then
                    int_ap_idle <= ap_idle;
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_ap_ready <= '0';
            elsif (ACLK_EN = '1') then
                if (true) then
                    int_ap_ready <= ap_ready;
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_auto_restart <= '0';
            elsif (ACLK_EN = '1') then
                if (w_hs = '1' and waddr = ADDR_AP_CTRL and WSTRB(0) = '1') then
                    int_auto_restart <= WDATA(7);
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_gie <= '0';
            elsif (ACLK_EN = '1') then
                if (w_hs = '1' and waddr = ADDR_GIE and WSTRB(0) = '1') then
                    int_gie <= WDATA(0);
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_ier <= "00";
            elsif (ACLK_EN = '1') then
                if (w_hs = '1' and waddr = ADDR_IER and WSTRB(0) = '1') then
                    int_ier <= UNSIGNED(WDATA(1 downto 0));
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_isr(0) <= '0';
            elsif (ACLK_EN = '1') then
                if (int_ier(0) = '1' and ap_done = '1') then
                    int_isr(0) <= '1';
                elsif (w_hs = '1' and waddr = ADDR_ISR and WSTRB(0) = '1') then
                    int_isr(0) <= int_isr(0) xor WDATA(0); -- toggle on write
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_isr(1) <= '0';
            elsif (ACLK_EN = '1') then
                if (int_ier(1) = '1' and ap_ready = '1') then
                    int_isr(1) <= '1';
                elsif (w_hs = '1' and waddr = ADDR_ISR and WSTRB(0) = '1') then
                    int_isr(1) <= int_isr(1) xor WDATA(1); -- toggle on write
                end if;
            end if;
        end if;
    end process;


-- ----------------------- Memory logic ------------------
    -- A
    int_A_address0       <= UNSIGNED(A_address0);
    int_A_ce0            <= A_ce0;
    int_A_we0            <= '0';
    int_A_be0            <= (others => '0');
    int_A_d0             <= (others => '0');
    A_q0                 <= STD_LOGIC_VECTOR(RESIZE(int_A_q0, 32));
    int_A_address1       <= raddr(7 downto 2) when ar_hs = '1' else waddr(7 downto 2);
    int_A_ce1            <= '1' when ar_hs = '1' or (int_A_write = '1' and WVALID  = '1') else '0';
    int_A_we1            <= '1' when int_A_write = '1' and WVALID = '1' else '0';
    int_A_be1            <= UNSIGNED(WSTRB);
    int_A_d1             <= UNSIGNED(WDATA);
    -- B
    int_B_address0       <= UNSIGNED(B_address0);
    int_B_ce0            <= B_ce0;
    int_B_we0            <= '0';
    int_B_be0            <= (others => '0');
    int_B_d0             <= (others => '0');
    B_q0                 <= STD_LOGIC_VECTOR(RESIZE(int_B_q0, 32));
    int_B_address1       <= raddr(7 downto 2) when ar_hs = '1' else waddr(7 downto 2);
    int_B_ce1            <= '1' when ar_hs = '1' or (int_B_write = '1' and WVALID  = '1') else '0';
    int_B_we1            <= '1' when int_B_write = '1' and WVALID = '1' else '0';
    int_B_be1            <= UNSIGNED(WSTRB);
    int_B_d1             <= UNSIGNED(WDATA);
    -- result
    int_result_address0  <= UNSIGNED(result_address0);
    int_result_ce0       <= result_ce0;
    int_result_we0       <= result_we0;
    int_result_be0       <= (others => result_we0);
    int_result_d0        <= RESIZE(UNSIGNED(result_d0), 32);
    int_result_address1  <= raddr(7 downto 2) when ar_hs = '1' else waddr(7 downto 2);
    int_result_ce1       <= '1' when ar_hs = '1' or (int_result_write = '1' and WVALID  = '1') else '0';
    int_result_we1       <= '1' when int_result_write = '1' and WVALID = '1' else '0';
    int_result_be1       <= UNSIGNED(WSTRB);
    int_result_d1        <= UNSIGNED(WDATA);

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_A_read <= '0';
            elsif (ACLK_EN = '1') then
                if (ar_hs = '1' and raddr >= ADDR_A_BASE and raddr <= ADDR_A_HIGH) then
                    int_A_read <= '1';
                else
                    int_A_read <= '0';
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_A_write <= '0';
            elsif (ACLK_EN = '1') then
                if (aw_hs = '1' and UNSIGNED(AWADDR(ADDR_BITS-1 downto 0)) >= ADDR_A_BASE and UNSIGNED(AWADDR(ADDR_BITS-1 downto 0)) <= ADDR_A_HIGH) then
                    int_A_write <= '1';
                elsif (WVALID = '1') then
                    int_A_write <= '0';
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_B_read <= '0';
            elsif (ACLK_EN = '1') then
                if (ar_hs = '1' and raddr >= ADDR_B_BASE and raddr <= ADDR_B_HIGH) then
                    int_B_read <= '1';
                else
                    int_B_read <= '0';
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_B_write <= '0';
            elsif (ACLK_EN = '1') then
                if (aw_hs = '1' and UNSIGNED(AWADDR(ADDR_BITS-1 downto 0)) >= ADDR_B_BASE and UNSIGNED(AWADDR(ADDR_BITS-1 downto 0)) <= ADDR_B_HIGH) then
                    int_B_write <= '1';
                elsif (WVALID = '1') then
                    int_B_write <= '0';
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_result_read <= '0';
            elsif (ACLK_EN = '1') then
                if (ar_hs = '1' and raddr >= ADDR_RESULT_BASE and raddr <= ADDR_RESULT_HIGH) then
                    int_result_read <= '1';
                else
                    int_result_read <= '0';
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_result_write <= '0';
            elsif (ACLK_EN = '1') then
                if (aw_hs = '1' and UNSIGNED(AWADDR(ADDR_BITS-1 downto 0)) >= ADDR_RESULT_BASE and UNSIGNED(AWADDR(ADDR_BITS-1 downto 0)) <= ADDR_RESULT_HIGH) then
                    int_result_write <= '1';
                elsif (WVALID = '1') then
                    int_result_write <= '0';
                end if;
            end if;
        end if;
    end process;


end architecture behave;

library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity calc_AXILiteS_s_axi_ram is
    generic (
        BYTES   : INTEGER :=4;
        DEPTH   : INTEGER :=256;
        AWIDTH  : INTEGER :=8);
    port (
        clk0    : in  STD_LOGIC;
        address0: in  UNSIGNED(AWIDTH-1 downto 0);
        ce0     : in  STD_LOGIC;
        we0     : in  STD_LOGIC;
        be0     : in  UNSIGNED(BYTES-1 downto 0);
        d0      : in  UNSIGNED(BYTES*8-1 downto 0);
        q0      : out UNSIGNED(BYTES*8-1 downto 0);
        clk1    : in  STD_LOGIC;
        address1: in  UNSIGNED(AWIDTH-1 downto 0);
        ce1     : in  STD_LOGIC;
        we1     : in  STD_LOGIC;
        be1     : in  UNSIGNED(BYTES-1 downto 0);
        d1      : in  UNSIGNED(BYTES*8-1 downto 0);
        q1      : out UNSIGNED(BYTES*8-1 downto 0));

end entity calc_AXILiteS_s_axi_ram;

architecture behave of calc_AXILiteS_s_axi_ram is
    signal address0_tmp : UNSIGNED(AWIDTH-1 downto 0);
    signal address1_tmp : UNSIGNED(AWIDTH-1 downto 0);
    type RAM_T is array (0 to DEPTH - 1) of UNSIGNED(BYTES*8 - 1 downto 0);
    shared variable mem : RAM_T := (others => (others => '0'));
begin

    process (address0)
    begin
    address0_tmp <= address0;
    --synthesis translate_off
          if (address0 > DEPTH-1) then
              address0_tmp <= (others => '0');
          else
              address0_tmp <= address0;
          end if;
    --synthesis translate_on
    end process;

    process (address1)
    begin
    address1_tmp <= address1;
    --synthesis translate_off
          if (address1 > DEPTH-1) then
              address1_tmp <= (others => '0');
          else
              address1_tmp <= address1;
          end if;
    --synthesis translate_on
    end process;

    --read port 0
    process (clk0) begin
        if (clk0'event and clk0 = '1') then
            if (ce0 = '1') then
                q0 <= mem(to_integer(address0_tmp));
            end if;
        end if;
    end process;

    --read port 1
    process (clk1) begin
        if (clk1'event and clk1 = '1') then
            if (ce1 = '1') then
                q1 <= mem(to_integer(address1_tmp));
            end if;
        end if;
    end process;

    gen_write : for i in 0 to BYTES - 1 generate
    begin
        --write port 0
        process (clk0)
        begin
            if (clk0'event and clk0 = '1') then
                if (ce0 = '1' and we0 = '1' and be0(i) = '1') then
                    mem(to_integer(address0_tmp))(8*i+7 downto 8*i) := d0(8*i+7 downto 8*i);
                end if;
            end if;
        end process;

        --write port 1
        process (clk1)
        begin
            if (clk1'event and clk1 = '1') then
                if (ce1 = '1' and we1 = '1' and be1(i) = '1') then
                    mem(to_integer(address1_tmp))(8*i+7 downto 8*i) := d1(8*i+7 downto 8*i);
                end if;
            end if;
        end process;

    end generate;

end architecture behave;


