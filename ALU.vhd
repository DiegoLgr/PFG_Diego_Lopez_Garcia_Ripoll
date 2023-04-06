library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;


entity ALU is
  Port (
        opc: IN std_logic_vector(0 to 2);
        A: IN signed(0 to 31);
        B: IN signed(0 to 31);
        zero: OUT std_logic;
        result: OUT signed(0 to 31)
         );
end ALU;

architecture Behavioral of ALU is
    signal result_tmp: signed(0 to 31);
begin

result_tmp <= A + B when opc = "000" else
         A - B when opc = "001" else
         A xor B when opc = "010" else
         to_signed(1, result_tmp'length) when opc = "011" and signed(A) < signed(B) else
         to_signed(0, result_tmp'length) when opc = "011" and not (signed(A) < signed(B)) else
         A or B when opc = "100" else
         (others => 'U');
             
result <= result_tmp;
zero <= '1' when result_tmp = to_signed(0, result_tmp'length) else '0';
 

end Behavioral;