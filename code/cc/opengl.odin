package cc

import "core:math/linalg"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"
import "core:fmt"
import "core:image/png"
import "core:image"

GL_MINOR_VERSION :: 3
GL_MAJOR_VERSION :: 3

opengl_state :: struct
{
	// window
	Window: glfw.WindowHandle,
	
	// shaders
	ui_shader: u32,
	// font_shader: u32,
	// NOTE get rid of this eventually
	texture_shader: u32,

	// UIVertexBuffer: u32,
	// UIIndexBuffer: u32,
	VertexBuffer: u32,
	IndexBuffer: u32,
	
	// // not necessary...
	// FontVertexBuffer: u32,
	// FontIndexBuffer: u32,

	// framebuffers
	// ScreenFrameBuffer: u32,
	// FontFramebuffer: u32,
	// IntermediateFontFrameBuffer: u32,

	// textures
	Texture: u32,
	// MultisampledFontTexture: u32,
	// FontTexture: u32,

}

OpenglInit :: proc(Show: ^show)
{
	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)
	// gl.Enable(gl.DEPTH_TEST)
	// gl.Enable(gl.MULTISAMPLE)
	// gl.Enable(gl.BLEND)



	// gl.GenBuffers(1, &Show.State.glState.UIVertexBuffer)
	// gl.GenBuffers(1, &Show.State.glState.UIIndexBuffer)

	// gl.GenBuffers(1, &Show.State.glState.FontVertexBuffer)
	// gl.GenBuffers(1, &Show.State.glState.FontIndexBuffer)

	gl.GenBuffers(1, &Show.State.glState.VertexBuffer)
	gl.GenBuffers(1, &Show.State.glState.IndexBuffer)
	
	shader_success : bool

	glState := &Show.State.glState

	// Show.State.glState.font_shader, shader_success = gl.load_shaders_source(FONT_VS, FONT_FRAG);
	// if !shader_success do fmt.println("Font shader did not compile!");

	Show.State.glState.ui_shader, shader_success = gl.load_shaders_source(UIMAIN_VS, UIMAIN_FRAG)
	if !shader_success do fmt.println("UIMAIN shader did not compile!")

	Show.State.glState.texture_shader, shader_success = gl.load_shaders_source(TEXTURE_VS, TEXTURE_FRAG)
	if !shader_success do fmt.println("TEXTURE shader did not compile!")

	// -------------------------------------------------------------------------------- //
	// NOTE load image
	options : image.Options
	img, err := png.load("images/dogs.png", options)
	fmt.println(err)
	fmt.println(img.width, img.height, img.channels, img.depth)
	// Create & Bind texture
	gl.GenTextures(1, &Show.State.glState.Texture)
	gl.BindTexture(gl.TEXTURE_2D, Show.State.glState.Texture);
	
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
	
	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, i32(img.width), i32(img.height), 0, gl.RGBA, gl.UNSIGNED_BYTE, raw_data(img.pixels.buf));
	// -------------------------------------------------------------------------------- //



	// // NOTE configure font framebuffer
	// gl.GenFramebuffers(1, &glState.FontFramebuffer);
	// gl.BindFramebuffer(gl.FRAMEBUFFER, glState.FontFramebuffer);
	
	// gl.GenTextures(1, &glState.MultisampledFontTexture);
	// gl.BindTexture(gl.TEXTURE_2D_MULTISAMPLE, glState.MultisampledFontTexture);
	// gl.TexImage2DMultisample(gl.TEXTURE_2D_MULTISAMPLE, 8, gl.RGBA, i32(UI_FONT_TEXTURE_RES), i32(UI_FONT_TEXTURE_RES), gl.TRUE);
	// gl.BindTexture(gl.TEXTURE_2D_MULTISAMPLE, 0);
	// gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D_MULTISAMPLE, glState.MultisampledFontTexture, 0);

	// {
	// 	gl.GenFramebuffers(1, &glState.IntermediateFontFrameBuffer);
	// 	gl.BindFramebuffer(gl.FRAMEBUFFER, glState.IntermediateFontFrameBuffer);
		
	// 	gl.GenTextures(1, &glState.FontTexture);
	// 	gl.BindTexture(gl.TEXTURE_2D, glState.FontTexture);
	// 	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
	// 	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
	// 	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
	// 	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
	// 	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, i32(UI_FONT_TEXTURE_RES), i32(UI_FONT_TEXTURE_RES), 0, gl.RGBA, gl.UNSIGNED_BYTE, nil);
		
	// 	gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, glState.FontTexture, 0);
	// 	if gl.CheckFramebufferStatus(gl.FRAMEBUFFER) != gl.FRAMEBUFFER_COMPLETE do fmt.println("ERROR::FRAMEBUFFER:: Framebuffer is not complete!");
	// 	gl.BindFramebuffer(gl.FRAMEBUFFER, 0);
	// }
}


OpenglRender :: proc(Show: ^show)
{
	// glState := Show.State.glState;
	// Vertices := Show.State.Vertices;
	// Indices := Show.State.Indices;

	// good
	gl.BindFramebuffer(gl.FRAMEBUFFER, 0);
	gl.Viewport(0, 0, i32(Show.State.WindowRes.x), i32(Show.State.WindowRes.y));
	gl.ClearColor(0, 0, 0, 1)
	gl.Clear(gl.COLOR_BUFFER_BIT)

	// gl.UseProgram(glState.ui_shader);
	// gl.BindTexture(gl.TEXTURE_2D, glState.FontTexture);

	// gl.BindBuffer(gl.ARRAY_BUFFER, glState.UIVertexBuffer);
	// gl.BufferData(gl.ARRAY_BUFFER, Show.State.VIndex * size_of(f32), &Vertices[0], gl.DYNAMIC_DRAW);
	
	// // position (2)
	// gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, 7*size_of(f32), uintptr(0));
	// gl.EnableVertexAttribArray(0);
	// // color (3)
	// gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 7*size_of(f32), uintptr(size_of([2]f32)));
	// gl.EnableVertexAttribArray(1);
	// // UVs (2)
	// gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, 7*size_of(f32), uintptr(size_of(f64) * 5));
	// gl.EnableVertexAttribArray(2);
	
	// gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, glState.UIIndexBuffer);
	// gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, Show.State.IIndex * size_of(f32), &Indices[0], gl.DYNAMIC_DRAW);
	
	// gl.DrawElements(gl.TRIANGLES, i32(Show.State.IIndex), gl.UNSIGNED_INT, nil);

	OpenglRectTest(Show)
	glfw.SwapBuffers(Show.State.glState.Window)
}

OpenglRectTest :: proc(Show: ^show)
{
	gl.UseProgram(Show.State.glState.ui_shader);
	gl.BindTexture(gl.TEXTURE_2D, Show.State.glState.Texture);


	Vertices: [80]f32 = {
		// position			UV 			Color 		Texture Mix
	   	-1, 	-1, 0.0,	1.0, 1.0,	0,0,0,1,	0.5,
	    -1,	 	 0, 0.0,	1.0, 0.0,	0,0,0,1,	0.5,
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

OpenglRenderTextureRect :: proc(Show: ^show)
{
	// gl.UseProgram(Show.State.glState.texture_shader);
	// gl.BindTexture(gl.TEXTURE_2D, Show.State.glState.Texture);

	// Vertices: [20]f32 = {
	//    	-0.5, -0.5, 0.0,	1.0, 1.0,
	//     -0.5,  0.5, 0.0,	1.0, 0.0,
	//      0.5,  0.5, 0.0,	0.0, 0.0,
	//      0.5, -0.5, 0.0,	0.0, 1.0,
	// }

	// Indices: [6]u32 = {	
	// 	0,1,2, // first triangle
 //        0,2,3,
	// }
	
	// gl.BindBuffer(gl.ARRAY_BUFFER, Show.State.glState.VertexBuffer);
	// gl.BufferData(gl.ARRAY_BUFFER, size_of(Vertices), &Vertices[0], gl.STATIC_DRAW);
	
	// gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 5 * size_of(f32), 0 * size_of(f32))
	// gl.EnableVertexAttribArray(0)

	// gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, Show.State.glState.IndexBuffer);
	// gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(Indices), &Indices[0], gl.STATIC_DRAW);

	// gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 5 * size_of(f32), 3 * size_of(f32))
	// gl.EnableVertexAttribArray(1)

	// // bind vertex/UV data to buffer

	// gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil);
}

OpenglGenerateUIFont :: proc(Show: ^show)
{
	// fmt.println("Generating UI font.....");
	// glState := Show.State.glState;
	// //- NOTE Render to Font Framebuffer 
	// gl.Viewport(0, 0, i32(UI_FONT_TEXTURE_RES), i32(UI_FONT_TEXTURE_RES));
	// gl.BindFramebuffer(gl.FRAMEBUFFER, glState.FontFramebuffer);
	// gl.ClearColor( 0, 0, 0, 1);
	// gl.Clear(gl.COLOR_BUFFER_BIT);
	// gl.UseProgram(glState.font_shader);
	
	// Dim :f64= UI_FONT_TEXTURE_RES/10;
	// AspectMat: linalg.Matrix4x4f32 = {
	// 	0.1,0,0,-1,
	// 	0,0.1,0,-1,
	// 	0, 0,1,0,
	// 	0,0,0,1,
	// }
	
	// Font := Show.Assets.Font

	// for G, i in Font.Glyphs
	// {
	// 	Show.State.UIFontOffset[i].y = G.ybounds[0];
	// 	Show.State.UIFontOffset[i].x = G.advance;
	// 	if i > 0
	// 	{
	// 		Row    := i/10;
	// 		Column := i - (Row * 10);
	// 		// NOTE render glyph
	// 		Transform : linalg.Matrix4x4f32 = {
	// 			1, 0, 0,   f32(Column)/5,
	// 			0, 1, 0,   f32(Row)/5 - (G.ybounds[0]/10),
	// 			0, 0, 1,   0, 
	// 			0, 0, 0,   1,
	// 		};
			
	// 		Pos :v2= {Dim*f64(Column), Dim*f64(Row)};
	// 		Size :v2= Pos + {Dim, Dim};
			
	// 		// NOTE calculates the offset matrices for each glyph
	// 		glAspect:= gl.GetUniformLocation(glState.font_shader, "Aspect");
	// 		glColor := gl.GetUniformLocation(glState.font_shader, "color");
	// 		glTransform:= gl.GetUniformLocation(glState.font_shader, "Transform");
	// 		glAlpha := gl.GetUniformLocation(glState.font_shader, "Alpha");
	// 		glAdv := gl.GetUniformLocation(glState.font_shader, "Adv");
			
	// 		gl.UniformMatrix4fv(glAspect, 1, gl.FALSE, &AspectMat[0][0]);
	// 		gl.Uniform4f(glColor, 1, 1, 1, 1);
	// 		gl.Uniform1f(glAlpha, 1);
	// 		gl.UniformMatrix4fv(glTransform, 1, gl.FALSE, &Transform[0][0]);
	// 		gl.Uniform2f(glAdv, 0, 0);
			
	// 		gl.BindBuffer(gl.ARRAY_BUFFER, glState.FontVertexBuffer);
	// 		gl.BufferData(gl.ARRAY_BUFFER, len(G.Verts)*size_of(f32), &G.Verts[0], gl.STATIC_DRAW);
			
	// 		gl.EnableVertexAttribArray(0);
	// 		gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, uintptr(0));
			
	// 		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, glState.FontIndexBuffer);
	// 		gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(G.Indices)*size_of(u32), &G.Indices[0], gl.STATIC_DRAW);
			
	// 		gl.DrawElements(gl.TRIANGLES, i32(len(G.Indices)), gl.UNSIGNED_INT, nil);
	// 	}
	// }
	
	// gl.BindFramebuffer(gl.READ_FRAMEBUFFER, glState.FontFramebuffer);
	// gl.BindFramebuffer(gl.DRAW_FRAMEBUFFER, glState.IntermediateFontFrameBuffer);
	// gl.BlitFramebuffer(0, 0, i32(UI_FONT_TEXTURE_RES), i32(UI_FONT_TEXTURE_RES), 0, 0, i32(UI_FONT_TEXTURE_RES), i32(UI_FONT_TEXTURE_RES), gl.COLOR_BUFFER_BIT, gl.NEAREST);
}

PushQuad :: proc(Show: ^show, Q: v4, UV: [4]f32, Color: v3, Border: f32)
{
	State := &Show.State
	if State.QuadIndex < MAX_UI_ELEMENTS
	{

		W := f32(State.WindowRes.x/2);
		H := f32(State.WindowRes.y/2);
		C := f32(0.0);
		u:f32= 0;
		v:f32= 1;
		uvl:f32= UV[0];
		uvb:f32= UV[1];
		uvr:f32= UV[2];
		uvt:f32= UV[3];
		
		// if ColorIndex != ui_color_types.FONT
		if Color == WHITE
		{
			u   = -1;
			v   = u;
			uvl = u;
			uvb = u;
			uvr = u;
			uvt = u;
		}
		
		c1 := f32(Color[0]);
		c2 := f32(Color[1]);
		c3 := f32(Color[2]);
		
		Quad := QuadTo32(Q)
		if Border == 0
		{
			l := (Quad[0] - W) / W;
			b := (Quad[1] - H) / H;
			r := (Quad[2] - W) / W;
			t := (Quad[3] - H) / H;
			
			V :[28]f32 = { l,b,c1,c2,c3,uvl,uvb,  l,t,c1,c2,c3,uvl,uvt,  r,t,c1,c2,c3,uvr,uvt,  r,b,c1,c2,c3,uvr,uvb };
			copy(State.Vertices[State.VIndex:State.VIndex+28], V[:]);
			State.VIndex += 28;
			
			QI := u32(State.QuadIndex * 4);
			I :[6]u32 = {0+QI, 1+QI, 2+QI, 0+QI, 2+QI, 3+QI};
			copy(State.Indices[State.IIndex:State.IIndex+6], I[:]);
			State.IIndex += 6;
			State.QuadIndex += 1;
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
			
			V :[24]f32 = { L,T,C, R,T,C, R,B,C, L,B,C,  L2,T2,C, R2,T2,C, R2,B2,C, L2,B2,C};
			I :[24]u32 = { 0,1,5, 0,5,4, 1,6,5, 1,2,6,  2,7,6,   2,3,7,   3,4,7,   3,0,4  };
			
			VArrays :[4][28]f32= {
				{ L,T,c1,c2,c3,u,v, R,T,c1,c2,c3,u,v, R2,T2,c1,c2,c3,u,v, L2,T2,c1,c2,c3,u,v },
				{ R,T,c1,c2,c3,u,v, R,B,c1,c2,c3,u,v, R2,B2,c1,c2,c3,u,v, R2,T2,c1,c2,c3,u,v },
				{ R,B,c1,c2,c3,u,v, L,B,c1,c2,c3,u,v, L2,B2,c1,c2,c3,u,v, R2,B2,c1,c2,c3,u,v },
				{ L,B,c1,c2,c3,u,v, L,T,c1,c2,c3,u,v, L2,T2,c1,c2,c3,u,v, L2,B2,c1,c2,c3,u,v },
			}
			
			for VA in &VArrays
			{
				QI := u32(State.QuadIndex * 4);
				I1 :[6]u32 = {0+QI, 1+QI, 3+QI, 1+QI, 2+QI, 3+QI};
				
				copy(State.Vertices[State.VIndex:State.VIndex+28], VA[:]);
				State.VIndex += 28;
				
				copy(State.Indices[State.IIndex:State.IIndex+6], I1[:]);
				State.IIndex += 6;
				State.QuadIndex += 1;
			}
		}
	}
}