--------------------------------------------------------------------------------
-- Engineer		: Aleksandr Kienko
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
library UNISIM; 
use UNISIM.VCOMPONENTS.ALL; 
--------------------------------------------------------------------------------
entity clock_system is
port (
	clk_100Mhz_in	: in  STD_LOGIC;
	pix_clk_out		: out STD_LOGIC;
	bus_clk_out		: out STD_LOGIC
);
end clock_system;
-------------------------------------------------------------------------------
architecture IMP of clock_system is
-------------------------------------------------------------------------------
component vga_pix_clk_gen is	-- Coregen block 
port(
	CLK_IN1           : in	STD_LOGIC;
	CLK_OUT1          : out STD_LOGIC		-- Out frequency 25.185 MHz
);
end component;

signal clk_g			: STD_LOGIC;
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
-- Instantiate BUFG for clock inputs
bufg_inst : BUFG
port map (
	I 				=> clk_100Mhz_in,
	O 				=> clk_g
);
bus_clk_out			<= clk_g;

clk_wiz_inst: vga_pix_clk_gen
port map(	
	CLK_IN1			=> clk_g,
	CLK_OUT1        => pix_clk_out
);
-------------------------------------------------------------------------------
end IMP;
