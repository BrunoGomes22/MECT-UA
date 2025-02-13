library IEEE;
use IEEE.std_logic_1164.all;
entity register_unit is
    generic (
        WIDTH : integer := 8
    );
    port (
        clock : in std_logic;
        d  : in  std_logic_vector(WIDTH-1 downto 0);
        q  : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity;

architecture behavioral of register_unit is
    signal reg_value : std_logic_vector(WIDTH-1 downto 0);
    begin 
        process(clock)
        begin
            if rising_edge(clock) then
                reg_value <= d;
            end if;
        end process;
        q <= reg_value;
end architecture;