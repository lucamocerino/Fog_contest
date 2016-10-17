----------------------------------------------------------------------------------
-- Author:				Luca Mocerino/Biagio Feraco
-- Create Date:    	18:02:09 1/09/2016 
-- Design Name: 
-- Module Name:    	MEMORY_UNIT - beh
-- Project Name: 	  	DLX	
-- Revision: 			TESTED
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MEMORY_UNIT is
	port(
		clock : in std_logic;
		reset : in std_logic;
		enable : in std_logic;
		sel_jal: in std_logic;
		alu_result : in std_logic_vector(31 downto 0);
		data_from_memory : in std_logic_vector(31 downto 0);
		EX_MEM_Rd : in std_logic_vector(4 downto 0);
		
		address_memory : out std_logic_vector(31 downto 0);
		data_MEM : out std_logic_vector(31 downto 0);
		data_from_ALU : out std_logic_vector(31 downto 0);
		MEM_WB_Rd : out std_logic_vector(4 downto 0)
	);
end MEMORY_UNIT;

architecture Behavioral of MEMORY_UNIT is

component reg
	generic (N: natural:=32);
	port(
		input : in std_logic_vector(N-1 downto 0);
		en : in std_logic;
		clock,reset : in std_logic;
		output : out std_logic_vector(N-1 downto 0)
	);
end component;

component mux_21 is
	generic (N: natural:=5);
    Port ( 
           A   : in  STD_LOGIC_VECTOR (N-1 downto 0);
           B   : in  STD_LOGIC_VECTOR (N-1 downto 0);
			  SEL : in  STD_LOGIC;
           O   : out STD_LOGIC_VECTOR (N-1 downto 0));
end component;

signal MEM_WB_Rd_i: std_logic_vector(4 downto 0);
signal jal31: std_logic_vector(4 downto 0):=(others=>'1');

begin

jal31<=(others=>'1');
address_memory <= alu_result;


RE : reg generic map (5) port map(
								clock => clock,
								reset => reset,
								en => enable,
								input => EX_MEM_Rd,
								output => MEM_WB_Rd_i
							);
							
RE_1 : reg generic map (32) port map (
								clock => clock,
								reset => reset,
								en => enable,
								input => data_from_memory,
								output => data_MEM
							);

RE_2 : reg generic map (32) port map (
								clock => clock,
								reset => reset,
								en => enable,
								input => alu_result,
								output => data_from_ALU
							);
M_JAL : mux_21 port map(
							a => jal31,
							b =>mem_wb_rd_i ,
							sel => sel_jal, 
							o => mem_wb_rd
						);


end Behavioral;