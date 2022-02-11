--
-- Copyright (C) Doulos Ltd 2001
-- https://www.doulos.com/knowhow/vhdl_designers_guide/models/binary_bcd/
--

library IEEE;
use IEEE.std_logic_1164.all;

entity BCDconv is
  generic (N   : positive := 1);     -- number of digits
  port (Clock  : in std_logic;
        Reset  : in std_logic;
        Init   : in std_logic;  -- initialise conversion
        ModIn  : in std_logic;  -- carry in from outside
        ModOut : out std_logic; -- carry out 
        Q      : out std_logic_vector(4*N -1 downto 0) -- BCD result
       );
end;

architecture RTL of BCDconv is

  component Digit
  port (Clock : in std_logic;
        Reset : in std_logic;
        Init : in std_logic;
        ModIn : in std_logic;
        ModOut : out std_logic;
        Q : out std_logic_vector(3 downto 0)
       );
  end component;

  signal ModVec : std_logic_vector(1 to N+1);

begin

-- The magic of generate!  
g1 : for i in 1 to N generate
  c1: Digit
        port map
        (Clock => Clock,
        Reset => Reset,
        Init => Init,
        ModIn => ModVec(I+1),
        ModOut => ModVec(I),
        Q      => Q(I*4-1 downto I*4-4));
  end generate;
  
  ModOut <= ModVec(1);
  ModVec(N+1) <= ModIn;

end;
 
