package cc

uid :: u64

v2 :: [2]f64
v3 :: [3]f64
v4 :: [4]f64

v2i :: [2]i64
v3i :: [3]i64
v4i :: [4]i64

SHORT_STRING_LENGTH :: 128;
LONG_STRING_LENGTH :: 1024;

short_string :: struct
{
	Mem: [SHORT_STRING_LENGTH]byte,
	Len: int,
	Lines: int,
}

long_string :: struct
{
	Mem: [LONG_STRING_LENGTH]byte,
	Len: int,
}