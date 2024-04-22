/turf/open/floor/plating/dirt
	gender = PLURAL
	name = "dirt"
	desc = ""
	icon = 'icons/turf/floors.dmi'
	icon_state = "dirt"
	baseturfs = /turf/open/chasm/jungle
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	planetary_atmos = TRUE
	attachment_holes = FALSE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/floor/plating/dirt/dark
	icon_state = "greenerdirt"

/turf/open/floor/plating/dirt/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return
//underworld
/turf/open/floor/plating/dirt/underworld
	gender = PLURAL
	name = "ash"
	desc = "The floor is strange.."
	icon = 'icons/turf/floors.dmi'
	icon_state = "underworld"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
