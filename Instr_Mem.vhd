library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

entity Instruction_memory is
 Port ( pc : in unsigned(0 to 31);
           op1 : out STD_LOGIC_VECTOR (0 to 4);
           op2 : out STD_LOGIC_VECTOR (0 to 4);
           dest : out STD_LOGIC_VECTOR (0 to 4);
           func7 : out STD_LOGIC_VECTOR (0 to 6);
           func3 : out STD_LOGIC_VECTOR (0 to 2);
           opc : out STD_LOGIC_VECTOR (0 to 6)
           );
end Instruction_memory;

architecture Behavioral of Instruction_memory is

type MEM  is array (0 to 63) of std_logic_vector(0 to 15);

signal curr_inst : std_logic_vector (0 to 31) ;
SIGNAL inst_mem: MEM :=(
"0000000000000000", "0110000110010011",
"0000000000000000", "0110001000010011",
"0000000010010000", "0110001010010011",
"0000000000000000", "0011000010000011",
"0000000000010000", "0011000100000011",
"0000000000010001", "0000000110110011",
"0000000000000001", "0110000010010011",
"0000000000000001", "1110000100010011",
"0000000000010010", "0000001000010011",
"0000000001010010", "0000000101100011",
"1111111000000000", "0000110111100011",
"0000000000000001", "0110111010010011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011",
"0000000000000000", "0000000000110011"
);

begin 
      curr_inst <= inst_mem (to_integer(pc)) & inst_mem (to_integer(pc)+1);
      func7 <= curr_inst(0 to 6);
      op2 <= curr_inst(7 to 11);
      op1 <= curr_inst(12 to 16);
      func3 <= curr_inst(17 to 19);
      dest <= curr_inst(20 to 24);
      opc <= curr_inst(25 to 31);


end Behavioral;