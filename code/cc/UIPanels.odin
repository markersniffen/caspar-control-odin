package cc

import "core:fmt"

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