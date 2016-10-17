library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity RCA_GEN is 
	generic (N : integer := 4);
	
	Port (	A:	In	std_logic_vector(N-1 downto 0);
		B:	In	std_logic_vector(N-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(N-1 downto 0);
		Co:	Out	std_logic);
end RCA_GEN; 

architecture STRUCTURAL of RCA_GEN is

  signal TMP : std_logic_vector(N downto 0);

begin

	TMP<=(('0'&A) + B + Ci);
	S<=TMP(N-1 downto 0);
	Co<=TMP(N);

end STRUCTURAL;



