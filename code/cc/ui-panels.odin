package cc

import "core:fmt"

ui_panel 		:: struct
{
	UID: uid,
	CTX: v4,
	Parent: uid,
	Size: f64,
	Children: [2]uid,
	Type: int,
	Direction: ui_direction,
	Offset: v2,
}

UIPanel 	:: proc(PUID: uid)
{
	Panel, Pok:= Show.State.UIPanels[PUID]
	Show.State.UIPanelRendering = PUID
	if Pok
	{
		Quad := Panel.CTX
		if Panel.Direction == .X do Quad[2] = Quad[0] + 2
		if Panel.Direction == .Y do Quad[3] = Quad[1] + 2
		PushQuad(Quad, {0,0,0,0}, RED, 0, true)
		
		// INPUT

		// INSIDE PANEL
		if IsInsideBounds(Show.State.MousePos, Panel.CTX)
		{

			// MOUSE INPUT
			if Show.State.Mouse != .DRAG
			{
				// Show.State.UIPanelHot = PUID;
			}

			if Show.State.Mouse == .CLICK
			{
			}

			// KEYBOARD INPUT
			if Show.State.Mode == .EDITING
			{
				switch Show.State.UILastChar
				{
					case 'x':
						UIDeletePanel(Show.State.UIPanelHot)
				}
				Show.State.UILastChar = 0
			}

			if Show.State.KeyState[keys.TAB].Active
			{
				Panel.Type += 1
				if Panel.Type > 4 do Panel.Type = 0
			}

			if Show.State.KeyState[keys.N_PLUS].Active
			{
				fmt.println("PLUS")
				UICreatePanel(PUID, .Y, 0.5, 0)
				Show.State.KeyState[keys.N_PLUS].Active = false
			}

			if Show.State.KeyState[keys.N_MINUS].Active
			{
				UICreatePanel(PUID, .X, 0.5, 0)
				Show.State.KeyState[keys.N_MINUS].Active = false
			}

			Show.State.UIPanelHot = PUID
			// universal panel drawing
		}

		// change size of panel by scroll wheel
		if PUID == Show.State.UIPanelHot
		{
			if Show.State.MouseScroll != 0
			{
				if Show.State.KeyState[keys.CTRL].Active
				{
					Parent, Ok := Show.State.UIPanels[Panel.Parent]
					if Ok
					{
						Parent.Size += (Show.State.MouseScroll/10)
					}
				}
				else if Show.State.KeyState[keys.SHIFT].Active
				{
					Panel.Offset[0] = min(Panel.Offset[0] + Show.State.MouseScroll*250, 0)
				} else {
					Panel.Offset[1] = min(Panel.Offset[1] + Show.State.MouseScroll*250, 0)
				}
			}
		}

		// set context to top left of panel
		NewCTX :v4 = {Panel.CTX[0] + UI_MARGIN, Panel.CTX[1] + UI_MARGIN, Panel.CTX[2] - UI_MARGIN, Panel.CTX[1] + UI_MARGIN + UI_HEIGHT }
		Show.State.CTX = NewCTX
		// Show.State.CTX = OffsetQuad(NewCTX, Panel.Offset)

		// render the panel
		if Panel.Type == 0 do DebugPanel(PUID)
		if Panel.Type == 1 do GridPanel(PUID)
		if Panel.Type == 2 do PropertiesPanel(PUID)
		if Panel.Type == 3 do LibraryPanel(PUID)
		if Panel.Type == 4 do InstructionsPanel(PUID)
	}
}

DebugPanel :: proc(UID: uid)
{
	UIText("Active panel:", Show.State.UIPanelHot, false)
	HotPanel, Hok := Show.State.UIPanels[Show.State.UIPanelHot]
	if Hok do UIText("Panel Offset:", HotPanel.Offset)
	UIBar()
	UIText("# UI Elements", Show.Debug.UIElements)
	UIText("# of Charaters", Show.Debug.UICharactersLast)
	UIText("Size_of Vertices", len(Show.State.glState.Vertices))
	UIText("# of Vertices", Show.Debug.UIVertices)
	// UIBar()
	UIText("Mouse Pos:", Show.State.MousePos)
	UIText("Test Value:", Show.State.TestValue)
}

InstructionsPanel :: proc(UID: uid)
{
	UIText("Instructions", "")
	UIBar()
	UIText("", "Press \"Tab\" to change panel type.")
	UIText("", "Press \"Numpad +/-\" to add panel.")
	UIText("", "Press \"x\" delete panel.")
	UIText("", "Use scrollwheel to adjust panel size")
	UISliderFloatRaw("My Slider", &Show.State.TestValue, 0, 50, 1)
}

PropertiesPanel :: proc(UID: uid)
{
	// UIEditTextMultiline("Some Text", &Show.State.TestText)
	if UIDropDown("Main DropDown")
	{
		for P in Show.Data.Pages[0].RawData do UIText("", P)
	}
	UIEditTextSingle("SomeText", &Show.State.TestText)
}

GridPanel :: proc(UID: uid)
{
	Panel, Pok := Show.State.UIPanels[UID]
	if Pok
	{

		for Page, p in Show.Data.Pages
		{
			if UIDropDown(Page.Table)
			{
				fmt.println(Panel.Offset[1], int(Panel.Offset[1]))
				UIGrid(Show.Data.Pages[p].RawData, int(Panel.Offset[1])/10)
			}
		}
	}
}

LibraryPanel :: proc(UID: uid)
{
	if Value := UIButtonX({"Center Panel All Alone!"}); Value != "" do fmt.println("Clicked button!")
}