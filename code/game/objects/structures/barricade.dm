// Snow, wood, sandbags, metal, plasteel

/obj/structure/barricade
	climbable = TRUE
	anchored = TRUE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	atom_flags = ON_BORDER
	obj_flags = CAN_BE_HIT | IGNORE_DENSITY | BLOCKS_CONSTRUCTION_DIR
	resistance_flags = XENO_DAMAGEABLE
	allow_pass_flags = PASS_DEFENSIVE_STRUCTURE|PASSABLE|PASS_WALKOVER
	climb_delay = 2 SECONDS
	interaction_flags = INTERACT_CHECK_INCAPACITATED
	max_integrity = 100
	barrier_flags = HANDLE_BARRIER_CHANCE
	///The type of stack the barricade dropped when disassembled if any.
	var/stack_type
	///The amount of stack dropped when disassembled at full health
	var/stack_amount = 5
	///to specify a non-zero amount of stack to drop when destroyed
	var/destroyed_stack_amount = 0
	var/base_acid_damage = 2
	var/barricade_type = "barricade" //"metal", "plasteel", etc.
	///Whether this barricade has damaged states
	var/can_change_dmg_state = TRUE
	///Whether this is open
	var/is_open = FALSE
	///Can this barricade type be wired
	var/can_wire = FALSE
	///is this barriade wired?
	var/is_wired = FALSE

/obj/structure/barricade/Initialize(mapload, mob/user)
	. = ..()
	update_icon()
	var/static/list/connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_try_exit),
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
	)
	AddElement(/datum/element/connect_loc, connections)
	if(user)
		faction = user.faction

/obj/structure/barricade/handle_barrier_chance(mob/living/M)
	return prob(max(30,(100.0*obj_integrity)/max_integrity))

/obj/structure/barricade/examine(mob/user)
	. = ..()
	if(is_wired)
		. += span_info("There is a length of wire strewn across the top of this barricade.")
	switch((obj_integrity / max_integrity) * 100)
		if(75 to INFINITY)
			. += span_info("It appears to be in good shape.")
		if(50 to 75)
			. += span_warning("It's slightly damaged, but still very functional.")
		if(25 to 50)
			. += span_warning("It's quite beat up, but it's holding together.")
		if(-INFINITY to 25)
			. += span_warning("It's crumbling apart, just a few more blows will tear it apart.")

/obj/structure/barricade/on_try_exit(datum/source, atom/movable/mover, direction, list/knownblockers)
	. = ..()

	if(mover?.throwing && !CHECK_MULTIPLE_BITFIELDS(mover?.pass_flags, HOVERING) && density && is_wired && iscarbon(mover) && (direction & dir))
		knownblockers += src
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/barricade/CanAllowThrough(atom/movable/mover, turf/target)
	if(get_dir(loc, target) & dir)
		if(!CHECK_MULTIPLE_BITFIELDS(mover?.pass_flags, HOVERING) && is_wired && density && ismob(mover))
			return FALSE
		if(istype(mover, /obj/effect/xenomorph)) //cades stop xeno effects like acid spray
			return FALSE

	return ..()

/obj/structure/barricade/attack_animal(mob/user)
	return attack_alien(user)

/obj/structure/barricade/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return FALSE

	if(is_wired)
		balloon_alert(xeno_attacker, "barbed wire slicing into you!")
		xeno_attacker.apply_damage(15, blocked = MELEE , sharp = TRUE, updating_health = TRUE)

	return ..()

/obj/structure/barricade/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(get_self_acid())
		balloon_alert(user, "it's melting!")
		return TRUE

	if(!istype(I, /obj/item/stack/barbed_wire) || !can_wire)
		return

	var/obj/item/stack/barbed_wire/B = I

	balloon_alert_to_viewers("setting up wire...")
	if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_BUILD) || !can_wire)
		return

	if(get_self_acid())
		balloon_alert(user, "it's melting!")
		return TRUE

	playsound(loc, 'sound/effects/barbed_wire_movement.ogg', 25, 1)

	B.use(1)
	wire()


/obj/structure/barricade/proc/wire()
	can_wire = FALSE
	is_wired = TRUE
	climbable = FALSE
	modify_max_integrity(max_integrity + 50)
	update_icon()

/obj/structure/barricade/wirecutter_act(mob/living/user, obj/item/I)
	if(!is_wired || LAZYACCESS(user.do_actions, src))
		return FALSE

	balloon_alert_to_viewers("removing wire...")

	if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return TRUE

	playsound(loc, 'sound/items/wirecutter.ogg', 25, TRUE)
	balloon_alert_to_viewers("removed")
	modify_max_integrity(max_integrity - 50)
	can_wire = TRUE
	is_wired = FALSE
	climbable = TRUE
	update_icon()
	new /obj/item/stack/barbed_wire(loc)


/obj/structure/barricade/deconstruct(disassembled = TRUE, mob/living/blame_mob)
	if(disassembled && is_wired)
		new /obj/item/stack/barbed_wire(loc)
	if(stack_type)
		var/stack_amt
		if(!disassembled && destroyed_stack_amount)
			stack_amt = destroyed_stack_amount
		else
			stack_amt = round(stack_amount * (obj_integrity/max_integrity)) //Get an amount of sheets back equivalent to remaining health. Obviously, fully destroyed means 0

		if(stack_amt)
			new stack_type (loc, stack_amt)
	return ..()

/obj/structure/barricade/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct(FALSE)
			return
		if(EXPLODE_HEAVY)
			take_damage(rand(33, 66), BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(rand(10, 33), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(10, BRUTE, BOMB)
	update_icon()

/obj/structure/barricade/setDir(newdir)
	. = ..()
	update_icon()

/obj/structure/barricade/update_icon_state()
	. = ..()
	var/damage_state
	var/percentage = (obj_integrity / max_integrity) * 100
	switch(percentage)
		if(-INFINITY to 25)
			damage_state = 3
		if(25 to 50)
			damage_state = 2
		if(50 to 75)
			damage_state = 1
		if(75 to INFINITY)
			damage_state = 0

	if(is_open)
		icon_state = can_change_dmg_state ? "[barricade_type]_open_[damage_state]" : "[barricade_type]_open"
		layer = OBJ_LAYER
		return

	icon_state = can_change_dmg_state ? "[barricade_type]_[damage_state]" : "[barricade_type]"
	if(!anchored)
		layer = initial(layer)
		return
	switch(dir)
		if(SOUTH)
			layer = ABOVE_MOB_LAYER
		if(NORTH)
			layer = initial(layer) - 0.01
		else
			layer = initial(layer)

/obj/structure/barricade/update_overlays()
	. = ..()
	if(!is_wired)
		return
	if(is_open)
		. += image(icon, icon_state = "[barricade_type]_open_wire")
	else
		. += image(icon, icon_state = "[barricade_type]_wire", layer = dir == NORTH ? layer : ABOVE_MOB_LAYER) //it will layer under certain upgrades in some cases otherwise


/obj/structure/barricade/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		take_damage(base_acid_damage * S.strength, BURN, ACID)


/obj/structure/barricade/verb/rotate()
	set name = "Rotate Barricade Counter-Clockwise"
	set category = "IC.Object"
	set src in oview(1)

	if(anchored)
		balloon_alert(usr, "fastened to the floor")
		return FALSE

	setDir(turn(dir, 90))

/obj/structure/barricade/verb/revrotate()
	set name = "Rotate Barricade Clockwise"
	set category = "IC.Object"
	set src in oview(1)

	if(anchored)
		balloon_alert(usr, "fastened to the floor")
		return FALSE

	setDir(turn(dir, 270))


/obj/structure/barricade/attack_hand_alternate(mob/living/user)
	if(anchored)
		balloon_alert(usr, "fastened to the floor")
		return FALSE

	setDir(turn(dir, 270))


/*----------------------*/
// SNOW
/*----------------------*/

/obj/structure/barricade/snow
	name = "snow barricade"
	desc = "A mound of snow shaped into a sloped wall. Statistically better than thin air as cover."
	icon = 'icons/obj/structures/barricades/snow.dmi'
	icon_state = "snow_0"
	barricade_type = "snow"
	max_integrity = 75
	stack_type = /obj/item/stack/snow
	stack_amount = 5
	destroyed_stack_amount = 0
	can_wire = FALSE



//Item Attack
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
	barricade_type = "railing"
	can_wire = FALSE

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
	can_change_dmg_state = FALSE
	barricade_type = "wooden"
	can_wire = FALSE

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
	update_icon()


/*----------------------*/
// METAL
/*----------------------*/

#define BARRICADE_METAL_LOOSE 0
#define BARRICADE_METAL_ANCHORED 1
#define BARRICADE_METAL_FIRM 2

#define CADE_TYPE_BOMB "concussive armor"
#define CADE_TYPE_MELEE "ballistic armor"
#define CADE_TYPE_ACID "caustic armor"

#define CADE_UPGRADE_REQUIRED_SHEETS 1

//cade armor defines
#define CADE_UPGRADE_BOMB 80
#define CADE_UPGRADE_MELEE list(melee = 30, bullet = 50, laser = 50, energy = 50)
#define CADE_UPGRADE_ACID 35

/obj/structure/barricade/solid
	name = "metal barricade"
	desc = "A sturdy and easily assembled barricade made of metal plates, often used for quick fortifications. Use a blowtorch to repair."
	icon = 'icons/obj/structures/barricades/metal.dmi'
	icon_state = "metal_0"
	max_integrity = 250
	soft_armor = list(MELEE = 0, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 100, FIRE = 80, ACID = 40)
	coverage = 128
	stack_type = /obj/item/stack/sheet/metal
	stack_amount = BUILD_COST_METAL_CADE
	destroyed_stack_amount = 2
	hit_sound = "sound/effects/metalhit.ogg"
	barricade_type = "metal"
	can_wire = TRUE
	///Build state of the barricade
	var/build_state = BARRICADE_METAL_FIRM
	///The type of upgrade and corresponding overlay we have attached
	var/barricade_upgrade_type

/obj/structure/barricade/solid/Initialize(mapload, mob/user)
	. = ..()
	if(!user || !HAS_TRAIT(user, TRAIT_SUPERIOR_BUILDER))
		return
	modify_max_integrity(max_integrity + 75)

/obj/structure/barricade/solid/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -40, 8, 1)

/obj/structure/barricade/solid/update_overlays()
	. = ..()
	if(!barricade_upgrade_type)
		return
	var/damage_state
	var/percentage = (obj_integrity / max_integrity) * 100
	switch(percentage)
		if(-INFINITY to 25)
			damage_state = 3
		if(25 to 50)
			damage_state = 2
		if(50 to 75)
			damage_state = 1
		if(75 to INFINITY)
			damage_state = 0
	switch(barricade_upgrade_type)
		if(CADE_TYPE_BOMB)
			. += image('icons/obj/structures/barricades/upgrades.dmi', icon_state = "[barricade_type]+explosive_upgrade_[damage_state]")
		if(CADE_TYPE_MELEE)
			. += image('icons/obj/structures/barricades/upgrades.dmi', icon_state = "[barricade_type]+brute_upgrade_[damage_state]")
		if(CADE_TYPE_ACID)
			. += image('icons/obj/structures/barricades/upgrades.dmi', icon_state = "[barricade_type]+burn_upgrade_[damage_state]")

/obj/structure/barricade/solid/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!istype(I, /obj/item/stack/sheet/metal))
		return

	var/obj/item/stack/sheet/metal/metal_sheets = I
	if(obj_integrity >= max_integrity * 0.3)
		return attempt_barricade_upgrade(I, user, params)

	if(metal_sheets.get_amount() < 2)
		balloon_alert(user, "2 metal sheets needed!")
		return FALSE

	if(LAZYACCESS(user.do_actions, src))
		return

	balloon_alert_to_viewers("repairing base...")

	if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_FRIENDLY) || obj_integrity >= max_integrity * 0.3)
		return FALSE

	if(get_self_acid())
		balloon_alert(user, "it's melting!")
		return TRUE

	if(!metal_sheets.use(2))
		return FALSE

	repair_damage(max_integrity * 0.3, user)
	balloon_alert_to_viewers("base repaired")
	update_icon()


/obj/structure/barricade/solid/proc/attempt_barricade_upgrade(obj/item/stack/sheet/metal/metal_sheets, mob/user, params)
	if(barricade_upgrade_type)
		balloon_alert(user, "already upgraded!")
		return FALSE
	if(obj_integrity < max_integrity)
		balloon_alert(user, "not at full health!")
		return FALSE

	if(metal_sheets.get_amount() < CADE_UPGRADE_REQUIRED_SHEETS)
		balloon_alert(user, "[CADE_UPGRADE_REQUIRED_SHEETS] metal sheets required!")
		return FALSE

	var/static/list/cade_types = list(CADE_TYPE_BOMB = image(icon = 'icons/obj/structures/barricades/upgrades.dmi', icon_state = "explosive_obj"), CADE_TYPE_MELEE = image(icon = 'icons/obj/structures/barricades/upgrades.dmi', icon_state = "brute_obj"), CADE_TYPE_ACID = image(icon = 'icons/obj/structures/barricades/upgrades.dmi', icon_state = "burn_obj"))
	var/choice = show_radial_menu(user, src, cade_types, require_near = TRUE, tooltips = TRUE)

	if(!choice)
		return

	if(user.skills.getRating(SKILL_CONSTRUCTION) < SKILL_CONSTRUCTION_METAL)
		balloon_alert(user, "fumbling...")
		var/fumbling_time = 2 SECONDS * ( SKILL_CONSTRUCTION_METAL - user.skills.getRating(SKILL_CONSTRUCTION) )
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return FALSE

	balloon_alert_to_viewers("attaching [choice]...")
	if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return FALSE
	if(barricade_upgrade_type)
		balloon_alert(user, "already upgraded!")
		return FALSE

	if(!metal_sheets.use(CADE_UPGRADE_REQUIRED_SHEETS))
		return FALSE

	switch(choice)
		if(CADE_TYPE_BOMB)
			soft_armor = soft_armor.modifyRating(BOMB = CADE_UPGRADE_BOMB)
		if(CADE_TYPE_MELEE)
			soft_armor = soft_armor.modifyRating(MELEE = CADE_UPGRADE_MELEE["melee"], BULLET = CADE_UPGRADE_MELEE["bullet"], LASER = CADE_UPGRADE_MELEE["laser"], ENERGY = CADE_UPGRADE_MELEE["energy"])
		if(CADE_TYPE_ACID)
			soft_armor = soft_armor.modifyRating(ACID = CADE_UPGRADE_ACID)
			resistance_flags |= UNACIDABLE

	barricade_upgrade_type = choice
	stack_amount += 1

	balloon_alert_to_viewers("[choice] attached")

	playsound(loc, 'sound/items/screwdriver.ogg', 25, TRUE)
	update_icon()


/obj/structure/barricade/solid/examine(mob/user)
	. = ..()
	switch(build_state)
		if(BARRICADE_METAL_FIRM)
			. += span_info("The protection panel is still tighly screwed in place.")
		if(BARRICADE_METAL_ANCHORED)
			. += span_info("The protection panel has been removed, you can see the anchor bolts.")
		if(BARRICADE_METAL_LOOSE)
			. += span_info("The protection panel has been removed and the anchor bolts loosened. It's ready to be taken apart.")

	. += span_info("It is [barricade_upgrade_type ? "upgraded with [barricade_upgrade_type]" : "not upgraded"].")

/obj/structure/barricade/solid/welder_act(mob/living/user, obj/item/I)
	. = welder_repair_act(user, I, 85, 2.5 SECONDS, 0.3, SKILL_ENGINEER_METAL, 1)
	if(. == BELOW_INTEGRITY_THRESHOLD)
		balloon_alert(user, "too damaged, need metal sheets!")


/obj/structure/barricade/solid/screwdriver_act(mob/living/user, obj/item/I)
	if(LAZYACCESS(user.do_actions, src))
		return FALSE
	switch(build_state)
		if(BARRICADE_METAL_ANCHORED) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(user.skills.getRating(SKILL_CONSTRUCTION) < SKILL_CONSTRUCTION_METAL)
				var/fumbling_time = 1 SECONDS * ( SKILL_CONSTRUCTION_METAL - user.skills.getRating(SKILL_CONSTRUCTION) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return TRUE

			playsound(loc, 'sound/items/screwdriver.ogg', 25, TRUE)
			if(!do_after(user, 1 SECONDS, NONE, src, BUSY_ICON_BUILD))
				return TRUE

			balloon_alert_to_viewers("bolt protection panel replaced")
			build_state = BARRICADE_METAL_FIRM
			return TRUE

		if(BARRICADE_METAL_FIRM) //Fully constructed step. Use screwdriver to remove the protection panels to reveal the bolts
			if(user.skills.getRating(SKILL_CONSTRUCTION) < SKILL_CONSTRUCTION_METAL)
				var/fumbling_time = 1 SECONDS * ( SKILL_CONSTRUCTION_METAL - user.skills.getRating(SKILL_CONSTRUCTION) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return TRUE

			playsound(loc, 'sound/items/screwdriver.ogg', 25, TRUE)

			if(!do_after(user, 1 SECONDS, NONE, src, BUSY_ICON_BUILD))
				return TRUE

			balloon_alert_to_viewers("bolt protection panel removed")
			build_state = BARRICADE_METAL_ANCHORED
			return TRUE


/obj/structure/barricade/solid/wrench_act(mob/living/user, obj/item/I)
	if(LAZYACCESS(user.do_actions, src))
		return FALSE
	switch(build_state)
		if(BARRICADE_METAL_ANCHORED) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(user.skills.getRating(SKILL_CONSTRUCTION) < SKILL_CONSTRUCTION_METAL)
				var/fumbling_time = 1 SECONDS * ( SKILL_CONSTRUCTION_METAL - user.skills.getRating(SKILL_CONSTRUCTION) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return TRUE

			playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
			if(!do_after(user, 1 SECONDS, NONE, src, BUSY_ICON_BUILD))
				return TRUE

			balloon_alert_to_viewers("anchor bolts loosened")
			build_state = BARRICADE_METAL_LOOSE
			anchored = FALSE
			modify_max_integrity(initial(max_integrity) * 0.5)
			update_icon() //unanchored changes layer
			return TRUE

		if(BARRICADE_METAL_LOOSE) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to resecure anchor bolts

			var/turf/mystery_turf = get_turf(src)
			if(!isopenturf(mystery_turf))
				balloon_alert(user, "can't anchor here!")
				return TRUE

			var/turf/open/T = mystery_turf
			var/area/area = get_area(T)
			if(!T.allow_construction || area.area_flags & NO_CONSTRUCTION) //We shouldn't be able to anchor in areas we're not supposed to build; loophole closed.
				balloon_alert(user, "can't anchor here!")
				return TRUE

			if(user.skills.getRating(SKILL_CONSTRUCTION) < SKILL_CONSTRUCTION_METAL)
				var/fumbling_time = 1 SECONDS * ( SKILL_CONSTRUCTION_METAL - user.skills.getRating(SKILL_CONSTRUCTION) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return TRUE

			for(var/obj/structure/barricade/B in loc)
				if(B != src && B.dir == dir)
					balloon_alert(user, "already a barricade here!")
					return TRUE

			playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
			if(!do_after(user, 1 SECONDS, NONE, src, BUSY_ICON_BUILD))
				return TRUE

			balloon_alert_to_viewers("anchor bolts secured")
			build_state = BARRICADE_METAL_ANCHORED
			anchored = TRUE
			modify_max_integrity(initial(max_integrity))
			update_icon() //unanchored changes layer
			return TRUE


/obj/structure/barricade/solid/crowbar_act(mob/living/user, obj/item/I)
	if(LAZYACCESS(user.do_actions, src))
		return FALSE
	switch(build_state)
		if(BARRICADE_METAL_LOOSE) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to resecure anchor bolts
			if(user.skills.getRating(SKILL_CONSTRUCTION) < SKILL_CONSTRUCTION_METAL)
				var/fumbling_time = 5 SECONDS * ( SKILL_CONSTRUCTION_METAL - user.skills.getRating(SKILL_CONSTRUCTION) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return TRUE

			balloon_alert_to_viewers("disassembling")

			playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
			if(!do_after(user, 5 SECONDS, NONE, src, BUSY_ICON_BUILD))
				return TRUE

			user.visible_message(span_notice("[user] takes [src]'s panels apart."),
			span_notice("You take [src]'s panels apart."))
			playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
			deconstruct(!get_self_acid())
			return TRUE
		if(BARRICADE_METAL_FIRM)

			if(!barricade_upgrade_type) //Check to see if we actually have upgrades to remove.
				balloon_alert(user, "no upgrades to remove!")
				return TRUE

			if(user.skills.getRating(SKILL_CONSTRUCTION) < SKILL_CONSTRUCTION_METAL)
				var/fumbling_time = 5 SECONDS * ( SKILL_CONSTRUCTION_METAL - user.skills.getRating(SKILL_CONSTRUCTION) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return TRUE

			balloon_alert_to_viewers("removing armor plates...")

			playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
			if(!do_after(user, 5 SECONDS, NONE, src, BUSY_ICON_BUILD))
				return TRUE

			balloon_alert_to_viewers("removed armor plates")
			playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)

			switch(barricade_upgrade_type)
				if(CADE_TYPE_BOMB)
					soft_armor = soft_armor.modifyRating(BOMB = -CADE_UPGRADE_BOMB)
				if(CADE_TYPE_MELEE)
					soft_armor = soft_armor.modifyRating(MELEE = -CADE_UPGRADE_MELEE["melee"], BULLET = -CADE_UPGRADE_MELEE["bullet"], LASER = -CADE_UPGRADE_MELEE["laser"], ENERGY = -CADE_UPGRADE_MELEE["energy"])
				if(CADE_TYPE_ACID)
					soft_armor = soft_armor.modifyRating(ACID = -CADE_UPGRADE_ACID)
					resistance_flags &= ~UNACIDABLE

			new /obj/item/stack/sheet/metal(loc, CADE_UPGRADE_REQUIRED_SHEETS)
			barricade_upgrade_type = null
			stack_amount -= 1
			update_icon()
			return TRUE


/obj/structure/barricade/solid/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(rand(400, 600), BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(rand(150, 350), BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 100), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(rand(25, 50), BRUTE, BOMB)

	update_icon()

#undef BARRICADE_METAL_LOOSE
#undef BARRICADE_METAL_ANCHORED
#undef BARRICADE_METAL_FIRM

/obj/structure/barricade/solid/plasteel
	name = "plasteel barricade"
	desc = "A sturdy and easily assembled barricade made of reinforced plasteel plates, the pinnacle of strongpoints. Use a blowtorch to repair."
	icon = 'icons/obj/structures/barricades/plasteel.dmi'
	icon_state = "plasteel_0"
	max_integrity = 400
	stack_type = /obj/item/stack/sheet/plasteel
	stack_amount = BUILD_COST_PLASTEEL_CADE
	destroyed_stack_amount = 1
	barricade_type = "plasteel"
	soft_armor = list(MELEE = 0, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 100, FIRE = 80, ACID = 50)

/*----------------------*/
// Folding
/*----------------------*/

#define BARRICADE_PLASTEEL_LOOSE 0
#define BARRICADE_PLASTEEL_ANCHORED 1
#define BARRICADE_PLASTEEL_FIRM 2

/obj/structure/barricade/folding
	name = "folding plasteel barricade"
	desc = "A very sturdy barricade made out of plasteel panels, the pinnacle of strongpoints. Use a blowtorch to repair. Can be flipped down to create a path."
	icon = 'icons/obj/structures/barricades/plasteel.dmi'
	icon_state = "folding_plasteel_0"
	max_integrity = 550
	//barrier_flags = parent_type::barrier_flags|BARRIER_OPENS
	soft_armor = list(MELEE = 0, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 100, FIRE = 80, ACID = 50)
	coverage = 128
	stack_type = /obj/item/stack/sheet/plasteel
	stack_amount = BUILD_COST_PLASTEEL_CADE_FOLDABLE
	destroyed_stack_amount = 2
	hit_sound = "sound/effects/metalhit.ogg"
	barricade_type = "folding_plasteel"
	can_wire = TRUE
	climbable = TRUE
	COOLDOWN_DECLARE(tool_cooldown) //Delay to apply tools to prevent spamming
	///What state is our barricade in for construction steps?
	var/build_state = BARRICADE_PLASTEEL_FIRM
	var/busy = FALSE //Standard busy check
	///wether we react with other cades next to us ie when opening or so
	var/linked = FALSE
	///If we can be linked to nearby cades of the sametype
	var/linkable = TRUE
	///The skill type of this cade, used for fumble checks
	var/skilltype = SKILL_ENGINEER_PLASTEEL

/obj/structure/barricade/folding/Initialize(mapload, mob/user)
	. = ..()
	if(!user || !HAS_TRAIT(user, TRAIT_SUPERIOR_BUILDER))
		return
	modify_max_integrity(max_integrity + 100)

/obj/structure/barricade/folding/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -40, 8, 1)

/obj/structure/barricade/folding/handle_barrier_chance(mob/living/M)
	if(is_open)
		return FALSE
	return ..()

/obj/structure/barricade/folding/examine(mob/user)
	. = ..()

	switch(build_state)
		if(BARRICADE_PLASTEEL_FIRM)
			. += span_info("The protection panel is still tighly screwed in place.")
		if(BARRICADE_PLASTEEL_ANCHORED)
			. += span_info("The protection panel has been removed, you can see the anchor bolts.")
		if(BARRICADE_PLASTEEL_LOOSE)
			. += span_info("The protection panel has been removed and the anchor bolts loosened. It's ready to be taken apart.")

/obj/structure/barricade/folding/welder_act(mob/living/user, obj/item/I)
	. = welder_repair_act(user, I, 85, 2.5 SECONDS, 0.3, skilltype, 1)
	if(. == BELOW_INTEGRITY_THRESHOLD)
		balloon_alert(user, "too damaged, need [barricade_type] sheets!")

/obj/structure/barricade/folding/screwdriver_act(mob/living/user, obj/item/I)
	if(!isscrewdriver(I))
		return

	if(busy || !COOLDOWN_FINISHED(src, tool_cooldown))
		return

	if(LAZYACCESS(user.do_actions, src))
		return

	COOLDOWN_START(src, tool_cooldown, 1 SECONDS)

	switch(build_state)
		if(BARRICADE_PLASTEEL_FIRM) //Fully constructed step. Use screwdriver to remove the protection panels to reveal the bolts
			if(user.skills.getRating(SKILL_ENGINEER) < skilltype)
				var/fumbling_time = 1 SECONDS * ( skilltype - user.skills.getRating(SKILL_ENGINEER) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return

			for(var/obj/structure/barricade/B in loc)
				if(B != src && B.dir == dir)
					balloon_alert(user, "already a barricade here!")
					return

			if(!do_after(user, 1, NONE, src, BUSY_ICON_BUILD))
				return

			balloon_alert_to_viewers("bolt protection panel removed")
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			build_state = BARRICADE_PLASTEEL_ANCHORED
		if(BARRICADE_PLASTEEL_ANCHORED) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(user.skills.getRating(SKILL_ENGINEER) < skilltype)
				var/fumbling_time = 1 SECONDS * ( skilltype - user.skills.getRating(SKILL_ENGINEER) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return
			balloon_alert_to_viewers("bolt protection panel replaced")
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			build_state = BARRICADE_PLASTEEL_FIRM

/obj/structure/barricade/folding/crowbar_act(mob/living/user, obj/item/I)
	if(!iscrowbar(I))
		return

	if(busy || !COOLDOWN_FINISHED(src, tool_cooldown))
		return

	if(LAZYACCESS(user.do_actions, src))
		return

	COOLDOWN_START(src, tool_cooldown, 1 SECONDS)

	switch(build_state)
		if(BARRICADE_PLASTEEL_FIRM)
			if(linkable)
				balloon_alert_to_viewers("[linked ? "un" : "" ]linked")
				linked = !linked
				for(var/direction in GLOB.cardinals)
					for(var/obj/structure/barricade/folding/cade in get_step(src, direction))
						cade.update_icon()
				update_icon()
		if(BARRICADE_PLASTEEL_LOOSE) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing.
			if(user.skills.getRating(SKILL_ENGINEER) < skilltype)
				var/fumbling_time = 5 SECONDS * ( skilltype - user.skills.getRating(SKILL_ENGINEER) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return
			balloon_alert_to_viewers("disassembling...")
			playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
			busy = TRUE

			if(!do_after(user, 5 SECONDS, NONE, src, BUSY_ICON_BUILD))
				busy = FALSE
				return

			busy = FALSE
			user.visible_message(span_notice("[user] takes [src]'s panels apart."),
			span_notice("You take [src]'s panels apart."))
			playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
			deconstruct(!get_self_acid())

/obj/structure/barricade/folding/wrench_act(mob/living/user, obj/item/I)
	if(!iswrench(I))
		return

	if(busy || !COOLDOWN_FINISHED(src, tool_cooldown))
		return

	if(LAZYACCESS(user.do_actions, src))
		return

	COOLDOWN_START(src, tool_cooldown, 1 SECONDS)

	switch(build_state)
		if(BARRICADE_PLASTEEL_ANCHORED) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(user.skills.getRating(SKILL_ENGINEER) < skilltype)
				var/fumbling_time = 1 SECONDS * ( skilltype - user.skills.getRating(SKILL_ENGINEER) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return
			balloon_alert_to_viewers("anchor bolts loosened")
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			anchored = FALSE
			modify_max_integrity(initial(max_integrity) * 0.5)
			build_state = BARRICADE_PLASTEEL_LOOSE
			update_icon() //unanchored changes layer
		if(BARRICADE_PLASTEEL_LOOSE) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to rescure anchor bolts
			var/turf/mystery_turf = get_turf(src)
			if(!isopenturf(mystery_turf))
				balloon_alert(user, "can't anchor here!")
				return

			var/turf/open/T = mystery_turf
			var/area/area = get_area(T)
			if(!T.allow_construction || area.area_flags & NO_CONSTRUCTION) //We shouldn't be able to anchor in areas we're not supposed to build; loophole closed.
				balloon_alert(user, "can't anchor here!")
				return

			if(user.skills.getRating(SKILL_ENGINEER) < skilltype)
				var/fumbling_time = 1 SECONDS * ( skilltype - user.skills.getRating(SKILL_ENGINEER) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return
			balloon_alert_to_viewers("secured bolts")
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			anchored = TRUE
			modify_max_integrity(initial(max_integrity))
			build_state = BARRICADE_PLASTEEL_ANCHORED
			update_icon() //unanchored changes layer

/obj/structure/barricade/folding/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!istype(I, stack_type))
		return
	var/obj/item/stack/sheet/stack = I
	if(obj_integrity >= max_integrity * 0.3)
		return

	if(stack.get_amount() < 2)
		balloon_alert(user, "2 [barricade_type] sheets required!")
		return

	if(LAZYACCESS(user.do_actions, src))
		return

	balloon_alert_to_viewers("repairing base...")

	if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_FRIENDLY) || obj_integrity >= max_integrity * 0.3)
		return

	if(get_self_acid())
		balloon_alert(user, "it's melting!")
		return TRUE

	if(!stack.use(2))
		return

	repair_damage(max_integrity * 0.3, user)
	balloon_alert_to_viewers("base repaired")
	update_icon()

/obj/structure/barricade/folding/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	toggle_open(null, user)

/obj/structure/barricade/folding/proc/toggle_open(state, atom/user)
	if(state == is_open)
		return
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	is_open = !is_open
	density = !density

	user?.visible_message(span_notice("[user] flips [src] [is_open ? "open" :"closed"]."),
		span_notice("You flip [src] [is_open ? "open" :"closed"]."))

	if(!linked || !linkable)
		update_icon()
		return
	for(var/direction in GLOB.cardinals)
		for(var/obj/structure/barricade/folding/cade in get_step(src, direction))
			if(((dir & (NORTH|SOUTH) && get_dir(src, cade) & (EAST|WEST)) || (dir & (EAST|WEST) && get_dir(src, cade) & (NORTH|SOUTH))) && dir == cade.dir && cade.linked)
				cade.toggle_open(is_open)

	update_icon()

/obj/structure/barricade/folding/update_overlays()
	. = ..()
	if(!linked)
		return
	for(var/direction in GLOB.cardinals)
		for(var/obj/structure/barricade/folding/cade in get_step(src, direction))
			if(((dir & (NORTH|SOUTH) && get_dir(src, cade) & (EAST|WEST)) || (dir & (EAST|WEST) && get_dir(src, cade) & (NORTH|SOUTH))) && dir == cade.dir && cade.linked && cade.is_open == is_open)
				. += image(icon, icon_state = "[barricade_type]_[is_open ? "open" : "closed"]_connection_[get_dir(src, cade)]")

/obj/structure/barricade/folding/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(rand(450, 650), BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(rand(200, 400), BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 150), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(rand(25, 75), BRUTE, BOMB)

	update_icon()

#undef BARRICADE_PLASTEEL_LOOSE
#undef BARRICADE_PLASTEEL_ANCHORED
#undef BARRICADE_PLASTEEL_FIRM

/obj/structure/barricade/folding/metal
	name = "folding metal barricade"
	desc = "A folding barricade made out of metal, making it slightly stronger than a normal metal barricade. Use a blowtorch to repair. Can be flipped down to create a path."
	icon_state = "folding_metal_0"
	icon = 'icons/obj/structures/barricades/metal.dmi'
	max_integrity = 350
	stack_type = /obj/item/stack/sheet/metal
	stack_amount = BUILD_COST_METAL_CADE_FOLDABLE
	destroyed_stack_amount = 3
	barricade_type = "folding_metal"
	linkable = FALSE
	soft_armor = list(MELEE = 0, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 100, FIRE = 80, ACID = 40)

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
	barricade_type = "sandbag"
	can_wire = TRUE

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
		update_icon()

/obj/structure/barricade/solid/deployable
	icon = 'icons/obj/structures/barricades/folding.dmi'
	icon_state = "folding_0"
	max_integrity = 325
	coverage = 100
	barricade_type = "folding"
	can_wire = TRUE
	is_wired = FALSE
	soft_armor = list(MELEE = 35, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 25, BIO = 100, FIRE = 100, ACID = 30)
	///Whether this item can be deployed or undeployed
	var/item_flags = IS_DEPLOYABLE
	///What it deploys into. typecast version of internal_item
	var/obj/item/weapon/shield/riot/marine/deployable/internal_shield

/obj/structure/barricade/solid/deployable/Initialize(mapload, _internal_item, deployer)
	. = ..()
	if(!_internal_item && !internal_shield)
		return INITIALIZE_HINT_QDEL

	internal_shield = _internal_item

	name = internal_shield.name
	desc = internal_shield.desc
	//if the shield is wired, it deploys wired
	if(internal_shield.is_wired)
		can_wire = FALSE
		is_wired = TRUE
		climbable = FALSE

/obj/structure/barricade/solid/deployable/get_internal_item()
	return internal_shield

/obj/structure/barricade/solid/deployable/clear_internal_item()
	internal_shield = null

/obj/structure/barricade/solid/deployable/Destroy()
	if(internal_shield)
		QDEL_NULL(internal_shield)
	return ..()

/obj/structure/barricade/solid/deployable/MouseDrop(over_object, src_location, over_location)
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	if(over_object != user || !in_range(src, user) || user.incapacitated() || user.lying_angle)
		return
	disassemble(user)

/obj/structure/barricade/solid/deployable/wire()
	. = ..()
	//makes the shield item wired as well
	internal_shield.is_wired = TRUE
	internal_shield.modify_max_integrity(max_integrity + 50)

/obj/structure/barricade/solid/deployable/attempt_barricade_upgrade()
	return //not upgradable


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
	barricade_type = "concrete"
	can_wire = FALSE

