package cc

import "core:fmt"

DebugPanel :: proc(Show: ^show, UID: uid)
{
	
	UIText(Show, "Active panel:", Show.State.UIPanelHot)
	UIText(Show, "# of Panels:", len(Show.State.UIPanels))
	UIText(Show, "# of Quads in UI", Show.State.glState.QuadIndex)
	UIText(Show, "Mouse Pos:", Show.State.MousePos)
}

PlaylistPanel :: proc(Show: ^show, UID: uid)
{
	if Value := UIButtonX(Show, {"Uno", "Dos", "Tres"}); Value != "" do fmt.println("Clicked button!")
}


PropertiesPanel :: proc(Show: ^show, UID: uid)
{
	if Value := UIButtonX(Show, {"Left panel", "Right Panel"}); Value != "" do fmt.println("Clicked button!")
}


LibraryPanel :: proc(Show: ^show, UID: uid)
{
	if Value := UIButtonX(Show, {"Center Panel All Alone!"}); Value != "" do fmt.println("Clicked button!")
}