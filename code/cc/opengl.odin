package cc

import gl "vendor:OpenGL"
import glfw "vendor:glfw"
import "core:fmt"

GL_MINOR_VERSION :: 5
GL_MAJOR_VERSION :: 4

opengl_state :: struct
{
	// window
	Window: glfw.WindowHandle,
	
	// shaders
	ui_shader: u32,
	
	UIVertexBuffer: u32,
	UIIndexBuffer: u32,
	
}

OpenglInit :: proc(Show: ^show)
{
	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)
	gl.Enable(gl.MULTISAMPLE)
	gl.Enable(gl.BLEND)

	gl.GenBuffers(1, &Show.State.glState.UIVertexBuffer)
	gl.GenBuffers(1, &Show.State.glState.UIIndexBuffer)

	shader_success : bool

	Show.State.glState.ui_shader, shader_success = gl.load_shaders_source(UI_VS, UI_FRAG)
	if !shader_success do fmt.println("UI shader did not compile!")
}


OpenglRender :: proc(Show: ^show)
{
	glState := Show.State.glState;
	Vertices := Show.State.Vertices;
	Indices := Show.State.Indices;
	gl.ClearColor(0.0, 0.0, 0.0, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT)
	
	gl.UseProgram(glState.ui_shader);
	// gl.BindTexture(gl.TEXTURE_2D, glState.FontTexture);
	
	gl.BindBuffer(gl.ARRAY_BUFFER, glState.UIVertexBuffer);
	gl.BufferData(gl.ARRAY_BUFFER, Show.State.VIndex * size_of(f32), &Vertices[0], gl.DYNAMIC_DRAW);
	
	gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, 7*size_of(f32), uintptr(0));
	gl.EnableVertexAttribArray(0);
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 7*size_of(f32), uintptr(size_of([2]f32)));
	gl.EnableVertexAttribArray(1);
	gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, 7*size_of(f32), uintptr(size_of(f64) * 5));
	gl.EnableVertexAttribArray(2);
	
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, glState.UIIndexBuffer);
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, Show.State.IIndex * size_of(f32), &Indices[0], gl.DYNAMIC_DRAW);
	
	gl.DrawElements(gl.TRIANGLES, i32(Show.State.IIndex), gl.UNSIGNED_INT, nil);
	glfw.SwapBuffers(glState.Window)
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