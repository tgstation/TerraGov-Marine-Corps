///After how much time of being active we die
#define FACEHUGGER_DEATH 10 SECONDS
///Time it takes to impregnate someone
#define IMPREGNATION_TIME 10 SECONDS

/**
 *Facehuggers
 *
 *They work by being activated using timers to trigger leap_at_nearest_target()
 *Going inactive and active is handeled by go_active() and go_idle()
 *Lifetime is handled by a timer on check_lifecycle()
 *For the love of god do not use process() and rng for this kind of shit it makes it unreliable and buggy as fuck
 */
/obj/item/clothing/mask/facehugger
	name = "facehugger"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = WEIGHT_CLASS_TINY //Note: can be picked up by aliens unlike most other items of w_class below 4
	resistance_flags = NONE
	flags_inventory = COVEREYES|COVERMOUTH
	flags_armor_protection = FACE|EYES
	flags_atom = CRITICAL_ATOM
	flags_item = NOBLUDGEON
	throw_range = 1
	worn_layer = FACEHUGGER_LAYER
	layer = FACEHUGGER_LAYER

	///Whether the hugger is dead, active or inactive
	var/stat = CONSCIOUS
	///"Freezes" the hugger in for example, eggs
	var/stasis = FALSE
	///Whether this hugger can infect things
	var/sterile = FALSE
	///Whether we're attached to a host
	var/attached = FALSE
	///How long the hugger will survive outside of the egg, or carrier.
	var/lifecycle = FACEHUGGER_DEATH
	///Is actually attacking someone?
	var/leaping = FALSE
	///What hive this hugger belongs to
	var/hivenumber = XENO_HIVE_NORMAL
	///The xeno that spawned/threw/dropped the hugger. Used for anti-shuffle
	var/mob/living/carbon/xenomorph/source
	///The timer tracking when we die
	var/lifetimer
	///The timer tracking when we next jump
	var/jumptimer
	///The timer to go active
	var/activetimer
	///Time to become active after impacting on a direct thrown hit
	var/impact_time = 1.5 SECONDS
	///Time to become active again
	var/activate_time = 2 SECONDS
	///Time to recover after jumping
	var/jump_cooldown = 2 SECONDS
	///Is this hugger intended for combat?
	var/combat_hugger = FALSE
	///When TRUE hugger is about to jump
	var/about_to_jump = FALSE
	///Time to become active after moving into the facehugger's space.
	var/proximity_time = 0.75 SECONDS


/obj/item/clothing/mask/facehugger/Initialize(mapload, input_hivenumber, input_source)
	. = ..()
	if(stat == CONSCIOUS)
		lifetimer = addtimer(CALLBACK(src, PROC_REF(check_lifecycle)), FACEHUGGER_DEATH, TIMER_STOPPABLE)

	if(input_hivenumber)
		hivenumber = input_hivenumber

	if(input_source)
		facehugger_register_source(input_source)

	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)
	AddElement(/datum/element/connect_loc, connections)

///Registers the source of our facehugger for the purpose of anti-shuffle mechanics
/obj/item/clothing/mask/facehugger/proc/facehugger_register_source(mob/living/carbon/xenomorph/S)
	if(source) //If we have an existing source, unregister
		UnregisterSignal(source, COMSIG_QDELETING)

	source = S //set and register new source
	RegisterSignal(S, COMSIG_QDELETING, PROC_REF(clear_hugger_source))

///Clears the source of our facehugger for the purpose of anti-shuffle mechanics
/obj/item/clothing/mask/facehugger/proc/clear_hugger_source()
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_QDELETING)
	source = null

/obj/item/clothing/mask/facehugger/Destroy()
	remove_danger_overlay() //Remove the danger overlay
	if(source)
		clear_hugger_source()
	return ..()

/obj/item/clothing/mask/facehugger/update_icon()
	if(stat == DEAD)
		var/fertility = sterile ? "impregnated" : "dead"
		icon_state = "[initial(icon_state)]_[fertility]"
		remove_danger_overlay() //Remove the danger overlay
	else if(throwing)
		icon_state = "[initial(icon_state)]_thrown"
	else if(stat == UNCONSCIOUS && !attached)
		icon_state = "[initial(icon_state)]_inactive"
		remove_danger_overlay() //Remove the danger overlay
	else
		icon_state = "[initial(icon_state)]"


//Deal with picking up facehuggers. "attack_alien" is the universal 'xenos click something while unarmed' proc.
/obj/item/clothing/mask/facehugger/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return

	if(!issamexenohive(X) && stat != DEAD)
		X.do_attack_animation(src, ATTACK_EFFECT_SMASH)
		X.visible_message("<span class='xenowarning'>[X] crushes \the [src]",
			"<span class='xenowarning'>We crush \the [src]")
		kill_hugger()
		return
	else
		attack_hand(X)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/mask/facehugger/attack_hand(mob/living/user)
	if(isxeno(user))
		var/mob/living/carbon/xenomorph/X = user
		if(X.xeno_caste.can_flags & CASTE_CAN_HOLD_FACEHUGGERS)
			deltimer(jumptimer)
			deltimer(activetimer)
			remove_danger_overlay() //Remove the exclamation overlay as we pick it up
			facehugger_register_source(X)
			return ..() // These can pick up huggers.
		else
			return FALSE // The rest can't.
	if(stat == DEAD || (sterile && !combat_hugger))
		return ..() // Dead or sterile (lamarr) can be picked.
	else if(stat == CONSCIOUS && user.can_be_facehugged(src, provoked = TRUE)) // If you try to take a healthy one it will try to hug or attack you.
		user.visible_message("<span class ='warning'>\The [src] skitters up [user]'s arm as [user.p_they()] try to grab it!", \
		"<span class ='warning'>\The [src] skitters up your arm as you try to grab it!")
		if(!Attach(user))
			go_idle()
	return FALSE // Else you can't pick.

/obj/item/clothing/mask/facehugger/attack(mob/M, mob/user)
	if(stat != CONSCIOUS)
		return ..()
	if(!M.can_be_facehugged(src, provoked = TRUE))
		to_chat(user, span_warning("The facehugger refuses to attach."))
		return ..()
	user.visible_message(span_warning("\ [user] attempts to plant [src] on [M]'s face!"), \
	span_warning("We attempt to plant [src] on [M]'s face!"))
	if(M.client && !M.stat) //Delay for conscious cliented mobs, who should be resisting.
		if(!do_after(user, 1 SECONDS, NONE, M, BUSY_ICON_DANGER))
			return
	if(!Attach(M))
		go_idle()
	user.update_icons()

/obj/item/clothing/mask/facehugger/attack_self(mob/user)
	if(isxenocarrier(user))
		var/mob/living/carbon/xenomorph/carrier/C = user
		C.store_hugger(src)
	if(ishuman(user))
		if(stat == DEAD)
			return
		user.visible_message("<span class ='warning'>[user] crushes \the [src] in [user.p_their()] hand!", \
		"<span class ='warning'>You crushes \the [src] in your hand!")
		kill_hugger()

/obj/item/clothing/mask/facehugger/examine(mob/user)
	. = ..()
	switch(stat)
		if(CONSCIOUS)
			. += span_warning("[src] seems to be active.")
		if(UNCONSCIOUS)
			. += span_warning("[src] seems to be asleep.")
		if(DEAD)
			. += span_danger("[src] is not moving.")
	if(initial(sterile))
		. += span_warning("It looks like the proboscis has been removed.")


/obj/item/clothing/mask/facehugger/proc/go_idle(hybernate = FALSE, no_activate = FALSE)
	if(stat == DEAD)
		return FALSE
	deltimer(jumptimer) //Clear jump timers
	deltimer(activetimer)
	remove_danger_overlay() //Remove the danger overlay
	if(stat == CONSCIOUS)
		stat = UNCONSCIOUS
		update_icon()
	if(hybernate) //If we're hybernating we're going into stasis; we no longer have a death timer
		stasis = TRUE
		deltimer(lifetimer)
	else if(!attached && !(stasis || no_activate))
		activetimer = addtimer(CALLBACK(src, PROC_REF(go_active)), activate_time, TIMER_STOPPABLE|TIMER_UNIQUE)
		lifetimer = addtimer(CALLBACK(src, PROC_REF(check_lifecycle)), FACEHUGGER_DEATH, TIMER_STOPPABLE|TIMER_UNIQUE)

///Resets the life timer for the facehugger
/obj/item/clothing/mask/facehugger/proc/reset_life_timer()
	deltimer(lifetimer)
	lifetimer = null
	lifetimer = addtimer(CALLBACK(src, PROC_REF(check_lifecycle)), FACEHUGGER_DEATH, TIMER_STOPPABLE|TIMER_UNIQUE)

/obj/item/clothing/mask/facehugger/proc/go_active(unhybernate = FALSE, reset_life_timer = FALSE)
	if(QDELETED(src))
		return
	if(unhybernate)
		stasis = FALSE

	if(stasis || stat == DEAD) //If we're not in stasis or dead proceed
		return FALSE

	if(reset_life_timer) //Generally only used if we directly go to active mode, such as in the case of a hugger trap trigger
		reset_life_timer()

	stat = CONSCIOUS
	remove_danger_overlay() //Remove the danger overlay
	pre_leap() //Go into the universal leap set up proc
	update_icon()
	return TRUE

///Called before we leap
/obj/item/clothing/mask/facehugger/proc/pre_leap(activation_time = jump_cooldown)
	if(QDELETED(src))
		return
	jumptimer = addtimer(CALLBACK(src, PROC_REF(leap_at_nearest_target)), activation_time, TIMER_STOPPABLE|TIMER_UNIQUE)
	if(activation_time >= 2 SECONDS) //If activation timer is equal to or greater than two seconds, we trigger the danger overlay at 1 second, otherwise we do so immediately.
		addtimer(CALLBACK(src, PROC_REF(apply_danger_overlay)), 1 SECONDS)
		return
	apply_danger_overlay()

/obj/item/clothing/mask/facehugger/proc/leap_at_nearest_target()
	if(!isturf(loc) && !(ishuman(loc)))
		return

	if(stat != CONSCIOUS) //need to be active to leap
		return

	for(var/obj/effect/particle_effect/smoke/check_smoke in get_turf(src)) //Check for pacifying smoke
		if(CHECK_BITFIELD(check_smoke.smoke_traits, SMOKE_HUGGER_PACIFY)) //Cancel out and make the hugger go idle if we have the xeno pacify tag
			go_idle()
			return

	if(ishuman(loc)) //Having an angry xeno in your hand is a bad idea.
		var/mob/living/carbon/human/holder = loc
		holder.visible_message(span_warning("The facehugger [holder] is carrying leaps at [holder.p_them()]!") , "<span class ='danger'>The facehugger you're carrying leaps at you!</span>")
		if(!Attach(holder))
			go_idle()
		return

	var/i = 10//So if we have a pile of dead bodies around, it doesn't scan everything, just ten iterations.
	for(var/mob/living/carbon/M in view(4,src))
		if(!i)
			break
		if(M.can_be_facehugged(src))
			visible_message(span_warning("\The scuttling [src] leaps at [M]!"), null, null, 4)
			leaping = TRUE
			throw_at(M, 4, 1)
			return //We found a target and will jump towards it; cancel out. If we didn't find anything, continue and try again later
		--i

	remove_danger_overlay() //Remove the danger overlay
	pre_leap() //Go into the universal leap set up proc


/obj/item/clothing/mask/facehugger/update_overlays()
	. = ..()
	if(overlays)
		cut_overlays()

	if(!about_to_jump)
		return
	add_overlay(image('icons/obj/items/grenade.dmi', "danger"))

///Applies an alert overlay when the hugger is about to jump
/obj/item/clothing/mask/facehugger/proc/apply_danger_overlay()
	if(stat == DEAD || stat == UNCONSCIOUS || !isturf(loc)) //It's dead or inactive or not on a turf don't bother
		return
	about_to_jump = TRUE
	update_overlays()

///Remove the hugger's alert overlay
/obj/item/clothing/mask/facehugger/proc/remove_danger_overlay()
	about_to_jump = FALSE
	update_overlays()

/obj/item/clothing/mask/facehugger/proc/check_lifecycle()

	if(stasis || stat == DEAD) //We don't care about this while in stasis or if we're dead
		return FALSE

	if(sterile && !combat_hugger) //We are now useless; time to die.
		kill_hugger()
		return FALSE

	if(isturf(loc))
		var/obj/alien/egg/hugger/E = locate() in loc
		if(E?.insert_new_hugger(src))
			return FALSE
		var/obj/structure/xeno/trap/T = locate() in loc
		if(T && !T.hugger)
			visible_message(span_xenowarning("[src] crawls into [T]!"))
			forceMove(T)
			T.hugger = src
			T.set_trap_type(TRAP_HUGGER)
			go_idle(TRUE)
			return FALSE
		kill_hugger()
		return FALSE

	return TRUE

/obj/item/clothing/mask/facehugger/HasProximity(atom/movable/AM)
	if(iscarbon(AM))
		var/mob/living/carbon/M = AM
		if(M.can_be_facehugged(src))
			pre_leap(proximity_time) //Go into the universal leap set up proc
			return TRUE
	return FALSE

/obj/item/clothing/mask/facehugger/proc/on_cross(datum/source, atom/movable/target, oldloc, oldlocs)
	if(stat == CONSCIOUS  && !issamexenohive(target))
		HasProximity(target)

/obj/item/clothing/mask/facehugger/proc/on_exited(datum/source, atom/movable/AM, direction)
	if(stat != CONSCIOUS) //Have to be conscious
		return
	if(!source && issamexenohive(AM)) //shuffle hug prevention, if we don't have a source and a xeno from the same hive steps off go_idle()
		go_idle()
		return
	if(source == AM) //shuffle hug prevention, if we have a source and it steps off go_idle()
		go_idle()

/obj/item/clothing/mask/facehugger/on_found(mob/finder)
	if(stat == CONSCIOUS)
		finder.visible_message(span_danger("\A [src] leaps out of \the [loc]!") )
		forceMove(get_turf(src))
		reset_life_timer()
		HasProximity(finder)
		return TRUE
	return FALSE

/obj/item/clothing/mask/facehugger/throw_at(atom/target, range, speed, thrower, spin, flying = FALSE, targetted_throw = TRUE)
	. = ..()
	update_icon()

/obj/item/clothing/mask/facehugger/throw_impact(atom/hit_atom, speed)
	if(isopenturf(hit_atom))
		var/valid_victim
		for(var/mob/living/carbon/M in hit_atom)
			if(!M.can_be_facehugged(src))
				continue
			valid_victim = TRUE
			hit_atom = M
		if(!valid_victim)
			leaping = FALSE
			go_idle()
			return FALSE
	. = ..()
	if(!.)
		return
	if(stat != CONSCIOUS)
		return
	if(!iscarbon(hit_atom))
		leaping = FALSE
		go_idle()
		return

	var/mob/living/carbon/carbon_victim = hit_atom
	if(loc == carbon_victim) //Caught
		pre_leap(impact_time)
	else if(leaping && carbon_victim.can_be_facehugged(src)) //Standard leaping behaviour, not attributable to being _thrown_ such as by a Carrier.
		if(!Attach(carbon_victim))
			go_idle()
	else
		step(src, REVERSE_DIR(dir))
		if(!issamexenohive(carbon_victim))
			carbon_victim.adjust_stagger(3 SECONDS)
			carbon_victim.add_slowdown(3)
		pre_leap(activate_time)

	leaping = FALSE

/obj/item/clothing/mask/facehugger/stop_throw(flying, original_layer)
	. = ..()
	update_icon()

//////////////////////
//  FACEHUG CHECKS
//////////////////////
/mob/proc/can_be_facehugged(obj/item/clothing/mask/facehugger/F, check_death = TRUE, check_mask = TRUE, provoked = FALSE)
	return FALSE

/mob/living/can_be_facehugged(obj/item/clothing/mask/facehugger/F, check_death = TRUE, check_mask = TRUE, provoked = FALSE)
	if(!F.combat_hugger)
		return FALSE

	if(check_death && stat == DEAD)
		return FALSE

	return TRUE

/mob/living/carbon/xenomorph/can_be_facehugged(obj/item/clothing/mask/facehugger/F, check_death = TRUE, check_mask = TRUE, provoked = FALSE)
	if(!F.combat_hugger) //Only combat huggers will attack aliens
		return FALSE

	if(check_death && stat == DEAD) //Don't attack dead aliens
		return FALSE

	if(F.issamexenohive(src)) //Check for our hive
		return FALSE

	return ..()

/mob/living/carbon/human/can_be_facehugged(obj/item/clothing/mask/facehugger/F, check_death = TRUE, check_mask = TRUE, provoked = FALSE)
	if(check_death && stat == DEAD)
		return FALSE

	if(faction == FACTION_XENO)
		return FALSE

	if(F.combat_hugger) //Combat huggers will attack anything else
		return TRUE

	if((status_flags & (XENO_HOST|GODMODE)) || F.stat == DEAD)
		return FALSE

	if(!provoked)
		if(species?.species_flags & (IS_SYNTHETIC|ROBOTIC_LIMBS))
			return FALSE

	if(on_fire)
		return FALSE

	if(check_mask)
		if(wear_mask)
			var/obj/item/W = wear_mask
			if(HAS_TRAIT(W, TRAIT_NODROP))
				return FALSE
			if(istype(W, /obj/item/clothing/mask/facehugger))
				var/obj/item/clothing/mask/facehugger/hugger = W
				if(hugger.stat != DEAD)
					return FALSE
	else if (wear_mask && wear_mask != F)
		return FALSE

	return TRUE

/mob/living/carbon/human/species/monkey/can_be_facehugged(obj/item/clothing/mask/facehugger/F, check_death = TRUE, check_mask = TRUE, provoked = FALSE)
	if(mind)
		return ..() //facehuggers still attack player monkeys
	return FALSE //ai monkeys are ignored by facehuggers

/////////////////////////////
// ATTACHING AND IMPREGNATION
//////////////////////////////
/obj/item/clothing/mask/facehugger/proc/Attach(mob/living/carbon/M)

	set_throwing(FALSE)
	leaping = FALSE
	update_icon()

	if(!istype(M))
		return FALSE

	if(attached)
		return TRUE

	if(M.status_flags & XENO_HOST || M.status_flags & GODMODE || isxeno(M))
		return FALSE

	if(isxeno(loc)) //Being carried? Drop it
		var/mob/living/carbon/xenomorph/X = loc
		X.dropItemToGround(src)
		X.update_icons()

	if(M.in_throw_mode && M.dir != dir && !M.incapacitated() && !M.get_active_held_item())
		var/catch_chance = 50
		if(M.dir == REVERSE_DIR(dir))
			catch_chance += 20
		catch_chance -= M.shock_stage * 0.3
		if(M.get_inactive_held_item())
			catch_chance  -= 25

		if(prob(catch_chance))
			M.visible_message("<span class='notice'>[M] snatches [src] out of the air and [pickweight(list("clobbers" = 30, "kills" = 30, "squashes" = 25, "dunks" = 10, "dribbles" = 5))] it!")
			kill_hugger()
			return TRUE

	var/blocked = null //To determine if the hugger just rips off the protection or can infect.
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(!H.has_limb(HEAD))
			visible_message(span_warning("[src] looks for a face to hug on [H], but finds none!"))
			return FALSE

		if(H.head)
			var/obj/item/clothing/head/D = H.head
			if(istype(D))
				if(D.anti_hug > 0 || HAS_TRAIT(D, TRAIT_NODROP))
					blocked = D
					D.anti_hug = max(0, --D.anti_hug)
					H.visible_message("<span class='danger'>[src] smashes against [H]'s [D.name], damaging it!")
					return FALSE
				else
					H.update_inv_head()

	if(M.wear_mask)
		var/obj/item/clothing/mask/W = M.wear_mask
		if(istype(W))
			if(istype(W, /obj/item/clothing/mask/facehugger))
				var/obj/item/clothing/mask/facehugger/hugger = W
				if(hugger.stat != DEAD)
					return FALSE

			if(W.anti_hug > 0 || HAS_TRAIT(W, TRAIT_NODROP))
				if(!blocked)
					blocked = W
				W.anti_hug = max(0, --W.anti_hug)
				M.visible_message(span_danger("[src] smashes against [M]'s [blocked]!"))
				return FALSE

			if(!blocked)
				M.visible_message(span_danger("[src] smashes against [M]'s [W.name] and rips it off!"))
				M.dropItemToGround(W)

	if(blocked)
		M.visible_message(span_danger("[src] smashes against [M]'s [blocked]!"))
		return FALSE

	M.equip_to_slot(src, SLOT_WEAR_MASK)
	return TRUE

/obj/item/clothing/mask/facehugger/equipped(mob/living/user, slot)
	. = ..()
	if(slot != SLOT_WEAR_MASK || stat == DEAD)
		reset_attach_status(FALSE)
		return
	if(ishuman(user))
		var/hugsound = user.gender == FEMALE ? get_sfx("female_hugged") : get_sfx("male_hugged")
		playsound(loc, hugsound, 25, 0)
	if(!sterile && !issynth(user))
		var/stamina_dmg = user.maxHealth + user.max_stamina
		user.apply_damage(stamina_dmg, STAMINA) // complete winds the target
		user.Unconscious(2 SECONDS)
	attached = TRUE
	go_idle(FALSE, TRUE)
	addtimer(CALLBACK(src, PROC_REF(Impregnate), user), IMPREGNATION_TIME)

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/carbon/target)
	ADD_TRAIT(src, TRAIT_NODROP, HUGGER_TRAIT)
	var/as_planned = target?.wear_mask == src ? TRUE : FALSE
	if(target.can_be_facehugged(src, FALSE, FALSE) && !sterile && as_planned) //is hugger still on face and can they still be impregnated
		if(!(locate(/obj/item/alien_embryo) in target))
			var/obj/item/alien_embryo/embryo = new(target)
			embryo.hivenumber = hivenumber
			GLOB.round_statistics.now_pregnant++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "now_pregnant")
			if(source?.client)
				var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[source.ckey]
				personal_statistics.impregnations++
			sterile = TRUE
		kill_hugger()
	else
		reset_attach_status(as_planned)
		playsound(loc, 'sound/voice/alien_facehugger_dies.ogg', 25, 1)
		activetimer = addtimer(CALLBACK(src, PROC_REF(go_active)), activate_time, TIMER_STOPPABLE|TIMER_UNIQUE)
		update_icon()

	if(as_planned)
		if(sterile || target.status_flags & XENO_HOST)
			target.visible_message(span_danger("[src] falls limp after violating [target]'s face!"))
		else //Huggered but not impregnated, deal damage.
			target.visible_message(span_danger("[src] frantically claws at [target]'s face before falling down!"),span_danger("[src] frantically claws at your face before falling down! Auugh!"))
			target.apply_damage(15, BRUTE, BODY_ZONE_HEAD, updating_health = TRUE)


/obj/item/clothing/mask/facehugger/proc/kill_hugger(melt_timer = 1 MINUTES)
	reset_attach_status()

	if(stat == DEAD)
		return
	stat = DEAD

	deltimer(jumptimer)
	deltimer(lifetimer)
	deltimer(activetimer)
	remove_danger_overlay() //Remove the danger overlay

	update_icon()
	playsound(loc, 'sound/voice/alien_facehugger_dies.ogg', 25, 1)

	layer = BELOW_MOB_LAYER //so dead hugger appears below live hugger if stacked on same tile.

	addtimer(CALLBACK(src, PROC_REF(melt_away)), melt_timer)

/obj/item/clothing/mask/facehugger/proc/reset_attach_status(forcedrop = TRUE)
	REMOVE_TRAIT(src, TRAIT_NODROP, HUGGER_TRAIT)
	attached = FALSE
	if(isliving(loc) && forcedrop) //Make it fall off the person so we can update their icons. Won't update if they're in containers thou
		var/mob/living/M = loc
		M.dropItemToGround(src)
	update_icon()

/obj/item/clothing/mask/facehugger/proc/melt_away()
	visible_message("[icon2html(src, viewers(src))] [span_danger("\The [src] decays into a mass of acid and chitin.")]")
	qdel(src)

///////////////////////////////
//  DAMAGE STUFF
///////////////////////////////

/obj/item/clothing/mask/facehugger/ex_act(severity)
	kill_hugger()

/obj/item/clothing/mask/facehugger/attackby(obj/item/I, mob/user, params)
	if(I.flags_item & NOBLUDGEON || attached)
		return
	kill_hugger()

/obj/item/clothing/mask/facehugger/bullet_act(obj/projectile/P)
	..()
	if(P.ammo.flags_ammo_behavior & AMMO_XENO)
		return FALSE //Xeno spits ignore huggers.
	if(P.damage && !(P.ammo.damage_type in list(OXY, STAMINA)))
		kill_hugger()
	P.ammo.on_hit_obj(src,P)
	return TRUE

/obj/item/clothing/mask/facehugger/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		kill_hugger()

/obj/item/clothing/mask/facehugger/flamer_fire_act(burnlevel)
	kill_hugger()

/obj/item/clothing/mask/facehugger/dropped(mob/user)
	. = ..()
	go_idle()
	if(isxeno(user)) //Set the source mob
		facehugger_register_source(user)


/////////////////////////////
// SUBTYPES
/////////////////////////////
/obj/item/clothing/mask/facehugger/stasis
	stat = UNCONSCIOUS
	stasis = TRUE

/obj/item/clothing/mask/facehugger/stasis/Initialize(mapload)
	. = ..()
	update_icon()


/obj/item/clothing/mask/facehugger/dead
	desc = "It has some sort of a tube at the end of its tail. What the hell is this thing?"
	name = "????"
	stat = DEAD
	sterile = TRUE

/obj/item/clothing/mask/facehugger/dead/Initialize(mapload)
	. = ..()
	update_icon()


/obj/item/clothing/mask/facehugger/larval
	name = "larval hugger"

///Parent type for all non-larval huggers: can't be worn, is sterile
/obj/item/clothing/mask/facehugger/combat
	sterile = TRUE
	combat_hugger = TRUE
	flags_equip_slot = NONE


/obj/item/clothing/mask/facehugger/combat/neuro
	name = "neuro hugger"
	desc = "This strange creature has a single prominent sharp proboscis."
	color = COLOR_DARK_ORANGE
	impact_time = 1 SECONDS
	activate_time = 1.5 SECONDS
	jump_cooldown = 1.5 SECONDS
	proximity_time = 0.5 SECONDS

/obj/item/clothing/mask/facehugger/combat/neuro/Attach(mob/M, mob/user)
	if(!combat_hugger_check_target(M))
		return FALSE

	var/mob/living/victim = M
	do_attack_animation(M)
	victim.apply_damage(100, STAMINA, BODY_ZONE_HEAD, BIO) //This should prevent sprinting
	victim.apply_damage(1, BRUTE, sharp = TRUE, updating_health = TRUE) //Token brute for the injection
	victim.reagents.add_reagent(/datum/reagent/toxin/xeno_neurotoxin, 10, no_overdose = TRUE)
	playsound(victim, 'sound/effects/spray3.ogg', 25, 1)
	victim.visible_message(span_danger("[src] penetrates [victim] with its sharp probscius!"),span_danger("[src] penetrates you with a sharp probscius before falling down!"))
	leaping = FALSE
	go_idle() //We're a bit slow on the recovery
	return TRUE

/obj/item/clothing/mask/facehugger/combat/acid
	name = "acid hugger"
	desc = "This repulsive looking thing is bloated with throbbing, putrescent green sacks of flesh."
	color = COLOR_GREEN
	impact_time = 1 SECONDS
	activate_time = 1.5 SECONDS
	jump_cooldown = 1.5 SECONDS
	proximity_time = 0.5 SECONDS

/obj/item/clothing/mask/facehugger/combat/acid/Attach(mob/M, mob/user)
	if(!combat_hugger_check_target(M))
		return FALSE

	visible_message(span_danger("[src] explodes into a smoking splatter of acid!"))
	playsound(loc, 'sound/bullets/acid_impact1.ogg', 50, 1)

	for(var/turf/acid_tile AS in RANGE_TURFS(1, loc))
		new /obj/effect/temp_visual/acid_splatter(acid_tile) //SFX
		if(!locate(/obj/effect/xenomorph/spray) in acid_tile.contents)
			new /obj/effect/xenomorph/spray(acid_tile, 6 SECONDS, 16)


	var/datum/effect_system/smoke_spread/xeno/acid/light/A = new(get_turf(src)) //Spawn acid smoke
	A.set_up(1,src)
	A.start()
	kill_hugger(0.5 SECONDS)

	return TRUE


/obj/item/clothing/mask/facehugger/combat/resin
	name = "resin hugger"
	desc = "This truly bizzare, bloated creature drips with purple, viscous resin."
	color = COLOR_STRONG_VIOLET
	impact_time = 1 SECONDS
	activate_time = 1.5 SECONDS
	jump_cooldown = 1.5 SECONDS
	proximity_time = 0.5 SECONDS

/obj/item/clothing/mask/facehugger/combat/resin/Attach(mob/M, mob/user)
	if(!combat_hugger_check_target(M))
		return FALSE

	visible_message(span_danger("[src] explodes into a mess of viscous resin!"))
	playsound(loc, get_sfx("alien_resin_build"), 50, 1)

	for(var/turf/sticky_tile AS in RANGE_TURFS(1, loc))
		if(!locate(/obj/effect/xenomorph/spray) in sticky_tile.contents)
			new /obj/alien/resin/sticky/thin(sticky_tile)

	for(var/mob/living/target in range(1, loc))
		if(isxeno(target)) //Xenos aren't affected by sticky resin
			continue

		target.adjust_stagger(3 SECONDS)
		target.add_slowdown(15)
		target.apply_damage(100, STAMINA, BODY_ZONE_HEAD, BIO, updating_health = TRUE) //This should prevent sprinting

	kill_hugger(0.5 SECONDS)

	return TRUE


/obj/item/clothing/mask/facehugger/combat/slash
	name = "clawed hugger"
	desc = "This nasty little creature is a nightmarish scrabble of muscle and sharp, long claws."
	color = COLOR_RED
	impact_time = 0.5 SECONDS
	activate_time = 1.2 SECONDS
	jump_cooldown = 1.2 SECONDS
	proximity_time = 0.5 SECONDS

/obj/item/clothing/mask/facehugger/combat/slash/Attach(mob/M)
	if(!combat_hugger_check_target(M))
		return FALSE

	var/mob/living/victim = M
	do_attack_animation(M, ATTACK_EFFECT_REDSLASH)
	playsound(loc, "alien_claw_flesh", 25, 1)
	var/affecting = ran_zone(null, 0)
	if(!affecting) //Still nothing??
		affecting = BODY_ZONE_CHEST //Gotta have a torso?!
	victim.apply_damage(CARRIER_SLASH_HUGGER_DAMAGE, BRUTE, affecting, MELEE) //Crap base damage after armour...
	victim.visible_message(span_danger("[src] frantically claws at [victim]!"),span_danger("[src] frantically claws at you!"))
	leaping = FALSE
	go_active() //Slashy boys recover *very* fast.
	return TRUE

///See if our target is valid
/obj/item/clothing/mask/facehugger/proc/combat_hugger_check_target(mob/M)
	if(stat != CONSCIOUS)
		return FALSE
	if(!isliving(M))
		return FALSE
	if(isxeno(M))
		var/mob/living/carbon/xenomorph/X = M
		if(hivenumber == X.hive.hivenumber) //No friendly fire
			return FALSE

	return TRUE

#undef FACEHUGGER_DEATH
#undef IMPREGNATION_TIME
