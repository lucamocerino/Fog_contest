----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:18:13 07/09/2016 
-- Design Name: 
-- Module Name:    InstructionMemory - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: asynchronous ROM memory with active high reset
--
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

	type rom_type is array (0 to 16) of std_logic_vector(31 downto 0);
	signal rom : rom_type := 
									(
									X"20210005",--	addi r1, r1, 5
									X"00421026",--	xor r2, r2, r2
									X"00631826",--	xor r3, r3, r3
									X"2063000a",--	 loop1:  addi r3, r3, 10
									X"00631826",--	xor r3, r3, r3
									X"20420004",--	addi r2, r2, 4
									X"20040014",--	addi r4, r0, 20 
									X"3485000a",--	ori r5, r4, 10
									X"28210001",--	subi r1, r1, 1
									X"00853020",--	add r6, r4, r5
									X"1420ffe0",--	bnez r1,loop1
									X"204200ff",--	addi r2, r2, oxFF
									X"54000000",--NOP
									X"54000000",--NOP
									X"54000000",--NOP
									X"54000000",--NOP
									X"54000000"--NOP

	--SIMULATION 1400 ns
);
	
begin


	--dataout <= rom(to_integer(unsigned(address)));
		dataout<=rom(to_integer(unsigned(to_StdLogicVector((to_bitvector(address)) sra 2))));
end Behavioral;