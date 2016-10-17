library IEEE;
use IEEE.std_logic_1164.all;
entity MUX21_4bit is

generic (
	N : integer := 4);

        port (
		A:	in  std_logic_vector	(N-1 downto 0);
              	B:	in  std_logic_vector	(N-1 downto 0);
	      	SEL:	in  std_logic;
	      	Y:	out std_logic_vector	(N-1 downto 0)
		);

end MUX21_4bit;

architecture behavioral of MUX21_4bit is

	begin
		Y <= A  when SEL='1' else B; 

end behavioral;
	     






