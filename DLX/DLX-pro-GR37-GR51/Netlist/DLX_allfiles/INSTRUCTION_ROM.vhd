---------------------------------------------------------------- Create Date:    13:18:13 07/09/2016 
-- Design Name: 
-- Module Name:    InstructionMemory - Behavioral 
-- Project Name:    DLX
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.all;

entity INSTRUCTION_ROM is
	port (
   
	 Reset: in std_logic;
    address : in  std_logic_vector(31 downto 0);
    dataout : out std_logic_vector(31 downto 0)
  );
end INSTRUCTION_ROM;

architecture Behavioral of INSTRUCTION_ROM is

	type rom_type is array (0 to 14) of std_logic_vector(31 downto 0);
	signal rom : rom_type := 
									(
									
									
									
									
									
									X"2021002a",--	addi r1, r2, 42
									X"2042aaaa",--	addi r2, r2, 0xAAAAAAAA
									X"00221825",--	or r3, r1, r2
									X"20010002",--	addi r1, r0, 2
									X"00612004",--sll r4, r3, r1
									X"50650002",--	slli r5, r3, 2
									X"00a13006",--	srl r6, r5, r1
									X"58870002",--	srli r7, r4, 2
														--r6, r7 must be equal
									X"20020000",--	addi r2, r0, 0xF0000000
									X"3403f0f0",--	ori r3, r0, 0xF0F0F0F0
									X"20010005",--	addi r1, r0, 5
									X"00614007",--	sra r8, r3, r1
									X"5c690005",--	srai r9, r3, 5

									"01010100000000000000000000000000", --NOP
									"01010100000000000000000000000000" --NOP
									);
										

begin
			dataout<=rom(to_integer(unsigned(to_StdLogicVector((to_bitvector(address)) sra 2))));
end Behavioral;