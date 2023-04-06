library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Procesor is
end Procesor;

architecture Behavioral of Procesor is


component id_stage is
    Port (
        -- input
        clk: in std_logic;
        f7 : in STD_LOGIC_VECTOR (0 to 6);
        op2 : in STD_LOGIC_VECTOR (0 to 4);
        op1 : in STD_LOGIC_VECTOR (0 to 4);
        dest : in STD_LOGIC_VECTOR (0 to 4);
        opc : in STD_LOGIC_VECTOR (0 to 6);
        wb_dest: IN std_logic_vector(0 to 4);
        wb_data: IN signed(0 to 31);
        wb_isWrite: in std_logic;
        -- output
        immVal: out signed(0 to 31);
        isImm: out std_logic;
        isWrite: out std_logic;
        wbFromMem: out std_logic;
        wbFromAlu: out std_logic;
        isLoad: out std_logic;
        isStore: out std_logic;
        reg1Val: out signed(0 to 31);
        reg2Val: out signed(0 to 31);
        reg29: OUT signed(0 to 31);
        reg30: OUT signed(0 to 31);
        reg31: OUT signed(0 to 31)
    );
end component;
FOR ALL: id_stage USE ENTITY WORK.id_stage(Structural);

component ex_stage is
    Port (
        -- inputs
        clk: in std_logic;
        f7 : in STD_LOGIC_VECTOR (0 to 6);
        f3 : in STD_LOGIC_VECTOR (0 to 2);
        opc : in STD_LOGIC_VECTOR (0 to 6);
        reg1Val: IN signed(0 to 31);
        reg2Val: IN signed(0 to 31);
        immVal: IN signed(0 to 31);
        isImm: in std_logic;
        is1ExForwarded: in std_logic;
        is2ExForwarded: in std_logic;
        is1MemForwarded: in std_logic;
        is2MemForwarded: in std_logic;
        mem_writeVal: in signed(0 to 31);
           ex_result: in signed(0 to 31);

        -- outputs
        zero: OUT std_logic;
        result: OUT signed(0 to 31)
    );
end component;
FOR ALL: ex_stage USE ENTITY WORK.ex_stage(Structural);

component hazard_detection
    port (
        -- imputs
        id_op1: in STD_LOGIC_VECTOR (0 to 4);
        id_op2: in STD_LOGIC_VECTOR (0 to 4);
        ex_dest: in STD_LOGIC_VECTOR (0 to 4);
        ex_isWrite: in std_logic;
        ex_isImm: in std_logic;
        mem_dest: in STD_LOGIC_VECTOR (0 to 4);
        mem_isWrite: in std_logic;
        mem_isImm: in std_logic;
        isLoad: in std_logic;
        -- outputs
        is1ExForwarded: out std_logic;
        is2ExForwarded: out std_logic;
        is1MemForwarded: out std_logic;
        is2MemForwarded: out std_logic;
        isLoadRaw: out std_logic
    );
end component;
FOR ALL: hazard_detection USE ENTITY WORK.hazard_detection(Behavioral);

component Data_memory is
    Port (
        clk : in std_logic;
        write : in std_logic;
        read : in std_logic;
        addr : in STD_LOGIC_VECTOR (0 to 31);
        data_in : in STD_LOGIC_VECTOR (0 to 31);
        data_out : out STD_LOGIC_VECTOR (0 to 31)
    );
end component;
FOR ALL: Data_memory USE ENTITY WORK.Data_memory(Behavioral);

component Instruction_memory
    PORT (
        pc : unsigned(0 to 31);
        op1 : out STD_LOGIC_VECTOR (0 to 4);
        op2 : out STD_LOGIC_VECTOR (0 to 4);
        dest : out STD_LOGIC_VECTOR (0 to 4);
        func7 : out STD_LOGIC_VECTOR (0 to 6);
        func3 : out STD_LOGIC_VECTOR (0 to 2);
        opc : out STD_LOGIC_VECTOR (0 to 6)
    );
end component;
FOR ALL: Instruction_memory USE ENTITY WORK.Instruction_memory(Behavioral); -- SE LLAMA A LA (ARCHITECTURE) DE CADA ARCHIVO

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

signal clk: std_logic;

-- IF  
signal pc: unsigned(0 to 31):= TO_UNSIGNED(0, 32);
signal pc_next: unsigned(0 to 31);

signal if_f7 :  STD_LOGIC_VECTOR (0 to 6);
signal if_op1 : STD_LOGIC_VECTOR (0 to 4);
signal if_op2 : STD_LOGIC_VECTOR (0 to 4);
signal if_f3 :  STD_LOGIC_VECTOR (0 to 2);
signal if_dest : STD_LOGIC_VECTOR (0 to 4);
signal if_opc :  STD_LOGIC_VECTOR (0 to 6);

signal if_nop : std_logic;

-- ID
signal id_f7 :  STD_LOGIC_VECTOR (0 to 6);
signal id_f3 :  STD_LOGIC_VECTOR (0 to 2);
signal id_dest : STD_LOGIC_VECTOR (0 to 4);
signal id_opc :  STD_LOGIC_VECTOR (0 to 6);

signal id_isImm, isImm: std_logic := '0';
signal id_isLoad, isLoad: std_logic;
signal id_isStore, isStore: std_logic;
signal id_isWrite, isWrite: std_logic;
signal id_is1ExForwarded, is1ExForwarded: std_logic;
signal id_is2ExForwarded, is2ExForwarded: std_logic;
signal id_is1MemForwarded, is1MemForwarded: std_logic;
signal id_is2MemForwarded, is2MemForwarded: std_logic;
signal id_wbFromMem, wbFromMem: std_logic; -- In case of a write it comes from mem, but this may be '1' and wb '0'. In that case do not write.
signal isLoadRaw: std_logic;

signal id_immVal, immVal: signed(0 to 31);
signal id_reg1val, reg1val :  signed(0 to 31);
signal id_reg2val, reg2val :  signed(0 to 31);

signal reg29 :  signed(0 to 31);
signal reg30 :  signed(0 to 31);
signal reg31 :  signed(0 to 31);

-- EX
signal ex_opc :  STD_LOGIC_VECTOR (0 to 6);
signal ex_dest : STD_LOGIC_VECTOR (0 to 4);

signal ex_isWrite: std_logic;
signal ex_isLoad: std_logic;
signal ex_isStore: std_logic;

signal ex_isImm: std_logic := '0';
signal ex_wbFromMem: std_logic;

signal ex_immVal: signed(0 to 31);
signal ex_reg1Val :  signed(0 to 31);

signal ex_result, result: signed(0 to 31);
signal ex_zero, zero:  std_logic := '0';



-- MEM
signal mem_isWrite: std_logic;

signal memVal: signed(0 to 31);
signal mem_value: signed(0 to 31);
signal mem_dest : STD_LOGIC_VECTOR (0 to 4);
signal loadedData: std_logic_vector(0 to 31);


constant clock_period: time := 10 ns;
signal stop_the_clock: boolean;

  
begin

-- =========================
--    IF
-- =========================

pc_next <= pc - 4 + unsigned(shift_left(ex_immVal, 1)) when  ex_opc(0) = '1' and ex_zero = '1' -- -6 because current pc is 3 instr. after jump instr.
        else pc when isLoadRaw = '1'
        else pc + 2;

pc <= pc_next when rising_edge(clk);

i100: Instruction_memory PORT MAP (
    -- inputs
    pc => pc,
    -- outputs
    op1 => if_op1, op2 => if_op2, dest => if_dest, func7 => if_f7, func3 => if_f3, opc => if_opc -- I
);


if_nop <= ex_opc(0) and ex_zero; -- opc_i(0) = branch; nop = 1 when branch taken.

-- =========================
--    ID
-- =========================

i3: id_stage PORT MAP (
     -- inputs
     clk => clk,
     f7 => if_f7, op2  => if_op2, op1  => if_op1, dest => if_dest, opc => if_opc, -- I
     wb_data  => mem_value, wb_isWrite => mem_isWrite, wb_dest => mem_dest,
     -- outputs
     reg1Val  => reg1val, reg2Val  => reg2val,
     isImm  => isImm, immVal => immVal,
     isWrite => isWrite, wbFromMem => wbFromMem,
     isLoad => isLoad, isStore => isStore,
     reg29 => reg29, reg30 => reg30, reg31 => reg31
);

i2: hazard_detection port map (
    --inputs
    id_op1 => if_op1, id_op2 => if_op2,
    ex_dest => id_dest, ex_isWrite => id_isWrite, ex_isImm => isImm, isLoad => id_isLoad,
    mem_dest => ex_dest, mem_isWrite => ex_isWrite, mem_isImm => id_isImm,
    -- outputs
    is1ExForwarded => is1ExForwarded, is2ExForwarded => is2ExForwarded,
    is1MemForwarded => is1MemForwarded, is2MemForwarded => is2MemForwarded,
    isLoadRaw => isLoadRaw
);


id_f7 <= if_f7 when rising_edge(clk);
id_f3 <= if_f3 when rising_edge(clk);
id_dest <= if_dest when rising_edge(clk);
id_opc <= if_opc when rising_edge(clk);
id_isImm <= isImm when rising_edge(clk);
id_immVal <= immVal when rising_edge(clk);
id_reg1val <= reg1val when rising_edge(clk);
id_reg2val <= reg2val when rising_edge(clk);
id_wbFromMem <= wbFromMem when rising_edge(clk);
id_isLoad <= '0' when (if_nop = '1' or isLoadRaw = '1') and rising_edge(clk)
        else isLoad when rising_edge(clk);
id_isStore <=  '0' when (if_nop = '1' or isLoadRaw = '1') and rising_edge(clk)
        else isStore when rising_edge(clk);
id_isWrite <= '0' when (if_nop = '1' or isLoadRaw = '1') and rising_edge(clk)
         else isWrite when rising_edge(clk);
         
id_is1ExForwarded <= is1ExForwarded when rising_edge(clk);
id_is2ExForwarded <= is2ExForwarded when rising_edge(clk);
id_is1MemForwarded <= is1MemForwarded when rising_edge(clk);
id_is2MemForwarded <= is2MemForwarded when rising_edge(clk);
-- =========================
--    EX
-- =========================



i1: ex_stage PORT MAP (
    -- inputs
    clk => clk,
    f7 => id_f7, f3 => id_f3, opc => id_opc, -- I*
    reg1Val => id_reg1val, reg2Val => id_reg2val, immVal => id_immVal,
    isImm => id_isImm,
    is1ExForwarded => id_is1ExForwarded, is2ExForwarded => id_is2ExForwarded,
    is1MemForwarded => id_is1MemForwarded, is2MemForwarded => id_is2MemForwarded,
    mem_writeVal => mem_value,
    ex_result => ex_result,
    --outputs
    result => result, zero  => zero
);

ex_opc <= id_opc when rising_edge(clk);
ex_dest <= id_dest when rising_edge(clk);
ex_reg1Val <= id_reg1val when rising_edge(clk);

ex_immVal <= id_immVal when rising_edge(clk);
ex_result <= result when rising_edge(clk);
ex_wbFromMem <= id_wbFromMem when rising_edge(clk);
ex_isLoad <= '0' when if_nop = '1'
        else id_isLoad when rising_edge(clk);
ex_isStore <= '0' when if_nop = '1'
        else id_isStore when rising_edge(clk);
ex_isWrite <=  '0' when if_nop = '1'
        else id_isWrite when rising_edge(clk);
ex_zero <= '0' when if_nop = '1' and rising_edge(clk)
        else zero when rising_edge(clk);

-- =========================
--    MEM
-- =========================
i0: data_memory PORT MAP (
    -- inputs
    clk =>  clk,
    write  => ex_isStore, read  => ex_isLoad,
    addr => STD_LOGIC_VECTOR(ex_result), data_in => STD_LOGIC_VECTOR(ex_reg1Val),
    -- outputs
    data_out  => loadedData
);

memVal <=  signed(loadedData) when ex_wbFromMem = '1'
    else ex_result;
    
mem_dest <= ex_dest when rising_edge(clk);
mem_value <= memVal when rising_edge(clk);
mem_isWrite <= ex_isWrite when rising_edge(clk);




-- ===================================================================================================
-- ===================================================================================================
-- ===================================================================================================

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;


end Behavioral;
