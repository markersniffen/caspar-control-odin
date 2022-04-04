package cc

import "core:fmt"
import "core:os"
import "core:mem"
import stb "vendor:stb/truetype"
import gl "vendor:OpenGL"

TTInit :: proc(Show: ^show)
{
	using stb, mem, fmt

	NUM_CHARS :: 96
	Filedata, Ok := os.read_entire_file("fonts/SourceSansPro-Bold.ttf")

	Image:= alloc(512*512)
	CharData, Cok:= make([]bakedchar, NUM_CHARS)
	Show.State.glState.STBCharData = CharData

	BakeFontBitmap(raw_data(Filedata), 0, 32, cast([^]u8)Image, 512, 512, 32, NUM_CHARS, raw_data(CharData))

	gl.GenTextures(1, &Show.State.glState.STBTexture);
	gl.BindTexture(gl.TEXTURE_2D, Show.State.glState.STBTexture);
  	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.ALPHA, 512,512, 0, gl.ALPHA, gl.UNSIGNED_BYTE, Image);
  	// can free temp_bitmap at this point
  	free(Image)
  	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
  }

 //  TTDraw :: proc(Show: ^show)
 //  {
 //  	using stb, fmt

 //  	x:f32= 100
 //  	y:f32= 100

 //  	q: aligned_quad


 //  	for Letter in "Mark"
 //  	{
 //  		GetBakedQuad(raw_data(Show.State.glState.STBCharData), 512, 512, i32(Letter), &x, &y, &q, true)

	// 	v: [12]f32 = {
	// 		q.x0, q.y0,
	// 		q.x1, q.y1,
	// 		q.x1, q.y0,
	// 		q.x0, q.y0,
	// 		q.x0, q.y1,
	// 		q.x1, q.y1,
	// 	}
	// 	uv: [12]f32 = {
	// 		q.s0, q.t0,
	// 		q.s1, q.t1,
	// 		q.s1, q.t0,
	// 		q.s0, q.t0,
	// 		q.s0, q.t1,
	// 		q.s1, q.t1,
	// 	}

	// 	Vertices: [40]f32 = {
	// 	// position			UV 			Color 		Texture Mix
	//    	q.x0, q.y0, 0.0,	q.s0, q.t0,	1,0,0,1,	1,
	//     q.x1, q.y0, 0.0,	q.s1, q.t0,	1,0,0,1,	1,
	//     q.x1, q.y1, 0.0,	q.s1, q.t1,	1,0,0,1,	1,
	//     q.x0, q.y1, 0.0,	q.s0, q.t1,	1,0,0,1,	1,
	// }

	// 	Indices: [6]u32 = {	
	// 		0,1,2, // first quad
	//         0,2,3,
	// 	}

	// 	gl.UseProgram(Show.State.glState.ui_shader)
	// 	gl.BindTexture(gl.TEXTURE_2D, Show.State.glState.STBTexture)

	// 	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 0 * size_of(f32))
	// 	gl.EnableVertexAttribArray(0)
	// 	gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 3 * size_of(f32))
	// 	gl.EnableVertexAttribArray(1)
	// 	gl.VertexAttribPointer(2, 4, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 5 * size_of(f32))
	// 	gl.EnableVertexAttribArray(2)
	// 	gl.VertexAttribPointer(3, 1, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 9 * size_of(f32))
	// 	gl.EnableVertexAttribArray(3)

	// 	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, Show.State.glState.IndexBuffer);
	// 	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(Indices), &Indices[0], gl.STATIC_DRAW);

	// 	gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil);

 //  	}
 //  }


// TTTestRect :: proc(Show: ^show)
// {
// 	gl.UseProgram(Show.State.glState.ui_shader);
// 	gl.BindTexture(gl.TEXTURE_2D, Show.State.glState.STBTexture);

// 	Vertices: [80]f32 = {
// 		// position			UV 			Color 		Texture Mix
// 	   	-1, 	-1, 0.0,	1.0, 1.0,	0,0,0,1,	0.5,
// 	    -1,	 	 0, 0.0,	1.0, 0.0,	0,0,0,1,	0.5,
// 	     0, 	 0, 0.0,	0.0, 0.0,	0,0,0,1,	0.5,
// 	     0, 	-1, 0.0,	0.0, 1.0,	0,0,0,1,	0.5,

// 	     0.5, 0.5, 0.0,		1.0, 1.0,	1,1,1,0.5,	0.5,
// 	     0.5, 0.8, 0.0,		1.0, 0.0,	1,1,1,0.5,	0.5,
// 	     0.8, 0.8, 0.0,		0.0, 0.0,	1,1,1,0.5,	0.5,
// 	     0.8, 0.5, 0.0,		0.0, 1.0,	1,1,1,0.5,	0.5,
// 	}

// 	Indices: [12]u32 = {	
// 		0,1,2, // first quad
//         0,2,3,
//         4,5,6, // second quad
//         4,6,7,
// 	}
	
// 	gl.BindBuffer(gl.ARRAY_BUFFER, Show.State.glState.VertexBuffer);
// 	gl.BufferData(gl.ARRAY_BUFFER, size_of(Vertices), &Vertices[0], gl.STATIC_DRAW);
	
// 	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 0 * size_of(f32))
// 	gl.EnableVertexAttribArray(0)
// 	gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 3 * size_of(f32))
// 	gl.EnableVertexAttribArray(1)
// 	gl.VertexAttribPointer(2, 4, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 5 * size_of(f32))
// 	gl.EnableVertexAttribArray(2)
// 	gl.VertexAttribPointer(3, 1, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 9 * size_of(f32))
// 	gl.EnableVertexAttribArray(3)


// 	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, Show.State.glState.IndexBuffer);
// 	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(Indices), &Indices[0], gl.STATIC_DRAW);

// 	gl.DrawElements(gl.TRIANGLES, 12, gl.UNSIGNED_INT, nil);
// }



