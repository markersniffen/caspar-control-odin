package cc

import "core:fmt"
import stb "vendor:stb/truetype"

MAX_UI_ELEMENTS :: 4096
UI_MARGIN :: 6
UI_HALF_MARGIN :: UI_MARGIN / 2
UI_HEIGHT :: 20
UI_TEXT_HEIGHT :: 20
UI_TAB    :: 120
UI_TEXT_OFFSET :: 2
UI_TEXT_TAB :: 4
UI_CURSOR_THICK :: 3

// COLORS
WHITE	:: v4	{1.0,	1.0,	1.0,	1.0}
BLUE	:: v4	{0.2,	0.3,	1.0,	1.0}
RED 	:: v4	{1.0,	0.2,	0.4,	1.0}
GREEN	:: v4	{0.2,	1.0,	0.4,	1.0}

BG		:: v4	{0.1,	0.1,	0.1,	1.0}
BG_BAR	:: v4	{0.2,	0.2,	0.2,	1.0}
BORDER	:: v4	{0.5,	0.5,	0.5,	1.0}
BUTTON 	:: v4	{0.2,	0.3,	1.0,	1.0}
HOVER 	:: v4	{0.3,	0.5,	1.0,	1.0}

UIInit			:: proc(Show: ^show)
{
	Master, _ := UICreatePanel(Show, 0, .X, 1)
	NewMaster, Panel2 := UICreatePanel(Show, Master, .X, 0.75)
	UICreatePanel(Show, NewMaster, .Y, 0.3)
}

UIUpdate		:: proc(Show: ^show)
{
	Show.State.UIPanelCTX = {0,0,Show.State.WindowRes.x, Show.State.WindowRes.y}
	UIRenderPanel(Show, Show.State.UIMasterPanelUID)
}

UICreatePanel	:: proc(Show: ^show, PUID: uid, Direction: ui_direction, Size: f64) -> (uid, uid)
{
	if PUID == 0 // the first panel created
	{
		Show.State.UIMasterPanelUID = GetNewUID(Show)
		Show.State.UIPanels[Show.State.UIMasterPanelUID] = new(ui_panel)
		Show.State.UIPanels[Show.State.UIMasterPanelUID].Direction = Direction
		Show.State.UIPanels[Show.State.UIMasterPanelUID].Size = 1.0
		Show.State.UIPanels[Show.State.UIMasterPanelUID].Type = 0
		Show.State.UIPanels[Show.State.UIMasterPanelUID].UID = Show.State.UIMasterPanelUID
		return Show.State.UIMasterPanelUID, Show.State.UIMasterPanelUID
	} else { // all other panels
		fmt.println("Creating panel in ", PUID)
		Parent, Ok := Show.State.UIPanels[PUID]
		if Ok
		{
			UID1 := GetNewUID(Show)
			UID2 := GetNewUID(Show)
			fmt.println("NEW UIDS", UID1, UID2)
			Parent.Children[0] = UID1
			Parent.Children[1] = UID2
			Parent.Size = Size

			Show.State.UIPanels[UID1] = new(ui_panel)
			Show.State.UIPanels[UID1].Direction = Direction
			Show.State.UIPanels[UID1].Size = 1.0
			Show.State.UIPanels[UID1].Type = 0
			Show.State.UIPanels[UID1].UID = UID1

			Show.State.UIPanels[UID2] = new(ui_panel)
			Show.State.UIPanels[UID2].Direction = Direction
			Show.State.UIPanels[UID2].Size = 1.0
			Show.State.UIPanels[UID2].Type = 0
			Show.State.UIPanels[UID2].UID = UID2
			fmt.println(Parent)
			fmt.println(Show.State.UIPanels[UID1])
			fmt.println(Show.State.UIPanels[UID2])
			return UID1, UID2

		} else {
			assert(0!=0)
			return 0, 0
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
		T := CTX[1]
		R := CTX[2]
		B := CTX[3]
		ChildA, Cok := Show.State.UIPanels[P.Children[0]]
		if Cok
		{
			if ChildA.Direction == .X // minus key
			{
				L = CTX[0]
				T = CTX[1]
				R = ((CTX[2] - CTX[0]) * P.Size) + CTX[0]
				B = CTX[3]
				CTXa	= { L,T,R,B }
				CTXb	= { R,T,CTX[2],CTX[3]}
			} else {				  // plus key
				L = CTX[0]
				T = CTX[1]
				R = CTX[2]
				B = CTX[3] - ((CTX[3] - CTX[1]) * P.Size);
				CTXa	= { L,T,R,B }
				CTXb	= { L,B,R,CTX[3]}
			}
			Show.State.UIPanelCTX = CTXa
			UIRenderPanel(Show, P.Children[0])
			Show.State.UIPanelCTX = CTXb
			UIRenderPanel(Show, P.Children[1])
		} else {
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
		PushQuad(Show, Quad, {0,0,0,0}, BORDER, 1)
		if IsInsideBounds(Show.State.MousePos, Quad)
		{
			if Show.State.Mouse != .DRAG
			{
				PushQuad(Show, Quad, {0,0,0,0}, BORDER, 1.5) // hover over panel
				Show.State.UIPanelHot = PUID;
			}

			if Show.State.KeyState[keys.TAB].Active
			{
				Panel.Type += 1
				if Panel.Type > 3 do Panel.Type = 0
			}

			if Show.State.KeyState[keys.N_PLUS].Active
			{
				fmt.println("PLUS")
				UICreatePanel(Show, PUID, .Y, 0.5)
				Show.State.KeyState[keys.N_PLUS].Active = false
			}

			if Show.State.KeyState[keys.N_MINUS].Active
			{
				UICreatePanel(Show, PUID, .X, 0.5)
				Show.State.KeyState[keys.N_MINUS].Active = false
			}
		}
		Show.State.CTX = {Quad[0] + UI_MARGIN, Quad[1] + UI_MARGIN, Quad[2] - UI_MARGIN, Quad[1] + UI_MARGIN + UI_HEIGHT }

		if Panel.Type == 0 do DebugPanel(Show, PUID)
		if Panel.Type == 1 do PropertiesPanel(Show, PUID)
		if Panel.Type == 2 do LibraryPanel(Show, PUID)	
		if Panel.Type == 3 do PlaylistPanel(Show, PUID)
	}
}

UIIterate		:: proc(Show: ^show)	do Show.State.UIIndex += 1

UIAdvanceCTX	:: proc(Show: ^show)	do Show.State.CTX = { Show.State.CTX[0], Show.State.CTX[3] + UI_MARGIN, Show.State.CTX[2], Show.State.CTX[3] + UI_MARGIN + UI_HEIGHT }

UIButtonRaw :: proc(Show: ^show, Name: string, Quad: v4, Just: ui_justification) -> bool
{
	Result := false
	Hovering := false
	UIIterate(Show)
	Color := BUTTON
	
	if IsInsideBounds(Show.State.MousePos, Quad)
	{
		Hovering = true;
		Color = HOVER;
		if Show.State.Mouse == .CLICK
		{
			Result = true;
			Show.State.Mouse = .UP;
		}
	}
	PushQuad(Show, Quad, {0,0,0,0}, Color, 0);

	UIDrawText(Show, Name, Quad, Just, false);
	
	if Hovering do PushQuad(Show, Quad, {0,0,0,0}, BUTTON, 2);
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
		if UIButtonRaw(Show, N, Show.State.CTX, .CENTER) do Result = N;
		Show.State.CTX[0] += Width + UI_MARGIN;
		Show.State.CTX[2] = Show.State.CTX[0] + Width;
	}
	
	Show.State.CTX = Old;
	UIAdvanceCTX(Show);
	return Result;
}

UIText :: proc(Show: ^show, Label: string, Value: any)
{
	Text :string = fmt.tprint(Label, Value)
	UIIterate(Show);
	PushQuad(Show, Show.State.CTX, {0,0,0,0}, BG_BAR, 0)
	UIDrawText(Show, Text, Show.State.CTX, .LEFT, false)
	UIAdvanceCTX(Show)
}

UIDrawText :: proc(Show: ^show, Text: string, Quad: v4, Justified: ui_justification, Editing: bool)
{
	using stb, fmt

	x:f32= f32(Quad[0])
	y:f32= f32(Quad[3] - UI_HALF_MARGIN - 1)
	q: aligned_quad

	QuadWidth: f32
	QuadHeight: f32
	HalfWidth :f32
	LastPlace :f32
	if Justified == .CENTER
	{
		QuadWidth = f32((Quad[2] - Quad[0])/2)
		QuadHeight = f32((Quad[3] - Quad[1])/2)
		for Letter, i in Text
		{
			GetBakedQuad(raw_data(Show.State.glState.STBCharData), 512, 512, i32(Letter) - 32, &x, &y, &q, true)
			if i == 0 do LastPlace = q.x0

			HalfWidth += (q.x1 - LastPlace)/2
			LastPlace = q.x1
		}
		x = f32(Quad[0])
		y = f32(Quad[3] - UI_HALF_MARGIN - 1)
	}

	for Letter in Text
	{
		GetBakedQuad(raw_data(Show.State.glState.STBCharData), 512, 512, i32(Letter) - 32, &x, &y, &q, true)
		PushText(Show, QuadTo64({q.x0 - HalfWidth + QuadWidth, q.y0, q.x1 - HalfWidth + QuadWidth, q.y1}), {q.s0, q.t1, q.s1, q.t0}, WHITE, 0)
	}
}

// TODO Not needed?
UITextWidth :: proc(Show: ^show, S: string, Size: f64) -> f64
{
	Advance: v2 = {0,0};
	
	if len(S) > 0
	{
		for r, i in S
		{
			Char := r;
			Idx :u64= (u64(Char) - GLYPH_OFFSET);
			if int(Char) != 10
			{
				Advance.x += Size * f64(Show.State.UIFontOffset[Idx].x);
			} else {
				Advance.x = 0;
				Advance.y -= Size;
			}
		}
	}
	return Advance.x;
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

ui_justification :: enum
{
	LEFT,
	CENTER,
	RIGHT,
}