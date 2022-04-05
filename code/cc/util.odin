package cc

GetNewUID :: proc(Show: ^show) -> uid
{
	if Show.State.UID == 0 do Show.State.UID += 1;
	Show.State.UID += 1; // make atomic
	return Show.State.UID;
}

QuadTo32 :: proc(Value: [4]f64) -> [4]f32
{
	Result: [4]f32
	for V, i in Value do Result[i] = f32(V)
	return Result
}

QuadTo64 :: proc(Value: [4]f32) -> [4]f64
{
	Result: [4]f64
	for V, i in Value do Result[i] = f64(V)
	return Result
}

// NOTE       Point in Pos      Quad
IsInsideBounds :: proc(Pt: v2, Quad: v4) -> bool
{
	Result := false;
	L := Quad[0];
	T := Quad[1];
	R := Quad[2];
	B := Quad[3];
	if Pt.x > L && Pt.y > T && Pt.x < R && Pt.y < B do Result = true;
	return Result;
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