
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity segment_display is
	Port (
		input_digit : in std_logic_vector (3 downto 0);
		segment_info : out std_logic_vector (7 downto 0)
	);
end segment_display;

architecture Behavioral of segment_display is

begin

process (input_digit) begin
	case input_digit is
		when "0000" =>
			segment_info <= "00000011";
			
		when "0001" =>
			segment_info <= "10011111";
			
		when "0010" =>
			segment_info <= "00100101";
			
		when "0011" =>
			segment_info <= "00001101";
			
		when "0100" =>
			segment_info <= "10011001";
			
		when "0101" =>
			segment_info <= "01001001";
			
		when "0110" =>
			segment_info <= "01000001";
			
		when "0111" =>
			segment_info <= "00011111";
			
		when "1000" =>
			segment_info <= "00000001";
			
		when "1001" =>
			segment_info <= "00001001";
			
		when others =>
			segment_info <= "11111111";
			
	end case;
end process;

end Behavioral;
