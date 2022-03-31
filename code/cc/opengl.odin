package cc

import gl "vendor:OpenGL"
import glfw "vendor:glfw"
import "core:fmt"

GL_MINOR_VERSION :: 5
GL_MAJOR_VERSION :: 4

OpenglInit :: proc(Show: ^show)
{
	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)
}

OpenglRender :: proc(Show: ^show)
{
	fmt.println(Show.State.MousePos)	
	gl.ClearColor(f32(Show.State.MousePos.x)/500, 0.0, f32(Show.State.MousePos.y)/500, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT)
}