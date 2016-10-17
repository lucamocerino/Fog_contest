library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity HAZARD_UNIT is
	port(

		RS_address : in std_logic_vector(4 downto 0);
		RT_address : in std_logic_vector(4 downto 0);
		RT_address_ID_EX : in std_logic_vector(4 downto 0);
		MemRead_ID_EX : in std_logic;
		clock,reset : in std_logic;
		
		enable_signal : out std_logic;
		sel1 : out std_logic
	);
		
end HAZARD_UNIT;

architecture Behavioral of HAZARD_UNIT is


begin

	

	c_state : process(RS_address,RT_address,RT_address_ID_EX,MemRead_ID_EX)
	begin			
		
				if((MemRead_ID_EX = '1' and ((RT_address_ID_EX = RS_address)or (RT_address_ID_EX = RT_address)))  )then	
				
				enable_signal <= '0';
				sel1 <= '0';
				else 
			
				enable_signal<= '1';
				sel1 <= '1';
				
				end if;
				
	end process;
end Behavioral;
