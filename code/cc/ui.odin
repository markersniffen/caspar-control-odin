package cc

import "core:fmt"

MAX_UI_ELEMENTS :: 4096
UI_MARGIN :: 6
UI_HEIGHT :: 20
UI_TAB    :: 120
UI_TEXT_OFFSET :: 2
UI_TEXT_TAB :: 4
UI_CURSOR_THICK :: 3

// COLORS
BG		:: v3	{0.1,	0.1,	0.1}
BG_BAR	:: v3	{0.2,	0.2,	0.2}
BORDER	:: v3	{0.5,	0.5,	0.5}
BUTTON 	:: v3	{0.1,	0.2,	1.0}
BLUE	:: v3	{0.4,	0.3,	1.0}
RED 	:: v3	{1.0,	0.2,	0.4}
GREEN	:: v3	{0.2,	1.0,	0.4}

UIInit			:: proc(Show: ^show)
{
	MasterPanelUI := UICreatePanel(Show, 0, .X)
}

UIUpdate		:: proc(Show: ^show)
{
	Show.State.UIPanelCTX = {0,0,Show.State.WindowRes.x, Show.State.WindowRes.y}
	UIRenderPanel(Show, Show.State.UIMasterPanelUID)
}

UICreatePanel	:: proc(Show: ^show, PUID: uid, Direction: ui_direction) -> uid
{
	if PUID == 0
	{
		Show.State.UIMasterPanelUID = GetNewUID(Show)
		Show.State.UIPanels[Show.State.UIMasterPanelUID] = new(ui_panel)
		Show.State.UIPanels[Show.State.UIMasterPanelUID].Direction = Direction
		Show.State.UIPanels[Show.State.UIMasterPanelUID].Size = 1.0
		Show.State.UIPanels[Show.State.UIMasterPanelUID].Type = 0
		return Show.State.UIMasterPanelUID
	} else {
		Parent, Ok := Show.State.UIPanels[PUID]
		if Ok
		{
			UID1 := GetNewUID(Show)
			UID2 := GetNewUID(Show)
			Parent.Children[0] = UID1
			Parent.Children[1] = UID2
			Parent.Size = 0.5

			Show.State.UIPanels[UID1] = new(ui_panel)
			Show.State.UIPanels[UID1].Direction = Direction
			Show.State.UIPanels[UID1].Size = 1.0
			Show.State.UIPanels[UID1].Type = 0

			Show.State.UIPanels[UID2] = new(ui_panel)
			Show.State.UIPanels[UID2].Direction = Direction
			Show.State.UIPanels[UID2].Size = 1.0
			Show.State.UIPanels[UID2].Type = 0
			return UID2
		} else {
			assert(0!=0)
			return 0
		}
	}
}

UIRenderPanel	:: proc(Show: ^show, UID: uid)
{
	P, Ok := Show.State.UIPanels[UID]
	if Ok
	{
		CTX := Show.State.UIPanelCTX;

		CTXa: v4
		CTXb: v4
		L := CTX[0]
		B := CTX[1]
		R := CTX[2]
		T := CTX[3]
		ChildA, Cok := Show.State.UIPanels[P.Children[0]]
		if Cok
		{
			if ChildA.Direction == .X
			{
				L = CTX.x;
				B = CTX.y;
				R = ((CTX[2] - CTX.x) * P.Size) + CTX.x;
				T = CTX[3];
				CTXa	= { L,B,R,T }
				CTXb	= { R,B,CTX[2],CTX[3]}
			} else {
				L = CTX.x;
				B = CTX[3] - ((CTX[3] - CTX[1]) * P.Size);
				R = CTX[2];
				T = CTX[3];
				CTXa	= { L,B,R,T }
				CTXb	= { CTX[0],CTX[1],R,B}
			}
			Show.State.UIPanelCTX = CTXa
			UIRenderPanel(Show, P.Children[0])
			Show.State.UIPanelCTX = CTXb
			UIRenderPanel(Show, P.Children[1])
		}
		if UID != 0
		{
			UIPanel(Show, UID)
		}
	}
}

UIPanel 		:: proc(Show: ^show, PUID: uid)
{
	Panel, Pok:= Show.State.UIPanels[PUID]
	if Pok
	{
		Quad := Show.State.UIPanelCTX;
		PushQuad(Show, Quad, {0,0,0,0}, BG, 2)
			
		if IsInsideBounds(Show.State.MousePos, Quad)
		{
			if Show.State.Mouse != .DRAG
			{
				PushQuad(Show, Quad, {0,0,0,0}, BLUE, 1.5)
				Show.State.UIPanelHot = PUID;
			}

			if Show.State.KeyState[keys.TAB].Active
			{
				Panel.Type += 1
				if Panel.Type > 2 do Panel.Type = 0
			}

			if Show.State.KeyState[keys.N_MINUS].Active
			{
				UICreatePanel(Show, PUID, .X)
				Show.State.KeyState[keys.N_MINUS].Active = false
			}

			if Show.State.KeyState[keys.N_PLUS].Active
			{
				UICreatePanel(Show, PUID, .Y)
				Show.State.KeyState[keys.N_PLUS].Active = false
			}
		}
		Show.State.CTX = {Quad[0] + UI_MARGIN, Quad[3] - UI_MARGIN - UI_HEIGHT, Quad[2] - UI_MARGIN, Quad[3] - UI_MARGIN}

		if Panel.Type == 0 do PlaylistPanel(Show, PUID)
		if Panel.Type == 1 do PropertiesPanel(Show, PUID)
		if Panel.Type == 2 do LibraryPanel(Show, PUID)	
	}
}

UIIterate		:: proc(Show: ^show)	do Show.State.UIIndex += 1

UIAdvanceCTX	:: proc(Show: ^show)	do Show.State.CTX = { Show.State.CTX[0], Show.State.CTX[1] - UI_HEIGHT - UI_MARGIN, Show.State.CTX[2], Show.State.CTX[1] - UI_MARGIN }

UIButtonRaw :: proc(Show: ^show, Name: string, Quad: v4, Just: int) -> bool
{
	Result := false
	Hovering := false
	UIIterate(Show)
	Color := BUTTON
	
	if IsInsideBounds(Show.State.MousePos, Quad)
	{
		Hovering = true;
		Color = RED;
		if Show.State.Mouse == .CLICK
		{
			Result = true;
			Show.State.Mouse = .UP;
		}
	}
	
	PushQuad(Show, Quad, {0,0,0,0}, Color, 0);
	// HalfTextWidth := UITextWidth(Name, UI_HEIGHT-4, Show)/2;
	// PX :f32;
	
	// if Just == 0
	// {
	// 	PX = Quad[0] + ((Quad[2] - Quad[0]) / 2) - HalfTextWidth - UI_TEXT_TAB;
	// } else if Just == 1 {
	// 	PX = Quad[0];
	// } else if Just == -1 {
	// 	PX = Quad[2] - (HalfTextWidth*2) - (UI_TEXT_TAB*2);
	// }
	
	// UIDrawText(Name, {PX, Quad[1]+2}, UI_HEIGHT-4, false, Show);
	
	if Hovering do PushQuad(Show, Quad, {0,0,0,0}, RED, 1);
	return Result;
}

UIButtonX :: proc(Show: ^show, Names: []string) -> string
{
	Result := "";
	Old := Show.State.CTX;
	NumVals := f64(len(Names));
	Margins := UI_MARGIN * (NumVals-1);
	Width :f64= (Show.State.CTX[2] - Show.State.CTX[0] - Margins) / NumVals;
	Show.State.CTX = {Show.State.CTX[0], Show.State.CTX[1], Show.State.CTX[0] + Width, Show.State.CTX[3]};
	
	for N in Names
	{
		if UIButtonRaw(Show, N, Show.State.CTX, 0) do Result = N;
		Show.State.CTX[0] += Width + UI_MARGIN;
		Show.State.CTX[2] = Show.State.CTX[0] + Width;
	}
	
	Show.State.CTX = Old;
	UIAdvanceCTX(Show);
	return Result;
}

ui_panel :: struct
{
	UID: uid,
	Direction: ui_direction,
	Size: f64,
	Children: [2]uid,
	Type: int,
}

ui_direction :: enum
{
	X,
	Y,
}
