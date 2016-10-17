----------------------------------------------------------------------------------
-- Author:				Luca Mocerino/Biagio Feraco
-- Create Date:    	10:20:50 08/30/2016 
-- Design Name: 
-- Module Name:    	WB_UNIT - beh
-- Project Name: 	  	DLX	
-- Revision: 			TESTED
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity WB_UNIT is
	port(
		clock, reset, enable, sel_4 : in std_logic;
		data_from_memory : in std_logic_vector(31 downto 0);
		data_from_alu : in std_logic_vector(31 downto 0);
		write_back_value : out std_logic_vector(31 downto 0);
		debug_port : out std_logic_vector(31 downto 0)
	);
end WB_UNIT;

architecture Behavioral of WB_UNIT is

component mux_21 is
	generic (N: natural:=32);
    Port ( 
           A   : in  STD_LOGIC_VECTOR (N-1 downto 0);
           B   : in  STD_LOGIC_VECTOR (N-1 downto 0);
			  SEL : in  STD_LOGIC;
           O   : out STD_LOGIC_VECTOR (N-1 downto 0));
end component;

component reg 
	generic (N: natural:=32);
	port(
		input : in std_logic_vector(N-1 downto 0);
		en : in std_logic;
		clock,reset : in std_logic;
		output : out std_logic_vector(N-1 downto 0)
	);
end component;

signal from_mux_to_out : std_logic_vector(31 downto 0);

begin

MUX0 : mux_21 port map(
						a => data_from_memory,
						b => data_from_alu,
						o => from_mux_to_out,
						sel => sel_4
					);
					
RE_DEBUG : reg port map (
								clock => clock,
								reset => reset,
								en => enable,
								input => from_mux_to_out,
								output => debug_port
							);

write_back_value <= from_mux_to_out;

end Behavioral;