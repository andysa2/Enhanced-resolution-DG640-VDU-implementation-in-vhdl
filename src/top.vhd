--------------------------------------------------------------------------------
-- Engineer		: Aleksandr Kienko
--------------------------------------------------------------------------------
-- Revision 2.0
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
library UNisIM; 
use UNisIM.VCOMPONENTS.ALL; 
--------------------------------------------------------------------------------
entity top is
port (
	clk_in			: in  STD_LOGIC;	-- System clock input 100 MHz
	
	-- VGA Interface
	red_out			: out STD_LOGIC;
	green_out		: out STD_LOGIC;
	blue_out			: out STD_LOGIC;
	hsync_out		: out STD_LOGIC;
	vsync_out		: out STD_LOGIC;
	
	-- Bus Interface
	ce_n_in			: in  STD_LOGIC;
	addr_in			: in  STD_LOGIC_VECTOR(12 downto 0);
	data_inout		: inout  STD_LOGIC_VECTOR( 7 downto 0);
	rnw_in			: in  STD_LOGIC;	-- Memory read/write 
	p2_in				: in  STD_LOGIC	-- Memory phase 2 clock
	
);
end top;
-------------------------------------------------------------------------------
architecture IMP of top is
-------------------------------------------------------------------------------
component clock_system is

port (
	clk_100Mhz_in	: in  STD_LOGIC;	-- Input Frequence from external generator
	pix_clk_out		: out STD_LOGIC;	-- VGA Pixel clock	~25.175 MHz
	bus_clk_out		: out STD_LOGIC	-- BUS clock		100 MHz
);
end component;

component vga_system is
generic(

	C_SYS_DELAY				: integer	:= 0;			-- Address processing delay
	C_CNT_WIDTH				: integer	:= 10;		-- Width of the counters
	C_CHR_ADDR_WIDTH		: integer	:= 11;		-- Width of the character address
	
	C_H_SCANLINE_WIDTH	: integer	:= 800;		-- Horisontal line
	C_H_DISPLAY_AREA		: integer	:= 640;		-- Horisontal resolution
	C_H_BACK_PORCH			: integer 	:= 48;		-- Start blanking
	C_H_FRONT_PORCH		: integer	:= 16;		-- End blanking
	C_HSYNC_WIDTH			: integer	:= 96;		-- Hsync pulse width
	
	C_V_FRAME_HEIGHT		: integer	:= 525;		-- Vertical area
	C_V_DISPLAY_AREA		: integer	:= 480;		-- Vertical resolution
	C_V_FRONT_PORCH		: integer	:= 10;		-- Vertical start blanking
	C_V_BACK_PORCH			: integer	:= 33;		-- Vertcal end blanking
	C_VSYNC_WIDTH			: integer	:= 2			-- Vsync pulse width
);
port (
	clk_in					: in  STD_LOGIC;	-- Pixel clock in
	-- Global Interface
	haddr_cnt_out			: out STD_LOGIC_VECTOR(9 downto 0);	-- Horisontal address
	vaddr_cnt_out			: out STD_LOGIC_VECTOR(9 downto 0);	-- Vertiacl address
	chr_cnt_out				: out STD_LOGIC_VECTOR(10 downto 0);-- Character address
	-- VGA Interface
	hsync_out				: out STD_LOGIC;							-- VGA Hsync
	vsync_out				: out STD_LOGIC							-- VGA Vsync
);
end component;

component ram_2Kx8_chr is	-- Characters RAM (Coregen) with test pattern
port (
	clka		: in  STD_LOGIC;
	wea		: in  STD_LOGIC_VECTOR( 0 downto 0);
	addra		: in  STD_LOGIC_VECTOR(10 downto 0);
	dina		: in  STD_LOGIC_VECTOR( 7 downto 0);
	douta		: out STD_LOGIC_VECTOR( 7 downto 0);
	clkb		: in  STD_LOGIC;
	web		: in  STD_LOGIC_VECTOR( 0 downto 0);
	addrb		: in  STD_LOGIC_VECTOR(10 downto 0);
	dinb		: in  STD_LOGIC_VECTOR( 7 downto 0);
	doutb		: out STD_LOGIC_VECTOR( 7 downto 0)
);
end component;

component ram_2Kx8_attr is	-- Attributes RAM (Coregen) with test pattern
port (
	clka		: in  STD_LOGIC;
	wea		: in  STD_LOGIC_VECTOR( 0 downto 0);
	addra		: in  STD_LOGIC_VECTOR(10 downto 0);
	dina		: in  STD_LOGIC_VECTOR( 7 downto 0);
	douta		: out STD_LOGIC_VECTOR( 7 downto 0);
	clkb		: in  STD_LOGIC;
	web		: in  STD_LOGIC_VECTOR( 0 downto 0);
	addrb		: in  STD_LOGIC_VECTOR(10 downto 0);
	dinb		: in  STD_LOGIC_VECTOR( 7 downto 0);
	doutb		: out STD_LOGIC_VECTOR( 7 downto 0)
);
end component;

component ram_2Kx8_pcg is	-- Programmable Character Generator (Coregen) Empty
port (
	clka		: in  STD_LOGIC;
	wea		: in  STD_LOGIC_VECTOR( 0 downto 0);
	addra		: in  STD_LOGIC_VECTOR(10 downto 0);
	dina		: in  STD_LOGIC_VECTOR( 7 downto 0);
	douta		: out STD_LOGIC_VECTOR( 7 downto 0);
	clkb		: in  STD_LOGIC;
	web		: in  STD_LOGIC_VECTOR( 0 downto 0);
	addrb		: in  STD_LOGIC_VECTOR(10 downto 0);
	dinb		: in  STD_LOGIC_VECTOR( 7 downto 0);
	doutb		: out STD_LOGIC_VECTOR( 7 downto 0)
);
end component;

component chr_gen_rom is	-- (Coregen) ROM with init data
port (
    ADDRA      : in  STD_LOGIC_VECTOR(11 downto 0);
    DOUTA      : out STD_LOGIC_VECTOR( 7 downto 0);
    CLKA       : in  STD_LOGIC
);
end component;

component gra_gen_rom is	-- (Coregen) ROM with init data
port (
    ADDRA      : in  STD_LOGIC_VECTOR(11 downto 0);
    DOUTA      : out STD_LOGIC_VECTOR( 7 downto 0);
    CLKA       : in  STD_LOGIC
);
end component;

component bus_system is
port (

	clk_in						: in  STD_LOGIC;	-- Clock in
	ce_n_in						: in  STD_LOGIC;	-- CE (Active low)
	addr_in						: in  STD_LOGIC_VECTOR(12 downto 0);
	data_in						: in  STD_LOGIC_VECTOR( 7 downto 0);
	data_out						: out STD_LOGIC_VECTOR( 7 downto 0);
	data_oe_out					: out STD_LOGIC;	-- Read data output enable
	rnw_in						: in  STD_LOGIC;	-- Memory read/write 
	p2_in							: in  STD_LOGIC;	-- Memory phase 2 clock
	
	-- Character memory interface
	chr_mem_we_out				: out STD_LOGIC_VECTOR( 0 downto 0);
	chr_mem_bus_addr_out		: out STD_LOGIC_VECTOR(10 downto 0);
	chr_mem_bus_data_out		: out STD_LOGIC_VECTOR( 7 downto 0);
	chr_mem_bus_data_in		: in  STD_LOGIC_VECTOR( 7 downto 0);
	
	-- Attribute memory interface
	attr_mem_we_out			: out STD_LOGIC_VECTOR( 0 downto 0);
	attr_mem_bus_addr_out	: out STD_LOGIC_VECTOR(10 downto 0);
	attr_mem_bus_data_out	: out STD_LOGIC_VECTOR( 7 downto 0);
	attr_mem_bus_data_in		: in  STD_LOGIC_VECTOR( 7 downto 0);
	
	-- Programmable Character Generator RAM
	pcg_mem_we_out				: out STD_LOGIC_VECTOR( 0 downto 0);
	pcg_mem_bus_addr_out		: out STD_LOGIC_VECTOR(10 downto 0);
	pcg_mem_bus_data_out		: out STD_LOGIC_VECTOR( 7 downto 0);
	pcg_mem_bus_data_in		: in  STD_LOGIC_VECTOR( 7 downto 0)
);
end component;
-------------------------------------------------------------------------------
signal clk					: STD_LOGIC;							-- Video system clock
signal bus_clk				: STD_LOGIC;							-- Bus system clock
signal chr_cnt				: STD_LOGIC_VECTOR(10 downto 0);	-- Character address
signal haddr_cnt			: STD_LOGIC_VECTOR( 9 downto 0);	-- Horisontal pixel address
signal vaddr_cnt			: STD_LOGIC_VECTOR( 9 downto 0);	-- Vertcal pixel address
signal vaddr_s1			: STD_LOGIC_VECTOR( 9 downto 0);	-- Vertcal pixel address Stage 1
signal haddr_s1			: STD_LOGIC_VECTOR( 9 downto 0);	-- Horisontal pixel address Stage 1
signal haddr_s2			: STD_LOGIC_VECTOR( 9 downto 0);	-- Horisontal pixel address Stage 2
signal haddr_s3			: STD_LOGIC_VECTOR( 9 downto 0);	-- Horisontal pixel address Stage 3
signal haddr_s4			: STD_LOGIC_VECTOR( 9 downto 0);	-- Horisontal pixel address Stage 4
signal haddr_s5			: STD_LOGIC_VECTOR( 9 downto 0);	-- Horisontal pixel address Stage 5
signal attr_s3				: STD_LOGIC_VECTOR( 7 downto 0);	-- Attributes Stage 3
signal attr_s4				: STD_LOGIC_VECTOR( 7 downto 0);	-- Attributes Stage 4
signal attr_s5				: STD_LOGIC_VECTOR( 7 downto 0);	-- Attributes Stage 5
signal pcg_sel_s3			: STD_LOGIC;							-- PCG selection bit Stage 3
signal pcg_sel_s4			: STD_LOGIC;							-- PCG selection bit Stage 4
-- Character RAM
signal chr_mem_we				: STD_LOGIC_VECTOR( 0 downto 0);	-- Character memory write enable
signal chr_mem_bus_addr		: STD_LOGIC_VECTOR(10 downto 0);	-- Character memory address BUS side
signal chr_mem_bus_wr_data	: STD_LOGIC_VECTOR( 7 downto 0);	-- Character memory write data
signal chr_mem_bus_rd_data	: STD_LOGIC_VECTOR( 7 downto 0);	-- Character memory read data
signal chr_mem_vga_addr		: STD_LOGIC_VECTOR(10 downto 0);	-- Character memory address VGA side
signal chr_mem_vga_rd_data	: STD_LOGIC_VECTOR( 7 downto 0);	-- Character memory read data
-- Attribute RAM
signal attr_mem_we				: STD_LOGIC_VECTOR( 0 downto 0);	-- Attribute memory write enable
signal attr_mem_bus_addr		: STD_LOGIC_VECTOR(10 downto 0);	-- Attribute memory address BUS side
signal attr_mem_bus_wr_data	: STD_LOGIC_VECTOR( 7 downto 0);	-- Attribute memory write data
signal attr_mem_bus_rd_data	: STD_LOGIC_VECTOR( 7 downto 0);	-- Attribute memory read data
signal attr_mem_vga_addr		: STD_LOGIC_VECTOR(10 downto 0);	-- Attribute memory address VGA side
signal attr_mem_vga_rd_data	: STD_LOGIC_VECTOR( 7 downto 0);	-- Attribute memory read data
-- Programmable Character Generator RAM
signal pcg_mem_we				: STD_LOGIC_VECTOR( 0 downto 0);	-- Generator memory write enable
signal pcg_mem_bus_addr		: STD_LOGIC_VECTOR(10 downto 0);	-- Generator memory address
signal pcg_mem_bus_wr_data	: STD_LOGIC_VECTOR( 7 downto 0);	-- Generator memory write data
signal pcg_mem_bus_rd_data	: STD_LOGIC_VECTOR( 7 downto 0);	-- Generator memory read data
signal pcg_mem_vga_addr		: STD_LOGIC_VECTOR(10 downto 0);	-- Generator memory address
signal pcg_mem_vga_rd_data	: STD_LOGIC_VECTOR( 7 downto 0);	-- Generator memory read data
-- Character Generator ROM
signal chr_gen_rom_addr		: STD_LOGIC_VECTOR(11 downto 0);
signal chr_gen_rom_data		: STD_LOGIC_VECTOR( 7 downto 0);
-- Graphics ROM
signal gra_gen_rom_addr		: STD_LOGIC_VECTOR(11 downto 0);
signal gra_gen_rom_data		: STD_LOGIC_VECTOR( 7 downto 0);
signal pixel_data				: STD_LOGIC;							-- 8 Pixels from selected RAM/ROM
signal pixel_addr				: INTEGER range 0 to 7	:= 0;		-- Pixel position in byte

signal data_out				: STD_LOGIC_VECTOR( 7 downto 0);	-- Bus interface out driver
signal data_in					: STD_LOGIC_VECTOR( 7 downto 0);	-- Bus interface in data
signal data_oe					: STD_LOGIC;							-- Bus interface output enable

constant C_FLASH_PERIOD		: INTEGER		:= 12500000;					-- ~2 Hz
signal flash_cnt 				: INTEGER range 0 to C_FLASH_PERIOD := 0;	-- Flash counter
signal flash_toggle			: STD_LOGIC		:= '0';							-- Inversion bit
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
clock_system_inst: clock_system			-- Clocking system
port map(
	clk_100Mhz_in			=> clk_in,		-- Input clocl from external generator
	pix_clk_out				=> clk,			-- 25.185 MHz close enough to VGA pixel clock
	bus_clk_out				=> bus_clk		-- 100 MHz for bus interface
);
-------------------------------------------------------------------------------
bus_system_inst: bus_system
port map(
	clk_in					=> bus_clk,		-- Clock in
	ce_n_in					=> ce_n_in,
	addr_in					=> addr_in,
	data_in					=> data_in,
	data_out					=> data_out,
	data_oe_out				=> data_oe,
	rnw_in					=> rnw_in,		-- Memory read/write 
	p2_in						=> p2_in,		-- Memory phase 2 clock
	
	-- Character memory interface
	chr_mem_we_out				=> chr_mem_we,
	chr_mem_bus_addr_out		=> chr_mem_bus_addr,
	chr_mem_bus_data_out		=> chr_mem_bus_wr_data,
	chr_mem_bus_data_in		=> chr_mem_bus_rd_data,
	
	-- Attribute memory interface
	attr_mem_we_out			=> attr_mem_we,
	attr_mem_bus_addr_out	=> attr_mem_bus_addr,
	attr_mem_bus_data_out	=> attr_mem_bus_wr_data,
	attr_mem_bus_data_in	=> attr_mem_bus_rd_data,
	
	-- Programmable Character Generator RAM
	pcg_mem_we_out				=> pcg_mem_we,
	pcg_mem_bus_addr_out		=> pcg_mem_bus_addr,
	pcg_mem_bus_data_out		=> pcg_mem_bus_wr_data,
	pcg_mem_bus_data_in		=> pcg_mem_bus_rd_data
);
data_inout		<= data_out when data_oe = '1' else (others => 'Z');	-- Drive output bus
data_in			<= data_inout;														-- Read 3state bus

vga_sys_inst: vga_system
generic map(
	C_SYS_DELAY				=> 6,			-- Address processing delay (Processing stages)
	C_CNT_WIDTH				=> 10,		-- Width of the counters
	C_CHR_ADDR_WIDTH		=> 11,		-- Width of the character address
	
	C_H_SCANLINE_WIDTH		=> 800,	-- Horisontal line
	C_H_DISPLAY_AREA		=> 640,		-- Horisontal resolution
	C_H_BACK_PORCH			=> 48,		-- Start blanking
	C_H_FRONT_PORCH		=> 16,		-- End blanking
	C_HSYNC_WIDTH			=> 96,		-- Hsync pulse width
	
	C_V_FRAME_HEIGHT		=> 525,		-- Vertical area
	C_V_DisPLAY_AREA		=> 480,		-- Vertical resolution
	C_V_FRONT_PORCH		=> 10,		-- Vertical start blanking
	C_V_BACK_PORCH			=> 33,		-- Vertcal end blanking
	C_VSYNC_WIDTH			=> 2			-- Vsync pulse width
)
port map(
	clk_in					=> clk,
	-- Global Interface
	haddr_cnt_out			=> haddr_cnt,	-- Horisontal address
	vaddr_cnt_out			=> vaddr_cnt,	-- Vertiacl address
	chr_cnt_out				=> chr_cnt,		-- Character address

	-- VGA Interface
	hsync_out				=> hsync_out,	-- VGA Hsync
	vsync_out				=> vsync_out	-- VGA Vsync
);
-- Character RAM
character_mem_inst: ram_2Kx8_chr
port map(
	-- Bus side
	clka					=> bus_clk,
	wea					=> chr_mem_we,
	addra					=> chr_mem_bus_addr,
	dina					=> chr_mem_bus_wr_data,
	douta					=> chr_mem_bus_rd_data,
	-- VGA side
	clkb					=> clk,
	web					=> "0",			-- No write from this side
	addrb					=> chr_mem_vga_addr,
	dinb					=> x"00",		-- No write from this side
	doutb					=> chr_mem_vga_rd_data
);
-- Attribute RAM
attributes_mem_inst: ram_2Kx8_attr
port map(
	-- Bus side
	clka					=> bus_clk,
	wea					=> attr_mem_we,
	addra					=> attr_mem_bus_addr,
	dina					=> attr_mem_bus_wr_data,
	douta					=> attr_mem_bus_rd_data,
	-- VGA side
	clkb					=> clk,
	web					=> "0",		-- No write from this side
	addrb					=> attr_mem_vga_addr,
	dinb					=> x"00",	-- No write from this side
	doutb					=> attr_mem_vga_rd_data
);
-- Programmable Character Generator RAM
pcg_mem_inst: ram_2Kx8_pcg
port map(
	-- Bus side
	clka					=> bus_clk,
	wea					=> pcg_mem_we,
	addra					=> pcg_mem_bus_addr,
	dina					=> pcg_mem_bus_wr_data,
	douta					=> pcg_mem_bus_rd_data,
	-- VGA side
	clkb					=> clk,
	web					=> "0",		-- No write from this side
	addrb					=> pcg_mem_vga_addr,
	dinb					=> x"00",	-- No write from this side
	doutb					=> pcg_mem_vga_rd_data
);

chr_gen_rom_inst: chr_gen_rom	-- Character Generator ROM
port map(
    ADDRA					=> chr_gen_rom_addr,
    DOUTA					=> chr_gen_rom_data,
    CLKA						=> clk
);

gra_gen_rom_inst: gra_gen_rom	-- Graphics ROM
port map(
    ADDRA					=> gra_gen_rom_addr,
    DOUTA					=> gra_gen_rom_data,
    CLKA						=> clk
);

datapath: process(clk)
begin
	if(clk = '1' and clk'event)then
	
		-- Stage 1 - Init RAM addr 
		--chr_mem_vga_addr	<= "0" & vaddr_cnt(7 downto 4) & haddr_cnt(8 downto 3);	-- Vertcal word & Horisontal byte
		--attr_mem_vga_addr	<= "0" & vaddr_cnt(7 downto 4) & haddr_cnt(8 downto 3);	-- Vertcal word & Horisontal byte
		
		chr_mem_vga_addr	<= chr_cnt;																	-- Character address
		attr_mem_vga_addr	<= chr_cnt;																	-- Character address
		vaddr_s1				<= vaddr_cnt;																-- Store counter. Vertacal counter will be the same for all stages
		haddr_s1				<= haddr_cnt;																-- Store counter for next stage
		
		-- Stage 2 - Wait BRAM for read data
		haddr_s2				<= haddr_s1;																-- Store counter for next stage
		
		-- Stage 3 - Store Character RAM and Attributes RAM results
		haddr_s3				<= haddr_s2;																-- Store counter for next stage
		chr_gen_rom_addr	<= chr_mem_vga_rd_data & vaddr_s1(3 downto 0);					-- Horisontal byte & Vertcal word & Horisontal bit
		gra_gen_rom_addr	<= chr_mem_vga_rd_data & vaddr_s1(3 downto 0);					-- Horisontal byte & Vertcal word & Horisontal bit
		pcg_mem_vga_addr	<= chr_mem_vga_rd_data(6 downto 0) & vaddr_s1(3 downto 0);	-- Horisontal byte & Vertcal word & Horisontal bit
		attr_s3				<= attr_mem_vga_rd_data;												-- Save attributes for next stage
		pcg_sel_s3			<= chr_mem_vga_rd_data(7);												-- Bit 7 of Character Block (was the inverse bit) now becomes PCG Ram selection bit, when normal characters enabled in attribute byte
		
		-- Stage 4 - Wait BRAM for read data
		haddr_s4				<= haddr_s3;																-- Store counter for next stage
		attr_s4				<= attr_s3;																	-- Save attributes for next stage
		pcg_sel_s4			<= pcg_sel_s3;																-- Save selection
		
		-- Stage 5 - Select Source RAM/ROM and Pixel from byte
		haddr_s5				<= haddr_s4;																-- Store counter for next stage
		attr_s5				<= attr_s4;																	-- Save attributes for next stage
		if(attr_s4(1) = '0')then																		-- Attribute bit P - Normal or PCG Character ROM
			if(pcg_sel_s4 = '0')then																	-- Bit 7 of Character Block
				pixel_data	<= chr_gen_rom_data(pixel_addr);										-- Select Character Generator ROM
			else
				pixel_data	<= pcg_mem_vga_rd_data(pixel_addr);									-- Select Programmable Character Generator RAM
			end if;
		else						-- Select Graphics ROM
			pixel_data	<= gra_gen_rom_data(pixel_addr);											-- Select Graphics ROM
		end if;
		
		-- Stage 6 - Apply flashing and Image crop
		
		if((UNSIGNED(haddr_s5) >= TO_UNSIGNED(73*8,10)) or (UNSIGNED(vaddr_s1) >= TO_UNSIGNED(28*16,10)))then	-- 73 symbols * 8 pixels / 28 lines * 16 pixels
		--if((UNSIGNED(haddr_s5) >= TO_UNSIGNED(640,10)) or (UNSIGNED(vaddr_s1) >= TO_UNSIGNED(400,10)))then	-- 80 symbols * 8 pixels / 25 lines * 16 pixels
		
		red_out		<= '0';															-- Black screen
			green_out	<= '0';														-- Black screen
			blue_out		<= '0';														-- Black screen
			
		else																				-- Image area
		
			if((attr_s5(0) = '0') or (flash_toggle = '0'))then				-- Flashing disabled or Direct flashing state
			
				if(pixel_data = '1')then											-- Symbol
					red_out		<= attr_s5(7);										-- Pixel value I bit
					green_out	<= attr_s5(6);										-- Pixel value J bit
					blue_out		<= attr_s5(5);										-- Pixel value K bit
					
				else																		-- Background
					red_out		<= attr_s5(4);										-- Background value L bit
					green_out	<= attr_s5(3);										-- Background value M bit
					blue_out		<= attr_s5(2);										-- Background value N bit
				end if;
				
			else																			-- Flashing active
				red_out		<= attr_s5(4);											-- Background value L bit
				green_out	<= attr_s5(3);											-- Background value M bit
				blue_out		<= attr_s5(2);											-- Background value N bit
			end if;
		end if;
	end if;
end process;

pixel_addr_sel: process(haddr_s4)		-- Translate horisontal address to bit position in RAM/ROM
begin
	case haddr_s4(2 downto 0) is			-- 3 low bits of horisontal counter - address of bit 
		when "000" => pixel_addr <= 7;	-- Left pixel come first
		when "001" => pixel_addr <= 6;
		when "010" => pixel_addr <= 5;
		when "011" => pixel_addr <= 4;
		when "100" => pixel_addr <= 3;
		when "101" => pixel_addr <= 2;
		when "110" => pixel_addr <= 1;
		when "111" => pixel_addr <= 0;	-- Rigth pixel come last
		when others => null;
	end case;
end process;
-------------------------------------------------------------------------------
flash_ctrl: process(clk)	-- Flash counter
begin
	if(clk = '1' and clk'event)then
		if(flash_cnt = C_FLASH_PERIOD)then		-- End if period
			flash_cnt		<= 0;						-- Reset counter
			flash_toggle	<= not flash_toggle;	-- toggle flashing bit
		else
			flash_cnt		<= flash_cnt + 1;		-- Increment counter
		end if;
	end if;
end process;
-------------------------------------------------------------------------------
end IMP;
