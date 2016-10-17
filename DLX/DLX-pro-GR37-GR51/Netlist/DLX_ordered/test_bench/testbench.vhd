-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

  ENTITY testbench IS
  END testbench;

  ARCHITECTURE behavior OF testbench IS 

  -- Component Declaration
          COMPONENT DLX
          PORT(
                 	clock,reset: in std_logic;
			
	debug_port : out std_logic_vector(31 downto 0)
                  );
          END COMPONENT;

   SIGNAL 	clock,reset:  std_logic;
	signal debug_port :  std_logic_vector(31 downto 0);
          
  constant clock_period : time := 20 ns;
  BEGIN

  -- Component Instantiation
          uut: DLX PORT MAP(clock,reset,debug_port
                 
          );

			-- Clock process definitions
   clock_process :process
   begin
		clock <= '1';
		wait for clock_period/2;
		clock <= '0';
		wait for clock_period/2;
   end process;

  --  Test Bench Statements
     tb : PROCESS
     BEGIN
			reset<='1';
        wait for 100 ns; -- wait until global set/reset completes
			reset<='0';
       

        wait; -- will wait forever
     END PROCESS tb;
  --  End Test Bench 

  END;