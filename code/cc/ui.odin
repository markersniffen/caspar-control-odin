package cc

import "core:fmt"
import "core:mem"
import "core:strconv"
import stb "vendor:stb/truetype"



UI_MARGIN :: 2
UI_HALF_MARGIN :: UI_MARGIN / 2
UI_HEIGHT :: 20
UI_MIN_WIDTH :: 60
UI_TEXT_HEIGHT :: 16
UI_TAB    :: 120
UI_TEXT_OFFSET :: 2
UI_TEXT_TAB :: 4
UI_CURSOR_THICK :: 3

// COLORS
WHITE			:: v4	{1.0,	1.0,	1.0,	1.0}
BLUE			:: v4	{0.2,	0.3,	1.0,	1.0}
RED 			:: v4	{1.0,	0.2,	0.4,	1.0}
GREEN			:: v4	{0.2,	1.0,	0.4,	1.0}

BG				:: v4	{0.1,	0.1,	0.1,	1.0}
BG_BAR			:: v4	{0.2,	0.2,	0.2,	1.0}
BG_BAR_ACTIVE	:: v4	{0.3,	0.2,	0.1,	1.0}
BORDER			:: v4	{0.1,	0.3,	0.6,	1.0}
BUTTON 			:: v4	{0.2,	0.3,	1.0,	1.0}
HOVER 			:: v4	{0.3,	0.5,	1.0,	1.0}
HOT				:: v4	{1.0,	0.4,	0.1,	1.0}
ACTIVE			:: v4	{1.2,	0.5,	0.3,	1.0}

UIInit			:: proc()
{
	Master, _ := UICreatePanel(0, .X, 1, 0)
	NewMaster, Panel2 := UICreatePanel(Master, .X, 0.75, 1)
	// UICreatePanel(NewMaster, .Y, 0.3, 2)
	Show.State.TestText = StringToShort("test")
}

UIUpdate		:: proc()
{
	Show.State.UIPanelCTX = {0,0,Show.State.WindowRes.x, Show.State.WindowRes.y}
	UIRenderPanel(Show.State.UIMasterPanelUID)
}

UICreatePanel	:: proc(PUID: uid, Direction: ui_direction, Size: f64, Type: int) -> (uid, uid)
{
	if PUID == 0 // the first panel created
	{
		Show.State.UIMasterPanelUID = GetNewUID()
		Show.State.UIPanels[Show.State.UIMasterPanelUID] = new(ui_panel)
		Show.State.UIPanels[Show.State.UIMasterPanelUID].Parent = PUID
		Show.State.UIPanels[Show.State.UIMasterPanelUID].Direction = Direction
		Show.State.UIPanels[Show.State.UIMasterPanelUID].Size = 1.0
		Show.State.UIPanels[Show.State.UIMasterPanelUID].Type = Type
		Show.State.UIPanels[Show.State.UIMasterPanelUID].UID = Show.State.UIMasterPanelUID
		return Show.State.UIMasterPanelUID, Show.State.UIMasterPanelUID
	} else { // all other panels
		fmt.println("Creating panel in ", PUID)
		Parent, Ok := Show.State.UIPanels[PUID]
		if Ok
		{
			UID1 := GetNewUID()
			UID2 := GetNewUID()
			Parent.Children[0] = UID1
			Parent.Children[1] = UID2
			Parent.Size = Size

			Show.State.UIPanels[UID1] = new(ui_panel)
			Show.State.UIPanels[UID1].Direction = Direction
			Show.State.UIPanels[UID1].Size = 1.0
			Show.State.UIPanels[UID1].Type = Parent.Type
			Show.State.UIPanels[UID1].Parent = PUID
			Show.State.UIPanels[UID1].UID = UID1

			Show.State.UIPanels[UID2] = new(ui_panel)
			Show.State.UIPanels[UID2].Direction = Direction
			Show.State.UIPanels[UID2].Size = 1.0
			Show.State.UIPanels[UID2].Type = Type
			Show.State.UIPanels[UID2].Parent = PUID
			Show.State.UIPanels[UID2].UID = UID2
			return UID1, UID2

		} else {
			assert(0!=0)
			return 0, 0
		}
	}
}

UIDeletePanel	:: proc(UID:uid)
{
	Panel, Ok := Show.State.UIPanels[UID]
	if Ok
	{
		Parent, Pok := Show.State.UIPanels[Panel.Parent]
		if Pok
		{
			Grandpa, Gok := Show.State.UIPanels[Parent.Parent]
			if Gok
			{
				SUID: uid
				if Parent.Children[0] == UID
				{
					SUID = Parent.Children[1]
				} else {
					SUID = Parent.Children[0]
				}
				Sibling, Sok := Show.State.UIPanels[SUID]
				if Sok
				{
					Sibling.Parent = Parent.Parent
					for Child, c in Grandpa.Children
					{
						if Child == Panel.Parent do Grandpa.Children[c] = SUID
					}
					delete_key(&Show.State.UIPanels, Parent.UID)
					delete_key(&Show.State.UIPanels, UID)
				}
			} else {
				fmt.println("failed to find grandparent of", Panel)
			}
		} else {
			fmt.println("failed to find Parent of", Panel)
		}
	} else {
		fmt.println("failed to find panel:", Panel)
	}
}

UIRenderPanel	:: proc(UID: uid)
{
	P, Ok := Show.State.UIPanels[UID]
	if Ok
	{
		P.CTX = Show.State.UIPanelCTX

		CTXa: v4
		CTXb: v4
		L := P.CTX[0]
		T := P.CTX[1]
		R := P.CTX[2]
		B := P.CTX[3]
		ChildA, Cok := Show.State.UIPanels[P.Children[0]]
		if Cok
		{
			if ChildA.Direction == .X // minus key
			{
				L = P.CTX[0]
				T = P.CTX[1]
				R = ((P.CTX[2] - P.CTX[0]) * P.Size) + P.CTX[0]
				B = P.CTX[3]
				CTXa	= { L,T,R,B }
				CTXb	= { R,T,P.CTX[2],P.CTX[3]}
			} else {				  // plus key
				L = P.CTX[0]
				T = P.CTX[1]
				R = P.CTX[2]
				B = P.CTX[3] - ((P.CTX[3] - P.CTX[1]) * P.Size);
				CTXa	= { L,T,R,B }
				CTXb	= { L,B,R,P.CTX[3]}
			}
			Show.State.UIPanelCTX = CTXa
			UIRenderPanel(P.Children[0])
			Show.State.UIPanelCTX = CTXb
			UIRenderPanel(P.Children[1])
		} else {
			UIPanel(UID)
		}
	}
}

UIIterate		:: proc()	do Show.State.UIIndex += 1

UIAdvanceCTX	:: proc(Height :f64= UI_HEIGHT)	do Show.State.CTX = { Show.State.CTX[0], Show.State.CTX[3] + UI_MARGIN, Show.State.CTX[2], Show.State.CTX[3] + UI_MARGIN + Height }

UIButtonRaw 	:: proc(Name: string, Quad: v4, Just: ui_justification) -> bool
{
	Result := false
	Hovering := false
	UIIterate()
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
	PushQuad(Quad, {0,0,0,0}, Color, 0);

	UIDrawText(Name, Quad, Just);
	
	if Hovering do PushQuad(Quad, {0,0,0,0}, BUTTON, 2);
	return Result;
}

UIDrawText 		:: proc(Text: string, Quad: v4, Justified: ui_justification, Editing:= false)
{
	using stb, fmt
	LeftMargin := f32(Quad[0] + 2)
	Baseline := f32(Quad[3] - 5)

	x:= LeftMargin
	y:= Baseline
	q: aligned_quad

	QuadWidth :f32
	QuadHeight:f32
	HalfWidth :f32
	LastPlace :f32

	TextQuad := Quad
	Lines: f64 = 0
	for Letter in Text do if Letter == 10 do Lines += 1
	TextQuad[3] += UI_HEIGHT * Lines

	if Editing do PushQuad(TextQuad, {0,0,0,0}, BG_BAR_ACTIVE, 0)

	// NOTE calculate offset for center justified text
	if Justified == .CENTER
	{
		QuadWidth = f32((Quad[2] - Quad[0])/2)
		QuadHeight = f32((Quad[3] - Quad[1])/2)
		for Letter, i in Text
		{
			GetBakedQuad(raw_data(Show.State.glState.STBCharData), 512, 512, i32(Letter) - 32, &x, &y, &q, true)
			if i == 0 do LastPlace = q.x0
			if x > f32(Quad[2] - 10) do break
			HalfWidth += (q.x1 - LastPlace)/2
			LastPlace = q.x1
		}
		x = LeftMargin - 2
		y = Baseline
	}

	Cursor:v4

	// NOTE draw text
	for Letter, LetterIndex in Text
	{
		CharQuad: v4
		if Letter == 10
		{
			x = LeftMargin
			y += UI_HEIGHT
			CharQuad = {f64(x), f64(y) - UI_HEIGHT, f64(x) + UI_MARGIN, f64(y)}
		} else {
			GetBakedQuad(raw_data(Show.State.glState.STBCharData), 512, 512, i32(Letter) - 32, &x, &y, &q, true)
			if x > f32(Quad[2] - 10) // stop drawing text that goes out of bounds
			{
				GetBakedQuad(raw_data(Show.State.glState.STBCharData), 512, 512, i32('.') - 32, &x, &y, &q, true)
				PushText(QuadTo64({q.x0 - HalfWidth + QuadWidth, q.y0, q.x1 - HalfWidth + QuadWidth, q.y1}), {q.s0, q.t1, q.s1, q.t0}, WHITE, 0)
				break
			}
			if Letter == 32 // if keystroke is spacebar, manually calculate a wide enough quad for cursor
			{
				CharQuad= QuadTo64({q.x0 - HalfWidth + QuadWidth, q.y0, q.x0 + UI_MARGIN - HalfWidth + QuadWidth, q.y1})
			} else {
				CharQuad= QuadTo64({q.x0 - HalfWidth + QuadWidth, q.y0, q.x1 - HalfWidth + QuadWidth, q.y1})
			}
			PushText(CharQuad, {q.s0, q.t1, q.s1, q.t0}, WHITE, 0)
			TextQuad[3] = max(TextQuad[3], f64(y))
		}

		if Editing
		{
			if LetterIndex+1 == Show.State.UICharIndex do Cursor = {CharQuad[2], f64(y - UI_HEIGHT + 5), CharQuad[2] + UI_MARGIN, f64(y + 2)}
		}
	}
	if Editing // draw cursor
	{
		if Show.State.UICharIndex == 0 do Cursor = QuadTo64({LeftMargin, f32(Quad[3] - UI_HEIGHT), LeftMargin + UI_MARGIN, f32(Quad[3])})
		PushQuad(Cursor, {0,0,0,0}, RED, 2)
	}
}

// USE THESE IN PANELS //
UIBar 			:: proc() // Draws a thin, horizontal separator line
{
	UIIterate();
	Show.State.CTX[3] = Show.State.CTX[1] + 2
	PushQuad(Show.State.CTX, {0,0,0,0}, BORDER, 0)
	UIAdvanceCTX()
}

UIButtonX 		:: proc(Names: []string) -> string // draws x number of horizontal buttons
{
	Result := "";
	Old := Show.State.CTX;
	NumVals := f64(len(Names));
	Margins := UI_MARGIN * (NumVals-1);
	Width :f64= (Show.State.CTX[2] - Show.State.CTX[0] - Margins) / NumVals;
	Show.State.CTX = {Show.State.CTX[0], Show.State.CTX[1], Show.State.CTX[0] + Width, Show.State.CTX[3]};
	
	for N in Names
	{
		if UIButtonRaw(N, Show.State.CTX, .CENTER) do Result = N;
		Show.State.CTX[0] += Width + UI_MARGIN;
		Show.State.CTX[2] = Show.State.CTX[0] + Width;
	} 
	
	Show.State.CTX = Old;
	UIAdvanceCTX();
	return Result;
}

UIText 			:: proc(Label: string, Value: any, Editing:= false) // draws text and label(if provided)
{
	Text: string = fmt.tprint(Value)

	UIIterate();
	OldCTX := Show.State.CTX

	if Label != ""
	{
		// set indent/tab end for label
		Show.State.CTX[2] = Show.State.CTX[0] + UI_TAB
		PushQuad(Show.State.CTX, {0,0,0,0}, BG_BAR, 0)
		UIDrawText(Label, Show.State.CTX, .LEFT)
		Show.State.CTX = OldCTX
		Show.State.CTX[0] = Show.State.CTX[0] + UI_TAB + UI_MARGIN
	}

	TextCTX := Show.State.CTX
	for Letter in Text do if Letter == 10 do Show.State.CTX[3] += UI_HEIGHT
	PushQuad(Show.State.CTX, {0,0,0,0}, BG_BAR, 0)

	UIDrawText(Text, TextCTX, .LEFT, Editing)
	Show.State.CTX.x = OldCTX.x
	UIAdvanceCTX()
}

UIEditTextMultiline :: proc(Name: string, Text: ^short_string)
{
	UIIterate()
	Color, Editing := UIEditTextRaw(Text, true, Show.State.UIElementsState[Name], Show.State.CTX);
	Show.State.UIElementsState[Name] = Editing
	UIText(Name, ShortToString(Text), Editing)
}

UIEditTextSingle :: proc(Name: string, Text: ^short_string)
{
	UIIterate()
	Color, Editing := UIEditTextRaw(Text, false, Show.State.UIElementsState[Name], Show.State.CTX);
	Show.State.UIElementsState[Name] = Editing
	UIText(Name, ShortToString(Text), Editing)
}

UIEditTextRaw :: proc(Text: ^short_string, Multiline: bool, Active: bool, Quad: v4) -> (v4, bool)
{
	Color := BG_BAR_ACTIVE
	Result := Active

	// active typing mode if clicked
	if IsInsideBounds(Show.State.MousePos, Quad)
	{
		Color = BLUE
		if Show.State.Mouse == .CLICK
		{
			Result = true;
			Show.State.Mouse = .UP;
			Show.State.Mode = .TYPING;
			Show.State.UICharIndex = Text.Len
		}
	}
	
	if Active
	{
		if Show.State.Mode != .TYPING do Result = false
		if Show.State.KeyState[keys.ESCAPE].Active do Show.State.Mode = .EDITING
		if Show.State.KeyState[keys.RIGHT].Active do Show.State.UICharIndex += 1
		if Show.State.KeyState[keys.LEFT].Active do Show.State.UICharIndex -= 1
		Show.State.UICharIndex = clamp(Show.State.UICharIndex, 0, Text.Len)
		
		Color = ACTIVE
		CI := Show.State.UICharIndex
		NewChar:= Show.State.UILastChar

		// add new chars as you type
		if Show.State.UILastChar > 0
		{
			copy_slice(Text.Mem[CI+1:], Text.Mem[CI:])
			Text.Mem[CI] = u8(NewChar)
			Text.Len += 1
			Show.State.UICharIndex += 1
			Show.State.UILastChar = 0
		}

		// backspace
		if Show.State.KeyState[keys.BACKSPACE].Active || Show.State.KeyState[keys.BACKSPACE].IsDown
		{
			if Show.State.KeyState[keys.CTRL].Active
			{
				mem.zero_slice(Text.Mem[:])
				Text.Len = 0;
				Show.State.UICharIndex = 0
			} else if CI > 0 {
				Text.Len = max(0, Text.Len - 1)
				copy_slice(Text.Mem[CI:], Text.Mem[CI+1:])
				Show.State.UICharIndex = max(0, CI-1)
				Show.State.KeyState[keys.BACKSPACE].Active = false
			}
		}

		// delete chars
		if Show.State.KeyState[keys.DELETE].Active || Show.State.KeyState[keys.DELETE].IsDown
		{
			if CI < Text.Len
			{
				Text.Len = max(0, Text.Len - 1)
				copy_slice(Text.Mem[CI:], Text.Mem[CI+1:])
				Show.State.KeyState[keys.DELETE].Active = false
			}
		}

		// add return if enter pressed
		if Show.State.KeyState[keys.ENTER].Active || Show.State.KeyState[keys.ENTER].IsDown
		{
			if Multiline
			{
				copy_slice(Text.Mem[CI+1:], Text.Mem[CI:])
				Text.Mem[CI] = u8(10)
				Text.Len += 1
				Show.State.UICharIndex += 1
				Show.State.UILastChar = 0
				Show.State.KeyState[keys.ENTER].Active = false
			} else {
				Show.State.Mode = .EDITING
				Result = false
			}
		}
	}

	return Color, Result
}

UIGrid :: proc(Names: [dynamic][]string, Offset : int, MaxLines: int = 10)
{
	Old := Show.State.CTX;
	NumCols := f64(len(Names));
	Margins := UI_MARGIN * (NumCols-1);
	Width :f64= (Show.State.CTX[2] - Show.State.CTX[0] - Margins) / NumCols;
	Width = max(Width, UI_MIN_WIDTH)
	for l in abs(Offset)..<MaxLines + abs(Offset)
	{
		TempCTX :v4= {Show.State.CTX[0], Show.State.CTX[1], Show.State.CTX[0] + Width, Show.State.CTX[3]};
		Show.State.CTX = TempCTX
		Row : []string
		if l < len(Names) do Row = Names[l]
		for N, n in Row
		{
			Alignment: ui_justification = .CENTER
			if n == 0
			{
				Alignment = .LEFT
				// Show.State.CTX[2] += UI_MARGIN

			}
			PushQuad(Show.State.CTX, {0,0,0,0}, BG_BAR, 0)
			UIDrawText(N, Show.State.CTX, Alignment)
			Show.State.CTX[0] += Width + UI_MARGIN
			Show.State.CTX[2] = Show.State.CTX[0] + Width
		}
		Show.State.CTX = TempCTX
		if l == MaxLines-1
		{
			Show.State.CTX[2] = Old[2]
		}
		UIAdvanceCTX()
	}
}

//- NOTE SLIDER FLOAT 
UISliderFloatRaw :: proc(Name: string, Value: ^f64, Min, Max, Mul: f64) -> bool
{
	Result := false
	Color := RED
	BGColor := BG_BAR
	
	OuterQuad:= Show.State.CTX
	
	l := clamp(Linear(Value^, Min, Max, OuterQuad[0], OuterQuad[2]), OuterQuad[0], OuterQuad[2])
	t := Show.State.CTX[1]
	r := clamp(l + 10, Show.State.CTX[0], Show.State.CTX[2])
	b := Show.State.CTX[3]
	
	InnerQuad: v4 = {l, t, r, b}
	
	// NOTE drag slider value
	UIIterate()
	if IsInsideBounds(Show.State.MousePos, Show.State.CTX)
	{
		Color = BLUE
		BGColor = BG_BAR_ACTIVE
		if Show.State.Mouse == .CLICK
		{
			if !Show.State.KeyState[keys.CTRL].Active
			{
				Color = ACTIVE
				Show.State.Mouse = .DRAG
				Show.State.DeltaDrag = Show.State.MousePos
				Show.State.UIElementActive = Show.State.UIElementIterator
				Result = true
			} else {
				Show.State.UIElementsState[Name] = true
				Show.State.Mouse = .UP
				Show.State.Mode = .TYPING 
				Show.State.UITempText = StringToShort("")
				Show.State.UICharIndex = Show.State.UITempText.Len
			}
		}
	}
	
	PushQuad(OuterQuad, {0,0,0,0}, BGColor, 2)
	PushQuad(InnerQuad, {0,0,0,0}, RED, 0)
	TextQuad, Editing := UIEditTextRaw(&Show.State.UITempText, false, Show.State.UIElementsState[Name], Show.State.CTX)
	Show.State.UIElementsState[Name] = Editing

	if Editing
	{
		Color = BLUE
		if V, Ok := strconv.parse_f64(ShortToString(&Show.State.UITempText)); Ok
		{
			Value^ = V;
		}
		UIDrawText(ShortToString(&Show.State.UITempText), OuterQuad, .CENTER, true)
	} else {
		if Show.State.UIElementIterator == Show.State.UIElementActive && Show.State.Mouse == .DRAG
		{
			Color = RED
			BGColor = RED
			Value^ += Linear((Show.State.MousePos.x - Show.State.DeltaDrag.x), 0, Show.State.CTX[2]-Show.State.CTX[0], Min, Max) * Mul
			Show.State.DeltaDrag = Show.State.MousePos
			PushQuad(InnerQuad, {0,0,0,0}, RED, 0)
		}
		UIDrawText(fmt.tprintf("%v", Value^), OuterQuad, .CENTER, false)
	}
	return Result
}

UIDropDown		:: proc(Name: string) -> bool
{
	Visible := Show.State.UIElementsState[Name]
	UIIterate()
	if UIButtonRaw(Name, Show.State.CTX, .LEFT) do Visible = (Visible == true) ? false : true
	UIAdvanceCTX()
	Show.State.UIElementsState[Name] = Visible

	return(Visible)
}

ui_direction 	:: enum
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