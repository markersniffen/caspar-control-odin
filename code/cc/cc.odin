package cc

import "core:fmt"

ShowInit :: proc(Show: ^show)
{
	// set initial show state
	// pool memory
	// create inital viewports
	OpenglInit(Show)
}

ShowUpdateAndRender :: proc(Show: ^show)
{
	// use input state
	OpenglRender(Show)
}

show :: struct
{
	State: state,
}

state :: struct
{
	BaseDir: string,

	// SETTINGS
	Window: rawptr,
	WindowRes: v2,

	// INPUT
	KeyState: [keys.NUMBER_OF_KEYS]key_state,
	DeltaMouse: v2,
	DeltaDrag: v2,
	MousePos: v2,
	Mouse: mouse_state,
	MouseMiddle: mouse_state,
	MouseRight: mouse_state,
	MouseScroll: f64,
}

key_state :: struct
{
	Active: bool,
	IsDown: bool,
	WasDown: bool,
}

mouse_state :: enum { 
	UP,
	CLICK,
	DRAG,
	LOCKED,
}

keys :: enum
{
	LEFT,
	RIGHT,
	UP,
	DOWN,
	
	ESCAPE,
	TAB,
	ENTER,
	SPACE,
	BACKSPACE,
	DELETE,
	
	N_ENTER,
	N_PLUS,
	N_MINUS,
	
	CTRL,
	ALT,
	SHIFT,
	
	NUMBER_OF_KEYS,
}
