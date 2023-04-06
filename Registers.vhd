library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;


entity Registers is
  Port (clk: IN std_logic;
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
end Registers;

architecture Behavioral of Registers is

type REGS_ARRAY  is array (0 to 31) of signed(0 to 31);

SIGNAL regs: REGS_ARRAY := (others =>(others => '0'));

begin
    regs(to_integer(unsigned(dest))) <= data when write = '1' and falling_edge(clk);
    val1 <= regs(to_integer(unsigned(op1)));
    val2 <= regs(to_integer(unsigned(op2)));
    reg29 <= regs(29);
    reg30 <= regs(30);
    reg31 <= regs(31);

end Behavioral;