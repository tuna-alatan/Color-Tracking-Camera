library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_module_final is
	Port (
		clk_in				: in std_logic;
		uart_rx_in			: in std_logic;
		rst_in				: in std_logic;
		set_in				: in std_logic;
		
		
		set_out				: out std_logic;
		rx_done_tick_out	: out std_logic;
		servo_out			: out std_logic;
		
		seven_seg_out		: out std_logic_vector(7 downto 0);
		anodes_out			: out std_logic_vector(3 downto 0)
	);
end top_module_final;

architecture Behavioral of top_module_final is

component servo_controller is
	generic (
		clk_freq		: real := 100_000_000.0;
		pulse_freq		: real := 50.0;
		min_pulse_us	: real:= 500.0;
		max_pulse_us	: real:= 2500.0;
		step_count		: positive := 128
	);
	Port (
		clk			: in std_logic;
		rst			: in std_logic;
		position	: in integer range 0 to step_count - 1;
		
		pwm : out std_logic
	);
end component;

component uart_rx is
	generic (
		c_clkfreq		: integer := 100_000_000;
		c_baudrate		: integer := 115_200
	);
	port (
		clk				: in std_logic;
		rx_i			: in std_logic;
		dout_o			: out std_logic_vector (7 downto 0);
		rx_done_tick_o	: out std_logic
);
end component;

component bcd_8bit is
	Port (
		B: in std_logic_vector (7 downto 0);
		P: out std_logic_vector (9 downto 0)
	);
end component;

component segment_display is
	Port (
		input_digit : in std_logic_vector (3 downto 0);
		segment_info : out std_logic_vector (7 downto 0)
	);
end component;


constant STEP_COUNT : integer := 180;
signal s_position 	: integer range 0 to STEP_COUNT - 1;
signal s_data_out 	: std_logic_vector(7 downto 0) := (others => '0');
signal s_rst_uart 	: std_logic := '0';

signal anodes : std_logic_vector (3 downto 0) := "1110" ;

constant clk_freq 		: integer := 100_000_000;
constant timer_1ms_lim	: integer := clk_freq / 1000; 
signal timer_1ms		: integer range 0 to timer_1ms_lim := 0;

signal s_bdc_conv : std_logic_vector(9 downto 0) := (others => '0');

signal first_dig_info		: std_logic_vector(3 downto 0) := (others => '0');
signal second_dig_info		: std_logic_vector(3 downto 0) := (others => '0');
signal third_dig_info		: std_logic_vector(3 downto 0) := (others => '0');

signal first_seg_signal		: std_logic_vector(7 downto 0) := (others => '0');
signal second_seg_signal	: std_logic_vector(7 downto 0) := (others => '0');
signal third_seg_signal		: std_logic_vector(7 downto 0) := (others => '0');


begin

inst_servo_controller : servo_controller
	generic map(
		clk_freq		=> 100_000_000.0,
		pulse_freq		=> 50.0,
		min_pulse_us	=> 500.0,
		max_pulse_us	=> 2500.0,
		step_count		=> STEP_COUNT
	)
	Port map(
		clk			=> clk_in,
		rst			=> rst_in,
		position	=> s_position,
		
		pwm => servo_out
	);
	
inst_uart_rx : uart_rx
	generic map(
			c_clkfreq		=> 100_000_000,
			c_baudrate		=> 115_200
		)
		
	port map(
			clk				=> clk_in,
			rx_i			=> uart_rx_in,
			dout_o			=> s_data_out,
			rx_done_tick_o	=> rx_done_tick_out
	);
	
inst_bcd_8bit : bcd_8bit
	port map(
		B => std_logic_vector(to_unsigned(s_position, 8)),
		P => s_bdc_conv
	);
	
inst_segment_display_first : segment_display
	port map(
		input_digit		=> first_dig_info,
		segment_info	=> first_seg_signal
	);
	
inst_segment_display_second : segment_display
	port map(
		input_digit		=> second_dig_info,
		segment_info	=> second_seg_signal
	);
	
inst_segment_display_third : segment_display
	port map(
		input_digit		=> third_dig_info,
		segment_info	=> third_seg_signal
	);
	
p_main : process begin
	first_dig_info  <= s_bdc_conv(3 downto 0);
	second_dig_info <= s_bdc_conv(7 downto 4);
	third_dig_info  <= "00" & s_bdc_conv(9 downto 8);
	
	if (set_in = '1') then
		s_position <= 90;
		set_out <= '0';
	else
		s_position <= to_integer(unsigned(s_data_out));
		set_out <= '1';
	end if;
end process p_main;

anode_process : process (clk_in) begin
	if (rising_edge(clk_in)) then
	
		anodes(3) <= '1';
	
		if (timer_1ms = timer_1ms_lim - 1) then
			timer_1ms <= 0;
			anodes(2 downto 1) <= anodes(1 downto 0);
			anodes(0) <= anodes(2);
		else
			timer_1ms <= timer_1ms + 1;
		end if;
	
	end if;
end process;

cathode_process : process (clk_in) begin
	if (rising_edge(clk_in)) then

		if (anodes(0) = '0') then
			seven_seg_out <= first_seg_signal;
		elsif (anodes(1) = '0') then
			seven_seg_out <= second_seg_signal;
		elsif (anodes(2) = '0') then
			seven_seg_out <= third_seg_signal;
		else
			seven_seg_out <= (others => '1');
		end if;
	end if;	
end process;	

anodes_out <= anodes;

end Behavioral;
