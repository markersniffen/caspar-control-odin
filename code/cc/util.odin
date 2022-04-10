package cc

GetNewUID 		:: proc() -> uid
{
	if Show.State.UID == 0 do Show.State.UID += 1;
	Show.State.UID += 1; // make atomic
	return Show.State.UID;
}

IsInsideBounds 	:: proc(Pt: v2, Quad: v4) -> bool
{
	Result := false;
	L := Quad[0];
	T := Quad[1];
	R := Quad[2];
	B := Quad[3];
	if Pt.x > L && Pt.y > T && Pt.x < R && Pt.y < B do Result = true;
	return Result;
}

QuadTo32 		:: proc(Value: [4]f64) -> [4]f32
{
	Result: [4]f32
	for V, i in Value do Result[i] = f32(V)
	return Result
}

QuadTo64 		:: proc(Value: [4]f32) -> [4]f64
{
	Result: [4]f64
	for V, i in Value do Result[i] = f64(V)
	return Result
}

Linear :: proc(s, a1, a2, b1, b2: f64) -> f64
{
	return (s-a1)*(b2-b1)/(a2-a1) + b1;
}
