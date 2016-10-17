
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mux6_1 is
	
	port(
		in1 : in std_logic;
		in2 : in std_logic;
		in3 : in std_logic;
		in4 : in std_logic;
		in5 : in std_logic;
		in6 : in std_logic;
		s : in std_logic_vector(2 downto 0);
		output : out std_logic
		);
end mux6_1;

architecture Behavioral of mux6_1 is


begin

	with s select output <=
	in1 when "000",
	in2 when "001",
	in3 when "010",
	in4 when "011",
	in5 when "100",
	in6 when "101",
	'Z' when others;

end Behavioral;