--------------------------------------------------------------------------------
-- Engineer: Alexandr Kienko
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--------------------------------------------------------------------------------
ENTITY vga_sys_tb IS
END vga_sys_tb;
-------------------------------------------------------------------------------- 
ARCHITECTURE behavior OF vga_sys_tb IS 
 --------------------------------------------------------------------------------
-- Component Declaration for the Unit Under Test (UUT)
component vga_system is
generic(
	C_SYS_DELAY				: integer	:= 0;		-- Address processing delay
	C_CNT_WIDTH				: integer	:= 10;		-- Width of the counters
	
	C_H_SCANLINE_WIDTH		: integer	:= 800;		-- Horisontal line
	C_H_DISPLAY_AREA		: integer	:= 640;		-- Horisontal resolution
	C_H_BACK_PORCH			: integer 	:= 48;		-- Start blanking
	C_H_FRONT_PORCH			: integer	:= 16;		-- End blanking
	C_HSYNC_WIDTH			: integer	:= 96;		-- Hsync pulse width
	
	C_V_FRAME_HEIGHT		: integer	:= 525;		-- Vertical area
	C_V_DISPLAY_AREA		: integer	:= 480;		-- Vertical resolution
	C_V_FRONT_PORCH			: integer	:= 10;		-- Vertical start blanking
	C_V_BACK_PORCH			: integer	:= 33;		-- Vertcal end blanking
	C_VSYNC_WIDTH			: integer	:= 2		-- Vsync pulse width
);
port (
	clk_in				: in  STD_LOGIC;	-- Pixel clock in
	-- Global Interface
	haddr_cnt_out		: out STD_LOGIC_VECTOR(9 downto 0);	-- Horisontal address
	vaddr_cnt_out		: out STD_LOGIC_VECTOR(9 downto 0);	-- Vertiacl address
	-- VGA Interface
	hsync_out			: out STD_LOGIC;	-- VGA Hsync
	vsync_out			: out STD_LOGIC		-- VGA Vsync
);
end component;

--Inputs
signal clk_in : std_logic := '0';

--Outputs
signal haddr_cnt_out : std_logic_vector(9 downto 0);
signal vaddr_cnt_out : std_logic_vector(9 downto 0);
signal hsync_out : std_logic;
signal vsync_out : std_logic;

-- Clock period definitions
constant clk_in_period : time := 40 ns;
--------------------------------------------------------------------------------
BEGIN
-------------------------------------------------------------------------------- 
-- Instantiate the Unit Under Test (UUT)
uut: vga_system 
generic map(
	C_SYS_DELAY				=> 0,		-- Address processing delay
	C_CNT_WIDTH				=> 10,		-- Width of the counters
	
	C_H_SCANLINE_WIDTH		=> 800,		-- Horisontal line
	C_H_DISPLAY_AREA		=> 640,		-- Horisontal resolution
	C_H_BACK_PORCH			=> 48,		-- Start blanking
	C_H_FRONT_PORCH			=> 16,		-- End blanking
	C_HSYNC_WIDTH			=> 96,		-- Hsync pulse width
	
	C_V_FRAME_HEIGHT		=> 525,		-- Vertical area
	C_V_DISPLAY_AREA		=> 480,		-- Vertical resolution
	C_V_FRONT_PORCH			=> 10,		-- Vertical start blanking
	C_V_BACK_PORCH			=> 33,		-- Vertcal end blanking
	C_VSYNC_WIDTH			=> 2		-- Vsync pulse width
)
PORT MAP (
	clk_in 			=> clk_in,
	haddr_cnt_out	=> haddr_cnt_out,
	vaddr_cnt_out	=> vaddr_cnt_out,
	hsync_out		=> hsync_out,
	vsync_out		=> vsync_out
);

-- Clock process definitions
clk_in_process :process
begin
	clk_in <= '0';
	wait for clk_in_period/2;
	clk_in <= '1';
	wait for clk_in_period/2;
end process;

-- Stimulus process
-- stim_proc: process
-- begin		
	-- -- hold reset state for 100 ns.
	-- wait for 100 ns;	

	-- wait for clk_in_period*10;

	-- -- insert stimulus here 

	-- wait;
-- end process;
--------------------------------------------------------------------------------
END;
