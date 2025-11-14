
/*
* effect/alien
*/
/obj/alien
	name = "alien thing"
	desc = "theres something alien about this"
	icon = 'icons/Xeno/Effects.dmi'
	hit_sound = SFX_ALIEN_RESIN_BREAK
	anchored = TRUE
	max_integrity = 1
	resistance_flags = UNACIDABLE
	obj_flags = CAN_BE_HIT
	var/on_fire = FALSE
	///Set this to true if this object isn't destroyed when the weeds under it is.
	var/ignore_weed_destruction = FALSE

/obj/alien/Initialize(mapload)
	. = ..()
	if(!ignore_weed_destruction)
		RegisterSignal(loc, COMSIG_TURF_WEED_REMOVED, PROC_REF(weed_removed))

/// Destroy the alien effect when the weed it was on is destroyed
/obj/alien/proc/weed_removed()
	SIGNAL_HANDLER
	obj_destruction(damage_flag = "melee")

/obj/alien/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(user.a_intent == INTENT_HARM) //Already handled at the parent level.
		return

	if(obj_flags & CAN_BE_HIT)
		return I.attack_obj(src, user)

/obj/alien/fire_act(burn_level)
	take_damage(burn_level * 2, BURN, FIRE)

/obj/alien/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(500, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage((rand(140, 300)), BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage((rand(50, 100)), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(rand(25, 50), BRUTE, BOMB)

/obj/alien/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_BLISTERING))
		take_damage(rand(2, 20) * 0.1, BURN, ACID)

/*
* Resin
*/
/obj/alien/resin
	name = "resin"
	desc = "Looks like some kind of slimy growth."
	icon_state = "Resin1"
	max_integrity = 200
	resistance_flags = XENO_DAMAGEABLE|UNACIDABLE


/obj/alien/resin/attack_hand(mob/living/user)
	balloon_alert(user, "need a weapon!")
	return TRUE


/obj/alien/resin/sticky
	name = STICKY_RESIN
	desc = "A layer of disgusting sticky slime."
	icon_state = "sticky"
	density = FALSE
	opacity = FALSE
	max_integrity = 36
	plane = FLOOR_PLANE
	layer = ABOVE_WEEDS_LAYER
	hit_sound = SFX_ALIEN_RESIN_MOVE
	var/slow_amt = 8
	/// Does this refund build points when destoryed?
	var/refundable = TRUE

	ignore_weed_destruction = TRUE

/obj/alien/resin/sticky/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(slow_down_crosser)
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/alien/resin/sticky/proc/slow_down_crosser(datum/source, atom/movable/crosser)
	SIGNAL_HANDLER
	if(crosser.throwing || crosser.buckled)
		return

	if(issealedvehicle(crosser))
		var/obj/vehicle/sealed/vehicle = crosser
		COOLDOWN_INCREMENT(vehicle, cooldown_vehicle_move, WEED_SLOWDOWN)
		return

	if(!ishuman(crosser))
		return

	if(HAS_TRAIT(crosser, TRAIT_TANK_DESANT))
		return

	if(CHECK_MULTIPLE_BITFIELDS(crosser.allow_pass_flags, HOVERING))
		return

	var/mob/living/carbon/human/victim = crosser

	if(victim.lying_angle)
		return

	victim.next_move_slowdown += slow_amt

/obj/alien/resin/sticky/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return FALSE

	if(xeno_attacker.a_intent == INTENT_HARM) //Clear it out on hit; no need to double tap.
		if(CHECK_BITFIELD(SSticker.mode?.round_type_flags, MODE_ALLOW_XENO_QUICKBUILD) && SSresinshaping.active && refundable)
			SSresinshaping.quickbuild_points_by_hive[xeno_attacker.hivenumber]++
		xeno_attacker.do_attack_animation(src, ATTACK_EFFECT_CLAW) //SFX
		playsound(src, SFX_ALIEN_RESIN_BREAK, 25) //SFX
		deconstruct(TRUE)
		return

	return ..()

/obj/alien/resin/sticky/can_z_move(direction, turf/start, turf/destination, z_move_flags, mob/living/rider)
	z_move_flags |= ZMOVE_ALLOW_ANCHORED
	return ..()

/obj/alien/resin/sticky/onZImpact(turf/impacted_turf, levels, impact_flags = NONE)
	impact_flags |= ZIMPACT_NO_SPIN
	return ..()

// Hivelord Sticky Resin spit uses this.
/obj/alien/resin/sticky/thin
	name = "thin sticky resin"
	desc = "A thin layer of disgusting sticky slime."
	max_integrity = 6
	slow_amt = 4

	ignore_weed_destruction = FALSE
	refundable = FALSE

//Resin Doors
/obj/structure/mineral_door/resin
	name = RESIN_DOOR
	icon = 'icons/obj/smooth_objects/resin-door.dmi'
	icon_state = "resin-door-1"
	base_icon_state = "resin-door"
	resistance_flags = NONE
	layer = BELOW_OBJ_LAYER
	max_integrity = 100
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_XENO_STRUCTURES)
	canSmoothWith = list(
		SMOOTH_GROUP_XENO_STRUCTURES,
		SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS,
		SMOOTH_GROUP_MINERAL_STRUCTURES,
	)
	soft_armor = list(MELEE = 33, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 15, BIO = 0, FIRE = 0, ACID = 0)
	trigger_sound = SFX_ALIEN_RESIN_MOVE
	hit_sound = SFX_ALIEN_RESIN_MOVE
	destroy_sound = SFX_ALIEN_RESIN_MOVE

	///The delay before the door closes automatically after being open
	var/close_delay = 10 SECONDS
	///The timer that tracks the delay above
	var/closetimer

/obj/structure/mineral_door/resin/smooth_icon()
	. = ..()
	update_icon()

/obj/structure/mineral_door/resin/Initialize(mapload)
	. = ..()
	if(!locate(/obj/alien/weeds) in loc)
		new /obj/alien/weeds(loc)


/obj/structure/mineral_door/resin/Cross(atom/movable/mover, turf/target)
	. = ..()
	if(!. && isxeno(mover) && !open)
		toggle_state()
		return TRUE

/obj/structure/mineral_door/resin/attack_larva(mob/living/carbon/xenomorph/larva/M)
	var/turf/cur_loc = M.loc
	if(!istype(cur_loc))
		return FALSE
	try_toggle_state(M)
	return TRUE

//clicking on resin doors attacks them, or opens them without harm intent
/obj/structure/mineral_door/resin/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	var/turf/cur_loc = xeno_attacker.loc
	if(!istype(cur_loc))
		return FALSE //Some basic logic here
	if(xeno_attacker.a_intent != INTENT_HARM)
		try_toggle_state(xeno_attacker)
		return TRUE
	if(CHECK_BITFIELD(SSticker.mode?.round_type_flags, MODE_ALLOW_XENO_QUICKBUILD) && SSresinshaping.active)
		SSresinshaping.quickbuild_points_by_hive[xeno_attacker.hivenumber]++
		qdel(src)
		return TRUE

	src.balloon_alert(xeno_attacker, "destroying...")
	playsound(src, SFX_ALIEN_RESIN_BREAK, 25)
	if(do_after(xeno_attacker, 1 SECONDS, IGNORE_HELD_ITEM, src, BUSY_ICON_HOSTILE))
		src.balloon_alert(xeno_attacker, "destroyed")
		qdel(src)

/obj/structure/mineral_door/resin/take_damage(damage_amount, damage_type, armor_type, effects, attack_dir, armour_penetration, mob/living/blame_mob)
	if(damage_type != BRUTE && damage_type != BURN)
		return
	return ..()

/obj/structure/mineral_door/resin/fire_act(burn_level)
	take_damage(burn_level * 2, BURN, FIRE)

/obj/structure/mineral_door/resin/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel()
		if(EXPLODE_HEAVY)
			qdel()
		if(EXPLODE_LIGHT)
			take_damage((rand(50, 60)), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(30, BRUTE, BOMB)

/obj/structure/mineral_door/resin/try_toggle_state(atom/user)
	if(isxeno(user))
		return ..()

/obj/structure/mineral_door/resin/toggle_state()
	. = ..()
	if(open)
		closetimer = addtimer(CALLBACK(src, PROC_REF(do_close)), close_delay, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)
	else
		deltimer(closetimer)
		closetimer = null

/// Toggle(close) the door. Used for the timer's callback.
/obj/structure/mineral_door/resin/proc/do_close()
	if(locate(/mob/living) in loc) //there is a mob in the door, abort and reschedule the close
		closetimer = addtimer(CALLBACK(src, PROC_REF(do_close)), close_delay, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)
		return
	if(!open) //we got closed in the meantime
		return
	flick("[icon_state]-closing", src)
	toggle_state()

/obj/structure/mineral_door/resin/Destroy()
	var/turf/T
	for(var/i in GLOB.cardinals)
		T = get_step(loc, i)
		if(!istype(T))
			continue
		for(var/obj/structure/mineral_door/resin/R in T)
			INVOKE_NEXT_TICK(R, PROC_REF(check_resin_support))
	return ..()


//do we still have something next to us to support us?
/obj/structure/mineral_door/resin/proc/check_resin_support()
	var/turf/T
	for(var/i in GLOB.cardinals)
		T = get_step(src, i)
		if(T.density)
			. = TRUE
			break
		if(locate(/obj/structure/mineral_door/resin) in T)
			. = TRUE
			break
	if(!.)
		src.balloon_alert_to_viewers("collapsed")
		qdel(src)

/obj/structure/mineral_door/resin/thick
	max_integrity = 160

/obj/item/resin_jelly
	name = "resin jelly"
	desc = "A foul, viscous resin jelly that doesnt seem to burn easily."
	icon = 'icons/Xeno/xeno_materials.dmi'
	icon_state = "resin_jelly"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 200, ACID = 0)
	/// The amount of deciseconds to give the Resin Coating status effect.
	var/immune_time = 30 SECONDS
	/// Holder to ensure only one user per resin jelly.
	var/current_user
	/// If thrown, should it create a 3x3 when it lands? If so, how long in deciseconds if it impacts a human?
	var/combustive_duration = 0 SECONDS

/obj/item/resin_jelly/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return FALSE
	return attack_hand(xeno_attacker)

/obj/item/resin_jelly/attack_self(mob/living/carbon/xenomorph/user)
	//Activates if the item itself is clicked in hand.
	if(!isxeno(user))
		return
	if(user.do_actions || !isnull(current_user))
		return
	current_user = user
	user.balloon_alert(user, "applying...")
	if(!do_after(user, RESIN_SELF_TIME, NONE, user, BUSY_ICON_MEDICAL))
		current_user = null
		return
	activate_jelly(user)

/obj/item/resin_jelly/attack(mob/living/carbon/xenomorph/M, mob/living/user)
	//Activates if active hand and clicked on mob in game.
	//Can target self so we need to check for that.
	if(!isxeno(user))
		return TRUE
	if(!isxeno(M))
		M.balloon_alert(user, "that's not a xeno!")
		return FALSE
	if(user.do_actions || !isnull(current_user))
		return FALSE
	current_user = M
	M.balloon_alert(user, "applying...")
	if(M != user)
		user.balloon_alert(M, "applying jelly...") //Notify recipient to not move.
	if(!do_after(user, (M == user ? RESIN_SELF_TIME : RESIN_OTHER_TIME), NONE, M, BUSY_ICON_MEDICAL))
		current_user = null
		return FALSE
	activate_jelly(M)
	user.temporarilyRemoveItemFromInventory(src)
	return FALSE

/obj/item/resin_jelly/proc/activate_jelly(mob/living/carbon/xenomorph/user)
	user.visible_message(span_notice("[user]'s chitin begins to gleam with an unseemly glow..."), span_xenonotice("We feel powerful as we are covered in [src]!"))
	user.emote("roar")
	user.apply_status_effect(STATUS_EFFECT_RESIN_JELLY_COATING)
	SEND_SIGNAL(user, COMSIG_XENOMORPH_RESIN_JELLY_APPLIED)
	qdel(src)

/obj/item/resin_jelly/throw_at(atom/target, range, speed, thrower, spin, flying = FALSE, targetted_throw = TRUE)
	if(isxenohivelord(thrower))
		RegisterSignal(src, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
		RegisterSignal(src, COMSIG_MOVABLE_POST_THROW, PROC_REF(on_throw_ended))
	. = ..()

/// Applies the jelly effect for xenomorphs. Otherwise, may explode into sticky resin against everyone else.
/obj/item/resin_jelly/proc/on_throw_impact(datum/source, atom/hit_atom, speed)
	SIGNAL_HANDLER
	if(!isliving(hit_atom))
		return
	UnregisterSignal(source, list(COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_POST_THROW))
	var/mob/living/hit_living = hit_atom
	if(combustive_duration)
		for(var/turf/sticky_tile AS in RANGE_TURFS(1, get_turf(hit_living)))
			if(!locate(/obj/alien/resin/sticky/thin) in sticky_tile.contents)
				var/obj/alien/resin/sticky/thin/temporary_resin = new(sticky_tile)
				QDEL_IN(temporary_resin, 15 SECONDS)
		if(!hit_living.issamexenohive(thrower))
			hit_living.adjust_stagger(combustive_duration)
		playsound(loc, SFX_ALIEN_RESIN_BUILD, 50, 1)
		qdel(src)
		return
	if(!isxeno(hit_atom))
		return
	var/mob/living/carbon/xenomorph/hit_xenomorph = hit_atom
	if(hit_xenomorph.xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
		return
	hit_xenomorph.visible_message(span_notice("[hit_xenomorph] is splattered with jelly!"))
	INVOKE_ASYNC(src, PROC_REF(activate_jelly), hit_xenomorph)

/// Possibly explode into sticky resin upon finishing the throw.
/obj/item/resin_jelly/proc/on_throw_ended(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_POST_THROW))
	if(!combustive_duration)
		return
	for(var/turf/sticky_tile AS in RANGE_TURFS(1, loc))
		if(!locate(/obj/alien/resin/sticky/thin) in sticky_tile.contents)
			var/obj/alien/resin/sticky/thin/temporary_resin = new(sticky_tile)
			QDEL_IN(temporary_resin, 15 SECONDS)
	playsound(loc, SFX_ALIEN_RESIN_BUILD, 50, 1)
	qdel(src)

///////////////////////
/// Globadier Mines ///
///////////////////////

/obj/structure/xeno/acid_mine
	name = "acid mine"
	desc = "A weird bulb, filled with acid."
	icon = 'icons/obj/items/mines.dmi'
	icon_state = "acid_mine"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 5
	hit_sound = SFX_ALIEN_RESIN_BREAK
	///The amount of acid damage this deals
	var/acid_damage = 30

/obj/structure/xeno/acid_mine/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(oncrossed),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/xeno/acid_mine/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	detonate(blame_mob)
	return ..()

// Checks if the mob walking over the mine is human, and calls detonate if so
/obj/structure/xeno/acid_mine/proc/oncrossed(datum/source, atom/movable/A, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!ishuman(A))
		return
	if(CHECK_MULTIPLE_BITFIELDS(A.allow_pass_flags, HOVERING))
		return
	INVOKE_ASYNC(src, PROC_REF(detonate), A)

/obj/structure/xeno/acid_mine/proc/detonate(triggerer)
	for(var/spatter_effect in filled_turfs(get_turf(src), 1, "square", pass_flags_checked = PASS_AIR))
		new /obj/effect/temp_visual/acid_splatter(spatter_effect)
	for(var/mob/living/carbon/human/human_victim AS in cheap_get_humans_near(src,1))
		human_victim.apply_damage(acid_damage/2, BURN, BODY_ZONE_L_LEG, ACID,  penetration = 30)
		human_victim.apply_damage(acid_damage/2, BURN, BODY_ZONE_R_LEG, ACID,  penetration = 30)
		playsound(src, "sound/bullets/acid_impact1.ogg", 10)
	qdel(src)

////////////////
/// Gas Mine ///
////////////////

/obj/structure/xeno/acid_mine/gas_mine
	name = "gas mine"
	desc = "A weird bulb, overflowing with acid. Small wisps of gas escape every so often."
	icon_state = "gas_mine"
	acid_damage = 40

/obj/structure/xeno/acid_mine/gas_mine/detonate(triggerer)
	var/datum/effect_system/smoke_spread/xeno/acid/opaque/smog = new(get_turf(src))
	smog.set_up(1,src)
	smog.start()
	return ..()

//////////////////
/// Incen Mine ///
//////////////////

/obj/structure/xeno/acid_mine/incen_mine
	name = "incendiary mine"
	desc = "A purple blob that sparks like lightning."
	icon_state = "incen_mine"

/obj/structure/xeno/acid_mine/incen_mine/detonate(triggerer)
	flame_radius(1, get_turf(src), fire_type = /obj/fire/melting_fire/shattering, burn_intensity = 20, burn_duration = 180, colour = "violet")
	qdel(src)

//////////////////
/// Resin Mine ///
//////////////////

/obj/structure/xeno/acid_mine/resin_mine
	name = "resin mine"
	desc = "A translucent purple blob, insides lined with clear ampoules of resin."
	icon_state = "resin_mine"

/obj/structure/xeno/acid_mine/resin_mine/detonate(triggerer)
	var/cannotbuild = FALSE
	for(var/turf/resin_tile in filled_turfs(get_turf(src), 0.5, "circle", pass_flags_checked = PASS_AIR))
		cannotbuild = FALSE
		if((resin_tile.density || istype(resin_tile, /turf/open/space))) // No structures in space
			continue

		for(var/obj/O in resin_tile.contents)
			if(istype(O, /obj/alien/resin))
				cannotbuild = TRUE

		if(!cannotbuild)
			new /obj/alien/resin/sticky(resin_tile)

	for(var/mob/living/carbon/human/affected AS in cheap_get_humans_near(src,1))
		if(affected.stat == DEAD)
			continue
		var/throwloc = affected.loc
		for(var/x in 1 to 6)
			throwloc = get_step(throwloc, REVERSE_DIR(affected.dir))
		affected.throw_at(throwloc, 12, 2.5, src, TRUE)
	qdel(src)

//////////////////
/// Neuro Mine ///
//////////////////

/obj/structure/xeno/acid_mine/neuro_mine
	name = "neurotoxin mine"
	desc = "An oddly colored weed sac, filled with dense orange gas."
	icon_state = "neuro_mine"

/obj/structure/xeno/acid_mine/neuro_mine/detonate(triggerer)
	var/datum/effect_system/smoke_spread/xeno/neuro/medium/gas = new(get_turf(src))
	gas.set_up(2, src)
	gas.start()

	if(ishuman(triggerer))
		var/mob/living/carbon/human/victim = triggerer
		victim.reagents.add_reagent(/datum/reagent/toxin/xeno_neurotoxin, 5)
		to_chat(victim, span_userdanger("You are pricked by a spike on the mine!"))
	qdel(src)

//////////////////////
/// Lifetrade Mine ///
//////////////////////

/obj/structure/xeno/acid_mine/drain_mine
	name = "drain mine"
	desc = "A cyan blob that crackles with lifeblood."
	icon_state = "emp_mine"

/obj/structure/xeno/acid_mine/drain_mine/detonate(triggerer)
	if(ishuman(triggerer))
		var/mob/living/carbon/human/victim = triggerer
		victim.apply_status_effect(STATUS_EFFECT_LIFEDRAIN)
		new /obj/effect/temp_visual/telekinesis(get_turf(victim))
	var/datum/effect_system/smoke_spread/xeno/hemodile/gas = new(get_turf(src))
	gas.set_up(2, src)
	gas.start()
	qdel(src)
