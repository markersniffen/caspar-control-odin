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

// NOTE       Point in Pos      Quad
IsInsideBounds :: proc(Pos: v2, A: v4) -> bool
{
	Result := false;
	L := A[0];
	B := A[1];
	R := A[2];
	T := A[3];
	if Pos.x > L && Pos.y > B && Pos.x < R && Pos.y < T do Result = true;
	return Result;
}