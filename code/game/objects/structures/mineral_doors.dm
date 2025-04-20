//NOT using the existing /obj/machinery/door type, since that has some complications on its own, mainly based on its
//machineryness

/obj/structure/mineral_door
	name = "mineral door"
	density = TRUE
	opacity = TRUE
	allow_pass_flags = NONE
	icon = 'icons/obj/doors/mineral_doors.dmi'
	icon_state = "metal"

	///Are we open or not
	var/open = FALSE
	///Are we currently opening/closing
	var/switching_states = FALSE
	///The sound that gets played when opening/closing this door
	var/trigger_sound = 'sound/effects/stonedoor_openclose.ogg'
	///The type of material we're made from and what we drop when destroyed
	var/material_type

/obj/structure/mineral_door/Initialize(mapload)
	if((locate(/mob/living) in loc) && !open)	//If we build a door below ourselves, it starts open.
		toggle_state()
	/*
	We are calling parent later because if we toggle state, the opacity changes only to change to
	non opaque after the parent procs do their thing, this is an issue because this changes the
	directional opacity of the turf below to be opaque from all sides, which screws with
	line of sight because the turf below the door is considered opaque, when it shouldn't be.
	*/
	return ..()

/obj/structure/mineral_door/Bumped(atom/user)
	. = ..()
	if(!open)
		return try_toggle_state(user)

/obj/structure/mineral_door/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	return try_toggle_state(user)

/obj/structure/mineral_door/CanAllowThrough(atom/movable/mover, turf/target)
	if(istype(mover, /obj/effect/beam))
		return !opacity

	return ..()

/*
 * Checks all the requirements for opening/closing a door before opening/closing it
 *
 * atom/user - the mob trying to open/close this door
*/
/obj/structure/mineral_door/proc/try_toggle_state(atom/user)
	if(switching_states || !ismob(user) || locate(/mob/living) in get_turf(src))
		return
	var/mob/M = user
	if(!M.client)
		return
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.handcuffed)
			return
	toggle_state()


///The proc that actually does the door closing. Plays the sound, the animation, etc.
/obj/structure/mineral_door/proc/toggle_state()
	switching_states = TRUE
	open = !open
	playsound(get_turf(src), trigger_sound, 25, 1)
	flick("[base_icon_state][smoothing_flags ? "-[smoothing_junction]" : ""]-[open ? "opening" : "closing"]", src)
	density = !density
	opacity = !opacity
	update_icon()
	addtimer(VARSET_CALLBACK(src, switching_states, FALSE), 1 SECONDS)

/obj/structure/mineral_door/update_icon_state()
	. = ..()
	if(open)
		icon_state = "[base_icon_state][smoothing_flags ? "-[smoothing_junction]" : ""]-open"
	else
		icon_state = "[base_icon_state][smoothing_flags ? "-[smoothing_junction]" : ""]"


/obj/structure/mineral_door/attackby(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(.)
		return
	if(QDELETED(src))
		return

	if(user.a_intent == INTENT_HARM)
		return

	if(!(obj_flags & CAN_BE_HIT))
		return

	return attacking_item.attack_obj(src, user)

/obj/structure/mineral_door/attacked_by(obj/item/attacking_item, mob/living/user, def_zone)
	. = ..()
	if(attacking_item.damtype != BURN)
		return
	var/damage_multiplier = get_burn_damage_multiplier(attacking_item, user, def_zone)

	take_damage(max(0, attacking_item.force * damage_multiplier), attacking_item.damtype, MELEE)

/obj/structure/mineral_door/Destroy()
	if(material_type)
		for(var/i in 1 to rand(1,5))
			new material_type(get_turf(src))
	return ..()

///Takes extra damage if our attacking item does burn damage
/obj/structure/mineral_door/proc/get_burn_damage_multiplier(obj/item/attacking_item, mob/living/user, def_zone, bonus_damage = 0)
	if(!isplasmacutter(attacking_item))
		return bonus_damage

	var/obj/item/tool/pickaxe/plasmacutter/attacking_pc = attacking_item
	if(attacking_pc.start_cut(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD, no_string = TRUE))
		bonus_damage += PLASMACUTTER_RESIN_MULTIPLIER * 0.5
		attacking_pc.cut_apart(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD) //Minimal energy cost.

	return bonus_damage

/obj/structure/mineral_door/resin/get_burn_damage_multiplier(obj/item/attacking_item, mob/living/user, def_zone, bonus_damage = 1)
	if(!isplasmacutter(attacking_item))
		return bonus_damage

	var/obj/item/tool/pickaxe/plasmacutter/attacking_pc = attacking_item
	if(attacking_pc.start_cut(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD, no_string = TRUE))
		bonus_damage += PLASMACUTTER_RESIN_MULTIPLIER
		attacking_pc.cut_apart(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD) //Minimal energy cost.

	return bonus_damage

/obj/structure/mineral_door/resin/plasmacutter_act(mob/living/user, obj/item/I)
	if(!isplasmacutter(I) || user.do_actions)
		return FALSE
	if(!(obj_flags & CAN_BE_HIT) || CHECK_BITFIELD(resistance_flags, PLASMACUTTER_IMMUNE) || CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return FALSE
	var/obj/item/tool/pickaxe/plasmacutter/plasmacutter = I
	if(!plasmacutter.powered || (plasmacutter.item_flags & NOBLUDGEON))
		return FALSE
	var/charge_cost = PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD
	if(!plasmacutter.start_cut(user, name, src, charge_cost, no_string = TRUE))
		return FALSE

	user.changeNext_move(plasmacutter.attack_speed)
	user.do_attack_animation(src, used_item = plasmacutter)
	plasmacutter.cut_apart(user, name, src, charge_cost)
	take_damage(max(0, plasmacutter.force * (1 + PLASMACUTTER_RESIN_MULTIPLIER)), plasmacutter.damtype, MELEE)
	playsound(src, SFX_ALIEN_RESIN_BREAK, 25)
	return TRUE

/obj/structure/mineral_door/iron
	name = "iron door"
	material_type = /obj/item/stack/sheet/metal
	base_icon_state = "metal"
	max_integrity = 500

/obj/structure/mineral_door/silver
	name = "silver door"
	material_type = /obj/item/stack/sheet/mineral/silver
	base_icon_state = "silver"
	icon_state = "silver"
	max_integrity = 500

/obj/structure/mineral_door/gold
	name = "gold door"
	material_type = /obj/item/stack/sheet/mineral/gold
	base_icon_state = "gold"
	icon_state = "gold"
	max_integrity = 250

/obj/structure/mineral_door/uranium
	name = "uranium door"
	material_type = /obj/item/stack/sheet/mineral/uranium
	base_icon_state = "uranium"
	icon_state = "uranium"
	max_integrity = 500

/obj/structure/mineral_door/sandstone
	name = "sandstone door"
	material_type = /obj/item/stack/sheet/mineral/sandstone
	base_icon_state = "sandstone"
	icon_state = "sandstone"
	max_integrity = 100

/obj/structure/mineral_door/transparent
	name = "generic transparent door"
	desc = "You shouldn't be seeing this."
	opacity = FALSE

/obj/structure/mineral_door/transparent/toggle_state()
	..()
	opacity = FALSE

/obj/structure/mineral_door/transparent/phoron
	name = "phoron door"
	material_type = /obj/item/stack/sheet/mineral/phoron
	base_icon_state = "phoron"
	icon_state = "phoron"
	max_integrity = 250

/obj/structure/mineral_door/transparent/phoron/attackby(obj/item/attacking_item as obj, mob/user as mob)
	if(istype(attacking_item, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/WT = attacking_item
		if(WT.remove_fuel(0, user))
			var/turf/T = get_turf(src)
			T.ignite(25, 25)
			visible_message(span_danger("[src] suddenly combusts!"))
	return ..()


/obj/structure/mineral_door/transparent/phoron/fire_act(burn_level)
	if(burn_level > 30)
		var/turf/T = get_turf(src)
		T.ignite(25, 25)


/obj/structure/mineral_door/transparent/diamond
	name = "diamond door"
	material_type = /obj/item/stack/sheet/mineral/diamond
	base_icon_state = "diamond"
	icon_state = "diamond"
	max_integrity = 1000


/obj/structure/mineral_door/wood
	name = "wooden door"
	material_type = /obj/item/stack/sheet/wood
	base_icon_state = "wood"
	icon_state = "wood"
	trigger_sound = 'sound/effects/doorcreaky.ogg'
	max_integrity = 100

/obj/structure/mineral_door/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -40, 5)
