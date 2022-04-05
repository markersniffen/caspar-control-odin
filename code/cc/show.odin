package cc

import "core:fmt"

show :: struct
{
	State: state,
}

state :: struct
{
	glState: opengl_state,
	UID: uid,
	BaseDir: string,
	WindowRes: v2,
	Mode: mode,

	// INPUT
	KeyState: [keys.NUMBER_OF_KEYS]key_state,
	DeltaMouse: v2,
	DeltaDrag: v2,
	MousePos: v2,
	Mouse: mouse_state,
	MouseMiddle: mouse_state,
	MouseRight: mouse_state,
	MouseScroll: f64,

	// UI
	UIPanelHot: uid,
	UIIndex: int,
	UIPanelCTX: v4,
	UIMasterPanelUID: uid,
	UIPanels: map[uid]^ui_panel,
	CTX: v4,
	UILastChar: rune,
	// UICharIndex: int,
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

mode :: enum
{
	TYPING,
	EDITING,
}

ShowInit :: proc(Show: ^show)
{
	OpenglInit(Show)
	STBFontInit(Show)
	UIInit(Show)
}

ShowUpdateAndRender :: proc(Show: ^show)
{


	UIUpdate(Show)
	OpenglRender(Show)

	// NOTE reset all the keys
	for k, i in Show.State.KeyState {
		if k.Active
		{
			if i == int(keys.CTRL) || i == int(keys.SHIFT) || i == int(keys.ALT)
			{
			} else 
			{
				Show.State.KeyState[i].Active = false;
			}
			//Show.State.KeyState[i].WasDown = true;
		}
	}
}
