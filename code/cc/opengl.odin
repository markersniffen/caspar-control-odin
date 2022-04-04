package cc

import "core:math/linalg"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"
import stb "vendor:stb/truetype"
import "core:fmt"
import "core:image/png"
import "core:image"
import "core:math"


GL_MINOR_VERSION :: 3
GL_MAJOR_VERSION :: 3

opengl_state :: struct
{
	// window
	Window: glfw.WindowHandle,
	
	// shaders
	ui_shader: u32,
	font_shader: u32, // for loading font into gl texture

	Vertices: [MAX_UI_ELEMENTS * 12]f32,
	VertexBuffer: u32,
	VIndex:int,

	Indices: [MAX_UI_ELEMENTS * 6]u32,
	IndexBuffer: u32,
	IIndex:int, 

	QuadIndex: int,
	
	// framebuffers
	FontFramebuffer: u32,
	IntermediateFontFrameBuffer: u32,
	ScreenFrameBuffer: u32,

	// textures
	Texture: u32,
	MultisampledFontTexture: u32,
	FontTexture: u32,
	STBTexture: u32,
	STBCharData: []stb.bakedchar,

}

OpenglInit :: proc(Show: ^show)
{
	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)
	// gl.Enable(gl.MULTISAMPLE)
	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

	gl.GenBuffers(1, &Show.State.glState.VertexBuffer)
	gl.GenBuffers(1, &Show.State.glState.IndexBuffer)

	shader_success : bool

	glState := &Show.State.glState

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
	gl.BindTexture(gl.TEXTURE_2D, Show.State.glState.Texture);
	gl.GenerateMipmap(gl.TEXTURE_2D);
	
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
	// gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST_MIPMAP_LINEAR);
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);


	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, i32(img.width), i32(img.height), 0, gl.RGBA, gl.UNSIGNED_BYTE, raw_data(img.pixels.buf));
	// -------------------------------------------------------------------------------- //


	// --  FONT  ---------------------------------------------------------------------- //
	// NOTE configure font framebuffer
	gl.GenFramebuffers(1, &glState.FontFramebuffer);
	gl.BindFramebuffer(gl.FRAMEBUFFER, glState.FontFramebuffer);

	gl.GenTextures(1, &glState.MultisampledFontTexture);
	gl.BindTexture(gl.TEXTURE_2D_MULTISAMPLE, glState.MultisampledFontTexture);
	gl.TexImage2DMultisample(gl.TEXTURE_2D_MULTISAMPLE, 2, gl.RGBA, i32(UI_FONT_TEXTURE_RES), i32(UI_FONT_TEXTURE_RES), gl.TRUE);
	gl.BindTexture(gl.TEXTURE_2D_MULTISAMPLE, 0);
	gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D_MULTISAMPLE, glState.MultisampledFontTexture, 0);

	{
		gl.GenFramebuffers(1, &glState.IntermediateFontFrameBuffer);
		gl.BindFramebuffer(gl.FRAMEBUFFER, glState.IntermediateFontFrameBuffer);
		
		gl.GenTextures(1, &glState.FontTexture);
		gl.BindTexture(gl.TEXTURE_2D, glState.FontTexture);
		gl.GenerateMipmap(gl.TEXTURE_2D);
		gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
		gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
		gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

		gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, i32(UI_FONT_TEXTURE_RES), i32(UI_FONT_TEXTURE_RES), 0, gl.RGBA, gl.UNSIGNED_BYTE, nil);
		
		gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, glState.FontTexture, 0);
		if gl.CheckFramebufferStatus(gl.FRAMEBUFFER) != gl.FRAMEBUFFER_COMPLETE do fmt.println("ERROR::FRAMEBUFFER:: Framebuffer is not complete!");
		gl.BindFramebuffer(gl.FRAMEBUFFER, 0);
	}
	// -------------------------------------------------------------------------------- //
}


OpenglRender :: proc(Show: ^show)
{
	// good
	gl.BindFramebuffer(gl.FRAMEBUFFER, 0);
	gl.Viewport(0, 0, i32(Show.State.WindowRes.x), i32(Show.State.WindowRes.y));
	gl.ClearColor(0, 1, 0, 1)
	gl.Clear(gl.COLOR_BUFFER_BIT)

	OpenglRectTest(Show)
	// PushQuad(Show, {0,0,250,250}, {0,0,1,1}, {1,1,0,0}, 0)
	// PushQuad(Show, {250,0,1250,1000}, {0,0,1,1}, {1,1,0,0}, 0)
	
	OpenglRenderUI(Show)
	// TTDraw(Show)
	// TTTestRect(Show)
	// OpenglRenderGeneratedUIFont(Show)
	glfw.SwapBuffers(Show.State.glState.Window)
}

OpenglRenderUI :: proc(Show: ^show)
{
	gl.UseProgram(Show.State.glState.ui_shader)
	gl.BindTexture(gl.TEXTURE_2D, Show.State.glState.FontTexture)

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

OpenglRectTest :: proc(Show: ^show)
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

PushQuad :: proc(Show: ^show, Q: v4, UV: [4]f32, Color: v4, Border: f32)
{
	if Show.State.glState.QuadIndex < MAX_UI_ELEMENTS
	{

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
		
		Quad := QuadTo32(Q)
		if Border == 0
		{
			/// {1, 1, 0, 0}
			l := (Quad[0] - W) / W;
			b := (Quad[1] - H) / H;
			r := (Quad[2] - W) / W;
			t := (Quad[3] - H) / H;
			
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
		else
		{
			L := (Quad[0] - W) / W;
			B := (Quad[1] - H) / H;
			R := (Quad[2] - W) / W;
			T := (Quad[3] - H) / H;
			
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

OpenglGenerateUIFont :: proc(Show: ^show)
{
	glState := Show.State.glState;
	//- NOTE Render to Font Framebuffer 
	gl.Viewport(0, 0, i32(UI_FONT_TEXTURE_RES), i32(UI_FONT_TEXTURE_RES));
	gl.BindFramebuffer(gl.FRAMEBUFFER, Show.State.glState.FontFramebuffer);
	gl.ClearColor( 0, 0, 0, 0);
	gl.Clear(gl.COLOR_BUFFER_BIT);
	gl.UseProgram(glState.font_shader);
	
	Font := Show.Assets.Font

	for G, i in Font.Glyphs
	{
		Show.State.UIFontOffset[i].y = G.ybounds[0]
		Show.State.UIFontOffset[i].x = G.advance

		if i > 0
		{
			Row    :f32= linalg.floor(f32(i) / 10)
			Column :f32= linalg.floor(f32(i) - (Row * 10))

			Scale : linalg.Matrix4x4f32 = {
				0.05, 	0, 		0,  	0,
				0, 		0.05, 	0,  	0,
				0, 		0, 		1,  	0,
				0,		0,		0,		1,							
			}

			Transform : [2]f32 = {Column/5, (f32(Row)/5) - (G.ybounds[0]/10)};

			glColor		:= gl.GetUniformLocation(glState.font_shader, "color")
			glScale		:= gl.GetUniformLocation(glState.font_shader, "scale")
			glTransform	:= gl.GetUniformLocation(glState.font_shader, "transform")
			
			gl.Uniform4f(glColor, 1, 1, 1, 1)
			gl.UniformMatrix4fv(glScale, 1, gl.FALSE, &Scale[0][0])
			gl.Uniform2f(glTransform, Transform[0], Transform[1])
			
			gl.BindBuffer(gl.ARRAY_BUFFER, glState.VertexBuffer);
			gl.BufferData(gl.ARRAY_BUFFER, len(G.Verts)*size_of(f32), &G.Verts[0], gl.STATIC_DRAW);
			
			gl.EnableVertexAttribArray(0);
			gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, uintptr(0));
			
			gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, glState.IndexBuffer);
			gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(G.Indices)*size_of(u32), &G.Indices[0], gl.STATIC_DRAW);
			
			gl.DrawElements(gl.TRIANGLES, i32(len(G.Indices)), gl.UNSIGNED_INT, nil);
		}
	}
	gl.BindFramebuffer(gl.READ_FRAMEBUFFER, glState.FontFramebuffer);
	gl.BindFramebuffer(gl.DRAW_FRAMEBUFFER, glState.IntermediateFontFrameBuffer);
	gl.BlitFramebuffer(0, 0, i32(UI_FONT_TEXTURE_RES), i32(UI_FONT_TEXTURE_RES), 0, 0, i32(UI_FONT_TEXTURE_RES), i32(UI_FONT_TEXTURE_RES), gl.COLOR_BUFFER_BIT, gl.NEAREST);
}