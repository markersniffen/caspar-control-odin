package cc

import "core:fmt"

PlaylistPanel :: proc(Show: ^show, UID: uid)
{
	if Value := UIButtonX(Show, {"My Button", "My OTHER Button", "Another Button"}); Value != "" do fmt.println("Clicked button!")
}


PropertiesPanel :: proc(Show: ^show, UID: uid)
{
	if Value := UIButtonX(Show, {"My Button", "My OTHER Button"}); Value != "" do fmt.println("Clicked button!")
}


LibraryPanel :: proc(Show: ^show, UID: uid)
{
	if Value := UIButtonX(Show, {"My Button"}); Value != "" do fmt.println("Clicked button!")
}