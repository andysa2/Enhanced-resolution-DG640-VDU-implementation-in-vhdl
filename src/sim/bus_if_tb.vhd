--------------------------------------------------------------------------------
-- Engineer: Alexandr Kienko
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--------------------------------------------------------------------------------
ENTITY bus_if_tb IS
END bus_if_tb;

ARCHITECTURE behavior OF bus_if_tb IS 
--------------------------------------------------------------------------------
-- Component Declaration for the Unit Under Test (UUT)
component bus_system is
port (
	clk_in						: in  STD_LOGIC;	-- Clock in
	ce_n_in						: in  STD_LOGIC;	-- CE (Active low)
	addr_in						: in  STD_LOGIC_VECTOR(11 downto 0);
	data_in						: in  STD_LOGIC_VECTOR( 7 downto 0);
	data_out					: out STD_LOGIC_VECTOR( 7 downto 0);
	data_oe_out					: out STD_LOGIC;	-- Read data output enable
	rnw_in						: in  STD_LOGIC;	-- Memory read/write 
	p2_in						: in  STD_LOGIC;	-- Memory phase 2 clock
	-- Character memory interface
	chr_mem_we_out				: out STD_LOGIC_VECTOR( 0 downto 0);
	chr_mem_bus_addr_out		: out STD_LOGIC_VECTOR(10 downto 0);
	chr_mem_bus_data_out		: out STD_LOGIC_VECTOR( 7 downto 0);
	chr_mem_bus_data_in			: in  STD_LOGIC_VECTOR( 7 downto 0);
	-- Attribute memory interface
	attr_mem_we_out				: out STD_LOGIC_VECTOR( 0 downto 0);
	attr_mem_bus_addr_out		: out STD_LOGIC_VECTOR(10 downto 0);
	attr_mem_bus_data_out		: out STD_LOGIC_VECTOR( 7 downto 0);
	attr_mem_bus_data_in		: in  STD_LOGIC_VECTOR( 7 downto 0);
	-- Programmable Character Generator RAM
	pcg_mem_we_out				: out STD_LOGIC_VECTOR( 0 downto 0);
	pcg_mem_bus_addr_out		: out STD_LOGIC_VECTOR(10 downto 0);
	pcg_mem_bus_data_out		: out STD_LOGIC_VECTOR( 7 downto 0);
	pcg_mem_bus_data_in			: in  STD_LOGIC_VECTOR( 7 downto 0)
);
end component;
    

   --Inputs
   signal clk_in : std_logic := '0';
   signal ce_n_in : std_logic := '0';
   signal addr_in : std_logic_vector(11 downto 0) := (others => '0');
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');
   signal rnw_in : std_logic := '0';
   signal p2_in : std_logic := '0';
   signal chr_mem_bus_data_in : std_logic_vector(7 downto 0) := (others => '0');
   signal attr_mem_bus_data_in : std_logic_vector(7 downto 0) := (others => '0');
   signal pcg_mem_bus_data_in : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal data_out : std_logic_vector(7 downto 0);
   signal data_oe_out : std_logic;
   signal chr_mem_we_out : std_logic_vector(0 downto 0);
   signal chr_mem_bus_addr_out : std_logic_vector(10 downto 0);
   signal chr_mem_bus_data_out : std_logic_vector(7 downto 0);
   signal attr_mem_we_out : std_logic_vector(0 downto 0);
   signal attr_mem_bus_addr_out : std_logic_vector(10 downto 0);
   signal attr_mem_bus_data_out : std_logic_vector(7 downto 0);
   signal pcg_mem_we_out : std_logic_vector(0 downto 0);
   signal pcg_mem_bus_addr_out : std_logic_vector(10 downto 0);
   signal pcg_mem_bus_data_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_in_period : time := 10 ns;
   constant p2_in_period : time := 222 ns;

   signal read_data : std_logic_vector(7 downto 0) := (others => '0');
   
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: bus_system PORT MAP (
          clk_in => clk_in,
          ce_n_in => ce_n_in,
          addr_in => addr_in,
          data_in => data_in,
          data_out => data_out,
          data_oe_out => data_oe_out,
          rnw_in => rnw_in,
          p2_in => p2_in,
          chr_mem_we_out => chr_mem_we_out,
          chr_mem_bus_addr_out => chr_mem_bus_addr_out,
          chr_mem_bus_data_out => chr_mem_bus_data_out,
          chr_mem_bus_data_in => chr_mem_bus_data_in,
          attr_mem_we_out => attr_mem_we_out,
          attr_mem_bus_addr_out => attr_mem_bus_addr_out,
          attr_mem_bus_data_out => attr_mem_bus_data_out,
          attr_mem_bus_data_in => attr_mem_bus_data_in,
          pcg_mem_we_out => pcg_mem_we_out,
          pcg_mem_bus_addr_out => pcg_mem_bus_addr_out,
          pcg_mem_bus_data_out => pcg_mem_bus_data_out,
          pcg_mem_bus_data_in => pcg_mem_bus_data_in
        );

   -- Clock process definitions
   clk_in_process :process
   begin
		clk_in <= '0';
		wait for clk_in_period/2;
		clk_in <= '1';
		wait for clk_in_period/2;
   end process;

   p2_in_process :process
   begin
		p2_in <= '0';
		wait for p2_in_period/2;
		p2_in <= '1';
		wait for p2_in_period/2;
   end process;
   
   -- signal ce_n_in : std_logic := '0';
   -- signal addr_in : std_logic_vector(11 downto 0) := (others => '0');
   -- signal data_in : std_logic_vector(7 downto 0) := (others => '0');
   -- signal rnw_in : std_logic := '0';
   -- signal p2_in : std_logic := '0';
   -- signal chr_mem_bus_data_in : std_logic_vector(7 downto 0) := (others => '0');
   -- signal attr_mem_bus_data_in : std_logic_vector(7 downto 0) := (others => '0');
   -- signal pcg_mem_bus_data_in : std_logic_vector(7 downto 0) := (others => '0');

chr_mem_bus_data_in		<= x"AA";
attr_mem_bus_data_in	<= x"BB";
pcg_mem_bus_data_in		<= x"CC";

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
	  ce_n_in		<= '1';
	  addr_in		<= (others => 'Z');
	  data_in		<= (others => 'Z');
	  rnw_in		<= '1';
      wait for 40 ns;	
		addr_in		<= (others => '0');
		data_in		<= (others => '0');
		wait for p2_in_period*10;
		-- Write transaction
		ce_n_in		<= '0';
		rnw_in		<= '0';
		addr_in		<= x"123";
		data_in		<= x"12";
		wait for p2_in_period;
		ce_n_in		<= '1';
		rnw_in		<= '1';
		addr_in		<= x"333";
		data_in		<= x"34";
		wait for p2_in_period;
		-- Read transction
		ce_n_in		<= '0';
		rnw_in		<= '1';
		addr_in		<= x"333";
		data_in		<= (others => 'Z');
		wait for p2_in_period;
		ce_n_in		<= '1';
		rnw_in		<= '1';
		addr_in		<= x"333";
		data_in		<= x"34";
		wait for p2_in_period;
		

      wait;
   end process;

	read_data	<= data_out when data_oe_out = '1' else (others => 'Z');
END;
