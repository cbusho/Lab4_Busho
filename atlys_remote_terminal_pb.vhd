----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:56:03 03/13/2014 
-- Design Name: 
-- Module Name:    atlys_remote_terminal_pb - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity atlys_remote_terminal_pb is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           serial_in : in  STD_LOGIC;
           serial_out : out  STD_LOGIC;
           switch : in  STD_LOGIC_VECTOR (7 downto 0);
           led : out  STD_LOGIC_VECTOR (7 downto 0));
end atlys_remote_terminal_pb;

architecture Behavioral of atlys_remote_terminal_pb is

  component kcpsm6 
    generic(                 hwbuild : std_logic_vector(7 downto 0) := X"00";
                    interrupt_vector : std_logic_vector(11 downto 0) := X"3FF";
             scratch_pad_memory_size : integer := 64);
    port (                   address : out std_logic_vector(11 downto 0);
                         instruction : in std_logic_vector(17 downto 0);
                         bram_enable : out std_logic;
                             in_port : in std_logic_vector(7 downto 0);
                            out_port : out std_logic_vector(7 downto 0);
                             port_id : out std_logic_vector(7 downto 0);
                        write_strobe : out std_logic;
                      k_write_strobe : out std_logic;
                         read_strobe : out std_logic;
                           interrupt : in std_logic;
                       interrupt_ack : out std_logic;
                               sleep : in std_logic;
                               reset : in std_logic;
                                 clk : in std_logic);
  end component;
  
  component Custom_ROM                         
    generic(             C_FAMILY : string := "S6"; 
                C_RAM_SIZE_KWORDS : integer := 1;
             C_JTAG_LOADER_ENABLE : integer := 0);
    Port (      address : in std_logic_vector(11 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                 enable : in std_logic;
                    rdl : out std_logic;                    
                    clk : in std_logic);
  end component;
  
  COMPONENT uart_tx6
	PORT(
		data_in : IN std_logic_vector(7 downto 0);
		en_16_x_baud : IN std_logic;
		buffer_write : IN std_logic;
		buffer_reset : IN std_logic;
		clk : IN std_logic;          
		serial_out : OUT std_logic;
		buffer_data_present : OUT std_logic;
		buffer_half_full : OUT std_logic;
		buffer_full : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT uart_rx6
	PORT(
		serial_in : IN std_logic;
		en_16_x_baud : IN std_logic;
		buffer_read : IN std_logic;
		buffer_reset : IN std_logic;
		clk : IN std_logic;          
		data_out : OUT std_logic_vector(7 downto 0);
		buffer_data_present : OUT std_logic;
		buffer_half_full : OUT std_logic;
		buffer_full : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT clk_to_baud
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		baud_16x_en : OUT std_logic
		);
	END COMPONENT;

-- Signals for connection of KCPSM6 and Program Memory.
--

signal         address : std_logic_vector(11 downto 0);
signal     instruction : std_logic_vector(17 downto 0);
signal     bram_enable : std_logic;
signal         in_port : std_logic_vector(7 downto 0);
signal        out_port : std_logic_vector(7 downto 0);
signal         port_id : std_logic_vector(7 downto 0);
signal    write_strobe : std_logic;
signal  k_write_strobe : std_logic;
signal     read_strobe : std_logic;
signal       interrupt : std_logic;
signal   interrupt_ack : std_logic;
signal    kcpsm6_sleep : std_logic;
signal    kcpsm6_reset : std_logic;
signal serial, baud, buf_read, buf_write, buf_data, buf_half, buf_full, buff_reset: std_logic;
signal data, data_in_pico, data_out_pico: std_logic_vector(7 downto 0);
signal switch1, switch2: std_logic_vector(7 downto 0);
signal switcher1, switcher2: std_logic_vector(7 downto 0);

signal leds, led_output: std_logic_vector(7 downto 0);
signal num_result, letter_result: unsigned(7 downto 0);
signal leds_next1, leds_next2 : std_logic_vector(3 downto 0);

begin
	
	switcher1 <= "0000" & switch(7 downto 4);
	switcher2 <= "0000" & switch(3 downto 0);
	switch1 <= std_logic_vector(unsigned(switcher1) + X"30") when switcher1 <= "00001001" else
				  std_logic_vector(unsigned(switcher1) + X"57");
	switch2 <= std_logic_vector(unsigned(switcher2) + X"30") when switcher2 <= "00001001" else
				  std_logic_vector(unsigned(switcher2) + X"57");	

	num_result <= unsigned(out_port) - X"30";
	letter_result <= unsigned(out_port) - X"57";
	
	led_output <=  std_logic_vector(num_result) when num_result >= X"0" 
						and num_result <= X"9" else
						std_logic_vector(letter_result) when letter_result >= X"A"
						and letter_result <= X"F" else
						"00000000";
						
	process(clk, port_id)
	begin
		if(rising_edge(clk)) then
			if (reset = '1') then
				leds_next1 <= "0000";
			else
				if (port_id = X"06") then
					leds_next1 <= led_output(3 downto 0);
				end if;
			end if;
		end if;	
	end process;	

	process(clk, port_id)
	begin
		if(rising_edge(clk)) then
			if (reset = '1') then
				leds_next2 <= "0000";
			else
				if (port_id = X"05") then
					leds_next2 <= led_output(3 downto 0);
				end if;
			end if;
		end if;	
	end process;			
			
	
	led <= leds;
	leds <= leds_next1 & leds_next2;
						
processor: kcpsm6
    generic map (                 hwbuild => X"00", 
                         interrupt_vector => X"3FF",
                  scratch_pad_memory_size => 64)
    port map(      address => address,
               instruction => instruction,
               bram_enable => bram_enable,
                   port_id => port_id,
              write_strobe => write_strobe,
            k_write_strobe => k_write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     sleep => kcpsm6_sleep,
                     reset => kcpsm6_reset,
                       clk => clk);
	
	
	process(clk)
	begin
		if rising_edge(clk) then
			case port_id is
				when X"AF" => in_port <= data_in_pico;
				when X"AE" => in_port <= data_in_pico;
				when X"AD" => in_port <= data_in_pico;
				when X"AC" => in_port <= switch1;
				when X"AB" => in_port <= switch2;
				when X"07" => in_port <= "0000000" & buf_data;
				when others => in_port <= "00000000";
			end case;
		end if;
	end process;

  kcpsm6_sleep <= '0';
  interrupt <= interrupt_ack;
  
  program_rom: Custom_ROM                  --Name to match your PSM file
    generic map(             C_FAMILY => "S6",   --Family 'S6', 'V6' or '7S'
                    C_RAM_SIZE_KWORDS => 1,      --Program size '1', '2' or '4'
                 C_JTAG_LOADER_ENABLE => 1)      --Include JTAG Loader when set to '1' 
    port map(      address => address,      
               instruction => instruction,
                    enable => bram_enable,
                       rdl => kcpsm6_reset,
                       clk => clk);
							  
	Inst_uart_rx6: uart_rx6 PORT MAP(
		serial_in => serial_in,
		en_16_x_baud => baud,
		data_out => data_in_pico,
		buffer_read => buf_read, 
		buffer_data_present => buf_data,
		buffer_half_full => open,
		buffer_full => open,
		buffer_reset => reset,
		clk => clk
	);
		
	buf_read <= 	'1' when (port_id = X"AF" and read_strobe = '1') else
						'1' when (port_id = X"AE" and read_strobe = '1') else
						'1' when (port_id = X"AD" and read_strobe = '1') else
						'1' when (port_id = X"AC" and read_strobe = '1') else
						'1' when (port_id = X"AB" and read_strobe = '1') else
						'0';	
	buf_write <= 	'1' when (port_id = X"05" and write_strobe = '1') else
						'1' when (port_id = X"06" and write_strobe = '1') else
						'1' when (port_id = X"07" and write_strobe = '1') else
						'1' when (port_id = X"08" and write_strobe = '1') else
						'1' when (port_id = X"09" and write_strobe = '1') else
						'0';	
		
	Inst_uart_tx6: uart_tx6 PORT MAP(
		data_in => out_port,
		en_16_x_baud => baud,
		serial_out => serial_out,
		buffer_write => buf_write,
		buffer_data_present => open,
		buffer_half_full => open,
		buffer_full => open,
		buffer_reset => reset,
		clk => clk	
	);
	
	Inst_clk_to_baud: clk_to_baud PORT MAP(
		clk => clk,
		reset => reset,
		baud_16x_en => baud
	);

	
end Behavioral;

