----------------------------------------------------------------------------------
-- Author:				Luca Mocerino/Biagio Feraco
-- Create Date:    	09:54:33 3/09/2016 
-- Design Name: 
-- Module Name:    	EXECUTION_UNIT - beh
-- Project Name: 	  	DLX	
-- Revision: 			TESTED
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity EXECUTION_UNIT is
	port(
		clock : in std_logic;
		reset : in std_logic;
		operand_a : in std_logic_vector(31 downto 0);
		operand_b : in std_logic_vector(31 downto 0);
		operand_imm : in std_logic_vector(31 downto 0);
		operand_pc : in std_logic_vector(31 downto 0);
		forward_exe : in std_logic_vector(31 downto 0);
		forward_mem : in std_logic_vector(31 downto 0);
		EX_MEM_write : in std_logic;
		MEM_WB_write : in std_logic;
		MEM_WB_rd : in std_logic_vector(4 downto 0);
		ID_EX_Rd : in std_logic_vector(4 downto 0);
		ID_EX_Rs : in std_logic_vector(4 downto 0);
		ID_EX_Rt : in std_logic_vector(4 downto 0);
		enable : in std_logic;
		sel_1 : in std_logic;
		sel_2 : in std_logic;
		sel_3 : in std_logic;
		func : in std_logic_vector(10 downto 0);
		sel_set_branch: in std_logic;
		selALU_JAL: in std_logic;
		EX_MEM_rd : inout std_logic_vector(4 downto 0);
		alu_res_to_mem : out std_logic_vector(31 downto 0);
		out_op_b : out std_logic_vector(31 downto 0);
		next_pc : out std_logic_vector(31 downto 0);
		jump : out std_logic
		
	);
end EXECUTION_UNIT;

architecture Structural of EXECUTION_UNIT is

component ALU 
	port (
			OP_A: in std_logic_vector(31 downto 0);
			OP_B: in std_logic_vector(31 downto 0);
			func: in std_logic_vector(10 downto 0);
			ALU_OUT: out std_logic_vector(31 downto 0);
			CMP_OUT: out std_logic
			);
			
			
end component;

component reg
	generic (N: natural:=32);
	port(
		input : in std_logic_vector(N-1 downto 0);
		en : in std_logic;
		clock,reset : in std_logic;
		output : out std_logic_vector(N-1 downto 0)
	);
end component;



component mux4_1 
	port(
		a : in std_logic_vector(31 downto 0);
		b : in std_logic_vector(31 downto 0);
		c : in std_logic_vector(31 downto 0);
		d : in std_logic_vector(31 downto 0);
		enable : in std_logic;
		sel : in std_logic_vector(1 downto 0);
		out_res : out std_logic_vector(31 downto 0)
	);
end component;

component mux3_1 
	port(
		operand_one : in std_logic_vector(31 downto 0);
		operand_two : in std_logic_vector(31 downto 0);
		operand_three : in std_logic_vector(31 downto 0);
		sel : in std_logic_vector(1 downto 0);
		out_res : out std_logic_vector(31 downto 0)
	);
end component;

component mux_21 is
	generic (N: natural:=5);
    Port ( 
           A   : in  STD_LOGIC_VECTOR (N-1 downto 0);
           B   : in  STD_LOGIC_VECTOR (N-1 downto 0);
			  SEL : in  STD_LOGIC;
           O   : out STD_LOGIC_VECTOR (N-1 downto 0));
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


component forwarding_unit 
		port(
			EX_MEM_write : in std_logic;
			EX_MEM_Rd : in std_logic_vector(4 downto 0);
			ID_EX_Rs : in std_logic_vector(4 downto 0);
			ID_EX_Rt : in std_logic_vector(4 downto 0);
			MEM_WB_write : in std_logic;
			MEM_WB_Rd : in std_logic_vector(4 downto 0);
			sel_mux_high : out std_logic_vector(1 downto 0);
			sel_mux_low : out std_logic_vector(1 downto 0)
		);
								
end component;

signal mux_to_mux_high : std_logic_vector(31 downto 0);
signal mux_to_mux_low : std_logic_vector(31 downto 0);
signal next_pc_i,jal_pc: std_logic_vector(31 downto 0);
signal from_comparator_to_mux,comp_jump,zero_fix: std_logic_vector(31 downto 0):=(others=>'0');
signal from_mux4_1_to_reg : std_logic_vector(31 downto 0);
signal from_mux_2_1_to_high : std_logic_vector(31 downto 0);
signal from_mux_2_1_to_low : std_logic_vector(31 downto 0);
signal from_mux_4_1_to_mux_2_1 : std_logic_vector(31 downto 0);
signal from_mux_2_1_to_reg : std_logic_vector(31 downto 0);
signal sel_mux_3_1_high : std_logic_vector(1 downto 0);
signal sel_mux_3_1_low : std_logic_vector(1 downto 0);
signal EX_MEM_rd_next : std_logic_vector(4 downto 0);
signal signal_cmd_t2 : std_logic_vector(3 downto 0);
signal carry_in :  std_logic;
signal enable_mux_4_1 : std_logic;
signal sel_signal_5_1, sel_comparator : std_logic_vector(2 downto 0);
signal sel_signal_2_1 : std_logic;
signal from_latch_to_mux_sub_or_add,quotient : std_logic_vector(31 downto 0);
signal busy_i : std_logic;
signal pc_8: std_logic_vector(31 downto 0):= (2 => '1', others => '0');
signal res_branch,nexpc8,pc8_or_imm,from_jal_reg: std_logic_vector(31 downto 0);


begin

			
ALU_C: ALU port map (
			OP_A =>from_mux_2_1_to_high,
			OP_B =>from_mux_2_1_to_low,
			func => func,
			ALU_OUT =>from_mux_4_1_to_mux_2_1,
			CMP_OUT =>from_comparator_to_mux(0)
			);
			

REG_5 : reg generic map (5) port map(
							input => EX_MEM_rd_next,
							en => enable,
							clock => clock,
							reset => reset,
							output => EX_MEM_rd
						);

MUX_6 : mux_21 generic map (5) port map(
							a => ID_EX_Rd,
							b => ID_EX_Rt,
							sel => sel_3,
							o => EX_MEM_rd_next
						);

FU : forwarding_unit port map(
							EX_MEM_write => EX_MEM_write,
							EX_MEM_Rd => EX_MEM_rd,
							ID_EX_Rs => ID_EX_Rs,
							ID_EX_Rt => ID_EX_Rt,
							MEM_WB_write => MEM_WB_write,
							MEM_WB_Rd => MEM_WB_rd,
							sel_mux_high => sel_mux_3_1_high,
							sel_mux_low => sel_mux_3_1_low
						);

MJALALU : mux_21 generic map (32) port map(
							a => jal_pc,
							b => from_mux_4_1_to_mux_2_1,
							sel => selALU_JAL, 
							o =>from_jal_reg
						);

REG_ALU : reg generic map (32) port map(
							input => from_jal_reg,
							en => enable,
							clock => clock,
							reset => reset,
							output => alu_res_to_mem
						);


						
BRANCH_ADDER : pentium4_adder port map(
										A => operand_pc,
										B => operand_imm,
										C_0 => '0',
										S =>  next_pc,
										cout => open
									);

JAL_ADD : pentium4_adder port map(
										A => operand_pc,
										B => pc_8,
										C_0 => '0',
										S =>  jal_pc,
										cout => open
									);


SET_BRANCH: mux_21 generic map(32) port map(
							a =>from_comparator_to_mux,
							b => zero_fix,
							sel =>sel_set_branch , 
							o => comp_jump
						);


MUX_2 : mux_21 generic map (32) port map(
							a => mux_to_mux_high,
							b => operand_pc,
							sel => sel_1, 
							o => from_mux_2_1_to_high
						);

MUX_3 : mux_21 generic map(32) port map(
							a => mux_to_mux_low,
							b => operand_imm,
							sel => sel_2, 
							o => from_mux_2_1_to_low
						);

MUX_0 :mux3_1 port map(
							operand_one => operand_a,
							operand_two => forward_exe,
							operand_three => forward_mem,
							sel => sel_mux_3_1_high,
							out_res => mux_to_mux_high  
							);
							
MUX_31 : mux3_1 port map(
							operand_one => operand_b,
							operand_two => forward_exe,
							operand_three => forward_mem,
							sel => sel_mux_3_1_low,
							out_res => mux_to_mux_low 
							);
							

REG_OPB : reg generic map (32) port map(
							input => mux_to_mux_low,
							en => enable,
							clock => clock,
							reset => reset,
							output => out_op_b
						);

jump<=comp_jump(0);

end Structural;