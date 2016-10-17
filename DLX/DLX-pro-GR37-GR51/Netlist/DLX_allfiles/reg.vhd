----------------------------------------------------------------------------------
-- Author:				Luca Mocerino/Biagio Feraco
-- Create Date:    	19:42:59 16/08/2016 
-- Design Name: 
-- Module Name:    	reg - beh
-- Project Name: 	  	DLX	
-- Revision: 			TESTED
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg is
	generic (N: natural:=32);
	port(
	
		input : in std_logic_vector(N-1 downto 0);
		en : in std_logic;
		clock,reset : in std_logic;
		output : out std_logic_vector(N-1 downto 0)
	);
end reg;

architecture Behavioral of reg is
	signal R: std_logic_vector(N-1 downto 0);
begin
RegProcess: process(clock)
	begin
	if(clock = '1' and clock'event)then
		if(reset = '1')then
			R <= (others => '0');
		elsif(en = '1')then
			R <= input;
		end if;
	end if;
end process;

output <= R;

end Behavioral;
