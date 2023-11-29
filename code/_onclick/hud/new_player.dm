
/datum/hud/new_player/New(mob/owner, ui_style='icons/mob/screen/white.dmi', ui_color, ui_alpha = 230)
	..()
	var/list/buttons = subtypesof(/atom/movable/screen/text/lobby)
	buttons -= /atom/movable/screen/text/lobby/clickable //skip the parent type for clickables
	var/ycoord = 11
	for(var/button in buttons)
		var/atom/movable/screen/text/lobby/screen = new button()
		screen.hud = src
		screen.update_text()
		static_inventory += screen
		screen.set_position(2, ycoord--)

