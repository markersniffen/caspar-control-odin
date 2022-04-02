package cc

import "core:fmt"

ShowInit :: proc(Show: ^show)
{
	OpenglInit(Show)
	ImportFont(Show, 50, "fonts/Roboto-Regular.ttf")
	OpenglGenerateUIFont(Show)
	free(Show.Assets.Font)
	UIInit(Show)
}

ShowUpdateAndRender :: proc(Show: ^show)
{
	Show.State.QuadIndex = 0;
	Show.State.VIndex = 0
	Show.State.IIndex = 0

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

show :: struct
{
	State: state,
	Assets: assets,
}

state :: struct
{
	UID: uid,
	BaseDir: string,

	// SETTINGS
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

	// UI
	UIFontOffset: [NUM_GLYPHS][2]f32,
	// UIPanelPool: pool,
	// UIPanelMain: uid,
	glState: opengl_state,
	Vertices: [MAX_UI_ELEMENTS * 12]f32,
	Indices: [MAX_UI_ELEMENTS * 6]u32,
	QuadIndex: int,
	UILastChar: rune,
	UICharIndex: int,
	UIPanelHot: uid,
	UIIndex: int,
	UIPanelCTX: v4,
	UIMasterPanelUID: uid,
	UIPanels: map[uid]^ui_panel,
	CTX: v4,
	VIndex:int,
	IIndex:int, 
}

assets :: struct
{
	Font: ^superfont,
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
