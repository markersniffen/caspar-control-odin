package cc
import "core:fmt"

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

QuadIsInsideBounds	:: proc(Quad, Bounds: v4) -> bool
{
	Result := false
	if IsInsideBounds({Quad[0],Quad[1]}, Bounds) || IsInsideBounds({Quad[2],Quad[3]}, Bounds)
	{
		Result = true
	}
	return Result
}

QuadFullInsideBounds	:: proc(Quad, Bounds: v4) -> int
{
	Result := 0
	if IsInsideBounds({Quad[0],Quad[1]}, Bounds)
	{
		Result += 1
	}

	if IsInsideBounds({Quad[2],Quad[3]}, Bounds)
	{
		Result += 1
	}
	return Result
}

QuadClampToQuad :: proc (Quad, ClampToQuad: v4) -> v4
{
	Result: v4 = Quad
	Result[0] = clamp(Quad[0], ClampToQuad[0], ClampToQuad[2])
	Result[1] = clamp(Quad[1], ClampToQuad[1], ClampToQuad[3])
	Result[2] = clamp(Quad[2], ClampToQuad[0], ClampToQuad[2])
	Result[3] = clamp(Quad[3], ClampToQuad[1], ClampToQuad[3])
	// fmt.println(Quad)
	// fmt.println(ClampToQuad)
	// fmt.println(Result)
	// fmt.println("-------")
	return Result
}

OffsetQuad :: proc(Quad: v4, Offset: v2) -> v4
{
	AddQuad: v4 = {Offset[0], Offset[1], Offset[0], Offset[1]}
	return Quad + AddQuad
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
