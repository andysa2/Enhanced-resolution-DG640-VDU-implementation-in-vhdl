--------------------------------------------------------------------------------
-- Engineer		: Aleksandr Kienko
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
library UNISIM; 
use UNISIM.VCOMPONENTS.ALL; 
--------------------------------------------------------------------------------
entity ram_2Kx8_dp is
port (
	clka		: in  STD_LOGIC;
	wea			: in  STD_LOGIC_VECTOR( 0 downto 0);
	addra		: in  STD_LOGIC_VECTOR(10 downto 0);
	dina		: in  STD_LOGIC_VECTOR( 7 downto 0);
	douta		: out STD_LOGIC_VECTOR( 7 downto 0);
	clkb		: in  STD_LOGIC;
	web			: in  STD_LOGIC_VECTOR( 0 downto 0);
	addrb		: in  STD_LOGIC_VECTOR(10 downto 0);
	dinb		: in  STD_LOGIC_VECTOR( 7 downto 0);
	doutb		: out STD_LOGIC_VECTOR( 7 downto 0)
);
end ram_2Kx8_dp;
-------------------------------------------------------------------------------
architecture IMP of ram_2Kx8_dp is
-------------------------------------------------------------------------------
signal DOADO_L		: STD_LOGIC_VECTOR(15 downto 0); -- 16-bit A port data/LSB data output
signal DOBDO_L		: STD_LOGIC_VECTOR(15 downto 0); -- 16-bit B port data/MSB data output
signal DOADO_H		: STD_LOGIC_VECTOR(15 downto 0); -- 16-bit A port data/LSB data output
signal DOBDO_H		: STD_LOGIC_VECTOR(15 downto 0); -- 16-bit B port data/MSB data output
signal ADDRAWRADDR	: STD_LOGIC_VECTOR(12 downto 0); -- 13-bit A port address/Write address input
signal ADDRBRDADDR	: STD_LOGIC_VECTOR(12 downto 0); -- 13-bit B port address/Read address input
signal DIADI_L		: STD_LOGIC_VECTOR(15 downto 0); -- 16-bit A port data/LSB data input
signal DIBDI_L		: STD_LOGIC_VECTOR(15 downto 0); -- 16-bit B port data/MSB data input
signal DIADI_H		: STD_LOGIC_VECTOR(15 downto 0); -- 16-bit A port data/LSB data input
signal DIBDI_H		: STD_LOGIC_VECTOR(15 downto 0); -- 16-bit B port data/MSB data input
signal DIPADIP		: STD_LOGIC_VECTOR( 1 downto 0); -- 2-bit A port parity/LSB parity input
signal DIPBDIP		: STD_LOGIC_VECTOR( 1 downto 0); -- 2-bit B port parity/MSB parity input
signal WEAWEL		: STD_LOGIC_VECTOR( 1 downto 0); -- 2-bit A port write enable input
signal WEBWEU		: STD_LOGIC_VECTOR( 1 downto 0); -- 2-bit B port write enable input
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
RAMB_L_inst : RAMB8BWER
generic map (
	DATA_WIDTH_A => 4, -- 0, 1, 2, 4, 9, 18, or 36
	DATA_WIDTH_B => 4, -- 0, 1, 2, 4, 9, 18, or 36
	DOA_REG => 0, -- Optional output register on A port (0 or 1)
	DOB_REG => 0, -- Optional output register on B port (0 or 1)
	EN_RSTRAM_A => FALSE, -- Enable/disable A port RST
	EN_RSTRAM_B => FALSE, -- Enable/disable B port RST
	INIT_FILE => "NONE", -- File name of file used to specify initial RAM contents. 
	RAM_MODE => "TDP", -- SDP or TDP
	RSTTYPE => "SYNC", -- SYNC or ASYNC
	RST_PRIORITY_A => "CE", -- CE or SR
	RST_PRIORITY_B => "CE", -- CE or SR
	SIM_COLLISION_CHECK => "ALL", -- Collision check enable "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE"
	WRITE_MODE_A => "WRITE_FIRST", -- "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE"
	WRITE_MODE_B => "WRITE_FIRST" -- "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE"
)
port map (
	DOADO 		=> DOADO_L, -- 16-bit A port data/LSB data output
	DOBDO 		=> DOBDO_L, -- 16-bit B port data/MSB data output
	DOPADOP 	=> open, -- 2-bit A port parity/LSB parity output
	DOPBDOP 	=> open, -- 2-bit B port parity/MSB parity output
	ADDRAWRADDR	=> ADDRAWRADDR, -- 13-bit A port address/Write address input
	ADDRBRDADDR => ADDRBRDADDR, -- 13-bit B port address/Read address input
	CLKAWRCLK 	=> clka, -- 1-bit A port clock/Write clock input
	CLKBRDCLK 	=> clkb, -- 1-bit B port clock/Read clock input
	DIADI 		=> DIADI_L, -- 16-bit A port data/LSB data input
	DIBDI 		=> DIBDI_L, -- 16-bit B port data/MSB data input
	DIPADIP 	=> DIPADIP, -- 2-bit A port parity/LSB parity input
	DIPBDIP 	=> DIPBDIP, -- 2-bit B port parity/MSB parity input
	ENAWREN 	=> '1', -- 1-bit A port enable/Write enable input
	ENBRDEN 	=> '1', -- 1-bit B port enable/Read enable input
	REGCEA 		=> '1', -- 1-bit A port register enable input
	REGCEBREGCE => '1', -- 1-bit B port register enable/Register enable input
	RSTA 		=> '0', -- 1-bit A port set/reset input
	RSTBRST 	=> '0', -- 1-bit B port set/reset input
	WEAWEL 		=> WEAWEL, -- 2-bit A port write enable input
	WEBWEU 		=> WEBWEU -- 2-bit B port write enable input
);

RAMB_H_inst : RAMB8BWER
generic map (
	DATA_WIDTH_A => 4, -- 0, 1, 2, 4, 9, 18, or 36
	DATA_WIDTH_B => 4, -- 0, 1, 2, 4, 9, 18, or 36
	DOA_REG => 0, -- Optional output register on A port (0 or 1)
	DOB_REG => 0, -- Optional output register on B port (0 or 1)
	EN_RSTRAM_A => FALSE, -- Enable/disable A port RST
	EN_RSTRAM_B => FALSE, -- Enable/disable B port RST
	INIT_FILE => "NONE", -- File name of file used to specify initial RAM contents. 
	RAM_MODE => "TDP", -- SDP or TDP
	RSTTYPE => "SYNC", -- SYNC or ASYNC
	RST_PRIORITY_A => "CE", -- CE or SR
	RST_PRIORITY_B => "CE", -- CE or SR
	SIM_COLLISION_CHECK => "ALL", -- Collision check enable "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE"
	WRITE_MODE_A => "WRITE_FIRST", -- "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE"
	WRITE_MODE_B => "WRITE_FIRST" -- "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE"
)
port map (
	DOADO 		=> DOADO_H, -- 16-bit A port data/LSB data output
	DOBDO 		=> DOBDO_H, -- 16-bit B port data/MSB data output
	DOPADOP 	=> open, -- 2-bit A port parity/LSB parity output
	DOPBDOP 	=> open, -- 2-bit B port parity/MSB parity output
	ADDRAWRADDR	=> ADDRAWRADDR, -- 13-bit A port address/Write address input
	ADDRBRDADDR => ADDRBRDADDR, -- 13-bit B port address/Read address input
	CLKAWRCLK 	=> clka, -- 1-bit A port clock/Write clock input
	CLKBRDCLK 	=> clkb, -- 1-bit B port clock/Read clock input
	DIADI 		=> DIADI_H, -- 16-bit A port data/LSB data input
	DIBDI 		=> DIBDI_H, -- 16-bit B port data/MSB data input
	DIPADIP 	=> DIPADIP, -- 2-bit A port parity/LSB parity input
	DIPBDIP 	=> DIPBDIP, -- 2-bit B port parity/MSB parity input
	ENAWREN 	=> '1', -- 1-bit A port enable/Write enable input
	ENBRDEN 	=> '1', -- 1-bit B port enable/Read enable input
	REGCEA 		=> '1', -- 1-bit A port register enable input
	REGCEBREGCE => '1', -- 1-bit B port register enable/Register enable input
	RSTA 		=> '0', -- 1-bit A port set/reset input
	RSTBRST 	=> '0', -- 1-bit B port set/reset input
	WEAWEL 		=> WEAWEL, -- 2-bit A port write enable input
	WEBWEU 		=> WEBWEU -- 2-bit B port write enable input
);


DIPADIP		<= (others => '0'); -- 2-bit A port parity/LSB parity input
DIPBDIP		<= (others => '0'); -- 2-bit B port parity/MSB parity input

WEAWEL			<= '0' & wea(0);
WEBWEU			<= '0' & web(0);

ADDRAWRADDR		<= addra & "00"; -- 12:2
ADDRBRDADDR		<= addrb & "00"; -- 12:2
douta			<= DOADO_H( 3 downto 0) & DOADO_L( 3 downto 0);
doutb			<= DOBDO_H( 3 downto 0) & DOBDO_L( 3 downto 0);
DIADI_L			<= x"000" & dina(3 downto 0);
DIADI_H			<= x"000" & dina(7 downto 4);
DIBDI_L			<= x"000" & dinb(3 downto 0);
DIBDI_H			<= x"000" & dinb(7 downto 4);
-------------------------------------------------------------------------------
end IMP;
