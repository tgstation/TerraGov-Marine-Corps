
/obj/effect/decal/cleanable/food
	icon = 'icons/effects/tomatodecal.dmi'
	gender = NEUTER
	beauty = -100

/obj/effect/decal/cleanable/food/tomato_smudge
	name = "tomato smudge"
	desc = ""
	icon_state = "tomato_floor1"
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

/obj/effect/decal/cleanable/food/plant_smudge
	name = "plant smudge"
	desc = ""
	icon_state = "smashed_plant"

/obj/effect/decal/cleanable/food/egg_smudge
	name = "smashed egg"
	desc = ""
	icon_state = "smashed_egg1"
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3")

/obj/effect/decal/cleanable/food/pie_smudge //honk
	name = "smashed pie"
	desc = ""
	icon_state = "smashed_pie"

/obj/effect/decal/cleanable/food/salt
	name = "salt pile"
	desc = ""
	icon_state = "salt_pile"

/obj/effect/decal/cleanable/food/salt/CanPass(atom/movable/AM, turf/target)
	if(is_species(AM, /datum/species/snail))
		to_chat(AM, "<span class='danger'>My path is obstructed by <span class='phobia'>salt</span>.</span>")
		return FALSE
	return TRUE

/obj/effect/decal/cleanable/food/flour
	name = "flour"
	desc = ""
	icon_state = "flour"
	mouse_opacity = 0
