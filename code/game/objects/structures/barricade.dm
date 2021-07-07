// Snow, wood, sandbags, metal, plasteel

/obj/structure/barricade
	icon = 'icons/Marine/barricades.dmi'
	climbable = TRUE
	anchored = TRUE
	density = TRUE
	throwpass = TRUE //You can throw objects over this, despite its density.//This comment is a lie, throwpass is for projectiles apparently
	layer = BELOW_OBJ_LAYER
	flags_atom = ON_BORDER
	resistance_flags = XENO_DAMAGEABLE
	climb_delay = 20 //Leaping a barricade is universally much faster than clumsily climbing on a table or rack
	max_integrity = 100
	///The type of stack the barricade dropped when disassembled if any.
	var/stack_type
	///The amount of stack dropped when disassembled at full health
	var/stack_amount = 5
	///to specify a non-zero amount of stack to drop when destroyed
	var/destroyed_stack_amount = 0
	var/base_acid_damage = 2
	///Whether things can be thrown over
	var/allow_thrown_objs = TRUE
	var/barricade_type = "barricade" //"metal", "plasteel", etc.
	///Whether this barricade has damaged states
	var/can_change_dmg_state = TRUE
	///Whether we can open/close this barrricade and thus go over it
	var/closed = FALSE
	///Can this barricade type be wired
	var/can_wire = FALSE
	///is this barriade wired?
	var/is_wired = FALSE
	flags_barrier = HANDLE_BARRIER_CHANCE

/obj/structure/barricade/Initialize()
	. = ..()
	update_icon()

/obj/structure/barricade/handle_barrier_chance(mob/living/M)
	return prob(max(30,(100.0*obj_integrity)/max_integrity))

/obj/structure/barricade/examine(mob/user)
	. = ..()
	if(is_wired)
		to_chat(user, "<span class='info'>There is a length of wire strewn across the top of this barricade.</span>")
	switch((obj_integrity / max_integrity) * 100)
		if(75 to INFINITY)
			to_chat(user, "<span class='info'>It appears to be in good shape.</span>")
		if(50 to 75)
			to_chat(user, "<span class='warning'>It's slightly damaged, but still very functional.</span>")
		if(25 to 50)
			to_chat(user, "<span class='warning'>It's quite beat up, but it's holding together.</span>")
		if(-INFINITY to 25)
			to_chat(user, "<span class='warning'>It's crumbling apart, just a few more blows will tear it apart.</span>")


/obj/structure/barricade/CheckExit(atom/movable/O, turf/target)
	. = ..()
	if(closed)
		return TRUE

	if(CHECK_BITFIELD(O.flags_pass, PASSSMALLSTRUCT))
		return TRUE

	if(O.throwing)
		if(is_wired && iscarbon(O)) //Leaping mob against barbed wire fails
			if(get_dir(loc, target) & dir)
				return FALSE
		if(!allow_thrown_objs && !istype(O, /obj/projectile))
			if(get_dir(loc, target) & dir)
				return FALSE
		return TRUE

/obj/structure/barricade/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(closed)
		return TRUE

	if(CHECK_BITFIELD(mover.flags_pass, PASSSMALLSTRUCT))
		return TRUE

	if(mover?.throwing)
		if(is_wired && iscarbon(mover)) //Leaping mob against barbed wire fails
			if(get_dir(loc, target) & dir)
				return FALSE
		if(!allow_thrown_objs && !istype(mover, /obj/projectile))
			if(get_dir(loc, target) & dir)
				return FALSE
		return TRUE

	if(istype(mover, /obj/vehicle/multitile))
		visible_message("<span class='danger'>[mover] drives over and destroys [src]!</span>")
		deconstruct(FALSE)
		return FALSE

	if((mover.flags_atom & ON_BORDER) && get_dir(loc, target) & dir)
		return FALSE

	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S?.climbable && !(S.flags_atom & ON_BORDER) && climbable && isliving(mover)) //Climbable objects allow you to universally climb over others
		return TRUE

	if(get_dir(loc, target) & dir)
		return FALSE
	else
		return TRUE

/obj/structure/barricade/attack_animal(mob/user)
	return attack_alien(user)

/obj/structure/barricade/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if(is_wired)
		X.visible_message("<span class='danger'>The barbed wire slices into [X]!</span>",
		"<span class='danger'>The barbed wire slices into us!</span>", null, 5)
		X.apply_damage(10, updating_health = TRUE)

	SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_BARRICADE)
	return ..()

/obj/structure/barricade/attackby(obj/item/I, mob/user, params)
	. = ..()

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	if(istype(I, /obj/item/stack/barbed_wire))
		var/obj/item/stack/barbed_wire/B = I
		if(!can_wire)
			return

		user.visible_message("<span class='notice'>[user] starts setting up [I] on [src].</span>",
		"<span class='notice'>You start setting up [I] on [src].</span>")
		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD) || !can_wire)
			return

		playsound(loc, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] sets up [I] on [src].</span>",
		"<span class='notice'>You set up [I] on [src].</span>")

		B.use(1)
		wire()


/obj/structure/barricade/proc/wire()
	can_wire = FALSE
	is_wired = TRUE
	climbable = FALSE
	modify_max_integrity(max_integrity + 50)
	update_icon()

/obj/structure/barricade/wirecutter_act(mob/living/user, obj/item/I)
	if(!is_wired || user.do_actions)
		return FALSE

	user.visible_message("<span class='notice'>[user] begin removing the barbed wire on [src].</span>",
	"<span class='notice'>You begin removing the barbed wire on [src].</span>")

	if(!do_after(user, 2 SECONDS, TRUE, src, BUSY_ICON_BUILD))
		return TRUE

	playsound(loc, 'sound/items/wirecutter.ogg', 25, TRUE)
	user.visible_message("<span class='notice'>[user] removes the barbed wire on [src].</span>",
	"<span class='notice'>You remove the barbed wire on [src].</span>")
	modify_max_integrity(max_integrity - 50)
	can_wire = TRUE
	is_wired = FALSE
	climbable = TRUE
	update_icon()
	new /obj/item/stack/barbed_wire(loc)


/obj/structure/barricade/deconstruct(disassembled = TRUE)
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
			visible_message("<span class='danger'>[src] is blown apart!</span>")
			deconstruct(FALSE)
			return
		if(EXPLODE_HEAVY)
			take_damage(rand(33, 66))
		if(EXPLODE_LIGHT)
			take_damage(rand(10, 33))
	update_icon()

/obj/structure/barricade/setDir(newdir)
	. = ..()
	update_icon()

/obj/structure/barricade/update_icon()
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
	if(!closed)
		if(can_change_dmg_state)
			icon_state = "[barricade_type]_[damage_state]"
		else
			icon_state = "[barricade_type]"
		switch(dir)
			if(SOUTH)
				layer = ABOVE_MOB_LAYER
			if(NORTH)
				layer = initial(layer) - 0.01
			else
				layer = initial(layer)
		if(!anchored)
			layer = initial(layer)
	else
		if(can_change_dmg_state)
			icon_state = "[barricade_type]_closed_[damage_state]"
		else
			icon_state = "[barricade_type]_closed"
		layer = OBJ_LAYER

/obj/structure/barricade/update_overlays()
	. = ..()
	if(is_wired)
		if(!closed)
			. += image('icons/Marine/barricades.dmi', icon_state = "[barricade_type]_wire")
		else
			. += image('icons/Marine/barricades.dmi', icon_state = "[barricade_type]_closed_wire")


/obj/structure/barricade/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		take_damage(base_acid_damage * S.strength)


/obj/structure/barricade/verb/rotate()
	set name = "Rotate Barricade Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor, you can't rotate it!</span>")
		return FALSE

	setDir(turn(dir, 90))

/obj/structure/barricade/verb/revrotate()
	set name = "Rotate Barricade Clockwise"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor, you can't rotate it!</span>")
		return FALSE

	setDir(turn(dir, 270))


/obj/structure/barricade/attack_hand_alternate(mob/living/user)
	if(anchored)
		to_chat(user, "<span class='warning'>It is fastened to the floor, you can't rotate it!</span>")
		return FALSE

	setDir(turn(dir, 270))


/*----------------------*/
// SNOW
/*----------------------*/

/obj/structure/barricade/snow
	name = "snow barricade"
	desc = "A mound of snow shaped into a sloped wall. Statistically better than thin air as cover."
	icon_state = "snow_0"
	barricade_type = "snow"
	max_integrity = 75
	stack_type = /obj/item/stack/snow
	stack_amount = 3
	destroyed_stack_amount = 0
	can_wire = FALSE



//Item Attack
/obj/structure/barricade/snow/attackby(obj/item/I, mob/user, params)
	. = ..()

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	//Removing the barricades
	if(istype(I, /obj/item/tool/shovel) && user.a_intent != INTENT_HARM)
		var/obj/item/tool/shovel/ET = I

		if(ET.folded)
			return

		if(user.do_actions)
			to_chat(user, "<span class='warning'> You are already shoveling!</span>")
			return

		user.visible_message("[user] starts clearing out \the [src].", "You start removing \the [src].")

		if(!do_after(user, ET.shovelspeed, TRUE, src, BUSY_ICON_BUILD))
			return

		if(!ET.folded)
			user.visible_message("<span class='notice'> \The [user] removes \the [src].</span>")
			var/deconstructed = TRUE
			for(var/obj/effect/xenomorph/acid/A in loc)
				if(A.acid_t != src)
					continue
				deconstructed = FALSE
				break
			deconstruct(deconstructed)

/*----------------------*/
// GUARD RAIL
/*----------------------*/

/obj/structure/barricade/guardrail
	name = "guard rail"
	desc = "A short wall made of rails to prevent entry into dangerous areas."
	icon_state = "railing_0"
	coverage = 25
	max_integrity = 150
	soft_armor = list("melee" = 0, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 15, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 10)
	climbable = FALSE
	stack_type = /obj/item/stack/rods
	destroyed_stack_amount = 3
	hit_sound = "sound/effects/metalhit.ogg"
	barricade_type = "railing"
	allow_thrown_objs = FALSE
	can_wire = FALSE

/obj/structure/barricade/guardrail/update_icon()
	. = ..()
	if(dir == NORTH)
		pixel_y = 12

/*----------------------*/
// WOOD
/*----------------------*/

/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "A wall made out of wooden planks nailed together. Not very sturdy, but can provide some concealment."
	icon_state = "wooden"
	max_integrity = 100
	layer = OBJ_LAYER
	climbable = FALSE
	throwpass = FALSE
	stack_type = /obj/item/stack/sheet/wood
	stack_amount = 5
	destroyed_stack_amount = 3
	hit_sound = "sound/effects/woodhit.ogg"
	can_change_dmg_state = FALSE
	barricade_type = "wooden"
	can_wire = FALSE

/obj/structure/barricade/wooden/attackby(obj/item/I, mob/user, params)
	. = ..()

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	if(istype(I, /obj/item/stack/sheet/wood))
		var/obj/item/stack/sheet/wood/D = I
		if(obj_integrity >= max_integrity)
			return

		if(D.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one plank of wood to repair [src].</span>")
			return

		visible_message("<span class='notice'>[user] begins to repair [src].</span>")

		if(!do_after(user,20, TRUE, src, BUSY_ICON_FRIENDLY) || obj_integrity >= max_integrity)
			return

		if(!D.use(1))
			return

		repair_damage(max_integrity)
		visible_message("<span class='notice'>[user] repairs [src].</span>")


/*----------------------*/
// METAL
/*----------------------*/

#define BARRICADE_METAL_LOOSE 0
#define BARRICADE_METAL_ANCHORED 1
#define BARRICADE_METAL_FIRM 2

#define CADE_TYPE_BOMB "concussive armor"
#define CADE_TYPE_MELEE "ballistic armor"
#define CADE_TYPE_ACID "caustic armor"

#define CADE_UPGRADE_REQUIRED_SHEETS 2

/obj/structure/barricade/metal
	name = "metal barricade"
	desc = "A sturdy and easily assembled barricade made of metal plates, often used for quick fortifications. Use a blowtorch to repair."
	icon_state = "metal_0"
	max_integrity = 200
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 80, "acid" = 40)
	coverage = 128
	stack_type = /obj/item/stack/sheet/metal
	stack_amount = 4
	destroyed_stack_amount = 2
	hit_sound = "sound/effects/metalhit.ogg"
	barricade_type = "metal"
	can_wire = TRUE
	///Build state of the barricade
	var/build_state = BARRICADE_METAL_FIRM
	///The type of upgrade and corresponding overlay we have attached
	var/barricade_upgrade_type

/obj/structure/barricade/metal/update_overlays()
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
			. += image('icons/Marine/barricades.dmi', icon_state = "+explosive_upgrade_[damage_state]")
		if(CADE_TYPE_MELEE)
			. += image('icons/Marine/barricades.dmi', icon_state = "+brute_upgrade_[damage_state]")
		if(CADE_TYPE_ACID)
			. += image('icons/Marine/barricades.dmi', icon_state = "+burn_upgrade_[damage_state]")

/obj/structure/barricade/metal/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/metal_sheets = I
		if(obj_integrity > max_integrity * 0.3)
			return attempt_barricade_upgrade(I, user, params)

		if(metal_sheets.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two metal sheets to repair the base of [src].</span>")
			return FALSE

		visible_message("<span class='notice'>[user] begins to repair the base of [src].</span>")

		if(!do_after(user, 2 SECONDS, TRUE, src, BUSY_ICON_FRIENDLY) || obj_integrity >= max_integrity)
			return FALSE

		if(!metal_sheets.use(2))
			return FALSE

		repair_damage(max_integrity * 0.3)
		visible_message("<span class='notice'>[user] repairs the base of [src].</span>")



/obj/structure/barricade/metal/proc/attempt_barricade_upgrade(obj/item/stack/sheet/metal/metal_sheets, mob/user, params)
	if(barricade_upgrade_type)
		to_chat(user, "<span class='warning'>[src] is already upgraded.</span>")
		return FALSE
	if(obj_integrity < max_integrity)
		to_chat(user, "<span class='warning'>You need [src] to be at full health before you can upgrade it.</span>")
		return FALSE

	if(metal_sheets.get_amount() < CADE_UPGRADE_REQUIRED_SHEETS)
		to_chat(user, "<span class='warning'>You need at least [CADE_UPGRADE_REQUIRED_SHEETS] metal sheets to repair the base of [src].</span>")
		return FALSE

	var/static/list/cade_types = list(CADE_TYPE_BOMB = image(icon = 'icons/Marine/barricades.dmi', icon_state = "explosive_obj"), CADE_TYPE_MELEE = image(icon = 'icons/Marine/barricades.dmi', icon_state = "brute_obj"), CADE_TYPE_ACID = image(icon = 'icons/Marine/barricades.dmi', icon_state = "burn_obj"))
	var/choice = show_radial_menu(user, src, cade_types, require_near = TRUE, tooltips = TRUE)

	if(user.skills.getRating("construction") < SKILL_CONSTRUCTION_METAL)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to attach armor plates to [src].</span>",
		"<span class='notice'>You fumble around figuring out how to attach armor plates on [src].</span>")
		var/fumbling_time = 2 SECONDS * ( SKILL_CONSTRUCTION_METAL - user.skills.getRating("construction") )
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
			return FALSE

	user.visible_message("<span class='notice'>[user] begins attaching [choice] to [src].</span>",
		"<span class='notice'>You begin attaching [choice] to [src].</span>")
	if(!do_after(user, 2 SECONDS, TRUE, src, BUSY_ICON_BUILD))
		return FALSE

	if(!metal_sheets.use(CADE_UPGRADE_REQUIRED_SHEETS))
		return FALSE

	switch(choice)
		if(CADE_TYPE_BOMB)
			soft_armor = soft_armor.modifyRating(bomb = 50)
		if(CADE_TYPE_MELEE)
			soft_armor = soft_armor.modifyRating(melee = 30, bullet = 30)
		if(CADE_TYPE_ACID)
			soft_armor = soft_armor.modifyRating(bio = 0, acid = 20)

	barricade_upgrade_type = choice

	user.visible_message("<span class='notice'>[user] attaches [choice] to [src].</span>",
		"<span class='notice'>You attach [choice] to [src].</span>")

	playsound(loc, 'sound/items/screwdriver.ogg', 25, TRUE)
	update_icon()


/obj/structure/barricade/metal/examine(mob/user)
	. = ..()
	switch(build_state)
		if(BARRICADE_METAL_FIRM)
			to_chat(user, "<span class='info'>The protection panel is still tighly screwed in place.</span>")
		if(BARRICADE_METAL_ANCHORED)
			to_chat(user, "<span class='info'>The protection panel has been removed, you can see the anchor bolts.</span>")
		if(BARRICADE_METAL_LOOSE)
			to_chat(user, "<span class='info'>The protection panel has been removed and the anchor bolts loosened. It's ready to be taken apart.</span>")

	to_chat(user, "<span class='info'>It is [barricade_upgrade_type ? "upgraded with [barricade_upgrade_type]" : "not upgraded"].</span>")

/obj/structure/barricade/metal/welder_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE

	var/obj/item/tool/weldingtool/WT = I

	if(!WT.isOn())
		return FALSE

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return TRUE

	if(obj_integrity <= max_integrity * 0.3)
		to_chat(user, "<span class='warning'>[src] has sustained too much structural damage and needs more metal plates to be repaired.</span>")
		return TRUE

	if(obj_integrity == max_integrity)
		to_chat(user, "<span class='warning'>[src] doesn't need repairs.</span>")
		return TRUE

	if(user.skills.getRating("engineer") < SKILL_ENGINEER_METAL)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to repair [src].</span>",
		"<span class='notice'>You fumble around figuring out how to repair [src].</span>")
		var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_METAL - user.skills.getRating("engineer") )
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_BUILD))
			return TRUE

	user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
	"<span class='notice'>You begin repairing the damage to [src].</span>")
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)

	if(!do_after(user, 5 SECONDS, TRUE, src, BUSY_ICON_FRIENDLY))
		return TRUE

	if(obj_integrity <= max_integrity * 0.3 || obj_integrity == max_integrity)
		return TRUE

	if(!WT.remove_fuel(2, user))
		to_chat(user, "<span class='warning'>Not enough fuel to finish the task.</span>")
		return TRUE

	user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
	"<span class='notice'>You repair [src].</span>")
	repair_damage(150)
	update_icon()
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)
	return TRUE


/obj/structure/barricade/metal/screwdriver_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE
	switch(build_state)
		if(BARRICADE_METAL_ANCHORED) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(user.skills.getRating("construction") < SKILL_CONSTRUCTION_METAL)
				user.visible_message("<span class='notice'>[user] fumbles around figuring out how to assemble [src].</span>",
				"<span class='notice'>You fumble around figuring out how to assemble [src].</span>")
				var/fumbling_time = 1 SECONDS * ( SKILL_CONSTRUCTION_METAL - user.skills.getRating("construction") )
				if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
					return TRUE

			playsound(loc, 'sound/items/screwdriver.ogg', 25, TRUE)
			if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_BUILD))
				return TRUE

			user.visible_message("<span class='notice'>[user] set [src]'s protection panel back.</span>",
			"<span class='notice'>You set [src]'s protection panel back.</span>")
			build_state = BARRICADE_METAL_FIRM
			return TRUE

		if(BARRICADE_METAL_FIRM) //Fully constructed step. Use screwdriver to remove the protection panels to reveal the bolts
			if(user.skills.getRating("construction") < SKILL_CONSTRUCTION_METAL)
				user.visible_message("<span class='notice'>[user] fumbles around figuring out how to disassemble [src].</span>",
				"<span class='notice'>You fumble around figuring out how to disassemble [src].</span>")
				var/fumbling_time = 1 SECONDS * ( SKILL_CONSTRUCTION_METAL - user.skills.getRating("construction") )
				if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
					return TRUE

			playsound(loc, 'sound/items/screwdriver.ogg', 25, TRUE)

			if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_BUILD))
				return TRUE

			user.visible_message("<span class='notice'>[user] removes [src]'s protection panel.</span>",
			"<span class='notice'>You remove [src]'s protection panels, exposing the anchor bolts.</span>")
			build_state = BARRICADE_METAL_ANCHORED
			return TRUE


/obj/structure/barricade/metal/wrench_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE
	switch(build_state)
		if(BARRICADE_METAL_ANCHORED) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(user.skills.getRating("construction") < SKILL_CONSTRUCTION_METAL)
				user.visible_message("<span class='notice'>[user] fumbles around figuring out how to disassemble [src].</span>",
				"<span class='notice'>You fumble around figuring out how to disassemble [src].</span>")
				var/fumbling_time = 1 SECONDS * ( SKILL_CONSTRUCTION_METAL - user.skills.getRating("construction") )
				if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
					return TRUE

			playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
			if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_BUILD))
				return TRUE

			user.visible_message("<span class='notice'>[user] loosens [src]'s anchor bolts.</span>",
			"<span class='notice'>You loosen [src]'s anchor bolts.</span>")
			build_state = BARRICADE_METAL_LOOSE
			anchored = FALSE
			modify_max_integrity(initial(max_integrity) * 0.5)
			update_icon() //unanchored changes layer
			return TRUE

		if(BARRICADE_METAL_LOOSE) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to resecure anchor bolts

			var/turf/mystery_turf = get_turf(src)
			if(!isopenturf(mystery_turf))
				to_chat(user, "<span class='warning'>We can't anchor the barricade here!</span>")
				return TRUE

			var/turf/open/T = mystery_turf
			if(!T.allow_construction) //We shouldn't be able to anchor in areas we're not supposed to build; loophole closed.
				to_chat(user, "<span class='warning'>We can't anchor the barricade here!</span>")
				return TRUE

			if(user.skills.getRating("construction") < SKILL_CONSTRUCTION_METAL)
				user.visible_message("<span class='notice'>[user] fumbles around figuring out how to assemble [src].</span>",
				"<span class='notice'>You fumble around figuring out how to assemble [src].</span>")
				var/fumbling_time = 1 SECONDS * ( SKILL_CONSTRUCTION_METAL - user.skills.getRating("construction") )
				if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
					return TRUE

			for(var/obj/structure/barricade/B in loc)
				if(B != src && B.dir == dir)
					to_chat(user, "<span class='warning'>There's already a barricade here.</span>")
					return TRUE

			playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
			if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_BUILD))
				return TRUE

			user.visible_message("<span class='notice'>[user] secures [src]'s anchor bolts.</span>",
			"<span class='notice'>You secure [src]'s anchor bolts.</span>")
			build_state = BARRICADE_METAL_ANCHORED
			anchored = TRUE
			modify_max_integrity(initial(max_integrity))
			update_icon() //unanchored changes layer
			return TRUE


/obj/structure/barricade/metal/crowbar_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE
	switch(build_state)
		if(BARRICADE_METAL_LOOSE) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to resecure anchor bolts
			if(user.skills.getRating("construction") < SKILL_CONSTRUCTION_METAL)
				user.visible_message("<span class='notice'>[user] fumbles around figuring out how to disassemble [src].</span>",
				"<span class='notice'>You fumble around figuring out how to disassemble [src].</span>")
				var/fumbling_time = 5 SECONDS * ( SKILL_CONSTRUCTION_METAL - user.skills.getRating("construction") )
				if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
					return TRUE

			user.visible_message("<span class='notice'>[user] starts unseating [src]'s panels.</span>",
			"<span class='notice'>You start unseating [src]'s panels.</span>")

			playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
			if(!do_after(user, 5 SECONDS, TRUE, src, BUSY_ICON_BUILD))
				return TRUE

			user.visible_message("<span class='notice'>[user] takes [src]'s panels apart.</span>",
			"<span class='notice'>You take [src]'s panels apart.</span>")
			playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
			var/deconstructed = TRUE
			for(var/obj/effect/xenomorph/acid/A in loc)
				if(A.acid_t != src)
					continue
				deconstructed = FALSE
				break
			deconstruct(deconstructed)
			return TRUE
		if(BARRICADE_METAL_FIRM)

			if(!barricade_upgrade_type) //Check to see if we actually have upgrades to remove.
				to_chat(user, "<span class='warning'>This barricade has no upgrades to remove!</span>")
				return TRUE

			if(user.skills.getRating("construction") < SKILL_CONSTRUCTION_METAL)
				user.visible_message("<span class='notice'>[user] fumbles around figuring out how to disassemble [src]'s armor plates.</span>",
				"<span class='notice'>You fumble around figuring out how to disassemble [src]'s armor plates..</span>")
				var/fumbling_time = 5 SECONDS * ( SKILL_CONSTRUCTION_METAL - user.skills.getRating("construction") )
				if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
					return TRUE

			user.visible_message("<span class='notice'>[user] starts disassembling [src]'s armor plates.</span>",
			"<span class='notice'>You start disassembling [src]'s armor plates.</span>")

			playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
			if(!do_after(user, 5 SECONDS, TRUE, src, BUSY_ICON_BUILD))
				return TRUE

			user.visible_message("<span class='notice'>[user] takes [src]'s armor plates apart.</span>",
			"<span class='notice'>You take [src]'s armor plates apart.</span>")
			playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)

			switch(barricade_upgrade_type)
				if(CADE_TYPE_BOMB)
					soft_armor = soft_armor.modifyRating(bomb = -50)
				if(CADE_TYPE_MELEE)
					soft_armor = soft_armor.modifyRating(melee = -30, bullet = -30)
				if(CADE_TYPE_ACID)
					soft_armor = soft_armor.modifyRating(bio = 0, acid = -20)

			new /obj/item/stack/sheet/metal(loc, CADE_UPGRADE_REQUIRED_SHEETS)
			barricade_upgrade_type = null
			update_icon()
			return TRUE


/obj/structure/barricade/metal/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(rand(400, 600))
		if(EXPLODE_HEAVY)
			take_damage(rand(150, 350))
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 100))

	update_icon()


#undef BARRICADE_METAL_LOOSE
#undef BARRICADE_METAL_ANCHORED
#undef BARRICADE_METAL_FIRM

/*----------------------*/
// PLASTEEL
/*----------------------*/

#define BARRICADE_PLASTEEL_LOOSE 0
#define BARRICADE_PLASTEEL_ANCHORED 1
#define BARRICADE_PLASTEEL_FIRM 2

/obj/structure/barricade/plasteel
	name = "plasteel barricade"
	desc = "A very sturdy barricade made out of plasteel panels, the pinnacle of strongpoints. Use a blowtorch to repair. Can be flipped down to create a path."
	icon_state = "plasteel_closed_0"
	max_integrity = 500
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 80, "acid" = 40)
	coverage = 128
	stack_type = /obj/item/stack/sheet/plasteel
	stack_amount = 5
	destroyed_stack_amount = 2
	hit_sound = "sound/effects/metalhit.ogg"
	barricade_type = "plasteel"
	density = FALSE
	closed = TRUE
	can_wire = TRUE
	climbable = TRUE

	///What state is our barricade in for construction steps?
	var/build_state = BARRICADE_PLASTEEL_FIRM
	var/busy = FALSE //Standard busy check
	///ehther we react with other cades next to us ie when opening or so
	var/linked = FALSE
	COOLDOWN_DECLARE(tool_cooldown) //Delay to apply tools to prevent spamming

/obj/structure/barricade/plasteel/handle_barrier_chance(mob/living/M)
	if(closed)
		return ..()
	else
		return FALSE

/obj/structure/barricade/plasteel/examine(mob/user)
	. = ..()

	switch(build_state)
		if(BARRICADE_PLASTEEL_FIRM)
			to_chat(user, "<span class='info'>The protection panel is still tighly screwed in place.</span>")
		if(BARRICADE_PLASTEEL_ANCHORED)
			to_chat(user, "<span class='info'>The protection panel has been removed, you can see the anchor bolts.</span>")
		if(BARRICADE_PLASTEEL_LOOSE)
			to_chat(user, "<span class='info'>The protection panel has been removed and the anchor bolts loosened. It's ready to be taken apart.</span>")

/obj/structure/barricade/plasteel/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/plasteel/plasteel_sheets = I
		if(obj_integrity > max_integrity * 0.3)
			return

		if(plasteel_sheets.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two plasteel sheets to repair the base of [src].</span>")
			return

		visible_message("<span class='notice'>[user] begins to repair the base of [src].</span>")

		if(!do_after(user, 2 SECONDS, TRUE, src, BUSY_ICON_FRIENDLY) || obj_integrity >= max_integrity)
			return

		if(!plasteel_sheets.use(2))
			return

		repair_damage(max_integrity * 0.3)
		visible_message("<span class='notice'>[user] repairs the base of [src].</span>")
		return

	if(busy || !COOLDOWN_CHECK(src, tool_cooldown))
		return

	COOLDOWN_START(src, tool_cooldown, 1 SECONDS)

	if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I

		if(user.skills.getRating("engineer") < SKILL_ENGINEER_PLASTEEL)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out how to repair [src].</span>",
			"<span class='notice'>You fumble around figuring out how to repair [src].</span>")
			var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_PLASTEEL - user.skills.getRating("engineer") )
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
				return

		if(obj_integrity <= max_integrity * 0.3)
			to_chat(user, "<span class='warning'>[src] has sustained too much structural damage and needs more plasteel plates to be repaired.</span>")
			return

		if(obj_integrity == max_integrity)
			to_chat(user, "<span class='warning'>[src] doesn't need repairs.</span>")
			return

		if(!WT.remove_fuel(0, user))
			return FALSE


		user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
		"<span class='notice'>You begin repairing the damage to [src].</span>")
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)
		busy = TRUE

		if(!do_after(user, 50, TRUE, src, BUSY_ICON_FRIENDLY))
			busy = FALSE
			return

		busy = FALSE
		user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
		"<span class='notice'>You repair [src].</span>")
		repair_damage(150)
		update_icon()
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)

	if(user.do_actions) // you can only build one cade at once but repair multiple at once
		return

	switch(build_state)
		if(BARRICADE_PLASTEEL_FIRM) //Fully constructed step. Use screwdriver to remove the protection panels to reveal the bolts
			if(isscrewdriver(I))
				if(user.skills.getRating("engineer") < SKILL_ENGINEER_PLASTEEL)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out how to disassemble [src].</span>",
					"<span class='notice'>You fumble around figuring out how to disassemble [src].</span>")
					var/fumbling_time = 1 SECONDS * ( SKILL_ENGINEER_PLASTEEL - user.skills.getRating("engineer") )
					if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
						return

				for(var/obj/structure/barricade/B in loc)
					if(B != src && B.dir == dir)
						to_chat(user, "<span class='warning'>There's already a barricade here.</span>")
						return

				if(!do_after(user, 1, TRUE, src, BUSY_ICON_BUILD))
					return

				user.visible_message("<span class='notice'>[user] removes [src]'s protection panel.</span>",

				"<span class='notice'>You remove [src]'s protection panels, exposing the anchor bolts.</span>")
				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				build_state = BARRICADE_PLASTEEL_ANCHORED
			else if(iscrowbar(I))
				user.visible_message("<span class='notice'> [user] [linked ? "un" : "" ]links [src].", "<span class='notice'>You [linked ? "un" : "" ]link [src].</span>")
				linked = !linked
				for(var/direction in GLOB.cardinals)
					for(var/obj/structure/barricade/plasteel/cade in get_step(src, direction))
						cade.update_icon()
				update_icon()
		if(BARRICADE_PLASTEEL_ANCHORED) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(isscrewdriver(I))
				if(user.skills.getRating("engineer") < SKILL_ENGINEER_PLASTEEL)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out how to assemble [src].</span>",
					"<span class='notice'>You fumble around figuring out how to assemble [src].</span>")
					var/fumbling_time = 1 SECONDS * ( SKILL_ENGINEER_PLASTEEL - user.skills.getRating("engineer") )
					if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
						return
				user.visible_message("<span class='notice'>[user] set [src]'s protection panel back.</span>",
				"<span class='notice'>You set [src]'s protection panel back.</span>")
				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				build_state = BARRICADE_PLASTEEL_FIRM

			else if(iswrench(I))
				if(user.skills.getRating("engineer") < SKILL_ENGINEER_PLASTEEL)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out how to disassemble [src].</span>",
					"<span class='notice'>You fumble around figuring out how to disassemble [src].</span>")
					var/fumbling_time = 1 SECONDS * ( SKILL_ENGINEER_PLASTEEL - user.skills.getRating("engineer") )
					if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
						return
				user.visible_message("<span class='notice'>[user] loosens [src]'s anchor bolts.</span>",
				"<span class='notice'>You loosen [src]'s anchor bolts.</span>")
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				anchored = FALSE
				modify_max_integrity(initial(max_integrity) * 0.5)
				build_state = BARRICADE_PLASTEEL_LOOSE
				update_icon() //unanchored changes layer
		if(BARRICADE_PLASTEEL_LOOSE) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to rescure anchor bolts
			if(iswrench(I))

				var/turf/mystery_turf = get_turf(src)
				if(!isopenturf(mystery_turf))
					to_chat(user, "<span class='warning'>We can't anchor the barricade here!</span>")
					return

				var/turf/open/T = mystery_turf
				if(!T.allow_construction) //We shouldn't be able to anchor in areas we're not supposed to build; loophole closed.
					to_chat(user, "<span class='warning'>We can't anchor the barricade here!</span>")
					return

				if(user.skills.getRating("engineer") < SKILL_ENGINEER_PLASTEEL)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out how to assemble [src].</span>",
					"<span class='notice'>You fumble around figuring out how to assemble [src].</span>")
					var/fumbling_time = 1 SECONDS * ( SKILL_ENGINEER_PLASTEEL - user.skills.getRating("engineer") )
					if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
						return
				user.visible_message("<span class='notice'>[user] secures [src]'s anchor bolts.</span>",
				"<span class='notice'>You secure [src]'s anchor bolts.</span>")
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				anchored = TRUE
				modify_max_integrity(initial(max_integrity))
				build_state = BARRICADE_PLASTEEL_ANCHORED
				update_icon() //unanchored changes layer

			else if(iscrowbar(I))
				if(user.skills.getRating("engineer") < SKILL_ENGINEER_PLASTEEL)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out how to disassemble [src].</span>",
					"<span class='notice'>You fumble around figuring out how to disassemble [src].</span>")
					var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_PLASTEEL - user.skills.getRating("engineer") )
					if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
						return
				user.visible_message("<span class='notice'>[user] starts unseating [src]'s panels.</span>",
				"<span class='notice'>You start unseating [src]'s panels.</span>")
				playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
				busy = TRUE

				if(!do_after(user, 50, TRUE, src, BUSY_ICON_BUILD))
					busy = FALSE
					return

				busy = FALSE
				user.visible_message("<span class='notice'>[user] takes [src]'s panels apart.</span>",
				"<span class='notice'>You take [src]'s panels apart.</span>")
				playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
				var/deconstructed = TRUE
				for(var/obj/effect/xenomorph/acid/A in loc)
					if(A.acid_t != src)
						continue
					deconstructed = FALSE
					break
				deconstruct(deconstructed)


/obj/structure/barricade/plasteel/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	toggle_open(null, user)

/obj/structure/barricade/plasteel/proc/toggle_open(state, mob/living/user)
	if(state == closed)
		return
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	closed = !closed
	density = !density

	user?.visible_message("<span class='notice'>[user] flips [src] [closed ? "closed" :"open"].</span>",
		"<span class='notice'>You flip [src] [closed ? "closed" :"open"].</span>")

	if(!linked)
		update_icon()
		return
	for(var/direction in GLOB.cardinals)
		for(var/obj/structure/barricade/plasteel/cade in get_step(src, direction))
			if(((dir & (NORTH|SOUTH) && get_dir(src, cade) & (EAST|WEST)) || (dir & (EAST|WEST) && get_dir(src, cade) & (NORTH|SOUTH))) && dir == cade.dir && cade.linked)
				cade.toggle_open(closed)

	update_icon()

/obj/structure/barricade/plasteel/update_overlays()
	. = ..()
	if(!linked)
		return
	for(var/direction in GLOB.cardinals)
		for(var/obj/structure/barricade/plasteel/cade in get_step(src, direction))
			if(((dir & (NORTH|SOUTH) && get_dir(src, cade) & (EAST|WEST)) || (dir & (EAST|WEST) && get_dir(src, cade) & (NORTH|SOUTH))) && dir == cade.dir && cade.linked && cade.closed == closed)
				. += image('icons/Marine/barricades.dmi', icon_state = "[barricade_type]_[closed ? "closed" : "open"]_connection_[get_dir(src, cade)]")

/obj/structure/barricade/plasteel/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(rand(450, 650))
		if(EXPLODE_HEAVY)
			take_damage(rand(200, 400))
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 150))

	update_icon()

#undef BARRICADE_PLASTEEL_LOOSE
#undef BARRICADE_PLASTEEL_ANCHORED
#undef BARRICADE_PLASTEEL_FIRM

/*----------------------*/
// SANDBAGS
/*----------------------*/

/obj/structure/barricade/sandbags
	name = "sandbag barricade"
	desc = "A bunch of bags filled with sand, stacked into a small wall. Surprisingly sturdy, albeit labour intensive to set up. Trusted to do the job since 1914."
	icon_state = "sandbag_0"
	max_integrity = 300
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 80, "acid" = 40)
	coverage = 128
	stack_type = /obj/item/stack/sandbags
	hit_sound = "sound/weapons/genhit.ogg"
	barricade_type = "sandbag"
	can_wire = TRUE

/obj/structure/barricade/sandbags/update_icon()
	. = ..()
	if(dir == SOUTH)
		pixel_y = -7
	else if(dir == NORTH)
		pixel_y = 7
	else
		pixel_y = 0


/obj/structure/barricade/sandbags/attackby(obj/item/I, mob/user, params)
	. = ..()

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	if(istype(I, /obj/item/tool/shovel) && user.a_intent != INTENT_HARM)
		var/obj/item/tool/shovel/ET = I
		if(!ET.folded)
			user.visible_message("<span class='notice'>[user] starts disassembling [src].</span>",
			"<span class='notice'>You start disassembling [src].</span>")
			if(do_after(user, ET.shovelspeed, TRUE, src, BUSY_ICON_BUILD))
				user.visible_message("<span class='notice'>[user] disassembles [src].</span>",
				"<span class='notice'>You disassemble [src].</span>")
				var/deconstructed = TRUE
				for(var/obj/effect/xenomorph/acid/A in loc)
					if(A.acid_t != src)
						continue
					deconstructed = FALSE
					break
				deconstruct(deconstructed)
		return TRUE

	if(istype(I, /obj/item/stack/sandbags) )
		if(obj_integrity == max_integrity)
			to_chat(user, "<span class='warning'>[src] isn't in need of repairs!</span>")
			return
		var/obj/item/stack/sandbags/D = I
		if(D.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need a sandbag to repair [src].</span>")
			return
		visible_message("<span class='notice'>[user] begins to replace [src]'s damaged sandbags...</span>")

		if(!do_after(user, 30, TRUE, src, BUSY_ICON_BUILD) || obj_integrity >= max_integrity)
			return

		if(!D.use(1))
			return

		repair_damage(max_integrity * 0.2) //Each sandbag restores 20% of max health as 5 sandbags = 1 sandbag barricade.
		user.visible_message("<span class='notice'>[user] replaces a damaged sandbag, repairing [src].</span>",
		"<span class='notice'>You replace a damaged sandbag, repairing it [src].</span>")
		update_icon()
