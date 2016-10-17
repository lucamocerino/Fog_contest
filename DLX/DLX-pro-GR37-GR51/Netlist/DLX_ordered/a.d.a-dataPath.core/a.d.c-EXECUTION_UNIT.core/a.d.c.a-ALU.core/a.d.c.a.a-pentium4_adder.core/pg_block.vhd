library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity PG_BLOCK is 
	
	Port (	P1:	In	std_logic;
		P2:	In	std_logic;
		G1:	In	std_logic;
		G2:	In	std_logic;
		Pout:	Out	std_logic;
		Gout:	Out	std_logic);

end PG_BLOCK; 

architecture BEHAVIORAL of PG_BLOCK is

  begin
	
	Pout <= P1 and P2;
	Gout <= G1 or (P1 and G2);
  

end BEHAVIORAL;



