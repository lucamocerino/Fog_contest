-----------------------------------------------------------------------------------
-- Create Date:    17:03:58 10/05/2016 
-- Design Name: 
-- Module Name:    comparator_struct - Behavioral 
-- Project Name:   DLX
------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--use IEEE.NUMERIC_STD.ALL;


entity comparator_struct is
		generic (N: natural:= 32);
		port (
				op_a: in std_logic_vector(N-1 downto 0);
				op_b: in std_logic_vector(N-1 downto 0);
				sel: in std_logic_vector(2 downto 0);
				out_comp: out std_logic
				);
				
end comparator_struct;

architecture Behavioral of comparator_struct is

component pentium4_adder 


	generic (N  : integer := 32;
		     Nb : integer := 4);
	
	Port (	A:		In	std_logic_vector(N-1 downto 0);
			B:		In	std_logic_vector(N-1 downto 0);
			C_0:	In	std_logic;
			S:		Out	std_logic_vector(N-1 downto 0);
			Cout:	Out	std_logic
			);


end component;

component mux6_1 
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
end component;

signal sum_i: std_logic_vector(N-1 downto 0):=(others=>'0');
signal cout_i,sum_nor,less_than_equal,less_than,grater_than,grater_than_equal,equal,not_equal: std_logic;

begin


	
	
	sum_nor  <= '1' when (sum_i = (sum_i'range => '0')) else '0'; 
	
	less_than_equal<=(not cout_i ) or sum_nor;
	less_than<= not sum_nor;
	grater_than<= (not sum_nor) and cout_i;
	grater_than_equal<=cout_i;
	equal<=sum_nor;
	not_equal<= not (sum_nor);
	



ADD: pentium4_adder port map ( A=>op_a,
										 B=>op_b,
										 c_0 => '0',
										 S=>sum_i,
										 cout=>cout_i
										 );
										 
MUX61: mux6_1 port map 		   ( in1 =>less_than_equal,
										  in2 =>less_than,
										  in3 =>grater_than,
										  in4 =>grater_than_equal,
										  in5 =>equal,
										  in6 =>not_equal,
										  s => sel,
										  output=>out_comp
										  );
						

end Behavioral;



