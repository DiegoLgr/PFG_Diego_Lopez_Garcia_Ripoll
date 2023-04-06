library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--
--
--       ======      --
--       ENTITY      --
--       ======      --
entity EX_stage is
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
end EX_stage;
--
--
--    ============   --
--    ARCHITECTURE   --
--    ============   --
architecture Structural of EX_stage is
--
--    COMPONENTS     --

component ex_control
    Port (
        --inputs
        func7 : in STD_LOGIC_VECTOR (0 to 6);
        func3 : in STD_LOGIC_VECTOR (0 to 2);
        opc : in STD_LOGIC_VECTOR (0 to 6);
        -- outputs
        ALUop: out std_logic_vector(0 to 2)
    );
end component;
FOR ALL: ex_control USE ENTITY WORK.ex_control(Behavioral);

component ALU
    PORT (
        -- inputs
        opc: IN std_logic_vector(0 to 2);
        A: IN signed(0 to 31);
        B: IN signed(0 to 31);
        -- outputs
        result: OUT signed(0 to 31);
        zero: out std_logic
    );
end component;
FOR ALL: ALU USE ENTITY WORK.ALU(Behavioral);
--
--    SIGNALS     --
signal ALUop:  std_logic_vector(0 to 2);
signal A: signed(0 to 31);
signal B: signed(0 to 31);

--
--    MAPINGS     --
begin

A <= ex_result when is1ExForwarded = '1'
             else mem_writeVal when is1memForwarded = '1'
             else reg1Val;

B <= immVal when isImm = '1'
            else ex_result when is2ExForwarded = '1'
            else mem_writeVal when is2memForwarded = '1'
            else immVal when isImm = '1'
            else reg2Val;
                         

i1: ex_control PORT MAP (
    -- inputs
    func7 => f7, func3 => f3, opc => opc, -- I*
    -- outputs
    ALUop => ALUop
);

i2: ALU PORT MAP (
    -- inputs
    opc =>  ALUop, A  => A, B  => B,
    -- outputs
    result => result, zero  => zero
);

end Structural;