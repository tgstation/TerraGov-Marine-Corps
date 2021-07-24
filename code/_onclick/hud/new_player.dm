
/datum/hud/new_player/New(mob/owner, ui_style='icons/mob/screen/white.dmi', ui_color, ui_alpha = 230)
	..()
	var/list/buttons = subtypesof(/obj/screen/text/lobby)
	buttons -= /obj/screen/text/lobby/clickable //skip the parent type for clickables
	var/ycoord = 12
	for(var/button in buttons)
		var/obj/screen/text/lobby/screen = new button()
		screen.hud = src
		static_inventory += screen
		screen.set_position(2, ycoord--)

