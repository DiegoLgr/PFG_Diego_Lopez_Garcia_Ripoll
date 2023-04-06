library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;


entity ex_control is
  Port ( 
           func7 : in STD_LOGIC_VECTOR (0 to 6);
           func3 : in STD_LOGIC_VECTOR (0 to 2);
           opc : in STD_LOGIC_VECTOR (0 to 6);
           
           ALUop: out std_logic_vector(0 to 2)
);
end ex_control;

architecture Behavioral of ex_control is
  signal inmediate: std_logic := '0';

begin
    ALUop <= "000" when (opc="0010011" and func3 = "000")                   -- addi
                   or   (opc="0110011" and func3="000" and func7(1)='0')    -- add
                   or   (opc = "0110111")                                   -- lui
                   or   (func3 = "011") else                                -- ld & sd
             "001" when (opc="0110011" and func3="000" and func7(1)='0')    -- sub
                   or   (opc(0) = '1') else                                 -- beq
             "010" when opc="0010011" and func3="100" and func7(1)='0' else -- xori
             "011" when opc="0110011" and func3="010" and func7(1)='0' else -- slt
             "100" when opc="0010011" and func3="110" and func7(1)='0' else -- ori
             "UUU"
    ;             


             
end Behavioral;