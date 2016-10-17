----------------------------------------------------------------------------------
-- Author:				Luca Mocerino/Biagio Feraco
-- Create Date:    	10:29:40 30/09/2016 
-- Design Name: 
-- Module Name:    	ALL_DATAPATH - struct
-- Project Name: 	  	DLX	
-- Revision: 			TESTED
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALL_DATAPATH is

	port(
	
		clock : in std_logic;
		reset : in std_logic;
		istr_toDecode: out std_logic_vector(31 downto 0);
		
		sel0 : in std_logic;
		sel1 : in std_logic;
		sel2 : in std_logic;
		sel3 : in std_logic;
		sel4 : in std_logic;
		sel_ext : in std_logic;
		en1 : in std_logic;
		en2 : in std_logic;
		en3 : in std_logic;
		en4 : in std_logic;
		en5 : in std_logic;
		en6 : in std_logic;
		en7 : in std_logic;
		selALU_JAL: in std_logic;
		sel_set_branch: in std_logic;
		sel_jal: in std_logic;	
		selJump: in std_logic;
		hazard_condition : in std_logic;
		func : in std_logic_vector(10 downto 0);
		EX_MEM_write : in std_logic;
		MEM_WB_write : in std_logic;
		selectNop: out std_logic;
		
		--Instruction ROM signals
		rom_add: out std_logic_vector(31 downto 0);
		rom_data_out: in std_logic_vector(31 downto 0);
		-- Data RAM signals
		ram_add: out std_logic_vector(31 downto 0);
		ram_data_in: out std_logic_vector(31 downto 0);
		ram_data_out: in std_logic_vector(31 downto 0);
		
		-- Debug port
		jump: out std_logic;
		debug_port : out std_logic_vector(31 downto 0)
	);
		
end ALL_DATAPATH;

architecture Structural of ALL_DATAPATH is


	
	component MEMORY_UNIT
	port(
		clock : in std_logic;
		reset : in std_logic;
		enable : in std_logic;
		sel_jal: in std_logic;
		alu_result : in std_logic_vector(31 downto 0);
		data_from_memory : in std_logic_vector(31 downto 0);
		EX_MEM_Rd : in std_logic_vector(4 downto 0);
		
		address_memory : out std_logic_vector(31 downto 0);
		data_MEM : out std_logic_vector(31 downto 0);
		data_from_ALU : out std_logic_vector(31 downto 0);
		MEM_WB_Rd : out std_logic_vector(4 downto 0)
	);
	end component;
	
	component WB_UNIT
	port(
		clock, reset, enable, sel_4 : in std_logic;
		data_from_memory : in std_logic_vector(31 downto 0);
		data_from_alu : in std_logic_vector(31 downto 0);
		write_back_value : out std_logic_vector(31 downto 0);
		debug_port : out std_logic_vector(31 downto 0)
	);
	end component;
	

	component FETCH_UNIT
	port(
		sel0 : in std_logic;
		selJump: in std_logic;
		en0 : in std_logic;
		clock : in std_logic;
		reset : in std_logic;
		fromInstructionMemory : in std_logic_vector(31 downto 0);
		next_PC : in std_logic_vector(31 downto 0);
		
		PcToInstructionMemory : out std_logic_vector(31 downto 0);
		InstructionToDecode : out std_logic_vector(31 downto 0);
		pcToDecode : out std_logic_vector(31 downto 0)
	);
	
	end component;
	
	
	component DECODE_UNIT
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
	end component;

	component 	EXECUTION_UNIT
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
		selALU_JAL: in std_logic;
		sel_set_branch: in std_logic;
		func : in std_logic_vector(10 downto 0);
		EX_MEM_rd : inout std_logic_vector(4 downto 0);
		alu_res_to_mem : out std_logic_vector(31 downto 0);
		out_op_b : out std_logic_vector(31 downto 0);
		next_pc : out std_logic_vector(31 downto 0);
		jump : out std_logic

	);
		
	end component;

	signal all_zero : std_logic_vector(31 downto 0) := (others => '0');
	signal all_zero_5bit : std_logic_vector(4 downto 0) := (others => '0');
	signal bit_zero : std_logic := '0';
	signal all_zero_11bit : std_logic_vector(10 downto 0) := (others => '0');
	---------------------------------------------------------------------
	
	signal instructionWord_ToDecode : std_logic_vector(31 downto 0);
	signal NPC_to_decode : std_logic_vector(31 downto 0);
	signal disable_fetch_register : std_logic;
	signal operand_A : std_logic_vector(31 downto 0);
	signal operand_B : std_logic_vector(31 downto 0);
	signal operand_IMM : std_logic_vector(31 downto 0);
	signal operand_PC : std_logic_vector(31 downto 0);
	signal ID_EX_Rd : std_logic_vector(4 downto 0);
	signal ID_EX_Rs : std_logic_vector(4 downto 0);
	signal ID_EX_Rt : std_logic_vector(4 downto 0);
	signal PcToInstructionMemory : std_logic_vector(31 downto 0);
	signal fromInstructionMemory : std_logic_vector(31 downto 0);
	signal multi_cycle_operation : std_logic;
	signal operand_res_alu : std_logic_vector(31 downto 0);
	signal operand_two : std_logic_vector(31 downto 0);
	signal data_from_data_memory : std_logic_vector(31 downto 0);
	signal EX_MEM_RD : std_logic_vector(4 downto 0);
	signal next_pc : std_logic_vector(31 downto 0);
	signal address_data_memory : std_logic_vector(31 downto 0);
	signal data_to_data_memory : std_logic_vector(31 downto 0);
	signal MEM_WB_RD : std_logic_vector(4 downto 0);
	signal write_back_op1 : std_logic_vector(31 downto 0);
	signal write_back_op2 : std_logic_vector(31 downto 0);
	signal forward_mem,out_op_b_i ,ram_add_i: std_logic_vector(31 downto 0);
	signal correctFunc: std_logic_vector(10 downto 0);
begin

WB_U: WB_UNIT port map(
								clock => clock,
								reset => reset,
								enable => en7,
								sel_4 => sel4,
								data_from_memory => write_back_op1,
								data_from_alu => write_back_op2,
								write_back_value => forward_mem,
								debug_port => debug_port
							);


									

MEMORY_U : MEMORY_UNIT port map(
									clock => clock,
									reset => reset,
									enable => en6,
									sel_jal=>sel_jal,
									alu_result => operand_res_alu,
									data_from_memory => ram_data_out,
									EX_MEM_Rd => EX_MEM_RD,
									address_memory => ram_add,
									data_MEM =>  write_back_op1,
									data_from_alu => write_back_op2,
									MEM_WB_Rd => MEM_WB_RD
								);
								




EXE_UNIT : EXECUTION_UNIT port map (
									clock => clock,
									reset => reset,
									operand_a => operand_A,
									operand_b => operand_B,
									operand_imm => operand_IMM,
									operand_pc => operand_PC,
									forward_exe => operand_res_alu,
									forward_mem => forward_mem,
									EX_MEM_write => EX_MEM_write,
									MEM_WB_write => MEM_WB_write,
									MEM_WB_rd => MEM_WB_RD,
									ID_EX_Rd => ID_EX_Rd,
									ID_EX_Rs => ID_EX_Rs,
									ID_EX_Rt => ID_EX_Rt,
									enable => en5,
									sel_1 => sel1,
									sel_2 => sel2,
									sel_3 => sel3,
									sel_set_branch=>sel_set_branch,
									selALU_JAL=>selALU_JAL,
									func => func,
									EX_MEM_rd => EX_MEM_RD,
									alu_res_to_mem => operand_res_alu,
									out_op_b =>ram_data_in,
									next_pc => next_pc,
									jump => jump
								);

DEC_UNIT: DECODE_UNIT port map (	clock => clock,
									reset => reset,
									en1 => en1,
									read_enable_portA => en2,
									read_enable_portB => en3,
									write_enable_portW => en4,
									instructionWord => instructionWord_ToDecode,
									ID_EX_MemRead => hazard_condition,
									ID_EX_RT_Address => ID_EX_Rt,
									writeData => forward_mem,
									writeAddress => MEM_WB_RD,
									pc => NPC_to_decode,
									sel_ext => sel_ext,
									enable_signal_PC_IF_ID => disable_fetch_register,
									outRT => ID_EX_Rt,
									outRD => ID_EX_Rd,
									outRS => ID_EX_Rs,
									outIMM => operand_IMM,
									outPC => operand_PC,
									outA => operand_A,
									outB => operand_B,
									selectNop =>selectNop
								
								);

FETCH_U : FETCH_UNIT port map (	sel0 => sel0,
									selJump=>selJump,
									en0 => disable_fetch_register,
									clock => clock,
									reset => reset,
									fromInstructionMemory => rom_data_out,
									next_PC => next_pc,
									PcToInstructionMemory =>rom_add,
									InstructionToDecode => instructionWord_ToDecode,
									pcToDecode => NPC_to_decode
 								);
								
istr_toDecode<=instructionWord_ToDecode;


								


end Structural;