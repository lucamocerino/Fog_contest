library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity SUM_GEN is 
	generic (N  : integer := 32;
			Nb : integer := 4);
	Port (	A:		In	std_logic_vector(N-1 downto 0);
			B:		In	std_logic_vector(N-1 downto 0);
			Cin:	In	std_logic_vector((N/Nb)-1 downto 0);
			Y:		Out	std_logic_vector(N-1 downto 0));

end SUM_GEN; 

architecture STRUCTURAL of SUM_GEN is

  signal S0 : std_logic_vector(N-1 downto 0);
  signal S1 : std_logic_vector(N-1 downto 0);
  signal C0 : std_logic:='0';  
  signal C1 : std_logic:='1'; 
  signal cout0 : std_logic;  
  signal cout1 : std_logic;  
  

  component SUM_GEN_BLOCK is  
	
	Port (	A:	In	std_logic_vector(Nb-1 downto 0);
			B:	In	std_logic_vector(Nb-1 downto 0);
			Cin:	In	std_logic;
			Y:	Out	std_logic_vector(Nb-1 downto 0));
  end component;


begin

  SUM: for i in 1 to (N/Nb) generate

    sum1 : SUM_GEN_BLOCK 
	  
	  Port Map (A(((i*Nb)-1) downto ((i*Nb)-Nb)), 
				B(((i*Nb)-1) downto ((i*Nb)-Nb)), 
				Cin(i-1), 
				Y(((i*Nb)-1) downto ((i*Nb)-Nb))); 

	end generate;	


end STRUCTURAL;




