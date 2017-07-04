
/atom/movable/light_object
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	layer = LIGHTING_LAYER
	mouse_opacity = 0
	blend_mode = BLEND_MULTIPLY
	invisibility = INVISIBILITY_LIGHTING
	color = "#000"
	luminosity = 0
	infra_luminosity = 1
	anchored = 1


/atom/movable/light_object/Dispose()
	return 1

/atom/movable/light_object/Move()
	return 0

/atom/movable/lighting_object/forceMove()
	return

/atom/movable/light_object/ex_act(severity)
	return 0


