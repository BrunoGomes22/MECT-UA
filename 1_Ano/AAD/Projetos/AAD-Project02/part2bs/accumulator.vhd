library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity accumulator is
    generic (
        ADDR_BITS : integer range 2 to 8 := 4;
        DATA_BITS_LOG2 : integer range 2 to 5 := 3
    );
    port (
        clock       : in  std_logic;
        write_addr  : in  std_logic_vector(ADDR_BITS-1 downto 0);
        write_inc   : in  std_logic_vector((2**DATA_BITS_LOG2)-1 downto 0);
        write_shift : in  std_logic_vector(2 downto 0);
        read_addr   : in  std_logic_vector(ADDR_BITS-1 downto 0);
        read_data   : out std_logic_vector((2**DATA_BITS_LOG2)-1 downto 0)
    );
end accumulator;

architecture structural of accumulator is
    constant DATA_BITS : integer := 2**DATA_BITS_LOG2;
    signal s_aux_read_data           : std_logic_vector(DATA_BITS-1 downto 0) := (others => '0');
    signal s_value_to_write          : std_logic_vector(DATA_BITS-1 downto 0) := (others => '0');
    signal s_value_to_write_pipe     : std_logic_vector(DATA_BITS-1 downto 0) := (others => '0');
    signal s_write_addr_pipe         : std_logic_vector(ADDR_BITS-1 downto 0) := (others => '0');
    signal s_shifted_inc       : std_logic_vector(DATA_BITS-1 downto 0) := (others => '0');
    begin

    barrel_shifter_inst: entity work.barrel_shifter
        generic map (
            DATA_BITS => DATA_BITS
        )
        port map (
            data_in  => write_inc,
            shift    => write_shift,
            data_out => s_shifted_inc
        );

    register_data: entity work.register_unit
        generic map (
            WIDTH => DATA_BITS
        )
        port map (
            clock  => clock,
            d => s_value_to_write,
            q => s_value_to_write_pipe
        );

    write_addr_pipeline: entity work.register_unit
        generic map (
            WIDTH => ADDR_BITS
        )
        port map (
            clock  => clock,
            d => write_addr,
            q => s_write_addr_pipe
        );

    ram_inst: entity work.triple_port_ram
        generic map (
            ADDR_BITS => ADDR_BITS,
            DATA_BITS => DATA_BITS
        )
        port map (
            clock        => clock,
            write_data   => s_value_to_write_pipe,
            read_addr    => read_addr,
            read_data    => read_data,
            write_addr   => s_write_addr_pipe,
            aux_read_addr => write_addr,
            aux_read_data => s_aux_read_data,
            aux_forwarded_write_data => s_value_to_write
        );

    adder_inst: entity work.addr_n
        generic map (
            N => DATA_BITS
        )
        port map (
            c_in  => '0',
            a     => s_shifted_inc,
            b     => s_aux_read_data,
            s     => s_value_to_write,
            c_out => open
        );
end structural;