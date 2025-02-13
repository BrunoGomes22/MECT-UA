library IEEE;
use IEEE.std_logic_1164.all;

entity shift_slice is
    generic
    (
        DATA_BITS    : integer range 1 to 32 := 4;
        SHIFT_AMOUNT : integer range 1 to 32 := 8
    );
    port(
        data_in : in std_logic_vector(DATA_BITS-1 downto 0);
        data_out: out std_logic_vector(DATA_BITS-1 downto 0);
        sel     : in std_logic
    );
end shift_slice;

architecture behavioral of shift_slice is
begin
    assert (SHIFT_AMOUNT < DATA_BITS) report "Bad SHIFT_AMOUNT generic value" severity failure;
    process(data_in, sel) is
        begin
            if sel = '0' then
                data_out <= data_in;
            else
                if SHIFT_AMOUNT < DATA_BITS then
                    data_out <= data_in(DATA_BITS-SHIFT_AMOUNT-1 downto 0) & (SHIFT_AMOUNT-1 downto 0 => '0');
                else
                    data_out <= (others => '0');
                end if;
            end if;
        end process;
end behavioral;