----------------------------------------------------------------------------------
-- Create Date:    	16:13:05 05/18/2016 
-- Design Name: 
-- Module Name:    	decodeUnit - Structural 
-- Project Name: 		DLX
-- Revision: 			TESTED
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use ieee.numeric_std.all;


-- This module implements the physical RF
entity register_file is
	port(
		-- 1 write port, 2 read ports
		data_in_port_w : in std_logic_vector(31 downto 0);
		data_out_port_a : out std_logic_vector(31 downto 0);
		data_out_port_b : out std_logic_vector(31 downto 0);
		address_port_a : in std_logic_vector(4 downto 0);
		address_port_b : in std_logic_vector(4 downto 0);
		address_port_w : in std_logic_vector(4 downto 0);
		--active high signal, asynchronous R, synchronous W
		r_signal_port_a : in std_logic;
		r_signal_port_b : in std_logic;
		w_signal : in std_logic;
		--synchronous and active high reset, enable
		reset,clock,enable : in std_logic
	);

end register_file;

architecture Behavioral of register_file is
	
	type regFile is array(0 to 31) of std_logic_vector(31 downto 0);
	signal registers : regFile;

begin

	writeProcess : process (reset, w_signal, address_port_w, data_in_port_w )
	begin
		
			if(reset = '1')then
				registers <= (others =>(others =>'0'));
			else
				if(enable = '1') then
					-- Write and bypass, in case the read signal is asserted
					if w_signal = '1' then
						-- Keep R0 always tied to ground
						if to_integer(unsigned(address_port_w)) /= 0 then
							  registers(to_integer(unsigned(address_port_w))) <= data_in_port_w;  -- Write
						end if;
					end if;
				end if;
			end if;
	
	end process;

	readProcess : process (registers, r_signal_port_a, r_signal_port_b, address_port_a, address_port_b, enable) is
	begin
		if(enable = '1')then
			if(r_signal_port_a='1') then
				data_out_port_a <= registers(to_integer(unsigned(address_port_a)));
			else
				data_out_port_a <= (others=>'Z');
			end if;
			if(r_signal_port_b='1') then
				data_out_port_b <= registers(to_integer(unsigned(address_port_b)));	
			else
				data_out_port_b <= (others=>'Z');
			end if;
		else 
			data_out_port_a <= (others => 'Z');
			data_out_port_b <= (others => 'Z');
		end if;
	end process;

end Behavioral;