--------------------------------------------------------------------------------
-- Engineer		: Aleksandr Kienko
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
library UNISIM; 
use UNISIM.VCOMPONENTS.ALL; 
--------------------------------------------------------------------------------
entity ram_1Kx8_dp is
port (
	clka		: in  STD_LOGIC;
	wea			: in  STD_LOGIC_VECTOR(0 downto 0);
	addra		: in  STD_LOGIC_VECTOR(9 downto 0);
	dina		: in  STD_LOGIC_VECTOR(7 downto 0);
	douta		: out STD_LOGIC_VECTOR(7 downto 0);
	clkb		: in  STD_LOGIC;
	web			: in  STD_LOGIC_VECTOR(0 downto 0);
	addrb		: in  STD_LOGIC_VECTOR(9 downto 0);
	dinb		: in  STD_LOGIC_VECTOR(7 downto 0);
	doutb		: out STD_LOGIC_VECTOR(7 downto 0)
);
end ram_1Kx8_dp;
-------------------------------------------------------------------------------
architecture IMP of ram_1Kx8_dp is
-------------------------------------------------------------------------------
signal DOADO		: STD_LOGIC_VECTOR(15 downto 0); -- 16-bit A port data/LSB data output
signal DOBDO		: STD_LOGIC_VECTOR(15 downto 0); -- 16-bit B port data/MSB data output
signal ADDRAWRADDR	: STD_LOGIC_VECTOR(12 downto 0); -- 13-bit A port address/Write address input
signal ADDRBRDADDR	: STD_LOGIC_VECTOR(12 downto 0); -- 13-bit B port address/Read address input
signal DIADI		: STD_LOGIC_VECTOR(15 downto 0); -- 16-bit A port data/LSB data input
signal DIBDI		: STD_LOGIC_VECTOR(15 downto 0); -- 16-bit B port data/MSB data input
signal DIPADIP		: STD_LOGIC_VECTOR( 1 downto 0); -- 2-bit A port parity/LSB parity input
signal DIPBDIP		: STD_LOGIC_VECTOR( 1 downto 0); -- 2-bit B port parity/MSB parity input
signal WEAWEL		: STD_LOGIC_VECTOR( 1 downto 0); -- 2-bit A port write enable input
signal WEBWEU		: STD_LOGIC_VECTOR( 1 downto 0); -- 2-bit B port write enable input
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
RAMB8BWER_inst : RAMB8BWER
generic map (
	DATA_WIDTH_A => 9, -- 0, 1, 2, 4, 9, 18, or 36
	DATA_WIDTH_B => 9, -- 0, 1, 2, 4, 9, 18, or 36
	DOA_REG => 0, -- Optional output register on A port (0 or 1)
	DOB_REG => 0, -- Optional output register on B port (0 or 1)
	EN_RSTRAM_A => FALSE, -- Enable/disable A port RST
	EN_RSTRAM_B => FALSE, -- Enable/disable B port RST
	-- INITP_00 to INITP_03: Allows specification of the initial contents of the 1KB parity data memory array.
	INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
	-- INIT_00 to INIT_1F: Allows specification of the initial contents of the 8KB data memory array.
	INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
	INIT_A => X"0000000", -- Initial values on A output port
	INIT_B => X"0000000", -- Initial values on B output port
	INIT_FILE => "NONE", -- File name of file used to specify initial RAM contents. 
	RAM_MODE => "TDP", -- SDP or TDP
	RSTTYPE => "SYNC", -- SYNC or ASYNC
	RST_PRIORITY_A => "CE", -- CE or SR
	RST_PRIORITY_B => "CE", -- CE or SR
	SIM_COLLISION_CHECK => "ALL", -- Collision check enable "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE"
	SRVAL_A => X"0000000", -- Set/Reset value for A port output
	SRVAL_B => X"0000000", -- Set/Reset value for B port output
	WRITE_MODE_A => "WRITE_FIRST", -- "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE"
	WRITE_MODE_B => "WRITE_FIRST" -- "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE"
)
port map (
	DOADO 		=> DOADO, -- 16-bit A port data/LSB data output
	DOBDO 		=> DOBDO, -- 16-bit B port data/MSB data output
	DOPADOP 	=> open, -- 2-bit A port parity/LSB parity output
	DOPBDOP 	=> open, -- 2-bit B port parity/MSB parity output
	ADDRAWRADDR	=> ADDRAWRADDR, -- 13-bit A port address/Write address input
	ADDRBRDADDR => ADDRBRDADDR, -- 13-bit B port address/Read address input
	CLKAWRCLK 	=> clka, -- 1-bit A port clock/Write clock input
	CLKBRDCLK 	=> clkb, -- 1-bit B port clock/Read clock input
	DIADI 		=> DIADI, -- 16-bit A port data/LSB data input
	DIBDI 		=> DIBDI, -- 16-bit B port data/MSB data input
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

ADDRAWRADDR		<= addra & "000"; -- 12:3
ADDRBRDADDR		<= addrb & "000"; -- 12:3
douta			<= DOADO( 7 downto 0);
doutb			<= DOBDO( 7 downto 0);
DIADI			<= x"00" & dina;
DIBDI			<= x"00" & dinb;
-------------------------------------------------------------------------------
end IMP;
