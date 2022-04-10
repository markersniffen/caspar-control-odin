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

UIPanel 	:: proc(PUID: uid)
{
	Panel, Pok:= Show.State.UIPanels[PUID]
	if Pok
	{
		Quad := Panel.CTX
		if Panel.Direction == .X do Quad[2] = Quad[0] + 2
		if Panel.Direction == .Y do Quad[3] = Quad[1] + 2
		PushQuad(Quad, {0,0,0,0}, RED, 0)
		
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
						UIDeletePanel(Show.State.UIPanelHot)
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

		if PUID == Show.State.UIPanelHot
		{
			if Show.State.MouseScroll != 0
			{
				Parent, Ok := Show.State.UIPanels[Panel.Parent]
				if Ok
				{
					Parent.Size += (Show.State.MouseScroll/10)
				}
			}
			PushQuad(Panel.CTX, {0,0,0,0}, BLUE, 2)
		}

		Show.State.CTX = {Panel.CTX[0] + UI_MARGIN, Panel.CTX[1] + UI_MARGIN, Panel.CTX[2] - UI_MARGIN, Panel.CTX[1] + UI_MARGIN + UI_HEIGHT }

		if Panel.Type == 0 do DebugPanel(PUID)
		if Panel.Type == 1 do InstructionsPanel(PUID)
		if Panel.Type == 2 do PropertiesPanel(PUID)
		if Panel.Type == 3 do LibraryPanel(PUID)	
	}
}

DebugPanel :: proc(UID: uid)
{
	UIText("Active panel:", Show.State.UIPanelHot)
	UIText("# of Panels:", len(Show.State.UIPanels))
	UIText("# of Quads in UI", Show.Debug.UIQuads)
	UIText("Mouse Pos:", Show.State.MousePos)
}

InstructionsPanel :: proc(UID: uid)
{
	UIText("Instructions", "")
	UIBar()
	UIText("", "Press \"Tab\" to change panel type.")
	UIText("", "Press \"Numpad +/-\" to add panel.")
	UIText("", "Press \"x\" delete panel.")
	UIText("", "Use scrollwheel to adjust panel size")
}

PropertiesPanel :: proc(UID: uid)
{
	if UIDropDown("Main DropDown")
	{
		for P in Show.State.UIPanels do UIText("Panel:", P)
	}

}

LibraryPanel :: proc(UID: uid)
{
	if Value := UIButtonX({"Center Panel All Alone!"}); Value != "" do fmt.println("Clicked button!")
}