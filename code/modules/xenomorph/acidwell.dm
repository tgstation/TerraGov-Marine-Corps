
//Resin Water Well
/obj/structure/xeno/acidwell
	name = "acid well"
	desc = "An acid well. It stores acid to put out fires."
	icon = 'icons/Xeno/acid_well.dmi'
	icon_state = "well"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 5
	plane = FLOOR_PLANE
	layer = ABOVE_WEEDS_LAYER

	hit_sound = SFX_ALIEN_RESIN_MOVE
	destroy_sound = SFX_ALIEN_RESIN_MOVE
	///How many charges of acid this well contains
	var/charges = 1
	///If a xeno is charging this well
	var/charging = FALSE
	///What xeno created this well
	var/mob/living/carbon/xenomorph/creator = null

/obj/structure/xeno/acidwell/Initialize(mapload, _creator)
	. = ..()
	creator = _creator
	RegisterSignal(creator, COMSIG_QDELETING, PROC_REF(clear_creator))
	update_icon()
	var/static/list/listen_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
		COMSIG_TURF_PRE_SHUTTLE_CRUSH = PROC_REF(pre_shuttle_crush)
	)
	AddElement(/datum/element/connect_loc, listen_connections)

/obj/structure/xeno/acidwell/Destroy()
	creator = null
	return ..()

///Signal handler for creator destruction to clear reference
/obj/structure/xeno/acidwell/proc/clear_creator()
	SIGNAL_HANDLER
	creator = null

/// Deletes this first before it can get crushed by a shuttle.
/obj/structure/xeno/acidwell/proc/pre_shuttle_crush(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/obj/structure/xeno/acidwell/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	if(!QDELETED(creator) && creator.stat == CONSCIOUS && creator.z == z)
		var/area/A = get_area(src)
		if(A)
			to_chat(creator, span_xenoannounce("You sense your acid well at [A.name] has been destroyed!") )

	if(damage_amount || damage_flag) //Spawn the gas only if we actually get destroyed by damage
		var/datum/effect_system/smoke_spread/xeno/acid/opaque/A = new(get_turf(src))
		A.set_up(clamp(CEILING(charges*0.5, 1),0,3),src) //smoke scales with charges
		A.start()
	return ..()

/obj/structure/xeno/acidwell/examine(mob/user)
	. = ..()
	if(!isxeno(user) && !isobserver(user))
		return
	. += span_xenonotice("An acid well made by [creator]. It currently has <b>[charges]/[XENO_ACID_WELL_MAX_CHARGES] charges</b>.")

/obj/structure/xeno/acidwell/deconstruct(disassembled = TRUE, mob/living/blame_mob)
	visible_message(span_danger("[src] suddenly collapses!") )
	return ..()

/obj/structure/xeno/acidwell/update_icon()
	. = ..()
	set_light(charges , charges / 2, LIGHT_COLOR_GREEN)

/obj/structure/xeno/acidwell/update_overlays()
	. = ..()
	if(!charges)
		return
	. += mutable_appearance(icon, "[charges]", alpha = src.alpha)
	. += emissive_appearance(icon, "[charges]", src, alpha = src.alpha)

/obj/structure/xeno/acidwell/fire_act(burn_level)
	acid_well_fire_interaction()

///Handles fire based interactions with the acid well. Depletes 1 charge if there are any to extinguish all fires in the turf while producing acid smoke.
/obj/structure/xeno/acidwell/proc/acid_well_fire_interaction()
	if(!charges)
		take_damage(50, BURN, FIRE)
		return

	charges--
	update_icon()
	var/turf/T = get_turf(src)
	var/datum/effect_system/smoke_spread/xeno/acid/opaque/acid_smoke = new(T) //spawn acid smoke when charges are actually used
	acid_smoke.set_up(0, src) //acid smoke in the immediate vicinity
	acid_smoke.start()

	for(var/obj/fire/flamer/F in T) //Extinguish all flames in turf
		qdel(F)

/obj/structure/xeno/acidwell/attackby(obj/item/I, mob/user, params)
	if(!isxeno(user))
		return ..()
	attack_alien(user)

/obj/structure/xeno/acidwell/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.a_intent == INTENT_HARM && (CHECK_BITFIELD(xeno_attacker.xeno_caste.caste_flags, CASTE_IS_BUILDER) || xeno_attacker == creator) ) //If we're a builder caste or the creator and we're on harm intent, deconstruct it.
		balloon_alert(xeno_attacker, "Removing...")
		if(!do_after(xeno_attacker, XENO_ACID_WELL_FILL_TIME, IGNORE_HELD_ITEM, src, BUSY_ICON_HOSTILE))
			balloon_alert(xeno_attacker, "Stopped removing")
			return
		playsound(src, SFX_ALIEN_RESIN_BREAK, 25)
		deconstruct(TRUE, xeno_attacker)
		return

	if(charges >= 5)
		balloon_alert(xeno_attacker, "Already full")
		return
	if(charging)
		balloon_alert(xeno_attacker, "Already being filled")
		return

	if(xeno_attacker.plasma_stored < XENO_ACID_WELL_FILL_COST) //You need to have enough plasma to attempt to fill the well
		balloon_alert(xeno_attacker, "Need [XENO_ACID_WELL_FILL_COST - xeno_attacker.plasma_stored] more plasma")
		return

	charging = TRUE

	balloon_alert(xeno_attacker, "Refilling...")
	if(!do_after(xeno_attacker, XENO_ACID_WELL_FILL_TIME, IGNORE_HELD_ITEM, src, BUSY_ICON_BUILD))
		charging = FALSE
		balloon_alert(xeno_attacker, "Aborted refilling")
		return

	if(xeno_attacker.plasma_stored < XENO_ACID_WELL_FILL_COST)
		charging = FALSE
		balloon_alert(xeno_attacker, "Need [XENO_ACID_WELL_FILL_COST - xeno_attacker.plasma_stored] more plasma")
		return

	xeno_attacker.plasma_stored -= XENO_ACID_WELL_FILL_COST
	charges++
	charging = FALSE
	update_icon()
	balloon_alert(xeno_attacker, "Now has [charges] / [XENO_ACID_WELL_MAX_CHARGES] charges")
	to_chat(xeno_attacker,span_xenonotice("We add acid to [src]. It is currently has <b>[charges] / [XENO_ACID_WELL_MAX_CHARGES] charges</b>.") )

/obj/structure/xeno/acidwell/proc/on_cross(datum/source, atom/movable/A, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(CHECK_MULTIPLE_BITFIELDS(A.allow_pass_flags, HOVERING))
		return
	if(iscarbon(A))
		HasProximity(A)

/obj/structure/xeno/acidwell/HasProximity(atom/movable/AM)
	if(!charges)
		return
	if(!isliving(AM))
		return
	var/mob/living/stepper = AM
	if(stepper.stat == DEAD)
		return

	var/charges_used = 0

	for(var/obj/item/explosive/grenade/sticky/sticky_bomb in stepper.contents)
		if(charges_used >= charges)
			break
		if(sticky_bomb.active)
			sticky_bomb.unstick_from(src)
			sticky_bomb.forceMove(loc)
			charges_used++

	if(stepper.on_fire && (charges_used < charges))
		stepper.ExtinguishMob()
		charges_used++

	if(!isxeno(stepper))
		stepper.next_move_slowdown += charges * 2 //Acid spray has slow down so this should too; scales with charges, Min 2 slowdown, Max 10
		stepper.apply_damage(charges * 10, BURN, BODY_ZONE_PRECISE_L_FOOT, ACID, penetration = 33)
		stepper.apply_damage(charges * 10, BURN, BODY_ZONE_PRECISE_R_FOOT, ACID, penetration = 33)
		stepper.visible_message(span_danger("[stepper] is immersed in [src]'s acid!") , \
		span_danger("We are immersed in [src]'s acid!") , null, 5)
		playsound(stepper, "sound/bullets/acid_impact1.ogg", 10 * charges)
		new /obj/effect/temp_visual/acid_bath(get_turf(stepper))
		charges_used = charges //humans stepping on it empties it out

	if(!charges_used)
		return

	var/datum/effect_system/smoke_spread/xeno/acid/opaque/acid_smoke = new(get_turf(stepper)) //spawn acid smoke when charges are actually used
	acid_smoke.set_up(0, src) //acid smoke in the immediate vicinity
	acid_smoke.start()

	charges -= charges_used
	update_icon()
