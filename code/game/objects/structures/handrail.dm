/obj/structure/barricade/handrail
	name = "handrail"
	desc = "A railing, for your hands. Woooow."
	icon = 'icons/obj/structures/handrail.dmi'
	icon_state = "handrail_a_0"
	barricade_type = "handrail_a_0"
	stack_amount = 0
	destroyed_stack_amount = 1
	can_wire = FALSE
	coverage = 10
	can_change_dmg_state = FALSE
	resistance_flags = XENO_DAMAGEABLE
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE|PASS_WALKOVER
	max_integrity = 20

/obj/structure/barricade/handrail/update_icon_state()
	. = ..()
	switch(dir)
		if(SOUTH)
			layer = ABOVE_MOB_LAYER
		if(NORTH)
			layer = initial(layer) - 0.01
		else
			layer = initial(layer)
	if(!anchored)
		layer = initial(layer)

/obj/structure/barricade/handrail/Bumped(atom/bumpingcreature)
	if(!isxeno(bumpingcreature))
		return
	balloon_alert_to_viewers("breaks [src]")
	qdel(src)

/obj/structure/barricade/handrail/type_b
	icon_state = "handrail_b_0"
	barricade_type = "handrail_b_0"

/obj/structure/barricade/handrail/strata
	icon_state = "handrail_strata"
	barricade_type = "handrail_strata"

/obj/structure/barricade/handrail/medical
	icon_state = "handrail_med"
	barricade_type = "handrail_med"

/obj/structure/barricade/handrail/kutjevo
	icon_state = "hr_kutjevo"
	barricade_type = "hr_kutjevo"

/obj/structure/barricade/handrail/wire
	icon_state = "wire_rail"
	barricade_type = "wire_rail"

/obj/structure/barricade/handrail/sandstone
	name = "sandstone handrail"
	icon_state = "hr_sandstone"
	barricade_type = "hr_sandstone"
	stack_type = /obj/item/stack/sheet/mineral/sandstone

/obj/structure/barricade/handrail/sandstone/b
	icon_state = "hr_sandstone_b"
	barricade_type = "hr_sandstone_b"

// Hybrisa Barricades

/obj/structure/barricade/handrail/urban
	icon_state = "plasticroadbarrierred"
	stack_amount = 0 //we do not want it to drop any stuff when destroyed
	destroyed_stack_amount = 0
	barricade_type = "plasticroadbarrierred"
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 15, BIO = 100, FIRE = 100, ACID = 10)

// Plastic
/obj/structure/barricade/handrail/urban/road/plastic
	name = "plastic road barrier"
	icon_state = "plasticroadbarrierred"
	barricade_type = "plasticroadbarrierred"

/obj/structure/barricade/handrail/urban/road/plastic/red
	name = "plastic road barrier"
	icon_state = "plasticroadbarrierred"
	barricade_type = "plasticroadbarrierred"

/obj/structure/barricade/handrail/urban/road/plastic/blue
	name = "plastic road barrier"
	icon_state = "plasticroadbarrierblue"
	barricade_type = "plasticroadbarrierblue"

/obj/structure/barricade/handrail/urban/road/plastic/black
	name = "plastic road barrier"
	icon_state = "plasticroadbarrierblack"
	barricade_type = "plasticroadbarrierblack"

//Wood

/obj/structure/barricade/handrail/urban/road/wood
	name = "wood road barrier"
	icon_state = "roadbarrierwood"
	barricade_type = "roadbarrierwood"

/obj/structure/barricade/handrail/urban/road/wood/orange
	name = "wood road barrier"
	icon_state = "roadbarrierwood"
	barricade_type = "roadbarrierwood"

/obj/structure/barricade/handrail/urban/road/wood/blue
	name = "wood road barrier"
	icon_state = "roadbarrierpolice"
	barricade_type = "roadbarrierpolice"

// Metal
/obj/structure/barricade/handrail/urban/road/metal
	name = "metal road barrier"
	icon_state = "centerroadbarrier"
	barricade_type = "centerroadbarrier"

/obj/structure/barricade/handrail/urban/road/metal/metaltan
	name = "metal road barrier"
	icon_state = "centerroadbarrier"
	barricade_type = "centerroadbarrier"

/obj/structure/barricade/handrail/urban/road/metal/metaldark
	name = "metal road barrier"
	icon_state = "centerroadbarrier2"
	barricade_type = "centerroadbarrier2"

/obj/structure/barricade/handrail/urban/road/metal/metaldark/Initialize(mapload)
	. = ..()
	if(dir == WEST || dir == EAST)
		density = FALSE

/obj/structure/barricade/handrail/urban/road/metal/metaldark2
	name = "metal road barrier"
	icon_state = "centerroadbarrier3"
	barricade_type = "centerroadbarrier3"

/obj/structure/barricade/handrail/urban/road/metal/metaldark2/Initialize(mapload)
	. = ..()
	if(dir == WEST || dir == EAST)
		density = FALSE

/obj/structure/barricade/handrail/urban/road/metal/double
	name = "metal road barrier"
	icon_state = "centerroadbarrierdouble"
	barricade_type = "centerroadbarrierdouble"

/obj/structure/barricade/handrail/urban/road/metal/double/Initialize(mapload)
	. = ..()
	if(dir == NORTH || dir == SOUTH)
		overlays += image(icon, src, "[icon_state]_overlay", layer = ABOVE_ALL_MOB_LAYER)

/obj/structure/barricade/handrail/urban/road/metal/double/white
	icon_state = "centerroadbarrierdouble_white"
	barricade_type = "centerroadbarrierdouble_white"

/obj/structure/barricade/handrail/urban/road/metal/double/dark
	icon_state = "centerroadbarrierdouble_dark"
	barricade_type = "centerroadbarrierdouble_dark"

/obj/structure/barricade/handrail/urban/handrail
	name = "handrail"
	icon_state = "handrail_hybrisa"
	barricade_type = "handrail_hybrisa"
