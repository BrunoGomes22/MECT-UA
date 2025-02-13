library IEEE;
use IEEE.std_logic_1164.all;

entity barrel_shifter is
    generic (
        DATA_BITS : integer range 1 to 32 := 8
    );
    port (
        data_in  : in  std_logic_vector(DATA_BITS-1 downto 0);
        shift    : in  std_logic_vector(2 downto 0);
        data_out : out std_logic_vector(DATA_BITS-1 downto 0)
    );
end barrel_shifter;

architecture structural of barrel_shifter is
    signal stage0, stage1, stage2 : std_logic_vector(DATA_BITS-1 downto 0);
begin
    -- Shift by 1
    shift1: entity work.shift_slice
        generic map (
            DATA_BITS    => DATA_BITS,
            SHIFT_AMOUNT => 1
        )
        port map (
            data_in  => data_in,
            data_out => stage0,
            sel      => shift(0)
        );

    -- Shift by 2
    shift2: entity work.shift_slice
        generic map (
            DATA_BITS    => DATA_BITS,
            SHIFT_AMOUNT => 2
        )
        port map (
            data_in  => stage0,
            data_out => stage1,
            sel      => shift(1)
        );

    -- Shift by 4
    shift4: entity work.shift_slice
        generic map (
            DATA_BITS    => DATA_BITS,
            SHIFT_AMOUNT => 4
        )
        port map (
            data_in  => stage1,
            data_out => stage2,
            sel      => shift(2)
        );

    data_out <= stage2;
end structural;