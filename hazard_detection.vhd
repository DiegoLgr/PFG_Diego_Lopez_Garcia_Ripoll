library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity hazard_detection is
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
end hazard_detection;

architecture Behavioral of hazard_detection is

signal aux_is1ExForwarded: std_logic;
signal aux_is2ExForwarded: std_logic;
begin

-- ex forwarded
aux_is1ExForwarded <= '1' when unsigned(id_op1) = unsigned(ex_dest) and ex_isWrite = '1'
             else '0';         
aux_is2ExForwarded <= '1' when unsigned(id_op2) = unsigned(ex_dest) and ex_isWrite = '1' and ex_isImm = '0'
             else '0';
-- mem forwarded
is1MemForwarded <= '1' when unsigned(id_op1) = unsigned(mem_dest) and mem_isWrite = '1'
             else '0';         
is2MemForwarded <= '1' when unsigned(id_op2) = unsigned(mem_dest) and mem_isWrite = '1' and ex_isImm = '0'
             else '0';
-- Raw in load
isLoadRaw <= '1' when (aux_is1ExForwarded = '1' or aux_is2ExForwarded = '1') and isLoad  = '1'
             else '0';

is1ExForwarded <= aux_is1ExForwarded;
is2ExForwarded <= aux_is2ExForwarded;

end Behavioral;