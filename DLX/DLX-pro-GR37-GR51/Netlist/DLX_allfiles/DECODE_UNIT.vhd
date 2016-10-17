----------------------------------------------------------------------------------
-- Author:				Luca Mocerino/Biagio Feraco
-- Create Date:    	12:12:39 08/09/2016 
-- Design Name: 
-- Module Name:    	DECODE_UNIT - beh
-- Project Name: 	  	DLX	
-- Revision: 			TESTED
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity DECODE_UNIT is
	port(
		
		clock,reset : in std_logic;
		en1 : in std_logic;
		read_enable_portA : in std_logic;
		read_enable_portB : in std_logic;
		write_enable_portW : in std_logic;
		instructionWord : in std_logic_vector(31 downto 0);
		ID_EX_MemRead : in std_logic;
		ID_EX_RT_Address : in std_logic_vector(4 downto 0);
		writeData : in std_logic_vector(31 downto 0);
		writeAddress : in std_logic_vector(4 downto 0);
		pc : in std_logic_vector(31 downto 0);
		sel_ext : in std_logic;

		enable_signal_PC_IF_ID : out std_logic;
		outRT : out std_logic_vector(4 downto 0);
		outRD : out std_logic_vector(4 downto 0);
		outRS : out std_logic_vector(4 downto 0);
		outIMM : out std_logic_vector(31 downto 0);
		outPC : out std_logic_vector(31 downto 0);
		outA : out std_logic_vector(31 downto 0);
		outB : out std_logic_vector(31 downto 0);
		selectNop: out std_logic
		
	);
end DECODE_UNIT;

architecture Structural of DECODE_UNIT is

component mux_21 is
	generic (N: natural:=32);
    Port ( 
           A   : in  STD_LOGIC_VECTOR (N-1 downto 0);
           B   : in  STD_LOGIC_VECTOR (N-1 downto 0);
			  SEL : in  STD_LOGIC;
           O   : out STD_LOGIC_VECTOR (N-1 downto 0));
end component;

component reg
	generic (N:natural:=32);
	port(
		input : in std_logic_vector(N-1 downto 0);
		en : in std_logic;
		clock,reset : in std_logic;
		output : out std_logic_vector(N-1 downto 0)
	);
end component;


component register_file 
	port(

		data_in_port_w : in std_logic_vector(31 downto 0);
		data_out_port_a : out std_logic_vector(31 downto 0);
		data_out_port_b : out std_logic_vector(31 downto 0);
		address_port_a : in std_logic_vector(4 downto 0);
		address_port_b : in std_logic_vector(4downto 0);
		address_port_w : in std_logic_vector(4 downto 0);
		r_signal_port_a : in std_logic;
		r_signal_port_b : in std_logic;
		w_signal : in std_logic;
		reset,clock, enable : in std_logic
	);
end component;

component HAZARD_UNIT
	port(
		
		RS_address : in std_logic_vector(4 downto 0);
		RT_address : in std_logic_vector(4 downto 0);
		RT_address_ID_EX : in std_logic_vector(4 downto 0);
		MemRead_ID_EX : in std_logic;
		clock,reset : in std_logic;
		enable_signal : out std_logic;
		sel1 : out std_logic
	);
end component;

component mux11
	port(
			i0 : in std_logic_vector(10 downto 0);
			i1 : in std_logic_vector(10 downto 0);
			sel : in std_logic;
			o : out std_logic_vector(10 downto 0)
	);
end component;


component mux13 
	port(
			i0 : in std_logic_vector(13 downto 0);
			i1 : in std_logic_vector(13 downto 0);
			sel : in std_logic;
			o : out std_logic_vector(13 downto 0)
	);
end component;


component extensionModule 
	port(
		i : in std_logic_vector(15 downto 0);
		o : out std_logic_vector(31 downto 0)
	);
end component;

component extensionModule26bit 
	port(
		i : in std_logic_vector(25 downto 0);
		o : out std_logic_vector(31 downto 0)
	);
end component;

signal fromFirstExtToImm, fromSecExtToImm, fromMuxToImm : std_logic_vector(31 downto 0);
signal fromPortAToRegA : std_logic_vector(31 downto 0);
signal fromPortBToRegB : std_logic_vector(31 downto 0);
signal stall: std_logic_vector(13 downto 0):=(others=>'1');
signal selectNop_i: std_logic;
begin




IMMEDIATE : reg generic map (32) port map(	input => fromMuxToImm,
										en => en1,
										clock => clock,
										reset => reset,
										output => outIMM
									);
PC_REG : reg generic map (32) port map(	input => pc,
											en => en1,
											clock => clock,
											reset => reset,
											output => outPC
										);
OPERAND_A : reg generic map (32) port map(	input => fromPortAToRegA,
											en => en1,
											clock => clock,
											reset => reset,
											output => outA
									);
OPERAND_B : reg generic map (32) port map(	input => fromPortBToRegB,
											en => en1,
											clock => clock,
											reset => reset,
											output => outB
									);
OPERAND_RD : reg generic map (5) port map(	input => instructionWord(15 downto 11),
											en => en1,
											clock => clock,
											reset => reset,
											output => outRD
									);		
OPERAND_RS : reg generic map (5) port map(	input => instructionWord(25 downto 21),
											en => en1,
											clock => clock,
											reset => reset,
											output => outRS
									);
OPERADN_RT : reg generic map (5) port map(	input => instructionWord(20 downto 16),
											en => en1,
											clock => clock,
											reset => reset,
											output => outRT
									);									
H_UNIT : HAZARD_UNIT port map(	RS_address => instructionWord(25 downto 21),
									RT_address => instructionWord(20 downto 16),
									RT_address_ID_EX => ID_EX_RT_Address,
									MemRead_ID_EX => ID_EX_MemRead,
									clock => clock,
									reset => reset,
									enable_signal => enable_signal_PC_IF_ID,
									sel1 => selectNop
								);
RF : register_file port map(	data_in_port_w => writeData,
										data_out_port_a => fromPortAToRegA, 
										data_out_port_b => fromPortBToRegB,
										address_port_a => instructionWord(25 downto 21),
										address_port_b => instructionWord(20 downto 16),
										address_port_w => writeAddress,
										r_signal_port_a => read_enable_portA,
										r_signal_port_b => read_enable_portB,
										w_signal => write_enable_portW,
										reset => reset,
										clock => clock,
										enable => en1
									);
EXT16 : extensionModule port map(	i => instructionWord(15 downto 0),
											o => fromFirstExtToImm
										);
EXT26 : extensionModule26bit port map(	i => instructionWord(25 downto 0),
											o => fromSecExtToImm
										);
MUX_EXT: mux_21 port map(
							a => fromSecExtToImm,
							b => fromFirstExtToImm,
							sel => sel_ext, 
							o => fromMuxToImm
						);

end Structural;