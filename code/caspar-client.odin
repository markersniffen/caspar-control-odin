package casparclient

import "/cc"
import "vendor:glfw"
import "core:fmt"

WIDTH  	:: 1280
HEIGHT 	:: 720
TITLE 	:: "CasparCG Client | Odin"

main :: proc() {
	using cc
	
	if !bool(glfw.Init())
	{
		fmt.eprintln("GLFW has failed to load.")
		return
	}

	window := glfw.CreateWindow(WIDTH, HEIGHT, TITLE, nil, nil)
	defer glfw.Terminate()
	defer glfw.DestroyWindow(window)

	if window == nil
	{
		fmt.eprintln("GLFW has failed to load the window.")
		return
	}

	glfw.MakeContextCurrent(window)
	glfw.SetKeyCallback(window, cast(glfw.KeyProc)keyboard_callback)
	glfw.SetMouseButtonCallback(window, cast(glfw.MouseButtonProc)mouse_callback)
	glfw.SetScrollCallback(window, cast(glfw.ScrollProc)scroll_callback)
	glfw.SetCharCallback(window, cast(glfw.CharProc)typing_callback)
	
	//- NOTE Initialize Show
	Show = new(show)
	defer free(Show)
	glfw.SetWindowUserPointer(window, Show)
	Show.State.glState.Window = window
	ShowInit()

	for !glfw.WindowShouldClose(window)
	{
		glfw.PollEvents()

		X, Y := glfw.GetWindowSize(window)
		Show.State.WindowRes.x = f64(X)
		Show.State.WindowRes.y = f64(Y)
		
		mX, mY := glfw.GetCursorPos(window)
		OldMouse := Show.State.MousePos
		Show.State.MousePos.x = mX
		Show.State.MousePos.y = mY
		Show.State.DeltaMouse = Show.State.MousePos - OldMouse

		// NOTE all render functions
		ShowUpdateAndRender()
		Show.State.MouseScroll = 0
	}
}

process_keyboard_input :: proc(Action: int, State: ^cc.key_state, CanToggle: bool) -> cc.key_state
{
	Result := State
	
	// NOTE on initial press
	if Action == int(glfw.PRESS)
	{
		State.Active = true
		if !State.WasDown do State.Active = true
		State.WasDown = true
	}
	else if Action == int(glfw.REPEAT) && CanToggle
	{
		State.IsDown = true
		if !State.WasDown do State.Active = true
		State.Active = false
	}
	else if Action == int(glfw.REPEAT) && !CanToggle
	{
		State.IsDown = true
	}
	else
	{
		State.IsDown = false
		State.Active = false
		State.WasDown = false
	}
	return Result^
}

keyboard_callback :: proc(window: glfw.WindowHandle, key: int, scancode: int, action: int, mods: int)
{
	using cc, fmt
	
	switch key
	{
		case glfw.KEY_LEFT:
		process_keyboard_input(action, &Show.State.KeyState[keys.LEFT], true)
		case glfw.KEY_RIGHT:
		process_keyboard_input(action, &Show.State.KeyState[keys.RIGHT], true)
		case glfw.KEY_UP:
		process_keyboard_input(action, &Show.State.KeyState[keys.UP], true)
		case glfw.KEY_DOWN:
		process_keyboard_input(action, &Show.State.KeyState[keys.DOWN], true)
		
		case glfw.KEY_ESCAPE:
		process_keyboard_input(action, &Show.State.KeyState[keys.ESCAPE], true)
		case glfw.KEY_TAB:
		process_keyboard_input(action, &Show.State.KeyState[keys.TAB], false)
		case glfw.KEY_ENTER:
		process_keyboard_input(action, &Show.State.KeyState[keys.ENTER], true)
		case glfw.KEY_SPACE:
		process_keyboard_input(action, &Show.State.KeyState[keys.SPACE], true)
		case glfw.KEY_BACKSPACE:
		process_keyboard_input(action, &Show.State.KeyState[keys.BACKSPACE], true)
		case glfw.KEY_DELETE:
		process_keyboard_input(action, &Show.State.KeyState[keys.DELETE], true)
		
		case glfw.KEY_KP_ENTER:
		process_keyboard_input(action, &Show.State.KeyState[keys.ENTER], true)
		case glfw.KEY_KP_SUBTRACT:
		process_keyboard_input(action, &Show.State.KeyState[keys.N_MINUS], false)
		case glfw.KEY_KP_ADD:
		process_keyboard_input(action, &Show.State.KeyState[keys.N_PLUS], false)
		
		case glfw.KEY_LEFT_ALT:
		process_keyboard_input(action, &Show.State.KeyState[keys.ALT], false)
		case glfw.KEY_RIGHT_ALT:
		process_keyboard_input(action, &Show.State.KeyState[keys.ALT], false)
		
		case glfw.KEY_LEFT_CONTROL:
		process_keyboard_input(action, &Show.State.KeyState[keys.CTRL], false)
		case glfw.KEY_RIGHT_CONTROL:
		process_keyboard_input(action, &Show.State.KeyState[keys.CTRL], false)
		
		case glfw.KEY_LEFT_SHIFT:
		process_keyboard_input(action, &Show.State.KeyState[keys.SHIFT], false)
		case glfw.KEY_RIGHT_SHIFT:
		process_keyboard_input(action, &Show.State.KeyState[keys.SHIFT], false)
	}
}

mouse_callback :: proc(window: glfw.WindowHandle, button: int, action: int, mods: int)
{
	using cc
	if button == int(glfw.MOUSE_BUTTON_LEFT)
	{
		if action == int(glfw.PRESS) do Show.State.Mouse = .CLICK
		if action == int(glfw.RELEASE) do Show.State.Mouse = .UP
	}
	
	if button == int(glfw.MOUSE_BUTTON_MIDDLE)
	{
		if action == int(glfw.PRESS) do Show.State.MouseMiddle = .CLICK
		if action == int(glfw.RELEASE) do Show.State.MouseMiddle = .UP
	}
	
	if button == int(glfw.MOUSE_BUTTON_RIGHT)
	{
		if action == int(glfw.PRESS) do Show.State.MouseRight = .CLICK
		if action == int(glfw.RELEASE) do Show.State.MouseRight = .UP
	}
}

scroll_callback :: proc(window: glfw.WindowHandle, x: f64, y: f64)
{
	using cc
	Show.State.MouseScroll = y/10
}

typing_callback :: proc(window: glfw.WindowHandle, codepoint: u32)
{
	using cc
	if Show.State.Mode == .TYPING
	{
		Show.State.UILastChar = rune(codepoint);
	}
}