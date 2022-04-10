package cc

import "core:fmt"
import "core:os"
import "core:mem"
import stb "vendor:stb/truetype"
import gl "vendor:OpenGL"

STBFontInit :: proc()
{
	using stb, mem, fmt

	NUM_CHARS :: 96
	
	Filedata, Ok := os.read_entire_file("fonts/Roboto-Regular.ttf")
	defer delete(Filedata)
	Image:= alloc(512*512)
	CharData, Cok:= make([]bakedchar, NUM_CHARS)
	Show.State.glState.STBCharData = CharData
	BakeFontBitmap(raw_data(Filedata), 0, UI_TEXT_HEIGHT, cast([^]u8)Image, 512, 512, 32, NUM_CHARS, raw_data(CharData))

	gl.GenTextures(1, &Show.State.glState.STBTexture)
	gl.BindTexture(gl.TEXTURE_2D, Show.State.glState.STBTexture)
  	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.ALPHA, 512,512, 0, gl.ALPHA, gl.UNSIGNED_BYTE, Image)
  	free(Image)
  	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
					

	BoldFiledata, BFOk := os.read_entire_file("fonts/Roboto-Bold.ttf")
	defer delete(BoldFiledata)
	ImageBold:= alloc(512*512)
	CharDataBold, Bok:= make([]bakedchar, NUM_CHARS)
	Show.State.glState.STBCharDataBold = CharDataBold
	BakeFontBitmap(raw_data(BoldFiledata), 0, UI_TEXT_HEIGHT, cast([^]u8)ImageBold, 512, 512, 32, NUM_CHARS, raw_data(CharDataBold))

	gl.GenTextures(1, &Show.State.glState.STBTextureBold)
	gl.BindTexture(gl.TEXTURE_2D, Show.State.glState.STBTextureBold)
  	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.ALPHA, 512,512, 0, gl.ALPHA, gl.UNSIGNED_BYTE, Image)
  	free(ImageBold)
  	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
}

PushText :: proc(Q: v4, UV: [4]f32, Color: v4, Border: f32)
{
	if Show.State.glState.QuadIndex < MAX_UI_ELEMENTS
	{
		W := f32(Show.State.WindowRes.x/2)
		H := f32(Show.State.WindowRes.y/2)
		C := f32(0.0)
		u:f32 = 0
		v:f32 = 1
		uvl:f32 = UV[0]
		uvb:f32 = UV[3]
		uvr:f32 = UV[2]
		uvt:f32 = UV[1]
		
		c1 := f32(Color[0])
		c2 := f32(Color[1])
		c3 := f32(Color[2])
		c4 := f32(Color[3])

		m:f32 = 1

		Quad := QuadTo32(Q)
		
		/// {1, 1, 0, 0}
		l := (Quad[0] - W) / W;
		b := (Quad[1] - H) / H;
		r := (Quad[2] - W) / W;
		t := (Quad[3] - H) / H;

		t = t * -1
		b = b * -1

		V :[40]f32 = { 
			l,b,0,	uvl,uvb,	c1,c2,c3,c4,	m,
			l,t,0,	uvl,uvt,	c1,c2,c3,c4,	m,
			r,t,0,	uvr,uvt,	c1,c2,c3,c4,	m,
			r,b,0,	uvr,uvb,	c1,c2,c3,c4,	m,
		}
		copy(Show.State.glState.Vertices[Show.State.glState.VIndex:Show.State.glState.VIndex+40], V[:])
		Show.State.glState.VIndex += 40
		
		QI := u32(Show.State.glState.QuadIndex * 4);
		I :[6]u32 = {0+QI, 1+QI, 2+QI, 0+QI, 2+QI, 3+QI};
		copy(Show.State.glState.Indices[Show.State.glState.IIndex:Show.State.glState.IIndex+6], I[:]);
		Show.State.glState.IIndex += 6;
		Show.State.glState.QuadIndex += 1;
	}
}