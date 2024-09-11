library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.round;

entity servo_controller is
	generic (
		clk_freq : real := 100_000_000.0;
		pulse_freq : real := 50.0;
		min_pulse_us : real:= 500.0;
		max_pulse_us : real:= 2500.0;
		step_count : positive := 128
	);
	Port (
		clk : in std_logic;
		rst : in std_logic;
		position : in integer range 0 to step_count - 1;
		
		pwm : out std_logic
	);
end servo_controller;

architecture Behavioral of servo_controller is
	function cycles_per_us (us_count : real) return integer is
	begin
		return integer(round((clk_freq / 1_000_000.0) * us_count));
	end function;
	
	constant min_count : integer := cycles_per_us(min_pulse_us);
	constant max_count : integer := cycles_per_us(max_pulse_us);
	
	
	constant min_max_range_us : real := max_pulse_us - min_pulse_us;
	constant step_us : real := min_max_range_us / real(step_count - 1);
	constant cycles_per_step : positive := cycles_per_us(step_us);
	
	constant counter_max : integer := integer(round(clk_freq / pulse_freq)) - 1;
	signal counter : integer range 0 to counter_max := 0;
  
	signal duty_cycle : integer range 0 to max_count:= 0;
	
begin
	PWM_PROC : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				pwm <= '0';
				counter <= 0;
			end if;
			
			if (counter < counter_max) then
				if (counter < duty_cycle) then
					pwm <= '1';
				else 
					pwm <= '0';
				end if;
				counter <= counter + 1;
			else
				counter <= 0;
			end if;
		end if;
	end process;
	
	DUTY_CYCLE_PROC	: process(clk)
	begin 
		if rising_edge(clk) then
			if rst = '1' then
				duty_cycle <= min_count;
			else
				duty_cycle <= position * cycles_per_step + min_count;
			end if;
		end if;
	end process;
end Behavioral;
