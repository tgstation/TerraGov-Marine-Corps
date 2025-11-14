
//Xeno-style acids
//Ideally we'll consolidate all the "effect" objects here
//Also need to change the icons
/obj/effect/xenomorph
	name = "alien thing"
	desc = "You shouldn't be seeing this."
	icon = 'icons/Xeno/Effects.dmi'
	layer = FLY_LAYER

/obj/effect/xenomorph/spray
	name = "splatter"
	desc = "It burns! It burns like hygiene!"
	icon_state = "acid2"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	layer = ABOVE_OBJ_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pass_flags = PASS_LOW_STRUCTURE|PASS_MOB|PASS_GRILLE|PASS_AIR
	var/slow_amt = 0.8
	var/duration = 10 SECONDS
	var/acid_damage = XENO_DEFAULT_ACID_PUDDLE_DAMAGE
	/// Who created that spray
	var/mob/xeno_owner

/obj/effect/xenomorph/spray/Initialize(mapload, duration = 10 SECONDS, damage = XENO_DEFAULT_ACID_PUDDLE_DAMAGE, mob/living/_xeno_owner) //Self-deletes
	. = ..()
	notify_ai_hazard()
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, duration + rand(0, 2 SECONDS))
	acid_damage = damage
	xeno_owner = _xeno_owner
	RegisterSignal(xeno_owner, COMSIG_QDELETING, PROC_REF(clean_mob_owner))
	RegisterSignal(loc, COMSIG_ATOM_ENTERED, PROC_REF(atom_enter_turf))
	TIMER_COOLDOWN_START(src, COOLDOWN_PARALYSE_ACID, 5)

/obj/effect/xenomorph/spray/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	xeno_owner = null
	return ..()

/obj/effect/xenomorph/spray/can_z_move(direction, turf/start, turf/destination, z_move_flags, mob/living/rider)
	z_move_flags |= ZMOVE_ALLOW_ANCHORED
	return ..()

/obj/effect/xenomorph/spray/onZImpact(turf/impacted_turf, levels, impact_flags = NONE)
	impact_flags |= ZIMPACT_NO_SPIN
	return ..()

/// Signal handler to check if an human is entering the acid spray turf
/obj/effect/xenomorph/spray/proc/atom_enter_turf(datum/source, atom/movable/moved_in, direction)
	SIGNAL_HANDLER
	if(!ishuman(moved_in))
		return
	var/mob/living/carbon/human/victim = moved_in
	if(victim.pass_flags & HOVERING)
		return
	victim.acid_spray_entered(null, src, acid_damage, slow_amt)

/// Set xeno_owner to null to avoid hard del
/obj/effect/xenomorph/spray/proc/clean_mob_owner()
	UnregisterSignal(xeno_owner, COMSIG_QDELETING)
	xeno_owner = null

/// Signal handler to burn and maybe stun the human entering the acid spray
/mob/living/carbon/human/proc/acid_spray_entered(datum/source, obj/effect/xenomorph/spray/acid_spray, acid_damage, slow_amt)
	SIGNAL_HANDLER
	if(CHECK_MULTIPLE_BITFIELDS(pass_flags, HOVERING) || stat == DEAD)
		return

	if(acid_spray.xeno_owner && TIMER_COOLDOWN_RUNNING(acid_spray, COOLDOWN_PARALYSE_ACID)) //To prevent being able to walk "over" acid sprays
		acid_spray_act(acid_spray.xeno_owner)
		return

	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_ACID))
		return

	TIMER_COOLDOWN_START(src, COOLDOWN_ACID, 1 SECONDS)
	if(HAS_TRAIT(src, TRAIT_FLOORED))
		INVOKE_ASYNC(src, PROC_REF(take_overall_damage), acid_damage, BURN, ACID, FALSE, FALSE, TRUE, 0, 3)
		to_chat(src, span_danger("You are scalded by the burning acid!"))
		return
	to_chat(src, span_danger("Your feet scald and burn! Argh!"))
	if(!(species.species_flags & NO_PAIN))
		INVOKE_ASYNC(src, PROC_REF(emote), "pain")

	next_move_slowdown += slow_amt
	for(var/limb_to_hit in list(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT))
		INVOKE_ASYNC(src, PROC_REF(apply_damage), acid_damage * 0.5, BURN, limb_to_hit, ACID)

/obj/effect/xenomorph/spray/process()
	var/turf/T = loc
	if(!istype(T))
		qdel(src)
		return

	SEND_SIGNAL(T, COMSIG_ATOM_ACIDSPRAY_ACT, src) //Signal the turf
	for(var/H in T)

		var/atom/A = H
		SEND_SIGNAL(A, COMSIG_ATOM_ACIDSPRAY_ACT, src, acid_damage, slow_amt)

/// Creates or replaces an xenomorph acid spray effect on a specific turf with a new one.
/proc/xenomorph_spray(turf/spraying_turf, duration, damage, mob/living/carbon/xenomorph/xenomorph_creator, should_do_additional_visual_effect = FALSE, should_acid_act = FALSE)
	var/obj/effect/xenomorph/spray/existing_spray = locate(/obj/effect/xenomorph/spray) in spraying_turf
	if(existing_spray)
		qdel(existing_spray)
	if(should_do_additional_visual_effect)
		new /obj/effect/temp_visual/acid_splatter(spraying_turf)
	. = new /obj/effect/xenomorph/spray(spraying_turf, duration, damage, xenomorph_creator)
	if(should_acid_act)
		if(!xenomorph_creator)
			CRASH("xenomorph_spray wanted should_acid_act, but had no xenomorph_creator.")
		for(var/atom/atom_in_turf AS in spraying_turf)
			atom_in_turf.acid_spray_act(xenomorph_creator)

//Medium-strength acid // todo please god make me into an overlay and component already...
/obj/effect/xenomorph/acid
	name = "acid"
	desc = "Burbling corrosive stuff. I wouldn't want to touch it."
	icon_state = "acid_normal"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	base_icon_state = null
	///the target atom for being melted
	var/atom/acid_t
	///the current tick on destruction stage, currently used to determine what messages to output
	var/ticks = 0
	///how fast something will melt when subject to this acid.
	var/acid_strength = REGULAR_ACID_STRENGTH
	///acid damage on pick up, subject to armor
	var/acid_damage = 125
	///stages of meltage, currently used to determine what messages to output
	var/strength_t = 4
	///How much faster or slower acid melts specific objects/turfs.
	var/acid_melt_multiplier

/obj/effect/xenomorph/acid/Initialize(mapload, atom/target, melting_rate)
	if(!istype(target))
		return INITIALIZE_HINT_QDEL

	var/obj/effect/xenomorph/acid/current_acid = target.get_self_acid()
	if(current_acid)
		current_acid.acid_strength = acid_strength
		current_acid.acid_damage = acid_damage
		current_acid.strength_t = strength_t
		current_acid.acid_melt_multiplier = melting_rate
		current_acid.base_icon_state = icon_state
		current_acid.update_appearance(UPDATE_ICON_STATE)
		return INITIALIZE_HINT_QDEL

	. = ..()
	acid_melt_multiplier = melting_rate
	acid_t = target
	RegisterSignal(acid_t, COMSIG_ATOM_GET_SELF_ACID, PROC_REF(return_self_acid))
	RegisterSignal(acid_t, COMSIG_ITEM_ATTEMPT_PICK_UP, PROC_REF(on_attempt_pickup))
	RegisterSignal(acid_t, COMSIG_QDELETING, PROC_REF(on_target_del))
	RegisterSignal(acid_t, COMSIG_MOVABLE_MOVED, PROC_REF(on_target_move))
	layer = acid_t.layer+0.001
	base_icon_state = icon_state
	update_appearance(UPDATE_ICON_STATE)
	START_PROCESSING(SSslowprocess, src)

/obj/effect/xenomorph/acid/Destroy()
	STOP_PROCESSING(SSslowprocess, src)
	acid_t = null
	return ..()

/obj/effect/xenomorph/acid/update_icon_state()
	icon_state = base_icon_state
	if(iswallturf(acid_t))
		icon_state += "_wall"

/obj/effect/xenomorph/acid/process(delta_time)
	if(!acid_t || !acid_t.loc)
		qdel(src)
		return
	ticks += delta_time * (acid_strength * acid_melt_multiplier)
	if(ticks >= strength_t)
		acid_t.do_acid_melt()
		qdel(src)
		return
	switch(strength_t - ticks)
		if(0 to 1)
			visible_message(span_xenowarning("\The [acid_t] begins to crumble under the acid!"))
		if(2)
			visible_message(span_xenowarning("\The [acid_t] is struggling to withstand the acid!"))
		if(4)
			visible_message(span_xenowarning("\The [acid_t]\s structure is being melted by the acid!"))
		if(6)
			visible_message(span_xenowarning("\The [acid_t] is barely holding up against the acid!"))

///cleans up if the target is destroyed
/obj/effect/xenomorph/acid/proc/on_target_del(atom/source)
	SIGNAL_HANDLER
	qdel(src)

///Moves with the target
/obj/effect/xenomorph/acid/proc/on_target_move(atom/source)
	SIGNAL_HANDLER
	abstract_move(source.loc)

///Sig handler to show this acid is attached to something
/obj/effect/xenomorph/acid/proc/return_self_acid(atom/source, list/acid_List)
	SIGNAL_HANDLER
	acid_List += src

///Sig handler to show this acid is attached to something
/obj/effect/xenomorph/acid/proc/on_attempt_pickup(obj/item/source, mob/user)
	SIGNAL_HANDLER
	if(!ishuman(user))
		qdel(src)
		return
	INVOKE_ASYNC(src, PROC_REF(on_pickup), source, user)

///Sig handler to show this acid is attached to something
/obj/effect/xenomorph/acid/proc/on_pickup(obj/item/item, mob/living/carbon/human/human_user)
	human_user.visible_message(span_danger("Corrosive substances seethe all over [human_user] as [human_user.p_they()] retrieves the acid-soaked [item]!"),
	span_danger("Corrosive substances burn and seethe all over you upon retrieving the acid-soaked [item]!"))
	playsound(human_user, SFX_ACID_HIT, 25)
	human_user.emote("pain")
	var/list/affected_limbs = list("l_hand", "r_hand", "l_arm", "r_arm")
	var/limb_count = null
	for(var/datum/limb/limb AS in human_user.limbs)
		if(limb_count > 4)
			break
		if(!affected_limbs.Find(limb.name))
			continue
		limb.take_damage_limb(0, human_user.modify_by_armor(acid_damage * 0.25 * randfloat(0.75, 1.25), ACID, def_zone = limb.name))
		limb_count++
	human_user.UpdateDamageIcon()
	UPDATEHEALTH(human_user)
	qdel(src)

/obj/effect/xenomorph/acid/weak
	name = "weak acid"
	acid_strength = WEAK_ACID_STRENGTH
	acid_damage = 75
	icon_state = "acid_weak"

/obj/effect/xenomorph/acid/strong
	name = "strong acid"
	acid_strength = STRONG_ACID_STRENGTH
	acid_damage = 175
	icon_state = "acid_strong"

/obj/effect/xenomorph/warp_shadow
	name = "warp shadow"
	desc = "A strange rift in space and time. You probably shouldn't touch this."
	icon = 'icons/Xeno/castes/wraith.dmi'
	icon_state = "Wraith Walking"
	color = COLOR_BLACK
	alpha = 128 //Translucent
	density = FALSE
	opacity = FALSE
	anchored = TRUE

/obj/effect/xenomorph/warp_shadow/Initialize(mapload, target)
	. = ..()
	add_filter("wraith_warp_shadow", 4, list("type" = "blur", 5)) //Cool filter appear
