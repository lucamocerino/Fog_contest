library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.all;

entity DATA_RAM is
	port (
    clock   : in  std_logic;
	 reset 	: in 	std_logic;
    we      : in  std_logic;
	 re		: in std_logic;
    address : in  std_logic_vector(31 downto 0);
    datain  : in  std_logic_vector(31 downto 0);
    dataout : out std_logic_vector(31 downto 0)
  );
end DATA_RAM;

architecture Behavioral of DATA_RAM is

	type ram_type is array (0 to 36) of std_logic_vector(31 downto 0);
	signal ram : ram_type := 
									(
										X"00000001",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000001",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000",
										X"00000000"
									 );

begin

	WrProc: process(clock) is
	begin
		if(clock'event and clock='1') then
		if (reset = '1') then
			ram <= (others =>(others =>'0'));
		else
			if we = '1' then
			 ram(to_integer(unsigned(address))) <= datain;
			
				end if;
			end if;
		end if;
	end process;

	RdProc : process (address, ram, we ) is
	begin
		if(re='1') then
		dataout <= ram(to_integer(unsigned(address)));
			
	else dataout<=datain;
		end if;
	end process;
end Behavioral;