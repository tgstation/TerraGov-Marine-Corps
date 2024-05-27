/obj/structure/barricade/handrail
	name = "handrail"
	desc = "A railing, for your hands. Woooow."
	icon = 'icons/obj/structures/handrail.dmi'
	icon_state = "handrail_a_0"
	barricade_type = "handrail"
	stack_type = /obj/item/stack/sheet/metal
	stack_amount = 2
	destroyed_stack_amount = 1
	can_wire = FALSE
	coverage = 10
	can_change_dmg_state = FALSE
	resistance_flags = XENO_DAMAGEABLE

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

/obj/structure/barricade/handrail/attackby(obj/item/item, mob/user)
	for(var/obj/effect/xenomorph/acid/A in src.loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

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

/obj/structure/barricade/handrail/hybrisa
	icon_state = "plasticroadbarrierred"
	stack_amount = 0 //we do not want it to drop any stuff when destroyed
	destroyed_stack_amount = 0

// Plastic
/obj/structure/barricade/handrail/urban/road/plastic
	name = "plastic road barrier"
	icon_state = "plasticroadbarrierred"

/obj/structure/barricade/handrail/urban/road/plastic/red
	name = "plastic road barrier"
	icon_state = "plasticroadbarrierred"

/obj/structure/barricade/handrail/urban/road/plastic/blue
	name = "plastic road barrier"
	icon_state = "plasticroadbarrierblue"

/obj/structure/barricade/handrail/urban/road/plastic/black
	name = "plastic road barrier"
	icon_state = "plasticroadbarrierblack"

//Wood

/obj/structure/barricade/handrail/urban/road/wood
	name = "wood road barrier"
	icon_state = "roadbarrierwood"

/obj/structure/barricade/handrail/urban/road/wood/orange
	name = "wood road barrier"
	icon_state = "roadbarrierwood"

/obj/structure/barricade/handrail/urban/road/wood/blue
	name = "wood road barrier"
	icon_state = "roadbarrierpolice"

// Metal
/obj/structure/barricade/handrail/urban/road/metal
	name = "metal road barrier"
	icon_state = "centerroadbarrier"
/obj/structure/barricade/handrail/urban/road/metal/metaltan
	name = "metal road barrier"
	icon_state = "centerroadbarrier"
/obj/structure/barricade/handrail/urban/road/metal/metaldark
	name = "metal road barrier"
	icon_state = "centerroadbarrier2"
/obj/structure/barricade/handrail/urban/road/metal/metaldark2
	name = "metal road barrier"
	icon_state = "centerroadbarrier3"
/obj/structure/barricade/handrail/urban/road/metal/double
	name = "metal road barrier"
	icon_state = "centerroadbarrierdouble"

/obj/structure/barricade/handrail/urban/handrail
	name = "haindrail"
	icon_state = "handrail_hybrisa"
