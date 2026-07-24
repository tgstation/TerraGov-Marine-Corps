/*----------------------*/
// SNOW
/*----------------------*/

/obj/structure/barricade/snow
	name = "snow barricade"
	desc = "A mound of snow shaped into a sloped wall. Statistically better than thin air as cover."
	icon = 'icons/obj/structures/barricades/snow.dmi'
	icon_state = "snow_0"
	base_icon_state = "snow"
	max_integrity = 75
	stack_type = /obj/item/stack/snow
	stack_amount = 5
	destroyed_stack_amount = 3

/obj/structure/barricade/snow/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(istype(I, /obj/item/tool/shovel))
		return shovel_decon(I, user)

/obj/structure/barricade/wooden/get_repair_amount()
	return max_integrity / stack_amount

/*----------------------*/
// GUARD RAIL
/*----------------------*/

/obj/structure/barricade/guardrail
	name = "guard rail"
	desc = "A short wall made of rails to prevent entry into dangerous areas."
	icon = 'icons/obj/structures/barricades/misc.dmi'
	icon_state = "railing_0"
	coverage = 25
	max_integrity = 150
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 15, BIO = 100, FIRE = 100, ACID = 10)
	stack_type = /obj/item/stack/rods
	destroyed_stack_amount = 3
	hit_sound = "sound/effects/metalhit.ogg"
	base_icon_state = "railing"

/*----------------------*/
// RAILING
/*----------------------*/

/obj/structure/barricade/railing
	name = "railing"
	desc = "Basic railing meant to protect idiots like you from falling."
	icon = 'icons/obj/structures/prop/mainship.dmi'
	icon_state = "railing"
	base_icon_state = "railing"
	barricade_flags = NONE
	stack_type = null
	stack_amount = 0
	destroyed_stack_amount = 0
	resistance_flags = RESIST_ALL

/*----------------------*/
// WOOD
/*----------------------*/

/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "A wall made out of wooden planks nailed together. Not very sturdy, but can provide some concealment."
	icon = 'icons/obj/structures/barricades/misc.dmi'
	icon_state = "wooden"
	max_integrity = 100
	layer = OBJ_LAYER
	stack_type = /obj/item/stack/sheet/wood
	stack_amount = 5
	destroyed_stack_amount = 3
	hit_sound = "sound/effects/natural/woodhit.ogg"
	base_icon_state = "wooden"
	barricade_flags = NONE

/obj/structure/barricade/wooden/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -40, 5)

/*----------------------*/
// CONCRETE
/*----------------------*/

/obj/structure/barricade/concrete
	name = "concrete barricade"
	desc = "A short wall made of reinforced concrete. It looks like it can take a lot of punishment."
	icon = 'icons/obj/structures/barricades/concrete.dmi'
	icon_state = "concrete_0"
	coverage = 100
	max_integrity = 500
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 40, BIO = 100, FIRE = 100, ACID = 20)
	stack_type = null
	destroyed_stack_amount = 0
	hit_sound = "sound/effects/metalhit.ogg"
	base_icon_state = "concrete"

/*----------------------*/
// SANDBAGS
/*----------------------*/

/obj/structure/barricade/sandbags
	name = "sandbag barricade"
	desc = "A bunch of bags filled with sand, stacked into a small wall. Surprisingly sturdy, albeit labour intensive to set up. Trusted to do the job since 1914."
	icon = 'icons/obj/structures/barricades/sandbags.dmi'
	icon_state = "sandbag_0"
	max_integrity = 325
	soft_armor = list(MELEE = 0, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 100, FIRE = 80, ACID = 40)
	coverage = 128
	stack_type = /obj/item/stack/sandbags
	hit_sound = "sound/weapons/genhit.ogg"
	base_icon_state = "sandbag"
	barricade_flags = parent_type::barricade_flags|BARRICADE_CAN_WIRE

/obj/structure/barricade/sandbags/setDir(newdir)
	. = ..()
	if(dir == SOUTH)
		pixel_z = -7
	else
		pixel_z = 0

/obj/structure/barricade/sandbags/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(istype(I, /obj/item/tool/shovel))
		return shovel_decon(I, user)
