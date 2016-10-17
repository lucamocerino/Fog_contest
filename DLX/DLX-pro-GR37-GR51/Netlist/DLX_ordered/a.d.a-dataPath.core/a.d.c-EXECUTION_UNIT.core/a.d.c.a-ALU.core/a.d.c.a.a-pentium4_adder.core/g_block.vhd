library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity G_BLOCK is 
	
	Port (	P1:	In	std_logic;
		G1:	In	std_logic;
		G2:	In	std_logic;
		Gout:	Out	std_logic);

end G_BLOCK; 

architecture BEHAVIORAL of G_BLOCK is

  begin
	
	Gout <= G1 or (P1 and G2);
  

end BEHAVIORAL;




