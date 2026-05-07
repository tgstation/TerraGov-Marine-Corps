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

	//Removing the barricades
	if(!istype(I, /obj/item/tool/shovel) || user.a_intent == INTENT_HARM)
		return
	var/obj/item/tool/shovel/ET = I

	if(ET.folded)
		return

	if(LAZYACCESS(user.do_actions, src))
		balloon_alert(user, "already shoveling!")
		return

	user.visible_message("[user] starts clearing out \the [src].", "You start removing \the [src].")

	if(!do_after(user, ET.shovelspeed, NONE, src, BUSY_ICON_BUILD))
		return

	if(ET.folded)
		return
	deconstruct(!get_self_acid())

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

/obj/structure/barricade/wooden/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!istype(I, /obj/item/stack/sheet/wood))
		return
	var/obj/item/stack/sheet/wood/D = I
	if(obj_integrity >= max_integrity)
		return

	if(D.get_amount() < 1)
		balloon_alert(user, "need more wood!")
		return

	if(LAZYACCESS(user.do_actions, src))
		return

	balloon_alert_to_viewers("repairing...")

	if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_FRIENDLY) || obj_integrity >= max_integrity)
		return

	if(get_self_acid())
		balloon_alert(user, "it's melting!")
		return TRUE

	if(!D.use(1))
		return

	repair_damage(max_integrity, user)
	balloon_alert_to_viewers("repaired")
	update_appearance(UPDATE_ICON)

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
		pixel_y = -7
	else
		pixel_y = 0

/obj/structure/barricade/sandbags/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/tool/shovel) && user.a_intent != INTENT_HARM)
		var/obj/item/tool/shovel/ET = I
		if(ET.folded)
			return TRUE
		balloon_alert_to_viewers("disassembling...")
		if(!do_after(user, ET.shovelspeed, NONE, src, BUSY_ICON_BUILD))
			return TRUE
		user.visible_message(span_notice("[user] disassembles [src]."),
		span_notice("You disassemble [src]."))
		deconstruct(!get_self_acid())
		return TRUE

	if(istype(I, /obj/item/stack/sandbags))
		if(obj_integrity == max_integrity)
			balloon_alert(user, "already repaired!")
			return
		var/obj/item/stack/sandbags/D = I
		if(D.get_amount() < 1)
			balloon_alert(user, "not enough sandbags!")
			return
		balloon_alert_to_viewers("replacing sandbags...")

		if(LAZYACCESS(user.do_actions, src))
			return

		if(!do_after(user, 3 SECONDS, NONE, src, BUSY_ICON_BUILD) || obj_integrity >= max_integrity)
			return

		if(get_self_acid())
			balloon_alert(user, "it's melting!")
			return

		if(!D.use(1))
			return

		repair_damage(max_integrity * 0.2, user) //Each sandbag restores 20% of max health as 5 sandbags = 1 sandbag barricade.
		balloon_alert_to_viewers("repaired")
		update_appearance(UPDATE_ICON)
