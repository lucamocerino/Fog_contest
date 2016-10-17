----------------------------------------------------------------------------------
-- Author:				Luca Mocerino/Biagio Feraco
-- Create Date:    	12:54:39 03/09/2016 
-- Design Name: 
-- Module Name:    	ALU - struct
-- Project Name: 	  	DLX	
-- Revision: 			TESTED
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU is
	port (
			OP_A: in std_logic_vector(31 downto 0);
			OP_B: in std_logic_vector(31 downto 0);
			func: in std_logic_vector(10 downto 0);
			ALU_OUT: out std_logic_vector(31 downto 0);
			CMP_OUT: out std_logic
			);
			
			
end ALU;

architecture Behavioral of ALU is

component comparator_struct 
		generic (N: natural:= 32);
		port (
				op_a: in std_logic_vector(N-1 downto 0);
				op_b: in std_logic_vector(N-1 downto 0);
				sel: in std_logic_vector(2 downto 0);
				out_comp: out std_logic
				);
				
end component;




component LU_T2 
	generic (
		data_size : integer := 32
	);
	port (
		operand_a : in std_logic_vector(data_size-1 downto 0);
		operand_b : in std_logic_vector(data_size-1 downto 0);
		type_op : in std_logic_vector(3 downto 0);
		result : out std_logic_vector(data_size-1 downto 0)
	);
end component;

component Shifter 
	generic (
		NBIT: integer := 32
	);
	port (
		left_right: in std_logic;	-- LEFT/RIGHT
		logic_Arith : in std_logic;	-- LOGIC/ARITHMETIC
		shift_rot : in std_logic;	-- SHIFT/ROTATE
		a : in std_logic_vector(NBIT-1 downto 0);
		b : in std_logic_vector(NBIT-1 downto 0);
		o : out std_logic_vector(NBIT-1 downto 0)
	);
end component;



component booths_multiplier 
	generic (N_bit : natural := 16);
	port (
			multiplier,multiplicand : in std_logic_vector(N_bit-1 downto 0);
			product : out std_logic_vector(2*N_bit-1 downto 0)
	);
end component;

component mux5x1
	port(
		a : in std_logic_vector(31 downto 0);
		b : in std_logic_vector(31 downto 0);
		c : in std_logic_vector(31 downto 0);
		d : in std_logic_vector(31 downto 0);
		e : in std_logic_vector(31 downto 0);
		enable : in std_logic;
		sel : in std_logic_vector(2 downto 0);
		out_res : out std_logic_vector(31 downto 0)
	);
end component;

component pentium4_adder 
	generic (N  : integer := 32;
		     Nb : integer := 4);
	
	Port (	A:		In	std_logic_vector(N-1 downto 0);
			B:		In	std_logic_vector(N-1 downto 0);
			C_0:	In	std_logic;
			S:		Out	std_logic_vector(N-1 downto 0);
			Cout:	Out	std_logic
			);


end component;


signal from_adder_to_mux,from_logict2_to_mux:std_logic_vector(31 downto 0);
signal	enable : std_logic;
signal	sel_signal_5_1 :  std_logic_vector(2 downto 0);
		
		
		--t2
		-- 1000 -> and
		-- 0111 -> nand
		-- 1110 -> or
		-- 0001 -> nor
		-- 0110 -> xor
		-- 1001 -> xnor
signal cmd_t2 : std_logic_vector(3 downto 0); 
signal carry_in :  std_logic;
signal	left_right : std_logic;
signal	logic_Arith :  std_logic;
signal	shift_rot :  std_logic;
		
		-- INPUT sel
		-- "000" A<=B
		-- "001" A<B
		-- "010" A>B
		-- "011" A>=B
		-- "100" A=B
		-- "101" A!=B

signal sel_comparator :  std_logic_vector(2 downto 0);
signal from_mul_to_mux: std_logic_vector(31 downto 0);
signal from_shifter_to_mux: std_logic_vector(31 downto 0);
signal from_comparator_to_mux: std_logic_vector(31 downto 0):=(others=>'0');

begin


SF : Shifter port map(
							left_right => left_right,
							logic_Arith => logic_Arith,
							shift_rot => shift_rot,
							a => OP_A,
							b => OP_B,
							o => from_shifter_to_mux
						);
						
BM : booths_multiplier port map(
						multiplier => OP_A(15 downto 0),
						multiplicand =>OP_B(15 downto 0),
						product => from_mul_to_mux
						);
						
T2 : LU_T2 port map(
								operand_a => OP_A,
								operand_b => OP_B,
								type_op => cmd_t2,
								result => from_logict2_to_mux
							);

									
COMP : comparator_struct port map(
									op_a => OP_A,
									op_b => OP_B,
									sel => sel_comparator,
									out_comp => from_comparator_to_mux(0)
									);

P4 : pentium4_adder port map(
										A =>OP_A,
										B => OP_B,
										C_0 => carry_in,
										S => from_adder_to_mux,
										cout => open
									);

M4 : mux5x1 port map(
							a => from_adder_to_mux,
							b => from_logict2_to_mux,
							c => from_mul_to_mux,
							d => from_shifter_to_mux,
							e => from_comparator_to_mux,
							enable => enable,
							sel => sel_signal_5_1, 
							out_res => ALU_OUT
						);

CMP_OUT<=from_comparator_to_mux(0);

	combo:process(func)
	begin
	
	case func is 
			-- ADD
		when "00000000001" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '0';
				logic_Arith <= '0';
				shift_rot <= '0';
				--t2
				cmd_t2 <= "0000";
				enable <= '1';
				sel_signal_5_1 <= "000";			
				--comparator
				sel_comparator <= "111";				
			
			-- SUB
			when "00000000010" =>
				--add/sub
				carry_in <= '1';
				--shifter
				left_right <= '0';
				logic_Arith <= '0';
				shift_rot <= '0';
				--t2
				cmd_t2 <= "0000";
				enable <= '1';
				sel_signal_5_1 <= "000";
				--comparator
				sel_comparator <= "111";

			-- AND
			when  "00000000011" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '0';
				logic_Arith <= '0';
				shift_rot <= '0';
				--t2
				cmd_t2 <= "1000";
				enable <= '1';
				sel_signal_5_1 <= "001";
				--comparator
				sel_comparator <= "111";

			-- MULT
			when "00000000100" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '0';
				logic_Arith <= '0';
				shift_rot <= '0';
				--t2
				cmd_t2 <= "0000";
				enable <= '1';
				sel_signal_5_1 <= "010";
				--comparator
				sel_comparator <= "111";

			-- OR
			when "00000000110" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '0';
				logic_Arith <= '0';
				shift_rot <= '0';
				--t2
				cmd_t2 <= "1110";
				enable <= '1';
				sel_signal_5_1 <= "001";
				--comparator
				sel_comparator <= "111";

			-- XOR
			when "00000000111" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '0';
				logic_Arith <= '0';
				shift_rot <= '0';
				--t2
				cmd_t2 <= "0110";
				enable <= '1';
				sel_signal_5_1 <= "001";
				--comparator
				sel_comparator <= "111";

			-- EQUAL
			when "00000001000" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '0';
				logic_Arith <= '0';
				shift_rot <= '0';
				--t2
				cmd_t2 <= "0000";
				enable <= '1';
				sel_signal_5_1 <= "100";
				--comparator
				sel_comparator <= "100";			
			
			-- NOT EQUAL
			when "00000001001" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '0';
				logic_Arith <= '0';
				shift_rot <= '0';
				--t2
				cmd_t2 <= "0000";
				enable <= '1';
				sel_signal_5_1 <= "100";
				--comparator
				sel_comparator <= "101";				
			
			-- GREATER
			when "00000001010" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '0';
				logic_Arith <= '0';
				shift_rot <= '0';
				--t2
				cmd_t2 <= "0000";
				enable <= '1';
				sel_signal_5_1 <= "100";
				--comparator
				sel_comparator <= "010";				
			
			-- GREATER EQUAL
			when "00000001011" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '0';
				logic_Arith <= '0';
				shift_rot <= '0';
				--t2
				cmd_t2 <= "0000";
				enable <= '1';
				sel_signal_5_1 <= "100";
				--comparator
				sel_comparator <= "011";	

			-- LESS
			When "00000001100" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '0';
				logic_Arith <= '0';
				shift_rot <= '0';
				cmd_t2 <= "0000";
				--mux4x1
				enable <= '1';
				sel_signal_5_1 <= "100";
				--comparator
				sel_comparator <= "001";	

			-- LESS EQUAL
			when "00000001101" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '0';
				logic_Arith <= '0';
				shift_rot <= '0';
				cmd_t2 <= "0000";
				enable <= '1';
				sel_signal_5_1 <= "100";
				--comparator
				sel_comparator <= "000";	

			-- LOGIC LEFT SHIFT
			when "00000001110" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '0';
				logic_Arith <= '0';
				shift_rot <= '0';
				--t2
				cmd_t2 <= "0000";
				enable <= '1';
				sel_signal_5_1 <= "011";
				--comparator
				sel_comparator <= "111";

			-- LOGIC RIGHT SHIFT
			when "00000001111" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '1';
				logic_Arith <= '0';
				shift_rot <= '0';
				--t2
				cmd_t2 <= "0000";
				enable <= '1';
				sel_signal_5_1 <= "011";
				--comparator
				sel_comparator <= "111";

			-- ARITH LEFT SHIFT
		when "00000010000" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '0';
				logic_Arith <= '1';
				shift_rot <= '0';
				--t2
				cmd_t2 <= "0000";
				enable <= '1';
				sel_signal_5_1 <= "011";
				--comparator
				sel_comparator <= "111";

			-- ARITH RIGHT SHIFT
			when "00000010001" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '1';
				logic_Arith <= '1';
				shift_rot <= '0';
				--t2
				cmd_t2 <= "0000";
				enable <= '1';
				sel_signal_5_1 <= "011";
				--comparator
				sel_comparator <= "111";			
			
			-- ROTATE LEFT 
			when "00000010010" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '0';
				logic_Arith <= '0';
				shift_rot <= '1';
				--t2
				cmd_t2 <= "0000";
				enable <= '1';
				sel_signal_5_1 <= "011";
				--comparator
				sel_comparator <= "111";

			-- ROTATE RIGHT 
			when "00000010011" =>
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '1';
				logic_Arith <= '0';
				shift_rot <= '1';
				--t2
				cmd_t2 <= "0000";
				--mux4x1
				enable <= '1';
				sel_signal_5_1 <= "011";
				--comparator
				sel_comparator <= "111";	

			when others =>		
				--add/sub
				carry_in <= '0';
				--shifter
				left_right <= '0';
				logic_Arith <= '0';
				shift_rot <= '0';
				--t2
				cmd_t2 <= "0000";
				enable <= '0';
				sel_signal_5_1 <= "000";
				--comparator
				sel_comparator <= "111";
			end case;
	
	end process;

end Behavioral;
