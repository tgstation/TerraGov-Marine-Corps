/obj/effect/elevator/supply
	name = "\improper empty space"
	desc = "There seems to be an awful lot of machinery down below"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "supply_elevator_lowered"
	unacidable = 1
	mouse_opacity = 0
	layer = ABOVE_TURF_LAYER

	ex_act(severity)
		return