----------------------------------------------------------------------------------
-- Create Date:    18:29:34 05/17/2016 
-- Design Name: 
-- Module Name:    Mux2X1 - Behavioral 
-- Project Name: 	  	DLX	
-- Revision: 			NOT TESTED
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mux_21 is
	generic (N: natural:=32);
    Port ( 
           A   : in  STD_LOGIC_VECTOR (N-1 downto 0);
           B   : in  STD_LOGIC_VECTOR (N-1 downto 0);
			  SEL : in  STD_LOGIC;
           O   : out STD_LOGIC_VECTOR (N-1 downto 0));
end mux_21;

architecture Behavioral of mux_21 is
begin
    O <= A when (SEL = '1') else B;
end Behavioral;