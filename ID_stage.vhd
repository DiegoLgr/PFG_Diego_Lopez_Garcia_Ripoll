library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--
--
--       ======      --
--       ENTITY      --
--       ======      --
entity ID_stage is
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
        isload: out std_logic;
        isstore: out std_logic;
        reg1Val: out signed(0 to 31);
        reg2Val: out signed(0 to 31);     
        reg29: OUT signed(0 to 31);
        reg30: OUT signed(0 to 31);
        reg31: OUT signed(0 to 31) 
    );
end ID_stage;
--
--
--    ============   --
--    ARCHITECTURE   --
--    ============   --
architecture Structural of ID_stage is
--
--    COMPONENTS     --

component Registers
    PORT (
        clk: IN std_logic;
        write: IN std_logic;
        op1: IN std_logic_vector(0 to 4);
        op2: IN std_logic_vector(0 to 4);
        dest: IN std_logic_vector(0 to 4);
        data: IN signed(0 to 31);
        val1: OUT signed(0 to 31);
        val2: OUT signed(0 to 31);     
        reg29: OUT signed(0 to 31);
        reg30: OUT signed(0 to 31);
        reg31: OUT signed(0 to 31) 
    );
end component;
FOR ALL: Registers USE ENTITY WORK.Registers(Behavioral); -- SE LLAMA A LA (ARCHITECTURE) DE CADA ARCHIVO

signal isImm_aux: std_logic := '0';

begin

i0: Registers PORT MAP (
    -- inputs
    clk => clk,
    op1  => op1, op2  => op2,
    dest  => wb_dest, data  => wb_data, write  => wb_isWrite,
    -- outputs
    val1  => reg1Val, val2  => reg2Val,
    reg29 => reg29, reg30 => reg30, reg31 => reg31
);
                     


isWrite <= not( opc(1) and not opc(2) ); -- beq & sd
        
wbFromMem <= not opc(0) and not opc(2); 
         
isLoad <= not opc(0) and not opc(1) and not opc(2);
        
isStore <= not opc(0) and opc(1) and not opc(2);
         
isImm_aux <= not opc(1) or opc(4);
        
immVal <= resize(signed(f7 & op2), immVal'length) when isImm_aux = '1'
         else resize(signed(f7 & dest), immVal'length); -- sd and beq
         
isImm <= isImm_aux;
         
end Structural;
