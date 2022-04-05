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
}

UIPanel 	:: proc(Show: ^show, PUID: uid)
{
	Panel, Pok:= Show.State.UIPanels[PUID]
	if Pok
	{
		Quad := Panel.CTX
		if Panel.Direction == .X do Quad[2] = Quad[0] + 2
		if Panel.Direction == .Y do Quad[3] = Quad[1] + 2
		PushQuad(Show, Quad, {0,0,0,0}, RED, 0)
		
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
			if Show.State.UILastChar != 0
			{
				switch Show.State.UILastChar
				{
					case 'x':
						UIDeletePanel(Show, Show.State.UIPanelHot)
				}


				Show.State.UILastChar = 0
			}

			if Show.State.KeyState[keys.TAB].Active
			{
				Panel.Type += 1
				if Panel.Type > 3 do Panel.Type = 0
			}

			if Show.State.KeyState[keys.N_PLUS].Active
			{
				fmt.println("PLUS")
				UICreatePanel(Show, PUID, .Y, 0.5, 0)
				Show.State.KeyState[keys.N_PLUS].Active = false
			}

			if Show.State.KeyState[keys.N_MINUS].Active
			{
				UICreatePanel(Show, PUID, .X, 0.5, 0)
				Show.State.KeyState[keys.N_MINUS].Active = false
			}

			Show.State.UIPanelHot = PUID
			// universal panel drawing
		}

		if PUID == Show.State.UIPanelHot
		{
			if Show.State.MouseScroll != 0
			{
				Parent, Ok := Show.State.UIPanels[Panel.Parent]
				if Ok
				{
					Parent.Size += (Show.State.MouseScroll/10)
					fmt.println(Show.State.MouseScroll)
				}
			}
			PushQuad(Show, Panel.CTX, {0,0,0,0}, BLUE, 2)
		}

		Show.State.CTX = {Panel.CTX[0] + UI_MARGIN, Panel.CTX[1] + UI_MARGIN, Panel.CTX[2] - UI_MARGIN, Panel.CTX[1] + UI_MARGIN + UI_HEIGHT }

		if Panel.Type == 0 do DebugPanel(Show, PUID)
		if Panel.Type == 1 do InstructionsPanel(Show, PUID)
		if Panel.Type == 2 do PropertiesPanel(Show, PUID)
		if Panel.Type == 3 do LibraryPanel(Show, PUID)	
	}
}

DebugPanel :: proc(Show: ^show, UID: uid)
{
	UIText(Show, "Active panel:", Show.State.UIPanelHot)
	UIText(Show, "# of Panels:", len(Show.State.UIPanels))
	UIText(Show, "# of Quads in UI", Show.State.glState.QuadIndex)
	UIText(Show, "Mouse Pos:", Show.State.MousePos)
}

InstructionsPanel :: proc(Show: ^show, UID: uid)
{
	UIText(Show, "Instructions", "")
	UIBar(Show)
	UIText(Show, "", "Press \"Tab\" to change panel type.")
	UIText(Show, "", "Press \"Numpad +/-\" to add panel.")
	UIText(Show, "", "Press \"x\" delete panel.")
	UIText(Show, "", "Use scrollwheel to adjust panel size")
}

PropertiesPanel :: proc(Show: ^show, UID: uid)
{
	if Value := UIButtonX(Show, {"Left panel", "Right Panel"}); Value != "" do fmt.println("Clicked button!")
}

LibraryPanel :: proc(Show: ^show, UID: uid)
{
	if Value := UIButtonX(Show, {"Center Panel All Alone!"}); Value != "" do fmt.println("Clicked button!")
}