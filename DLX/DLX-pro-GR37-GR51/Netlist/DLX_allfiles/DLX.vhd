----------------------------------------------------------------------------------
-- Author:				Luca Mocerino/Biagio Feraco
-- Create Date:    	19:46:59 04/10/2016 
-- Design Name: 
-- Module Name:    	DLX - beh
-- Project Name: 	  	DLX	
-- Revision: 			TESTED
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DLX is

	port (
	
	clock,reset: in std_logic;
	debug_port : out std_logic_vector(31 downto 0)
	);
	
end DLX;

architecture Behavioral of DLX is

component CU_HW
	generic (
		MICROCODE_MEM_SIZE : integer := 2**6-1; --Microcode Memory Size
		OPCODE_SIZE : integer := 6; --Opcode Size
		FUNC_SIZE : integer := 11; --Func Size
		CW_LENGTH : integer := 18 --It does not take into account the FUNC field for the EXE_CU, which is computed in a different way
	);
	port (
		clock : in std_logic; --Clock
		reset : in std_logic; --Active high reset

		stall : in std_logic; --From Hazard Unit (STALL IF stall='0')
		jump  : in std_logic; --From comparator output, used for branches
		
		opcode : in std_logic_vector(OPCODE_SIZE-1 downto 0); --Opcode instruction
		func : in std_logic_vector(FUNC_SIZE-1 downto 0); --Type of instruction


		--Output control signals
		
		--DECODE
		en1 : out std_logic; --Decode registers enable
		en2 : out std_logic; --PortA read enable
		en3 : out std_logic; --PortB read enable
		sel_ext : out std_logic; --Mux (IMM26/IMM16) selection signal

		--EXECUTION
		hazard_condition : out std_logic; --Hazard condition (1 if the istruction is a LOAD)
		sel1 : out std_logic; --Mux (PC/A) selection signal
		sel2 : out std_logic; --Mux (IMM/B) selection signal
		sel3 : out std_logic; --Mux (RT i-type/RD r-type) selection signal
		en5 : out std_logic;  --Exe registers enable
		exe_func : out std_logic_vector(FUNC_SIZE-1 downto 0); --FUNC field for the EXE_CU
		sel0 : out std_logic; --Mux (PC+1/NPC) selection signal
		
		sel_jal: out std_logic;
		selJump: out std_logic;
		sel_set_branch: out std_logic;
		
		--MEMORY
		ex_mem_write : out std_logic; --1 if the instruction writes on RF
		en6 : out std_logic; --Memory registers enable
		write_data_mem : out std_logic; --Memory write enable
		read_data_mem : out std_logic; --Memory read enable
		selALU_jal: out std_logic;
		
		--WRITEBACK
		en4 : out std_logic;  --PortA write enable
		en7 : out std_logic;	 --Writeback register enable
		sel4 : out std_logic;  --Mux (ALU/MEM) selection signal
		mem_wb_write : out std_logic --1 if the instruction writes on RF
	);

end component;


component ALL_DATAPATH

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
		
end component;

		component DATA_RAM
	port (
    clock   : in  std_logic;
	 reset 	: in 	std_logic;
    we,re   : in  std_logic;
    address : in  std_logic_vector(31 downto 0);
    datain  : in  std_logic_vector(31 downto 0);
    dataout : out std_logic_vector(31 downto 0)
  );
	end component;
	
	component INSTRUCTION_ROM
	port (
	 Reset	: in std_logic;
    address : in  std_logic_vector(31 downto 0);
    dataout : out std_logic_vector(31 downto 0)
  );
	end component;



signal sel0_i : std_logic;
signal sel1_i : std_logic;
signal sel2_i : std_logic;
signal sel3_i : std_logic;
signal sel4_i : std_logic;
signal sel_exta: std_logic;
signal write_data_memory_i :  std_logic;		
signal en1_i : std_logic;
signal en2_i : std_logic;	
signal en3_i : std_logic;
signal en4_i : std_logic;		
signal en5_i : std_logic;
signal en6_i : std_logic;		
signal en7_i : std_logic;		
signal jump_i,stall_i,selpcimm,sel_jal_i ,selpc8_i,selALU_JAL_i,selJump_i:std_logic;
signal clock_i : std_logic;
signal reset_i : std_logic;
signal hazard_condition_i,sel_set_branch_i : std_logic;
signal func_i : std_logic_vector(10 downto 0);
signal EX_MEM_write_i : std_logic;
signal MEM_WB_write_i,read_data_mem_i : std_logic;
signal cw_ex_mem_wb_i: std_logic_vector(13 downto 0);
signal current_cw_i: std_logic_vector(13 downto 0);
signal opcode_i : std_logic_vector(5 downto 0); --Opcode instruction
signal istr_toDecode_i: std_logic_vector(31 downto 0);
signal rom_add_i: std_logic_vector(31 downto 0);
signal rom_data_out_i:  std_logic_vector(31 downto 0);
signal ram_add_i:  std_logic_vector(31 downto 0);
signal ram_data_in_i:  std_logic_vector(31 downto 0);
signal ram_write_i,ram_read_i:  std_logic;
signal ram_data_out_i:  std_logic_vector(31 downto 0);
	
begin

DATAPATH: ALL_DATAPATH port map (
		
		clock => clock,
		reset => reset,
		selectNop =>stall_i,
		
			
		--Instruction ROM signals
		rom_add => rom_add_i,
		rom_data_out => rom_data_out_i,
		-- Data RAM signals
		ram_add => ram_add_i,
		ram_data_in => ram_data_in_i,
		ram_data_out =>ram_data_out_i,
		
		
		--DECODE
		en1 => en1_i,
		en2 => en2_i,
		en3 => en3_i,
		sel_ext => sel_exta, 
		
		--EXECUTION
		hazard_condition => hazard_condition_i,
		sel1 =>sel1_i,
		sel2 =>sel2_i,
		sel3 =>sel3_i,
		en5 =>en5_i,
		func => func_i,
		selALU_JAL=>selALU_JAL_i,
		selJump=>selJump_i,
		sel_set_branch=>sel_set_branch_i,
		
		--MEMORY
		ex_mem_write =>ex_mem_write_i,
		sel0 => sel0_i,
		en6 =>en6_i,
		sel_jal=>sel_jal_i,
		
		
		--WRITEBACK
		mem_wb_write => mem_wb_write_i,
		en4 => en4_i,
		en7 => en7_i,
		sel4 => sel4_i,
		
		istr_toDecode =>istr_toDecode_i,
		jump  => jump_i,
		debug_port => debug_port
		);
		
CONTROL_UNIT: CU_HW port map(

		
		clock =>clock,
		reset =>reset,
		opcode => istr_toDecode_i(31 downto 26),
		func=> istr_toDecode_i(10 downto 0),
		jump=> jump_i,
		stall=> stall_i,

		--DECODE
		en1 => en1_i,
		en2 => en2_i,
		en3 => en3_i,
		sel_ext => sel_exta, 
		
		--EXECUTION
		hazard_condition => hazard_condition_i,
		sel1 =>sel1_i,
		sel2 =>sel2_i,
		sel3 =>sel3_i,
		en5 =>en5_i,
		exe_func => func_i,
		selALU_JAL=>selALU_JAL_i,
		selJump=>selJump_i,
		sel_set_branch=>sel_set_branch_i,
		
		--MEMORY
		ex_mem_write =>ex_mem_write_i,
		sel0 => sel0_i,
		en6 =>en6_i,
		write_data_mem =>ram_write_i,
		read_data_mem=>ram_read_i,
		sel_jal => sel_jal_i,
		
		
		--WRITEBACK
		mem_wb_write => mem_wb_write_i,
		en4 => en4_i,
		en7 => en7_i,
		sel4 => sel4_i
);



DRAM : DATA_RAM port map(
								clock => clock,
								reset => reset,
								we => ram_write_i,
								re => ram_read_i,
								address =>ram_add_i,
								datain => ram_data_in_i,
								dataout => ram_data_out_i
							);


INSTR_ROM: INSTRUCTION_ROM port map(
									
									reset => reset,
									address => rom_add_i, 
									dataout => rom_data_out_i
								);

end Behavioral;