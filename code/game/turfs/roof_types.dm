// Roofing

/turf/open/floor/roof
	name = "roof"
	desc = "Old roofing."
	mediumxenofootstep = FOOTSTEP_ROOF
	barefootstep = FOOTSTEP_ROOF
	shoefootstep = FOOTSTEP_ROOF
	icon = 'icons/turf/roofs/roof_metal.dmi'
	icon_state = "roof-255"
	base_icon_state = "roof"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_ROOF_NORMAL)
	canSmoothWith = list(SMOOTH_GROUP_ROOF_NORMAL, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_OPEN_FLOOR)

/turf/open/floor/roof/broken_states()
	return icon_state

/turf/open/floor/roof/burnt_states()
	return icon_state

/turf/open/floor/roof/fire_act(burn_level)
	return

/turf/open/floor/roof/rusty
	icon = 'icons/turf/roofs/roof_rusty.dmi'

/turf/open/floor/roof/sheet
	icon = 'icons/turf/roofs/roof_sheet.dmi'
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_ROOF_SHEET)
	canSmoothWith = list(SMOOTH_GROUP_ROOF_SHEET, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_OPEN_FLOOR)

/turf/open/floor/roof/sheet/noborder //for holes and stuff
	icon = 'icons/turf/roofs/roof_sheet_noborder.dmi'

/turf/open/floor/roof/asphalt
	mediumxenofootstep = FOOTSTEP_GRAVEL
	barefootstep = FOOTSTEP_GRAVEL
	shoefootstep = FOOTSTEP_GRAVEL
	icon = 'icons/turf/roofs/roof_asphalt.dmi'
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_ROOF_ASPHALT)
	canSmoothWith = list(SMOOTH_GROUP_ROOF_ASPHALT, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_OPEN_FLOOR)

/turf/open/floor/roof/asphalt/noborder //for holes and stuff
	icon = 'icons/turf/roofs/roof_asphalt_noborder.dmi'

/turf/open/floor/roof/wood
	mediumxenofootstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD
	shoefootstep = FOOTSTEP_WOOD
	icon = 'icons/turf/roofs/roof_wood.dmi'
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_ROOF_WOOD)
	canSmoothWith = list(SMOOTH_GROUP_ROOF_WOOD, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_OPEN_FLOOR)
