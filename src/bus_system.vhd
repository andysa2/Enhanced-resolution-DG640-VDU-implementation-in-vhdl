--------------------------------------------------------------------------------
-- Engineer		: Aleksandr Kienko
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
--------------------------------------------------------------------------------
entity bus_system is
port (
	clk_in						: in  STD_LOGIC;	-- Clock in
	ce_n_in						: in  STD_LOGIC;
	addr_in						: in  STD_LOGIC_VECTOR(12 downto 0);
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
end bus_system;
-------------------------------------------------------------------------------
architecture IMP of bus_system is
-------------------------------------------------------------------------------
signal addr_sel		: STD_LOGIC_VECTOR( 4 downto 0);
signal addr			: STD_LOGIC_VECTOR(12 downto 0);
signal data_wr		: STD_LOGIC_VECTOR( 7 downto 0);
signal rnw			: STD_LOGIC;
signal ce_n			: STD_LOGIC;
signal strb_sr		: STD_LOGIC_VECTOR( 1 downto 0);
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
in_bufs: process(clk_in)
begin
	if(clk_in = '1' and clk_in'event)then
		addr		<= addr_in;
		data_wr		<= data_in;
		rnw			<= rnw_in;
		ce_n		<= ce_n_in;
		strb_sr		<= strb_sr(0) & p2_in;
	end if;
end process;

mem_bufs: process(clk_in)
begin
	if(clk_in = '1' and clk_in'event)then
		chr_mem_bus_addr_out	<= addr(10 downto 0);
		attr_mem_bus_addr_out	<= addr(10 downto 0);
		pcg_mem_bus_addr_out	<= addr(10 downto 0);
		chr_mem_bus_data_out	<= data_wr;
		attr_mem_bus_data_out	<= data_wr;
		pcg_mem_bus_data_out	<= data_wr;
		if((ce_n = '0') and (strb_sr = "10") and (rnw = '0'))then	-- Falling edge of strb signal
			case addr(12 downto 11) is
				when "00"	=> 	-- Character memory
					chr_mem_we_out	<= "1";
					attr_mem_we_out	<= "0";
					pcg_mem_we_out	<= "0";
				when "01"	=> 	-- Attribute memory
					chr_mem_we_out	<= "0";
					attr_mem_we_out	<= "1";
					pcg_mem_we_out	<= "0";
				when "10"	=>  -- Programmable Character Generator RAM
					chr_mem_we_out	<= "0";
					attr_mem_we_out	<= "0";
					pcg_mem_we_out	<= "1";
				when "11"	=>  -- Programmable Character Generator RAM
					chr_mem_we_out	<= "0";
					attr_mem_we_out	<= "0";
					pcg_mem_we_out	<= "1";
				when others => null;
			end case;
		else
			chr_mem_we_out	<= "0";
			attr_mem_we_out	<= "0";
			pcg_mem_we_out	<= "0";
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
-- Syncronous version (recomended but slow)
-- out_bufs: process(clk_in)	
-- begin
	-- if(clk_in = '1' and clk_in'event)then
		-- case addr(11 downto 10) is
			-- when "00"	=> 	-- Character memory
				-- data_out		<= chr_mem_bus_data_in;
			-- when "01"	=> 	-- Attribute memory
				-- data_out		<= attr_mem_bus_data_in;
			-- when "10"	=>  -- Programmable Character Generator RAM
				-- data_out		<= pcg_mem_bus_data_in;
			-- when "11"	=>  -- Programmable Character Generator RAM
				-- data_out		<= pcg_mem_bus_data_in;
			-- when others => null;
		-- end case;
		-- if((ce_n = '0') and (rnw = '1'))then	-- Read access
			-- data_oe_out		<= '1';
		-- else
			-- data_oe_out		<= '0';
		-- end if;
	-- end if;
-- end process;
-------------------------------------------------------------------------------
-- Asyncronous version faster but produce timing errors
out_bufs: process(addr, chr_mem_bus_data_in, attr_mem_bus_data_in, pcg_mem_bus_data_in)	
begin
	case addr(12 downto 11) is
		when "00"	=> 	-- Character memory
			data_out		<= chr_mem_bus_data_in;
		when "01"	=> 	-- Attribute memory
			data_out		<= attr_mem_bus_data_in;
		when "10"	=>  -- Programmable Character Generator RAM
			data_out		<= pcg_mem_bus_data_in;
		when "11"	=>  -- Programmable Character Generator RAM
			data_out		<= pcg_mem_bus_data_in;
		when others => null;
	end case;
end process;

data_oe_out		<= '1' when ((ce_n = '0') and (rnw = '1')) else '0';
-------------------------------------------------------------------------------
end IMP;
