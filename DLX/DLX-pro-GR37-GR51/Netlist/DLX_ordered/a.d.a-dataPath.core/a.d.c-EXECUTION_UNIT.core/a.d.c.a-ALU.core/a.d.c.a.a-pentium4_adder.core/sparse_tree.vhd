library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;


entity SPARSE_TREE is 
	
	Port (	A:		In	std_logic_vector(31 downto 0);
			B:		In	std_logic_vector(31 downto 0);
			Cin:	In	std_logic;
			Y:		Out	std_logic_vector(7 downto 0));

end SPARSE_TREE; 

architecture STRUCTURAL of SPARSE_TREE is

type SignalVector1 is array (31 downto 0) of std_logic_vector(31 downto 0) ;
type SignalVector2 is array (31 downto 0) of std_logic_vector(31 downto 0) ;

  signal P : SignalVector1;
  signal G : SignalVector2;
  signal G1 : std_logic; 


  component PG_NET_BLOCK is  

	Port (	A:	In	std_logic;
			B:	In	std_logic;
			p:	Out	std_logic;
			g:	Out	std_logic);
  end component;

  component PG_BLOCK is  

	Port (	P1:		In	std_logic;
			P2:		In	std_logic;
			G1:		In	std_logic;
			G2:		In	std_logic;
			Pout:	Out	std_logic;
			Gout:	Out	std_logic);
	
  end component;

  component G_BLOCK is  

	Port (	P1:	In	std_logic;
		G1:	In	std_logic;
		G2:	In	std_logic;
		Gout:	Out	std_logic);

  end component;



begin

  
rows : for row in 0 to 31 generate
	row0 : if row = 0 generate
		arrayand0 : for column in 0 to 31 generate
		rigaand0 : PG_NET_BLOCK

			port map (A(column) , B(column) , P(0)(column) , G(0)(column) ) ;
			
		end generate ;
		
		gen0 : G_BLOCK

			port map (P(0)(0) ,  G(0)(0) , Cin , G1 ) ;
		
	end generate row0 ;
	
	row1 : if row = 1 generate
		arrayand1 : for i in 1 to 15 generate
		rigaand1 : PG_BLOCK

			port map (P(0)((i*2)+1) , P(0)(i*2) , G(0)((i*2)+1) , G(0)(i*2) , P(1)(i) , G(1)(i) ) ;
			
		end generate ;
		
		gen1 : G_BLOCK

			port map (P(0)(1) ,  G(0)(1) , G1 , G(1)(0) ) ;
		
	end generate row1 ;
	
	row2 : if row = 2 generate
		arrayand2 : for i in 1 to 7 generate
		rigaand2 : PG_BLOCK

			port map (P(1)((i*2)+1) , P(1)(i*2) , G(1)((i*2)+1) , G(1)(i*2) , P(2)(i) , G(2)(i) ) ;
			
		end generate ;
		
		gen2 : G_BLOCK

			port map (P(1)(1) ,  G(1)(1) , G(1)(0) , G(2)(0) ) ;
			
			Y(0) <= G(2)(0);
		
	end generate row2 ;
	
	row3 : if row = 3 generate
		arrayand3 : for i in 1 to 3 generate
		rigaand3 : PG_BLOCK

			port map (P(2)((i*2)+1) , P(2)(i*2) , G(2)((i*2)+1) , G(2)(i*2) , P(3)(i) , G(3)(i) ) ;
			
		end generate ;
		
		gen3 : G_BLOCK

			port map (P(2)(1) ,  G(2)(1) , G(2)(0) , G(3)(0) ) ;
			
			Y(1) <= G(3)(0);
		
	end generate row3 ;
	
	row4 : if row = 4 generate
				
		rigaand42 : PG_BLOCK

			port map (P(3)(3) , P(3)(2) , G(3)(3) , G(3)(2) , P(4)(3) , G(4)(3) ) ;
			
		rigaand41 : PG_BLOCK

			port map (P(2)(6) , P(3)(2) , G(2)(6) , G(3)(2) , P(4)(2) , G(4)(2) ) ;
			
		gen42 : G_BLOCK

			port map (P(3)(1) ,  G(3)(1) , G(3)(0) , G(4)(1) ) ;
			
		gen41 : G_BLOCK

			port map (P(2)(2) ,  G(2)(2) , G(3)(0) , Y(2) ) ;
			
		Y(3) <= G(4)(1);
			
	end generate row4 ;
	
		row5 : if row = 5 generate
	
		gen54 : G_BLOCK

			port map (P(4)(3) ,  G(4)(3) , G(4)(1) , Y(7) ) ;
			
		gen53 : G_BLOCK

			port map (P(4)(2) ,  G(4)(2) , G(4)(1) , Y(6) ) ;
			
		gen52 : G_BLOCK

			port map (P(3)(2) ,  G(3)(2) , G(4)(1) , Y(5) ) ;
			
		gen51 : G_BLOCK

			port map (P(2)(4) ,  G(2)(4) , G(4)(1) , Y(4) ) ;
			
			
	end generate row5 ;
	
end generate rows ;
	
 


end STRUCTURAL;
	
 





