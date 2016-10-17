library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity booths_multiplier is
	generic (N_bit : natural := 16);
	port (
			multiplier,multiplicand : in std_logic_vector(N_bit-1 downto 0);
			product : out std_logic_vector(2*N_bit-1 downto 0)
	);
end booths_multiplier;

architecture Structural of booths_multiplier is

component generator is
	generic (N_bit : natural := 8);
	port(
			multiplicant : in std_logic_vector(N_bit-1 downto 0);
			N_shift: in integer;
			select_signal : in std_logic_vector(2 downto 0);
			out_value : out std_logic_vector(2*N_bit-1 downto 0)
	);
	
end component;

component pentium4_adder is
	generic (N  : integer := 32;
		     Nb : integer := 4);
	
	Port (	A:		In	std_logic_vector(N-1 downto 0);
			B:		In	std_logic_vector(N-1 downto 0);
			C_0:	In	std_logic;
			S:		Out	std_logic_vector(N-1 downto 0);
			Cout:	Out	std_logic
			);


end component ;

signal tmp: std_logic_vector(2 downto 0);
type matrix is array (N_bit-1 downto 1) of std_logic_vector(2*N_bit-1 downto 0);
signal routing_wires : matrix;

begin
tmp<=multiplier(1 downto 0)&'0';
external_loop : for i in 0 to N_bit-1 generate 
	
	block_zero : if i= 0 generate
		g0: generator generic map (N_bit => N_bit) port map (multiplicand,i,tmp,routing_wires(1));
		g1: generator generic map (N_bit => N_bit) port map (multiplicand,i+2,multiplier(3 downto 1),routing_wires(2));
		a0: pentium4_adder  port map (routing_wires(1),routing_wires(2),'0',routing_wires(3));
	end generate block_zero;
	
	block_i: if ((i mod 2) = 0 and i/= 0 and i/=2 and i/=N_bit-2 and i/=N_bit) generate 
		gi:generator generic map (N_bit => N_bit) port map (multiplicand,i,multiplier(i+1 downto i-1),routing_wires(i));
		ai: pentium4_adder  port map (routing_wires(i-1),routing_wires(i),'0',routing_wires(i+1));
	end generate block_i;
	
	last_block: if ( ((i) mod 2 = 0) and i=N_bit-2 ) generate
		gi_l:generator generic map (N_bit => N_bit) port map (multiplicand,i,multiplier(i+1 downto i-1),routing_wires(i));
		ai_l: pentium4_adder  port map (routing_wires(i-1),routing_wires(i),'0',product);
	end generate last_block;
	
end generate external_loop;

end Structural;