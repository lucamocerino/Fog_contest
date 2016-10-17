library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity pentium4_adder is 

	generic (N  : integer := 32;
		     Nb : integer := 4);
	
	Port (	A:		In	std_logic_vector(N-1 downto 0);
			B:		In	std_logic_vector(N-1 downto 0);
			C_0:	In	std_logic;
			S:		Out	std_logic_vector(N-1 downto 0);
			Cout:	Out	std_logic
			);

end pentium4_adder; 

architecture STRUCTURAL of pentium4_adder is

  signal S1 : std_logic_vector((N/Nb)-1 downto 0); 
  signal S2 : std_logic_vector((N/Nb)-1 downto 0); 
  signal B_Sub, exit_muxA, exit_muxB : std_logic_vector (N-1 downto 0);

  component SPARSE_TREE is  

	Port (	A:		In	std_logic_vector(N-1 downto 0);
			B:		In	std_logic_vector(N-1 downto 0);
			Cin:	In	std_logic;
			Y:		Out	std_logic_vector((N/Nb)-1 downto 0));
		
  end component;

  component SUM_GEN is  

	Port (	A:		In	std_logic_vector(N-1 downto 0);
			B:		In	std_logic_vector(N-1 downto 0);
			Cin:	In	std_logic_vector((N/Nb)-1 downto 0);
			Y:		Out	std_logic_vector(N-1 downto 0));

  end component;
  
  component MUX21_32bit is  
  
	port (
				A: 	 in std_logic_vector(N-1 downto 0);
            B:	 in std_logic_vector(N-1 downto 0);
	      	SEL: in std_logic;
	      	Y: 	 out std_logic_vector(N-1 downto 0)
		);
  end component;


begin

	B_Sub <= not(B);
	
	MUX1: MUX21_32bit
		Port Map ( B_Sub, B, C_0, exit_muxB);
		

	P4ADD1: SPARSE_TREE
		Port Map ( A, exit_muxB, C_0, S1((N/Nb)-1 downto 0) );

	P4ADD2: SUM_GEN
		Port Map ( A, exit_muxB, S2((N/Nb)-1 downto 0), S );
		
	S2((N/Nb)-1 downto 1) <= S1 ((N/Nb)-2 downto 0);
	S2(0) <= C_0;
	Cout <= S1((N/Nb)-1);


end STRUCTURAL;
	
 

