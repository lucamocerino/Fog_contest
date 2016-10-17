----------------------------------------------------------------------------------
-- Author:				Luca Mocerino/Biagio Feraco
-- Create Date:    	01:50:50 10/09/2016 
-- Design Name: 
-- Module Name:    	CU_HW - beh
-- Project Name: 	  	DLX	
-- Revision: 			TESTED
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CU_HW is
	generic (
		MICROCODE_MEM_SIZE : integer := 2**6-1; 
		OPCODE_SIZE : integer := 6; 
		func_SIZE : integer := 11; 
		CW_LENGTH : integer := 22 
	);
	port (
		clock,reset: in std_logic;
		
		stall : in std_logic; 
		jump  : in std_logic; 
		opcode : in std_logic_vector(OPCODE_SIZE-1 downto 0); --Opcode instruction
		func : in std_logic_vector(func_SIZE-1 downto 0); --Type of instruction



		
		--N.B MUX (1/0)
		--DECODE
		en1 : out std_logic; -- Decode registers enable  
		en2 : out std_logic; -- PortA read enable			
		en3 : out std_logic; -- PortB read enable			
		sel_ext : out std_logic; --MUX: (IMM26/IMM16) selection signal 
		
		--EXECUTION

		hazard_condition : out std_logic; --Hazard condition (1 if the istruction is a LOAD) 
		sel1 : out std_logic; --MUX: (A/PC) 											 					
		sel2 : out std_logic; --MUX: (B/IMM) 																
		sel3 : out std_logic; --Mux (RD r-type/RT i-type) 		
		en5 : out std_logic;  -- EN: Execution Unit											
		selALU_JAL: out std_logic; --MUX: ALways 0, 1 JAL/J												
		selJump: out std_logic;  -- MUX: Always 0, 1 JAL/J											
		sel_set_branch: out std_logic; -- MUX: Always 0, 1 Branch	
		exe_func : out std_logic_vector(func_SIZE-1 downto 0); 
		sel0 : out std_logic; 							
		 
	--MEMORY 
	
		ex_mem_write : out std_logic; 	--1 for write on reg file				
		en6 : out std_logic; 				--EN: Memory registers enable											
		write_data_mem : out std_logic;  --EN: Memory write enable									
		read_data_mem : out std_logic; 	--EN: Memory read enable									
		sel_jal: out std_logic;	  			--EN: Always 0, 1 JAL
			  
	--WRITEBACK

		en4 : out std_logic;  			--EN: PortA write
		en7 : out std_logic;	 			--EN: Writeback 
		sel4 : out std_logic;  			--MUX: (MEM/ALU) 
		mem_wb_write : out std_logic 	--1  instruction writes on reg file
				 
	);
end CU_HW;

architecture CU_HW_beh of CU_HW is
	

	type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE-1) of std_logic_vector(20 downto 0);

	

	signal cw_mem : mem_array := (	
	
					"111001111000110001101", -- R-TYPE 
					"111001111000110001101", -- MULT
					"100100001110110001101", -- J
					"100100001110110011101", -- JAL
					"111001101001010000100", -- BEQZ 
					"111001101001010000100", -- BNEZ
					"000000000000000000000", 
					"000000000000000000000",
					"110001001000110001101", -- ADDI
					"000000000000000000000", 
					"110001001000110001101", -- SUBI
					"000000000000000000000", 
					"110001001000110001101", -- ANDI
					"110001001000110001101", -- ORI
					"110001001000110001101", -- XORI
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"110001001000110001101", -- SLLI					
					"000000000000000000000", -- NOP
					"110001001000110001101", -- SRLI
					"000000000000000000000", 
					"110001001000110001101", -- SEQI
					"110001001000110001101", -- SNEI
					"110001001000110001101", -- SLTI
					"110001001000110001101", -- SGTI
					"110001001000110001101", -- SLEI
					"110001001000110001101", -- SGEI
					"000000000000000000000", 					
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"110011001000110101111", -- LOAD
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 					
					"000000000000000000000", 
					"000000000000000000000", 
					"111001001000011000010", -- STORE
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 
					"000000000000000000000", 			
					"000000000000000000000", 					
					"000000000000000000000");

					

					

	signal ir_opcode : std_logic_vector(OPCODE_SIZE-1 downto 0); --Register for latch opcode part

	signal ir_opcode_two : std_logic_vector(OPCODE_SIZE-1 downto 0);
	signal ir_func : std_logic_vector(func_SIZE-1 downto 0);
	signal cw  : std_logic_vector(20 downto 0);
	signal exe_control_unit : std_logic_vector(func_SIZE-1 downto 0);

	signal cw_temp   : std_logic_vector(20 downto 0);
	signal cw_jump  : std_logic_vector(CW_LENGTH-1 downto 0);

	--Control word pipeline registers
	signal cw2 : std_logic_vector(16 downto 0);  	--ID/EX
	signal cw3 : std_logic_vector(8 downto 0);  	--EX/MEM
	signal cw4 : std_logic_vector(3 downto 0); 	--MEM/WB

	
	signal func1 : std_logic_vector(func_SIZE-1 downto 0);
	signal func2 : std_logic_vector(func_SIZE-1 downto 0);
	signal cont: std_logic_vector(1 downto 0):=(others=>'0');
	type state_type is (s0,s1,s2);
	signal current_state : state_type;
	signal next_state : state_type;
	
begin

	
	STALL_P : process(ir_opcode,stall)
	begin
		
		if (stall='0') then
				cw_temp <= (others=>'0');
		else cw_temp <= cw_mem(to_integer(unsigned(IR_opcode)));
		
		end if;
	end process;
	
--process that update the state
	p_state : process(clock)
	begin
		if(clock = '1' and clock'event)then
			if(reset = '1')then
				current_state <= s0;
			else current_state <= next_state;
			end if;
		end if;
	end process;
	
	--process that compute next state
	c_state : process(opcode,jump,current_state)
	
	begin
		case current_state is	 
			when s0 => 
			if (((IR_opcode_two="000100" or IR_opcode_two="000101") and jump='1') or IR_opcode_two="000010" or IR_opcode_two="000011") then 
					next_state <= s1;
				else next_state <= s0;
				end if;
				
			when s1 =>
				
				next_state <= s2;
				
			when s2 =>
				next_state <= s0;
			
			when others =>
				next_state <= s0;
		end case;
	end process;

	--process for the output
	o_state : process(current_state)
	begin
		case current_state is
			when s0 =>
			cont<="00";
				
				
			when s1 =>
			cont<="01";
				
			when s2=>
				cont<="10";
			when others =>
				cont<="00";
			end case;
			
	end process;

	--CONTROL WORD
	
	cw <= cw_temp;
	IR_opcode <= opcode;
	IR_func <= func;

	
	--DECODE

	en1 <= cw (20);	
	en2 <= cw (19); 	
	en3 <= cw (18); 	
	sel_ext <= cw(17); 

	--EXECUTION

	hazard_condition <= cw2 (16); 
	sel1 <= cw2 (15);  
	sel2 <= cw2 (14);  
	sel3 <= cw2 (13);  
	en5  <= cw2 (12);  
	sel0 <= jump;
	selALU_JAL<=cw2(11);
	selJump<=cw2(10);
	sel_set_branch<=cw2(9);
	
	
	exe_func <= func2;
	
	--MEMORY

	ex_mem_write <= cw3 (8);  
	en6 <= cw3(7);					
	write_data_mem <= cw3(6); 
	read_data_mem <= cw3(5);  
	sel_jal<=cw3 (4);
	
	--WRITE BACK

	en4 <= cw4 (3); 
	en7 <= cw4 (2); 
	sel4 <= cw4 (1); 
	mem_wb_write <= cw4 (0); 



	--process that control the cw throught the pipeline
	CW_PIPE : process(clock)
	begin
		if (clock = '1' and clock'event) then

			if (reset = '1') then
			cw2 <= (others => '0');
			cw3 <= (others => '0');
			cw4 <= (others => '0');
			func2 <= (others => '0');

				ir_opcode_two <= (others => '0');
			else
			
				if(cont="01" ) then 
				
						cw2<=(others=>'0');
				
				else 
			
				cw2<= cw (16 downto 0);
				cw3 <= cw2 (8 downto 0);
				cw4 <= cw3 (3 downto 0);
				end if;
				
				func2 <= func1;

				ir_opcode_two <= ir_opcode;

			end if;
		end if;
	end process CW_PIPE;

	

	function_p : process(ir_opcode,ir_func)
	variable var_opcode : std_logic_vector(5 downto 0);
	variable var_func : std_logic_vector(10 downto 0);
	begin
		var_opcode:= IR_opcode;
		var_func := IR_func;
	
		case var_opcode is
			when "000000" => --R-type instruction
				case var_func is
					when "00000100000" => func1 <= "00000000001";	--ADD

					when "00000100100" => func1 <= "00000000011";	--AND

					when "00000100101" => func1 <= "00000000110";	--OR

					when "00000101101" => func1 <= "00000001011";	--SGE

					when "00000101100" => func1 <= "00000001101";	--SLE

					when "00000000100" => func1 <= "00000001110";	--SLL

					when "00000101001" => func1 <= "00000001001";	--SNE

					when "00000000110" => func1 <= "00000010001";	--SRL

					when "00000100010" => func1 <= "00000000010";	--SUB

					when "00000100110" => func1 <= "00000000111";	--XOR

					when "00000101000" => func1 <= "00000001000";	--SEQ

					when "00000101011" => func1 <= "00000001010";	--SGT

					when "00000101010" => func1 <= "00000001100";	--SLT
					when others => func1 <= "00000000000";
				end case;
			when "000001" => --MULT
				case var_func is
					when "00000001110" => func1 <= "00000000100";	--MULT
					when others => func1 <= "00000000000";
				end case;
			when "001000" => --ADDI
				func1 <= "00000000001";
			when "001100" => --ANDI
				func1 <= "00000000011";

			when "010101" => --NOP
				func1 <= "11111111111";

			when "001101" => --ORI
				func1 <= "00000000110";

			when "011101" => --SGEI
				func1 <= "00000001011";

			when "011100" => --SLEI
				func1 <= "00000001101";

			when "010100" => --SLLI
				func1 <= "00000001110";

			when "011001" => --SNEI
				func1 <= "00000001001";

			when "010110" => --SRLI
				func1 <= "00000010001";

			when "001010" => --SUBI
				func1 <= "00000000010";				

			when "001110" => --XORI
				func1 <= "00000000111";

			when "100011" => --LW
				func1 <= "00000000001";

			when "101011" => --SW
				func1 <= "00000000001";

			when "011000" => --SEQI
				func1 <= "00000001000";

			when "011011" => --SGTI
				func1 <= "00000001010";

			when "011010" => --SLTI
				func1 <= "00000001100";

			when "000100" => --BEQZ
				func1 <= "00000001000";

			when "000101" => --BNEZ
				func1 <= "00000001001";				
			when others =>
				func1 <= "00000000000";
		end case;
	end process;
	
end CU_HW_beh;