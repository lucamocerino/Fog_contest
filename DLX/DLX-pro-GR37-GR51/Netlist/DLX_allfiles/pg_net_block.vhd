library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity PG_NET_BLOCK is 
	
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		p:	Out	std_logic;
		g:	Out	std_logic);

end PG_NET_BLOCK; 

architecture BEHAVIORAL of PG_NET_BLOCK is

  begin
	
	p <= A xor B;
	g <= A and B;
  

end BEHAVIORAL;


