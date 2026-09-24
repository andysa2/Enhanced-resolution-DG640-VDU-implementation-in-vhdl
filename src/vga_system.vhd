--------------------------------------------------------------------------------
-- Engineer		: Aleksandr Kienko
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
--------------------------------------------------------------------------------
entity vga_system is
generic(



   C_COLUMNS   			: integer	:= 73;		-- Text columns on screen ... added by Andrew  73 x 28 (2044 bytes) is best fit for 2048 (2K) of RAM
	C_ROWS					: integer   := 28;      -- Text Rows on screen ... added by Andrew

	C_SYS_DELAY				: integer	:= 0;			-- Address processing delay
	C_CNT_WIDTH				: integer	:= 10;		-- Width of the counters
	C_CHR_ADDR_WIDTH		: integer	:= 11;		-- Width of the character address
	
	C_H_SCANLINE_WIDTH	: integer	:= 800;		-- Horizontal line
	C_H_DISPLAY_AREA		: integer	:= 640;		-- Horizontal resolution
	C_H_BACK_PORCH			: integer 	:= 48;		-- Start blanking
	C_H_FRONT_PORCH		: integer	:= 16;		-- End blanking
	C_HSYNC_WIDTH			: integer	:= 96;		-- Hsync pulse width
	
	C_V_FRAME_HEIGHT		: integer	:= 525;		-- Vertical area
	C_V_DISPLAY_AREA		: integer	:= 480;		-- Vertical resolution
	C_V_FRONT_PORCH		: integer	:= 10;		-- Vertical start blanking
	C_V_BACK_PORCH			: integer	:= 33;		-- Vertical end blanking
	C_VSYNC_WIDTH			: integer	:= 2			-- Vsync pulse width
);
port (
	clk_in				: in  STD_LOGIC;	-- Pixel clock in
	
	-- Global Interface
	haddr_cnt_out		: out STD_LOGIC_VECTOR(C_CNT_WIDTH-1 downto 0);			-- Horizontal address
	vaddr_cnt_out		: out STD_LOGIC_VECTOR(C_CNT_WIDTH-1 downto 0);			-- Vertical address
	chr_cnt_out			: out STD_LOGIC_VECTOR(C_CHR_ADDR_WIDTH-1 downto 0);	-- Character address
	
	-- VGA Interface
	hsync_out			: out STD_LOGIC;		-- VGA Hsync
	vsync_out			: out STD_LOGIC		-- VGA Vsync
);
end vga_system;
-------------------------------------------------------------------------------
architecture IMP of vga_system is
-------------------------------------------------------------------------------
signal h_cnt			: UNSIGNED(C_CNT_WIDTH-1 downto 0) := (others => '0');		-- Horisontal timing counter
signal h_line_end		: STD_LOGIC	:= '0';				-- Timing sync pulse
signal v_cnt			: UNSIGNED(C_CNT_WIDTH-1 downto 0) := (others => '0');		-- Vertical timing counter
signal h_area_start	: STD_LOGIC	:= '0';				-- start of visible area
signal haddr_cnt		: UNSIGNED(C_CNT_WIDTH-1 downto 0) := (others => '0');		-- Horisontal pixel counter
signal vaddr_cnt		: UNSIGNED(C_CNT_WIDTH-1 downto 0) := (others => '0');		-- Vertical pixel counter
signal chr_cnt			: UNSIGNED(C_CHR_ADDR_WIDTH-1 downto 0) := (others => '0');	-- Character counter
signal row_cnt			: UNSIGNED(C_CHR_ADDR_WIDTH-1 downto 0) := (others => '0');	-- Row counter
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
h_cnt_drv: process(clk_in)
begin
	if(clk_in = '1' and clk_in'event)then
		if(h_cnt >= TO_UNSIGNED((C_H_SCANLINE_WIDTH - 1), C_CNT_WIDTH))then	-- Last pixel
			h_cnt			<= (others => '0');
			hsync_out		<= '0';			-- Start of Hsync pulse
		else
			h_cnt			<= h_cnt + 1;
			if(h_cnt = TO_UNSIGNED((C_HSYNC_WIDTH - 1), C_CNT_WIDTH))then
				hsync_out	<= '1';			-- End of Hsync pulse
			end if;
		end if;
		if(h_cnt = TO_UNSIGNED((C_H_SCANLINE_WIDTH - 2), C_CNT_WIDTH))then	-- Genarate pulse at Last pixel
			h_line_end		<= '1';
		else
			h_line_end		<= '0';
		end if;
		if(h_cnt = TO_UNSIGNED((C_HSYNC_WIDTH + C_H_BACK_PORCH - 1 - C_SYS_DELAY), C_CNT_WIDTH))then	-- Before visible area
			h_area_start	<= '1';
		else
			h_area_start	<= '0';
		end if;
	end if;
end process;

haddr_cnt_drv: process(clk_in)
begin
	if(clk_in = '1' and clk_in'event)then
		if(h_area_start = '1')then
			haddr_cnt		<= (others => '0');
		elsif(haddr_cnt < TO_UNSIGNED(C_H_DISPLAY_AREA, C_CNT_WIDTH))then					-- Count 1 address more pixel 640 will be blank indicator
			haddr_cnt	<= haddr_cnt + 1;
		end if;
	end if;
end process;
-------------------------------------------------------------------------------
v_cnt_drv: process(clk_in)
begin
	if(clk_in = '1' and clk_in'event)then
		if(h_line_end = '1')then			-- Count by the end of the horisontal line
			if(v_cnt >= TO_UNSIGNED((C_V_FRAME_HEIGHT - 1), C_CNT_WIDTH))then
				v_cnt		<= (others => '0');
				vsync_out	<= '0';			-- Start of Vsync pulse
			else
				v_cnt		<= v_cnt + 1;
				if(v_cnt = TO_UNSIGNED((C_VSYNC_WIDTH - 1), C_CNT_WIDTH))then
					vsync_out	<= '1';		-- End of Vsync pulse
				end if;
			end if;
		end if;
	end if;
end process;

vaddr_cnt_drv: process(clk_in)
begin
	if(clk_in = '1' and clk_in'event)then
	
		if(h_line_end = '1')then																		-- Count by the end of the horisontal line
			
			if(v_cnt = TO_UNSIGNED((C_VSYNC_WIDTH + C_V_FRONT_PORCH - 1), C_CNT_WIDTH))then
				vaddr_cnt	<= (others => '0');
				row_cnt		<= (others => '0');
				
			else
			
				if(vaddr_cnt /= TO_UNSIGNED(C_V_DISPLAY_AREA, C_CNT_WIDTH))then			-- Count 1 address more pixel 480 will be blank indicator
					vaddr_cnt	<= vaddr_cnt + 1;
				end if;
				
				if(vaddr_cnt(3 downto 0) = TO_UNSIGNED(15, 4))then								-- Height of character is 16 pixels
					--row_cnt		<= row_cnt + TO_UNSIGNED(80, C_CHR_ADDR_WIDTH);			-- Characters in horisontal line
					row_cnt		<= row_cnt + TO_UNSIGNED(C_COLUMNS, C_CHR_ADDR_WIDTH);	-- Characters in horisontal line
				end if;
				
			end if;
		end if;
	end if;
end process;

-- chr_cnt_drv: process(clk_in)
-- begin
	-- if(clk_in = '1' and clk_in'event)then
		-- chr_cnt		<= row_cnt + resize(haddr_cnt(9 downto 3),C_CHR_ADDR_WIDTH) + 1;
	-- end if;
-- end process;

chr_cnt		<= row_cnt + resize(haddr_cnt(9 downto 3),C_CHR_ADDR_WIDTH);

outs_drv: process(clk_in)
begin
	if(clk_in = '1' and clk_in'event)then
		haddr_cnt_out	<= STD_LOGIC_VECTOR(haddr_cnt);	-- Horizontal address
		vaddr_cnt_out	<= STD_LOGIC_VECTOR(vaddr_cnt);	-- Vertical address
		chr_cnt_out		<= STD_LOGIC_VECTOR(chr_cnt);		-- Character address
	end if;
end process;
-------------------------------------------------------------------------------
end IMP;
