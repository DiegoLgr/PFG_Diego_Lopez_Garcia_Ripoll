library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

entity id_control is
  Port (            
           op2 : in STD_LOGIC_VECTOR (0 to 4);
           dest : in STD_LOGIC_VECTOR (0 to 4);
           func7 : in STD_LOGIC_VECTOR (0 to 6);
           opc : in STD_LOGIC_VECTOR (0 to 6);
           
           imm_value: out signed(0 to 31);
           is_imm: out std_logic
           );
end id_control;

architecture Behavioral of id_control is

signal I_type: std_logic := '0';
signal S_Type: std_logic := '0';


begin

  S_type <= '1' when (opc(0) = '0' and opc(1) = '1' and opc(2) = '0') -- sd
                     or (opc(0) = '1')                                -- beq 
            else '0';
  I_type <= '1' when (opc(1) = '0') -- I type
                 or   (opc(4) = '1')
             else '0';
  
  imm_value <= resize(signed(func7 & op2), imm_value'length) when I_type = '1'
         else resize(signed(func7 & dest), imm_value'length) when S_type = '1';
  is_imm <= I_type;

end Behavioral;