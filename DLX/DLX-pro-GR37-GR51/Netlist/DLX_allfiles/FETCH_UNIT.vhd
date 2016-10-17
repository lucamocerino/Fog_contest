----------------------------------------------------------------------------------
-- Author:				Luca Mocerino/Biagio Feraco
-- Create Date:    	08:30:28 24/09/2016 
-- Design Name: 
-- Module Name:    	FETCH_UNIT - beh
-- Project Name: 	  	DLX	
-- Revision: 			TESTED
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity FETCH_UNIT is
	port(
	
		sel0 : in std_logic;
		selJump: in std_logic;
	
		en0 : in std_logic;	--load signal
		clock : in std_logic;
		reset : in std_logic;
	
		fromInstructionMemory : in std_logic_vector(31 downto 0);
		next_PC : in std_logic_vector(31 downto 0);
		PcToInstructionMemory : out std_logic_vector(31 downto 0);
		InstructionToDecode : out std_logic_vector(31 downto 0);
		pcToDecode : out std_logic_vector(31 downto 0)
	);
		
		
end FETCH_UNIT;

architecture Behavioral of FETCH_UNIT is


	component regWithLoad32bit is
	port(
		clock,reset,load : in std_logic;
		i : in std_logic_vector(31 downto 0);
		o : out std_logic_vector(31 downto 0)
	);
end component;

	component mux_21 is
	generic (N: natural:=32);
    Port ( 
           A   : in  STD_LOGIC_VECTOR (N-1 downto 0);
           B   : in  STD_LOGIC_VECTOR (N-1 downto 0);
			  SEL : in  STD_LOGIC;
           O   : out STD_LOGIC_VECTOR (N-1 downto 0));
end component;

	component  pentium4_adder is 

	generic (N  : integer := 32;
		     Nb : integer := 4);
	
	Port (	A:		In	std_logic_vector(N-1 downto 0);
			B:		In	std_logic_vector(N-1 downto 0);
			C_0:	In	std_logic;
			S:		Out	std_logic_vector(N-1 downto 0);
			Cout:	Out	std_logic
			);
 
	end component;
	
component Mux1bit is
	port(
		a : in std_logic;
		b : in std_logic;
		sel : in std_logic;
		o : out std_logic
		);
end component;

	
	
	signal byFour : std_logic_vector(31 downto 0) := (2 => '1', others => '0');
	signal sel0_i: std_logic;
	signal one:std_logic:='1';
	signal fromMuxToPc : std_logic_vector(31 downto 0); 
	signal fromPcToAdder : std_logic_vector(31 downto 0);
	signal fromAdderToMux : std_logic_vector(31 downto 0); 
	
	
begin

one<='1';

PC : regWithLoad32bit port map(clock,reset,en0,fromMuxToPc,fromPcToAdder);
IR : regWithLoad32bit port map(clock,reset,en0,fromInstructionMemory,InstructionToDecode);
MUX_1: MUX1bit port map ( one,sel0,selJump,sel0_i);

MUX_0: mux_21 port map(		a => next_PC,
									b => fromAdderToMux,
									sel => sel0_i,
									o => fromMuxToPc);
PC_ADDER : pentium4_adder port map(
						A => fromPcToAdder,
						B => byFour,
						c_0 => '0',
						S => fromAdderToMux,
						Cout => open);
						



PcToInstructionMemory <= fromPcToAdder;
PcToDecode <= fromPcToAdder;

end Behavioral;
