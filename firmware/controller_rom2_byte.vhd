
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"00",x"07",x"0f",x"79"),
     1 => (x"49",x"7f",x"36",x"00"),
     2 => (x"00",x"36",x"7f",x"49"),
     3 => (x"49",x"4f",x"06",x"00"),
     4 => (x"00",x"1e",x"3f",x"69"),
     5 => (x"66",x"00",x"00",x"00"),
     6 => (x"00",x"00",x"00",x"66"),
     7 => (x"e6",x"80",x"00",x"00"),
     8 => (x"00",x"00",x"00",x"66"),
     9 => (x"14",x"08",x"08",x"00"),
    10 => (x"00",x"22",x"22",x"14"),
    11 => (x"14",x"14",x"14",x"00"),
    12 => (x"00",x"14",x"14",x"14"),
    13 => (x"14",x"22",x"22",x"00"),
    14 => (x"00",x"08",x"08",x"14"),
    15 => (x"51",x"03",x"02",x"00"),
    16 => (x"00",x"06",x"0f",x"59"),
    17 => (x"5d",x"41",x"7f",x"3e"),
    18 => (x"00",x"1e",x"1f",x"55"),
    19 => (x"09",x"7f",x"7e",x"00"),
    20 => (x"00",x"7e",x"7f",x"09"),
    21 => (x"49",x"7f",x"7f",x"00"),
    22 => (x"00",x"36",x"7f",x"49"),
    23 => (x"63",x"3e",x"1c",x"00"),
    24 => (x"00",x"41",x"41",x"41"),
    25 => (x"41",x"7f",x"7f",x"00"),
    26 => (x"00",x"1c",x"3e",x"63"),
    27 => (x"49",x"7f",x"7f",x"00"),
    28 => (x"00",x"41",x"41",x"49"),
    29 => (x"09",x"7f",x"7f",x"00"),
    30 => (x"00",x"01",x"01",x"09"),
    31 => (x"41",x"7f",x"3e",x"00"),
    32 => (x"00",x"7a",x"7b",x"49"),
    33 => (x"08",x"7f",x"7f",x"00"),
    34 => (x"00",x"7f",x"7f",x"08"),
    35 => (x"7f",x"41",x"00",x"00"),
    36 => (x"00",x"00",x"41",x"7f"),
    37 => (x"40",x"60",x"20",x"00"),
    38 => (x"00",x"3f",x"7f",x"40"),
    39 => (x"1c",x"08",x"7f",x"7f"),
    40 => (x"00",x"41",x"63",x"36"),
    41 => (x"40",x"7f",x"7f",x"00"),
    42 => (x"00",x"40",x"40",x"40"),
    43 => (x"0c",x"06",x"7f",x"7f"),
    44 => (x"00",x"7f",x"7f",x"06"),
    45 => (x"0c",x"06",x"7f",x"7f"),
    46 => (x"00",x"7f",x"7f",x"18"),
    47 => (x"41",x"7f",x"3e",x"00"),
    48 => (x"00",x"3e",x"7f",x"41"),
    49 => (x"09",x"7f",x"7f",x"00"),
    50 => (x"00",x"06",x"0f",x"09"),
    51 => (x"61",x"41",x"7f",x"3e"),
    52 => (x"00",x"40",x"7e",x"7f"),
    53 => (x"09",x"7f",x"7f",x"00"),
    54 => (x"00",x"66",x"7f",x"19"),
    55 => (x"4d",x"6f",x"26",x"00"),
    56 => (x"00",x"32",x"7b",x"59"),
    57 => (x"7f",x"01",x"01",x"00"),
    58 => (x"00",x"01",x"01",x"7f"),
    59 => (x"40",x"7f",x"3f",x"00"),
    60 => (x"00",x"3f",x"7f",x"40"),
    61 => (x"70",x"3f",x"0f",x"00"),
    62 => (x"00",x"0f",x"3f",x"70"),
    63 => (x"18",x"30",x"7f",x"7f"),
    64 => (x"00",x"7f",x"7f",x"30"),
    65 => (x"1c",x"36",x"63",x"41"),
    66 => (x"41",x"63",x"36",x"1c"),
    67 => (x"7c",x"06",x"03",x"01"),
    68 => (x"01",x"03",x"06",x"7c"),
    69 => (x"4d",x"59",x"71",x"61"),
    70 => (x"00",x"41",x"43",x"47"),
    71 => (x"7f",x"7f",x"00",x"00"),
    72 => (x"00",x"00",x"41",x"41"),
    73 => (x"0c",x"06",x"03",x"01"),
    74 => (x"40",x"60",x"30",x"18"),
    75 => (x"41",x"41",x"00",x"00"),
    76 => (x"00",x"00",x"7f",x"7f"),
    77 => (x"03",x"06",x"0c",x"08"),
    78 => (x"00",x"08",x"0c",x"06"),
    79 => (x"80",x"80",x"80",x"80"),
    80 => (x"00",x"80",x"80",x"80"),
    81 => (x"03",x"00",x"00",x"00"),
    82 => (x"00",x"00",x"04",x"07"),
    83 => (x"54",x"74",x"20",x"00"),
    84 => (x"00",x"78",x"7c",x"54"),
    85 => (x"44",x"7f",x"7f",x"00"),
    86 => (x"00",x"38",x"7c",x"44"),
    87 => (x"44",x"7c",x"38",x"00"),
    88 => (x"00",x"00",x"44",x"44"),
    89 => (x"44",x"7c",x"38",x"00"),
    90 => (x"00",x"7f",x"7f",x"44"),
    91 => (x"54",x"7c",x"38",x"00"),
    92 => (x"00",x"18",x"5c",x"54"),
    93 => (x"7f",x"7e",x"04",x"00"),
    94 => (x"00",x"00",x"05",x"05"),
    95 => (x"a4",x"bc",x"18",x"00"),
    96 => (x"00",x"7c",x"fc",x"a4"),
    97 => (x"04",x"7f",x"7f",x"00"),
    98 => (x"00",x"78",x"7c",x"04"),
    99 => (x"3d",x"00",x"00",x"00"),
   100 => (x"00",x"00",x"40",x"7d"),
   101 => (x"80",x"80",x"80",x"00"),
   102 => (x"00",x"00",x"7d",x"fd"),
   103 => (x"10",x"7f",x"7f",x"00"),
   104 => (x"00",x"44",x"6c",x"38"),
   105 => (x"3f",x"00",x"00",x"00"),
   106 => (x"00",x"00",x"40",x"7f"),
   107 => (x"18",x"0c",x"7c",x"7c"),
   108 => (x"00",x"78",x"7c",x"0c"),
   109 => (x"04",x"7c",x"7c",x"00"),
   110 => (x"00",x"78",x"7c",x"04"),
   111 => (x"44",x"7c",x"38",x"00"),
   112 => (x"00",x"38",x"7c",x"44"),
   113 => (x"24",x"fc",x"fc",x"00"),
   114 => (x"00",x"18",x"3c",x"24"),
   115 => (x"24",x"3c",x"18",x"00"),
   116 => (x"00",x"fc",x"fc",x"24"),
   117 => (x"04",x"7c",x"7c",x"00"),
   118 => (x"00",x"08",x"0c",x"04"),
   119 => (x"54",x"5c",x"48",x"00"),
   120 => (x"00",x"20",x"74",x"54"),
   121 => (x"7f",x"3f",x"04",x"00"),
   122 => (x"00",x"00",x"44",x"44"),
   123 => (x"40",x"7c",x"3c",x"00"),
   124 => (x"00",x"7c",x"7c",x"40"),
   125 => (x"60",x"3c",x"1c",x"00"),
   126 => (x"00",x"1c",x"3c",x"60"),
   127 => (x"30",x"60",x"7c",x"3c"),
   128 => (x"00",x"3c",x"7c",x"60"),
   129 => (x"10",x"38",x"6c",x"44"),
   130 => (x"00",x"44",x"6c",x"38"),
   131 => (x"e0",x"bc",x"1c",x"00"),
   132 => (x"00",x"1c",x"3c",x"60"),
   133 => (x"74",x"64",x"44",x"00"),
   134 => (x"00",x"44",x"4c",x"5c"),
   135 => (x"3e",x"08",x"08",x"00"),
   136 => (x"00",x"41",x"41",x"77"),
   137 => (x"7f",x"00",x"00",x"00"),
   138 => (x"00",x"00",x"00",x"7f"),
   139 => (x"77",x"41",x"41",x"00"),
   140 => (x"00",x"08",x"08",x"3e"),
   141 => (x"03",x"01",x"01",x"02"),
   142 => (x"00",x"01",x"02",x"02"),
   143 => (x"7f",x"7f",x"7f",x"7f"),
   144 => (x"00",x"7f",x"7f",x"7f"),
   145 => (x"1c",x"1c",x"08",x"08"),
   146 => (x"7f",x"7f",x"3e",x"3e"),
   147 => (x"3e",x"3e",x"7f",x"7f"),
   148 => (x"08",x"08",x"1c",x"1c"),
   149 => (x"7c",x"18",x"10",x"00"),
   150 => (x"00",x"10",x"18",x"7c"),
   151 => (x"7c",x"30",x"10",x"00"),
   152 => (x"00",x"10",x"30",x"7c"),
   153 => (x"60",x"60",x"30",x"10"),
   154 => (x"00",x"06",x"1e",x"78"),
   155 => (x"18",x"3c",x"66",x"42"),
   156 => (x"00",x"42",x"66",x"3c"),
   157 => (x"c2",x"6a",x"38",x"78"),
   158 => (x"00",x"38",x"6c",x"c6"),
   159 => (x"60",x"00",x"00",x"60"),
   160 => (x"00",x"60",x"00",x"00"),
   161 => (x"5c",x"5b",x"5e",x"0e"),
   162 => (x"86",x"fc",x"0e",x"5d"),
   163 => (x"f4",x"c2",x"7e",x"71"),
   164 => (x"c0",x"4c",x"bf",x"d0"),
   165 => (x"c4",x"1e",x"c0",x"4b"),
   166 => (x"c4",x"02",x"ab",x"66"),
   167 => (x"c2",x"4d",x"c0",x"87"),
   168 => (x"75",x"4d",x"c1",x"87"),
   169 => (x"ee",x"49",x"73",x"1e"),
   170 => (x"86",x"c8",x"87",x"e1"),
   171 => (x"ef",x"49",x"e0",x"c0"),
   172 => (x"a4",x"c4",x"87",x"ea"),
   173 => (x"f0",x"49",x"6a",x"4a"),
   174 => (x"c8",x"f1",x"87",x"f1"),
   175 => (x"c1",x"84",x"cc",x"87"),
   176 => (x"ab",x"b7",x"c8",x"83"),
   177 => (x"87",x"cd",x"ff",x"04"),
   178 => (x"4d",x"26",x"8e",x"fc"),
   179 => (x"4b",x"26",x"4c",x"26"),
   180 => (x"71",x"1e",x"4f",x"26"),
   181 => (x"d4",x"f4",x"c2",x"4a"),
   182 => (x"d4",x"f4",x"c2",x"5a"),
   183 => (x"49",x"78",x"c7",x"48"),
   184 => (x"26",x"87",x"e1",x"fe"),
   185 => (x"1e",x"73",x"1e",x"4f"),
   186 => (x"b7",x"c0",x"4a",x"71"),
   187 => (x"87",x"d3",x"03",x"aa"),
   188 => (x"bf",x"c0",x"d9",x"c2"),
   189 => (x"c1",x"87",x"c4",x"05"),
   190 => (x"c0",x"87",x"c2",x"4b"),
   191 => (x"c4",x"d9",x"c2",x"4b"),
   192 => (x"c2",x"87",x"c4",x"5b"),
   193 => (x"fc",x"5a",x"c4",x"d9"),
   194 => (x"c0",x"d9",x"c2",x"48"),
   195 => (x"c1",x"4a",x"78",x"bf"),
   196 => (x"a2",x"c0",x"c1",x"9a"),
   197 => (x"87",x"e6",x"ec",x"49"),
   198 => (x"4f",x"26",x"4b",x"26"),
   199 => (x"c4",x"4a",x"71",x"1e"),
   200 => (x"49",x"72",x"1e",x"66"),
   201 => (x"fc",x"87",x"f0",x"eb"),
   202 => (x"1e",x"4f",x"26",x"8e"),
   203 => (x"c3",x"48",x"d4",x"ff"),
   204 => (x"d0",x"ff",x"78",x"ff"),
   205 => (x"78",x"e1",x"c0",x"48"),
   206 => (x"c1",x"48",x"d4",x"ff"),
   207 => (x"c4",x"48",x"71",x"78"),
   208 => (x"08",x"d4",x"ff",x"30"),
   209 => (x"48",x"d0",x"ff",x"78"),
   210 => (x"26",x"78",x"e0",x"c0"),
   211 => (x"5b",x"5e",x"0e",x"4f"),
   212 => (x"ec",x"0e",x"5d",x"5c"),
   213 => (x"48",x"a6",x"c8",x"86"),
   214 => (x"c4",x"7e",x"78",x"c0"),
   215 => (x"78",x"bf",x"ec",x"80"),
   216 => (x"f4",x"c2",x"80",x"f8"),
   217 => (x"e8",x"78",x"bf",x"d0"),
   218 => (x"d9",x"c2",x"4c",x"bf"),
   219 => (x"e4",x"49",x"bf",x"c0"),
   220 => (x"ee",x"cb",x"87",x"e7"),
   221 => (x"87",x"cc",x"cb",x"49"),
   222 => (x"c7",x"58",x"a6",x"d4"),
   223 => (x"87",x"df",x"e7",x"49"),
   224 => (x"c9",x"05",x"98",x"70"),
   225 => (x"49",x"66",x"cc",x"87"),
   226 => (x"c1",x"02",x"99",x"c1"),
   227 => (x"66",x"d0",x"87",x"c4"),
   228 => (x"ec",x"7e",x"c1",x"4d"),
   229 => (x"d9",x"c2",x"4b",x"bf"),
   230 => (x"e3",x"49",x"bf",x"c0"),
   231 => (x"49",x"75",x"87",x"fb"),
   232 => (x"70",x"87",x"ed",x"ca"),
   233 => (x"87",x"d7",x"02",x"98"),
   234 => (x"bf",x"e8",x"d8",x"c2"),
   235 => (x"c2",x"b9",x"c1",x"49"),
   236 => (x"71",x"59",x"ec",x"d8"),
   237 => (x"cb",x"87",x"f4",x"fd"),
   238 => (x"c7",x"ca",x"49",x"ee"),
   239 => (x"c7",x"4d",x"70",x"87"),
   240 => (x"87",x"db",x"e6",x"49"),
   241 => (x"ff",x"05",x"98",x"70"),
   242 => (x"49",x"73",x"87",x"c7"),
   243 => (x"fe",x"05",x"99",x"c1"),
   244 => (x"02",x"6e",x"87",x"ff"),
   245 => (x"c2",x"87",x"e3",x"c0"),
   246 => (x"4a",x"bf",x"c0",x"d9"),
   247 => (x"d9",x"c2",x"ba",x"c1"),
   248 => (x"0a",x"fc",x"5a",x"c4"),
   249 => (x"9a",x"c1",x"0a",x"7a"),
   250 => (x"49",x"a2",x"c0",x"c1"),
   251 => (x"c1",x"87",x"cf",x"e9"),
   252 => (x"ea",x"e5",x"49",x"da"),
   253 => (x"48",x"a6",x"c8",x"87"),
   254 => (x"d9",x"c2",x"78",x"c1"),
   255 => (x"c1",x"05",x"bf",x"c0"),
   256 => (x"c0",x"c8",x"87",x"c5"),
   257 => (x"d8",x"c2",x"4d",x"c0"),
   258 => (x"49",x"13",x"4b",x"ec"),
   259 => (x"87",x"cf",x"e5",x"49"),
   260 => (x"c2",x"02",x"98",x"70"),
   261 => (x"c1",x"b4",x"75",x"87"),
   262 => (x"ff",x"05",x"2d",x"b7"),
   263 => (x"49",x"74",x"87",x"ec"),
   264 => (x"71",x"99",x"ff",x"c3"),
   265 => (x"fb",x"49",x"c0",x"1e"),
   266 => (x"49",x"74",x"87",x"f2"),
   267 => (x"71",x"29",x"b7",x"c8"),
   268 => (x"fb",x"49",x"c1",x"1e"),
   269 => (x"86",x"c8",x"87",x"e6"),
   270 => (x"e4",x"49",x"fd",x"c3"),
   271 => (x"fa",x"c3",x"87",x"e1"),
   272 => (x"87",x"db",x"e4",x"49"),
   273 => (x"74",x"87",x"d4",x"c7"),
   274 => (x"99",x"ff",x"c3",x"49"),
   275 => (x"71",x"2c",x"b7",x"c8"),
   276 => (x"02",x"9c",x"74",x"b4"),
   277 => (x"d8",x"c2",x"87",x"df"),
   278 => (x"c7",x"49",x"bf",x"fc"),
   279 => (x"98",x"70",x"87",x"f2"),
   280 => (x"87",x"c4",x"c0",x"05"),
   281 => (x"87",x"d3",x"4c",x"c0"),
   282 => (x"c7",x"49",x"e0",x"c2"),
   283 => (x"d9",x"c2",x"87",x"d6"),
   284 => (x"c6",x"c0",x"58",x"c0"),
   285 => (x"fc",x"d8",x"c2",x"87"),
   286 => (x"74",x"78",x"c0",x"48"),
   287 => (x"05",x"99",x"c8",x"49"),
   288 => (x"c3",x"87",x"ce",x"c0"),
   289 => (x"d6",x"e3",x"49",x"f5"),
   290 => (x"c2",x"49",x"70",x"87"),
   291 => (x"e7",x"c0",x"02",x"99"),
   292 => (x"d4",x"f4",x"c2",x"87"),
   293 => (x"ca",x"c0",x"02",x"bf"),
   294 => (x"88",x"c1",x"48",x"87"),
   295 => (x"58",x"d8",x"f4",x"c2"),
   296 => (x"c4",x"87",x"d0",x"c0"),
   297 => (x"e0",x"c1",x"4a",x"66"),
   298 => (x"c0",x"02",x"6a",x"82"),
   299 => (x"ff",x"4b",x"87",x"c5"),
   300 => (x"c8",x"0f",x"73",x"49"),
   301 => (x"78",x"c1",x"48",x"a6"),
   302 => (x"99",x"c4",x"49",x"74"),
   303 => (x"87",x"ce",x"c0",x"05"),
   304 => (x"e2",x"49",x"f2",x"c3"),
   305 => (x"49",x"70",x"87",x"d9"),
   306 => (x"c0",x"02",x"99",x"c2"),
   307 => (x"f4",x"c2",x"87",x"f0"),
   308 => (x"48",x"7e",x"bf",x"d4"),
   309 => (x"03",x"a8",x"b7",x"c7"),
   310 => (x"6e",x"87",x"cb",x"c0"),
   311 => (x"c2",x"80",x"c1",x"48"),
   312 => (x"c0",x"58",x"d8",x"f4"),
   313 => (x"66",x"c4",x"87",x"d3"),
   314 => (x"80",x"e0",x"c1",x"48"),
   315 => (x"bf",x"6e",x"7e",x"70"),
   316 => (x"87",x"c5",x"c0",x"02"),
   317 => (x"73",x"49",x"fe",x"4b"),
   318 => (x"48",x"a6",x"c8",x"0f"),
   319 => (x"fd",x"c3",x"78",x"c1"),
   320 => (x"87",x"db",x"e1",x"49"),
   321 => (x"99",x"c2",x"49",x"70"),
   322 => (x"87",x"e9",x"c0",x"02"),
   323 => (x"bf",x"d4",x"f4",x"c2"),
   324 => (x"87",x"c9",x"c0",x"02"),
   325 => (x"48",x"d4",x"f4",x"c2"),
   326 => (x"d3",x"c0",x"78",x"c0"),
   327 => (x"48",x"66",x"c4",x"87"),
   328 => (x"70",x"80",x"e0",x"c1"),
   329 => (x"02",x"bf",x"6e",x"7e"),
   330 => (x"4b",x"87",x"c5",x"c0"),
   331 => (x"0f",x"73",x"49",x"fd"),
   332 => (x"c1",x"48",x"a6",x"c8"),
   333 => (x"49",x"fa",x"c3",x"78"),
   334 => (x"70",x"87",x"e4",x"e0"),
   335 => (x"02",x"99",x"c2",x"49"),
   336 => (x"c2",x"87",x"ed",x"c0"),
   337 => (x"48",x"bf",x"d4",x"f4"),
   338 => (x"03",x"a8",x"b7",x"c7"),
   339 => (x"c2",x"87",x"c9",x"c0"),
   340 => (x"c7",x"48",x"d4",x"f4"),
   341 => (x"87",x"d3",x"c0",x"78"),
   342 => (x"c1",x"48",x"66",x"c4"),
   343 => (x"7e",x"70",x"80",x"e0"),
   344 => (x"c0",x"02",x"bf",x"6e"),
   345 => (x"fc",x"4b",x"87",x"c5"),
   346 => (x"c8",x"0f",x"73",x"49"),
   347 => (x"78",x"c1",x"48",x"a6"),
   348 => (x"f4",x"c2",x"7e",x"c0"),
   349 => (x"50",x"c0",x"48",x"cc"),
   350 => (x"c3",x"49",x"ee",x"cb"),
   351 => (x"a6",x"d4",x"87",x"c6"),
   352 => (x"cc",x"f4",x"c2",x"58"),
   353 => (x"c1",x"05",x"bf",x"97"),
   354 => (x"49",x"74",x"87",x"de"),
   355 => (x"05",x"99",x"f0",x"c3"),
   356 => (x"c1",x"87",x"cd",x"c0"),
   357 => (x"df",x"ff",x"49",x"da"),
   358 => (x"98",x"70",x"87",x"c5"),
   359 => (x"87",x"c8",x"c1",x"02"),
   360 => (x"bf",x"e8",x"7e",x"c1"),
   361 => (x"ff",x"c3",x"49",x"4b"),
   362 => (x"2b",x"b7",x"c8",x"99"),
   363 => (x"d9",x"c2",x"b3",x"71"),
   364 => (x"ff",x"49",x"bf",x"c0"),
   365 => (x"d0",x"87",x"e2",x"db"),
   366 => (x"d3",x"c2",x"49",x"66"),
   367 => (x"02",x"98",x"70",x"87"),
   368 => (x"c2",x"87",x"c6",x"c0"),
   369 => (x"c1",x"48",x"cc",x"f4"),
   370 => (x"cc",x"f4",x"c2",x"50"),
   371 => (x"c0",x"05",x"bf",x"97"),
   372 => (x"49",x"73",x"87",x"d6"),
   373 => (x"05",x"99",x"f0",x"c3"),
   374 => (x"c1",x"87",x"c5",x"ff"),
   375 => (x"dd",x"ff",x"49",x"da"),
   376 => (x"98",x"70",x"87",x"fd"),
   377 => (x"87",x"f8",x"fe",x"05"),
   378 => (x"e0",x"c0",x"02",x"6e"),
   379 => (x"48",x"a6",x"cc",x"87"),
   380 => (x"bf",x"d4",x"f4",x"c2"),
   381 => (x"49",x"66",x"cc",x"78"),
   382 => (x"66",x"c4",x"91",x"cc"),
   383 => (x"70",x"80",x"71",x"48"),
   384 => (x"02",x"bf",x"6e",x"7e"),
   385 => (x"4b",x"87",x"c6",x"c0"),
   386 => (x"73",x"49",x"66",x"cc"),
   387 => (x"02",x"66",x"c8",x"0f"),
   388 => (x"c2",x"87",x"c8",x"c0"),
   389 => (x"49",x"bf",x"d4",x"f4"),
   390 => (x"ec",x"87",x"e9",x"f1"),
   391 => (x"26",x"4d",x"26",x"8e"),
   392 => (x"26",x"4b",x"26",x"4c"),
   393 => (x"00",x"00",x"00",x"4f"),
   394 => (x"00",x"00",x"00",x"00"),
   395 => (x"14",x"11",x"12",x"58"),
   396 => (x"23",x"1c",x"1b",x"1d"),
   397 => (x"94",x"91",x"59",x"5a"),
   398 => (x"f4",x"eb",x"f2",x"f5"),
   399 => (x"00",x"00",x"00",x"00"),
   400 => (x"00",x"00",x"00",x"00"),
   401 => (x"ff",x"4a",x"71",x"1e"),
   402 => (x"72",x"49",x"bf",x"c8"),
   403 => (x"4f",x"26",x"48",x"a1"),
   404 => (x"bf",x"c8",x"ff",x"1e"),
   405 => (x"c0",x"c0",x"fe",x"89"),
   406 => (x"a9",x"c0",x"c0",x"c0"),
   407 => (x"c0",x"87",x"c4",x"01"),
   408 => (x"c1",x"87",x"c2",x"4a"),
   409 => (x"26",x"48",x"72",x"4a"),
   410 => (x"5b",x"5e",x"0e",x"4f"),
   411 => (x"71",x"0e",x"5d",x"5c"),
   412 => (x"4c",x"d4",x"ff",x"4b"),
   413 => (x"c0",x"48",x"66",x"d0"),
   414 => (x"ff",x"49",x"d6",x"78"),
   415 => (x"c3",x"87",x"dd",x"dd"),
   416 => (x"49",x"6c",x"7c",x"ff"),
   417 => (x"71",x"99",x"ff",x"c3"),
   418 => (x"f0",x"c3",x"49",x"4d"),
   419 => (x"a9",x"e0",x"c1",x"99"),
   420 => (x"c3",x"87",x"cb",x"05"),
   421 => (x"48",x"6c",x"7c",x"ff"),
   422 => (x"66",x"d0",x"98",x"c3"),
   423 => (x"ff",x"c3",x"78",x"08"),
   424 => (x"49",x"4a",x"6c",x"7c"),
   425 => (x"ff",x"c3",x"31",x"c8"),
   426 => (x"71",x"4a",x"6c",x"7c"),
   427 => (x"c8",x"49",x"72",x"b2"),
   428 => (x"7c",x"ff",x"c3",x"31"),
   429 => (x"b2",x"71",x"4a",x"6c"),
   430 => (x"31",x"c8",x"49",x"72"),
   431 => (x"6c",x"7c",x"ff",x"c3"),
   432 => (x"ff",x"b2",x"71",x"4a"),
   433 => (x"e0",x"c0",x"48",x"d0"),
   434 => (x"02",x"9b",x"73",x"78"),
   435 => (x"7b",x"72",x"87",x"c2"),
   436 => (x"4d",x"26",x"48",x"75"),
   437 => (x"4b",x"26",x"4c",x"26"),
   438 => (x"26",x"1e",x"4f",x"26"),
   439 => (x"5b",x"5e",x"0e",x"4f"),
   440 => (x"86",x"f8",x"0e",x"5c"),
   441 => (x"a6",x"c8",x"1e",x"76"),
   442 => (x"87",x"fd",x"fd",x"49"),
   443 => (x"4b",x"70",x"86",x"c4"),
   444 => (x"a8",x"c2",x"48",x"6e"),
   445 => (x"87",x"f0",x"c2",x"03"),
   446 => (x"f0",x"c3",x"4a",x"73"),
   447 => (x"aa",x"d0",x"c1",x"9a"),
   448 => (x"c1",x"87",x"c7",x"02"),
   449 => (x"c2",x"05",x"aa",x"e0"),
   450 => (x"49",x"73",x"87",x"de"),
   451 => (x"c3",x"02",x"99",x"c8"),
   452 => (x"87",x"c6",x"ff",x"87"),
   453 => (x"9c",x"c3",x"4c",x"73"),
   454 => (x"c1",x"05",x"ac",x"c2"),
   455 => (x"66",x"c4",x"87",x"c2"),
   456 => (x"71",x"31",x"c9",x"49"),
   457 => (x"4a",x"66",x"c4",x"1e"),
   458 => (x"f4",x"c2",x"92",x"d4"),
   459 => (x"81",x"72",x"49",x"d8"),
   460 => (x"87",x"e0",x"ce",x"fe"),
   461 => (x"da",x"ff",x"49",x"d8"),
   462 => (x"c0",x"c8",x"87",x"e2"),
   463 => (x"f0",x"e2",x"c2",x"1e"),
   464 => (x"d2",x"e8",x"fd",x"49"),
   465 => (x"48",x"d0",x"ff",x"87"),
   466 => (x"c2",x"78",x"e0",x"c0"),
   467 => (x"cc",x"1e",x"f0",x"e2"),
   468 => (x"92",x"d4",x"4a",x"66"),
   469 => (x"49",x"d8",x"f4",x"c2"),
   470 => (x"cc",x"fe",x"81",x"72"),
   471 => (x"86",x"cc",x"87",x"e7"),
   472 => (x"c1",x"05",x"ac",x"c1"),
   473 => (x"66",x"c4",x"87",x"c2"),
   474 => (x"71",x"31",x"c9",x"49"),
   475 => (x"4a",x"66",x"c4",x"1e"),
   476 => (x"f4",x"c2",x"92",x"d4"),
   477 => (x"81",x"72",x"49",x"d8"),
   478 => (x"87",x"d8",x"cd",x"fe"),
   479 => (x"1e",x"f0",x"e2",x"c2"),
   480 => (x"d4",x"4a",x"66",x"c8"),
   481 => (x"d8",x"f4",x"c2",x"92"),
   482 => (x"fe",x"81",x"72",x"49"),
   483 => (x"d7",x"87",x"e7",x"ca"),
   484 => (x"c7",x"d9",x"ff",x"49"),
   485 => (x"1e",x"c0",x"c8",x"87"),
   486 => (x"49",x"f0",x"e2",x"c2"),
   487 => (x"87",x"d4",x"e6",x"fd"),
   488 => (x"d0",x"ff",x"86",x"cc"),
   489 => (x"78",x"e0",x"c0",x"48"),
   490 => (x"4c",x"26",x"8e",x"f8"),
   491 => (x"4f",x"26",x"4b",x"26"),
   492 => (x"5c",x"5b",x"5e",x"0e"),
   493 => (x"86",x"fc",x"0e",x"5d"),
   494 => (x"d4",x"ff",x"4d",x"71"),
   495 => (x"7e",x"66",x"d4",x"4c"),
   496 => (x"a8",x"b7",x"c3",x"48"),
   497 => (x"87",x"e2",x"c1",x"01"),
   498 => (x"66",x"c4",x"1e",x"75"),
   499 => (x"c2",x"93",x"d4",x"4b"),
   500 => (x"73",x"83",x"d8",x"f4"),
   501 => (x"dc",x"c4",x"fe",x"49"),
   502 => (x"49",x"a3",x"c8",x"87"),
   503 => (x"d0",x"ff",x"49",x"69"),
   504 => (x"78",x"e1",x"c8",x"48"),
   505 => (x"48",x"71",x"7c",x"dd"),
   506 => (x"70",x"98",x"ff",x"c3"),
   507 => (x"c8",x"4a",x"71",x"7c"),
   508 => (x"48",x"72",x"2a",x"b7"),
   509 => (x"70",x"98",x"ff",x"c3"),
   510 => (x"d0",x"4a",x"71",x"7c"),
   511 => (x"48",x"72",x"2a",x"b7"),
   512 => (x"70",x"98",x"ff",x"c3"),
   513 => (x"d8",x"48",x"71",x"7c"),
   514 => (x"7c",x"70",x"28",x"b7"),
   515 => (x"7c",x"7c",x"7c",x"c0"),
   516 => (x"7c",x"7c",x"7c",x"7c"),
   517 => (x"7c",x"7c",x"7c",x"7c"),
   518 => (x"48",x"d0",x"ff",x"7c"),
   519 => (x"c4",x"78",x"e0",x"c0"),
   520 => (x"49",x"dc",x"1e",x"66"),
   521 => (x"87",x"d9",x"d7",x"ff"),
   522 => (x"8e",x"fc",x"86",x"c8"),
   523 => (x"4c",x"26",x"4d",x"26"),
   524 => (x"4f",x"26",x"4b",x"26"),
   525 => (x"c0",x"1e",x"73",x"1e"),
   526 => (x"f4",x"e1",x"c2",x"4b"),
   527 => (x"c2",x"50",x"c0",x"48"),
   528 => (x"49",x"bf",x"f0",x"e1"),
   529 => (x"87",x"fe",x"dc",x"fe"),
   530 => (x"c4",x"05",x"98",x"70"),
   531 => (x"d8",x"e1",x"c2",x"87"),
   532 => (x"26",x"48",x"73",x"4b"),
   533 => (x"00",x"4f",x"26",x"4b"),
   534 => (x"77",x"6f",x"68",x"53"),
   535 => (x"64",x"69",x"68",x"2f"),
   536 => (x"53",x"4f",x"20",x"65"),
   537 => (x"20",x"3d",x"20",x"44"),
   538 => (x"20",x"79",x"65",x"6b"),
   539 => (x"00",x"32",x"31",x"46"),
   540 => (x"00",x"00",x"28",x"78"),
   541 => (x"00",x"00",x"00",x"00"),
   542 => (x"4f",x"54",x"55",x"41"),
   543 => (x"54",x"4f",x"4f",x"42"),
   544 => (x"00",x"53",x"45",x"4e"),
   545 => (x"00",x"00",x"1b",x"af"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;

