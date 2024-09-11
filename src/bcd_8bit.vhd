

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity bcd_8bit is
	Port (
		B: in std_logic_vector (7 downto 0);
		P: out std_logic_vector (9 downto 0)
	);
end bcd_8bit;

architecture Behavioral of bcd_8bit is
begin

bcd1: process(B)
	variable z: std_logic_vector (17 downto 0);
	begin
		for i in 0 to 17 loop
			z(i) := '0';
		end loop;
		z(10 downto 3) := B;
	
		for i in 0 to 4 loop
			if z(11 downto 8) > 4 then
				z(11 downto 8) := z(11 downto 8) + 3;
			end if;
			if z(15 downto 12) > 4 then
				z(15 downto 12) := z(15 downto 12) + 3;
			end if;
			z(17 downto 1) := z(16 downto 0);
		end loop;
	
		P <= z(17 downto 8);
		
	end process bcd1;
end Behavioral;
