package cc

import "core:math/linalg"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"
import stb "vendor:stb/truetype"
import "core:fmt"
import "core:image/png"
import "core:image"
import "core:math"
import "core:mem"

GL_MINOR_VERSION :: 3
GL_MAJOR_VERSION :: 3

opengl_state :: struct
{
	Window: glfw.WindowHandle,
	
	ui_shader: u32,
	font_shader: u32, // for loading font into gl texture NOTE legacy?

	Vertices: []f32,
	VertexBuffer: u32,
	VIndex:int,

	Indices: []u32,
	IndexBuffer: u32,
	IIndex: int,

	QuadIndex: int,
	
	// textures
	STBTexture: u32,
	STBTextureBold: u32,
	STBCharData: []stb.bakedchar,
	STBCharDataBold: []stb.bakedchar,
	Texture: u32,
}

OpenglInit :: proc()
{
	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)
	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
	// gl.Enable(gl.DEPTH_TEST)

	gl.GenBuffers(1, &Show.State.glState.VertexBuffer)
	Show.State.glState.Vertices = make_slice([]f32, mem.Megabyte * 2)

	gl.GenBuffers(1, &Show.State.glState.IndexBuffer)
	Show.State.glState.Indices = make([]u32, mem.Megabyte * 2)

	shader_success : bool
	Show.State.glState.font_shader, shader_success = gl.load_shaders_source(FONT_VS, FONT_FRAG);
	if !shader_success do fmt.println("Font shader did not compile!");
	Show.State.glState.ui_shader, shader_success = gl.load_shaders_source(UIMAIN_VS, UIMAIN_FRAG)
	if !shader_success do fmt.println("UIMAIN shader did not compile!")
	// Show.State.glState.texture_shader, shader_success = gl.load_shaders_source(TEXTURE_VS, TEXTURE_FRAG)
	// if !shader_success do fmt.println("TEXTURE shader did not compile!")

	// -------------------------------------------------------------------------------- //
	// TODO load image (get rid of or implement into separate function the eventually)
	options : image.Options
	img, err := png.load("images/dogs.png", options)
	fmt.println(err)
	fmt.println(img.width, img.height, img.channels, img.depth)
	// Create & Bind texture
	gl.GenTextures(1, &Show.State.glState.Texture)
	gl.BindTexture(gl.TEXTURE_2D, Show.State.glState.Texture)
	gl.GenerateMipmap(gl.TEXTURE_2D)
	
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST_MIPMAP_LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, i32(img.width), i32(img.height), 0, gl.RGBA, gl.UNSIGNED_BYTE, raw_data(img.pixels.buf))
}

OpenglRender :: proc()
{

	gl.BindFramebuffer(gl.FRAMEBUFFER, 0);
	gl.Viewport(0, 0, i32(Show.State.WindowRes.x), i32(Show.State.WindowRes.y));
	gl.ClearColor(0, 0, 0, 1)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	OpenglRenderUI()

	glfw.SwapBuffers(Show.State.glState.Window)

	Show.Debug.UIQuads = Show.State.glState.QuadIndex
	
	Show.Debug.UICharactersLast = Show.Debug.UICharacters
	Show.Debug.UICharacters = 0
	
	Show.Debug.UIElements = Show.State.glState.QuadIndex
	Show.Debug.UIQuads = Show.State.glState.QuadIndex
	Show.Debug.UIVertices = Show.State.glState.VIndex
	Show.State.glState.QuadIndex = 0;
	Show.State.glState.VIndex = 0
	Show.State.glState.IIndex = 0
}

OpenglRenderUI :: proc()
{

	gl.UseProgram(Show.State.glState.ui_shader)
	gl.BindTexture(gl.TEXTURE_2D, Show.State.glState.STBTexture)

	Vertices:= 	Show.State.glState.Vertices
	Indices:=	Show.State.glState.Indices
	
	gl.BindBuffer(gl.ARRAY_BUFFER, Show.State.glState.VertexBuffer);
	gl.BufferData(gl.ARRAY_BUFFER, Show.State.glState.VIndex * size_of(f32), &Vertices[0], gl.STATIC_DRAW);
	
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 0 * size_of(f32))
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 3 * size_of(f32))
	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(2, 4, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 5 * size_of(f32))
	gl.EnableVertexAttribArray(2)
	gl.VertexAttribPointer(3, 1, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 9 * size_of(f32))
	gl.EnableVertexAttribArray(3)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, Show.State.glState.IndexBuffer);
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, Show.State.glState.IIndex * size_of(u32), &Indices[0], gl.STATIC_DRAW);

	gl.DrawElements(gl.TRIANGLES, i32(Show.State.glState.IIndex), gl.UNSIGNED_INT, nil);
}

PushQuad :: proc(Q: v4, UV: [4]f32, Color: v4, Border: f32, ForceDraw:bool = false)
{
	if Show.State.glState.VIndex + 40 < len(Show.State.glState.Vertices)
	{
	
		Quad64 := Q

		IsInside := QuadFullInsideBounds(Quad64, Show.State.UIPanelCTX)

		if IsInside == 1 && ForceDraw == false
		{
			Quad64 = QuadClampToQuad(Quad64, Show.State.UIPanelCTX)
		}

		if ForceDraw || IsInside > 0		
		{
			Quad := QuadTo32(Quad64)
			if ForceDraw
			{
				Quad = QuadTo32(Q)
			}

			W := f32(Show.State.WindowRes.x/2)
			H := f32(Show.State.WindowRes.y/2)
			C := f32(0.0)
			u:f32 = 0
			v:f32 = 1
			uvl:f32 = UV[0]
			uvb:f32 = UV[1]
			uvr:f32 = UV[2]
			uvt:f32 = UV[3]
			
			c1 := f32(Color[0])
			c2 := f32(Color[1])
			c3 := f32(Color[2])
			c4 := f32(Color[3])

			m:f32 = 0
			if UV != {0,0,0,0} // if this is a font
			{
				m = 1
				c4 = 0
			}
			
			// NOTE simple quad
			if Border == 0
			{
				l := (Quad[0] - W) / W;
				t := (Quad[1] - H) / H;
				r := (Quad[2] - W) / W;
				b := (Quad[3] - H) / H;

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
				Show.State.glState.IIndex += 6
				Show.State.glState.QuadIndex += 1
			}
			else
			// NOTE Quad as border (techincally 4 quads)
			{
				// TODO NEED OT FIX THIS
				L := (Quad[0] - W) / W;
				T := (Quad[1] - H) / H;
				R := (Quad[2] - W) / W;
				B := (Quad[3] - H) / H;

				T = T * -1
				B = B * -1

				TX:= Border / W;
				TY:= Border / H;
				
				L2 := L + TX;
				R2 := R - TX;
				T2 := T - TY;
				B2 := B + TY;
				
				VArrays :[4][40]f32= {
					{ L,T,0, u,v, c1,c2,c3,c4, m,	R,T,0, u,v, c1,c2,c3,c4, m,	R2,T2,0, u,v, c1,c2,c3,c4, m,	L2,T2,0, u,v, c1,c2,c3,c4, m},
					{ R,T,0, u,v, c1,c2,c3,c4, m,	R,B,0, u,v, c1,c2,c3,c4, m,	R2,B2,0, u,v, c1,c2,c3,c4, m,	R2,T2,0, u,v, c1,c2,c3,c4, m},
					{ R,B,0, u,v, c1,c2,c3,c4, m,	L,B,0, u,v, c1,c2,c3,c4, m,	L2,B2,0, u,v, c1,c2,c3,c4, m,	R2,B2,0, u,v, c1,c2,c3,c4, m},
					{ L,B,0, u,v, c1,c2,c3,c4, m,	L,T,0, u,v, c1,c2,c3,c4, m,	L2,T2,0, u,v, c1,c2,c3,c4, m,	L2,B2,0, u,v, c1,c2,c3,c4, m},
				}
				
				for VA in &VArrays
				{
					QI := u32(Show.State.glState.QuadIndex * 4);
					I1 :[6]u32 = {0+QI, 1+QI, 3+QI, 1+QI, 2+QI, 3+QI};
					
					copy(Show.State.glState.Vertices[Show.State.glState.VIndex:Show.State.glState.VIndex+40], VA[:]);
					Show.State.glState.VIndex += 40;
					
					copy(Show.State.glState.Indices[Show.State.glState.IIndex:Show.State.glState.IIndex+6], I1[:]);
					Show.State.glState.IIndex += 6;
					Show.State.glState.QuadIndex += 1;
				}
			}
		}
	}
}

OpenglRectTest :: proc()
{
	gl.UseProgram(Show.State.glState.ui_shader);
	gl.BindTexture(gl.TEXTURE_2D, Show.State.glState.STBTexture);

	Vertices: [80]f32 = {
		// position			UV 			Color 		Texture Mix
	   	-1, 	-1, 0.0,	1.0, 1.0,	1,0,0,1,	0.5,
	    -1,	 	 0, 0.0,	1.0, 0.0,	1,0,0,1,	0.5,
	     0, 	 0, 0.0,	0.0, 0.0,	0,0,0,1,	0.5,
	     0, 	-1, 0.0,	0.0, 1.0,	0,0,0,1,	0.5,

	     0.5, 0.5, 0.0,		1.0, 1.0,	1,1,1,0.5,	0.5,
	     0.5, 0.8, 0.0,		1.0, 0.0,	1,1,1,0.5,	0.5,
	     0.8, 0.8, 0.0,		0.0, 0.0,	1,1,1,0.5,	0.5,
	     0.8, 0.5, 0.0,		0.0, 1.0,	1,1,1,0.5,	0.5,
	}

	Indices: [12]u32 = {	
		0,1,2, // first quad
        0,2,3,
        4,5,6, // second quad
        4,6,7,
	}
	
	gl.BindBuffer(gl.ARRAY_BUFFER, Show.State.glState.VertexBuffer);
	gl.BufferData(gl.ARRAY_BUFFER, size_of(Vertices), &Vertices[0], gl.STATIC_DRAW);
	
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 0 * size_of(f32))
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 3 * size_of(f32))
	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(2, 4, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 5 * size_of(f32))
	gl.EnableVertexAttribArray(2)
	gl.VertexAttribPointer(3, 1, gl.FLOAT, gl.FALSE, 10 * size_of(f32), 9 * size_of(f32))
	gl.EnableVertexAttribArray(3)


	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, Show.State.glState.IndexBuffer);
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(Indices), &Indices[0], gl.STATIC_DRAW);

	gl.DrawElements(gl.TRIANGLES, 12, gl.UNSIGNED_INT, nil);
}