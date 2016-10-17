library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity SUM_GEN_BLOCK is 
	generic (Nb : integer := 4);
			 
	Port (	A:	In	std_logic_vector(Nb-1 downto 0);
		B:	In	std_logic_vector(Nb-1 downto 0);
		Cin:	In	std_logic;
		Y:	Out	std_logic_vector(Nb-1 downto 0));

end SUM_GEN_BLOCK; 

architecture STRUCTURAL of SUM_GEN_BLOCK is

  signal S0 : std_logic_vector(Nb-1 downto 0);
  signal S1 : std_logic_vector(Nb-1 downto 0);
  

  component MUX21_4bit is  
	
	port (
			A: in std_logic_vector(Nb-1 downto 0);
            B: in std_logic_vector(Nb-1 downto 0);
	      	SEL: in std_logic;
	      	Y: out std_logic_vector(Nb-1 downto 0)
		);
  end component;

 component RCA_GEN is  

	port (	A:	In	std_logic_vector(Nb-1 downto 0);
		B:	In	std_logic_vector(Nb-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(Nb-1 downto 0);
		Co:	Out	std_logic); 
  end component;

begin

  
    RCA0 : RCA_GEN 
	  
	  Port Map (A, B, '1', S0, open); --for the mux21: Y <= (A and S) or (B and not(S))
	
    RCA1 : RCA_GEN 
	  
	  Port Map (A, B, '0', S1, open); 

    MUX1 : MUX21_4bit 
	  
	  Port Map (S0, S1, Cin, Y);    


end STRUCTURAL;



