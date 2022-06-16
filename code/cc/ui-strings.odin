package cc

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

StringToShort:: proc(S: string) -> short_string
{
	SS: short_string;
	SS.Len = len(S);
	copy(SS.Mem[:SS.Len], S);
	assert(SS.Len <= SHORT_STRING_LENGTH);
	return SS;
}

ShortToString :: proc(SS: ^short_string) -> string
{
	return string(SS.Mem[:SS.Len]);
}

StringToLong:: proc(S: string) -> long_string
{
	LS: long_string;
	LS.Len = len(S);
	copy(LS.Mem[:LS.Len], S);
	assert(LS.Len <= LONG_STRING_LENGTH);
	return LS;
}

LongToString :: proc(LS: ^long_string) -> string
{
	return string(LS.Mem[:LS.Len]);
}

grid :: struct
{
	
}