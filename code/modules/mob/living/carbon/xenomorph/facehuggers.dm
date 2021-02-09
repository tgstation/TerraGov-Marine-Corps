///After how much time of being active we die
#define FACEHUGGER_DEATH 10 SECONDS
///Time before we try another jump
#define JUMP_COOLDOWN 2 SECONDS
///Time between being dropped and going idle
#define ACTIVATE_TIME 4 SECONDS
///Time it takes to impregnate someone
#define IMPREGNATION_TIME 12 SECONDS

/**
 *Facehuggers
 *
 *They work by being activated using timers to trigger leap_at_nearest_target()
 *Going inactive and active is handeled by go_active() and go_idle()
 *Lifetime is handled by a timer on check_lifecycle()
 *For the love of god do not use process() and rng for this kind of shit it makes it unreliable and buggy as fuck
 */
/obj/item/clothing/mask/facehugger
	name = "alien"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = WEIGHT_CLASS_TINY //Note: can be picked up by aliens unlike most other items of w_class below 4
	flags_inventory = COVEREYES|ALLOWINTERNALS|COVERMOUTH|ALLOWREBREATH
	flags_armor_protection = FACE|EYES
	flags_atom = CRITICAL_ATOM
	flags_item = NOBLUDGEON
	throw_range = 1
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

	///The timer tracking when we die
	var/lifetimer
	///The timer tracking when we next jump
	var/jumptimer

/obj/item/clothing/mask/facehugger/Initialize()
	. = ..()
	if(stat == CONSCIOUS)
		lifetimer = addtimer(CALLBACK(src, .proc/check_lifecycle), FACEHUGGER_DEATH, TIMER_STOPPABLE)

/obj/item/clothing/mask/facehugger/Destroy()
	. = ..()
	deltimer(jumptimer)
	deltimer(lifetimer)
	lifetimer = null
	jumptimer = null

/obj/item/clothing/mask/facehugger/update_icon()
	if(stat == DEAD)
		var/fertility = sterile ? "impregnated" : "dead"
		icon_state = "[initial(icon_state)]_[fertility]"
	else if(throwing)
		icon_state = "[initial(icon_state)]_thrown"
	else if(stat == UNCONSCIOUS && !attached)
		icon_state = "[initial(icon_state)]_inactive"
	else
		icon_state = "[initial(icon_state)]"


//Deal with picking up facehuggers. "attack_alien" is the universal 'xenos click something while unarmed' proc.
/obj/item/clothing/mask/facehugger/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
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
		if(X.xeno_caste.caste_flags & CASTE_CAN_HOLD_FACEHUGGERS)
			deltimer(jumptimer)
			jumptimer = null
			return ..() // These can pick up huggers.
		else
			return FALSE // The rest can't.
	if(stat == DEAD || sterile)
		return ..() // Dead or sterile (lamarr) can be picked.
	else if(stat == CONSCIOUS && user.can_be_facehugged(src, provoked = TRUE)) // If you try to take a healthy one it will try to hug you.
		if(!Attach(user))
			go_idle()
	return FALSE // Else you can't pick.

/obj/item/clothing/mask/facehugger/attack(mob/M, mob/user)
	if(stat != CONSCIOUS)
		return ..()
	if(!M.can_be_facehugged(src, provoked = TRUE))
		to_chat(user, "<span class='warning'>The facehugger refuses to attach.</span>")
		return ..()
	user.visible_message("<span class='warning'>\ [user] attempts to plant [src] on [M]'s face!</span>", \
	"<span class='warning'>We attempt to plant [src] on [M]'s face!</span>")
	if(M.client && !M.stat) //Delay for conscious cliented mobs, who should be resisting.
		if(!do_after(user, 1 SECONDS, TRUE, M, BUSY_ICON_DANGER))
			return
	if(!Attach(M))
		go_idle()
	user.update_icons()

/obj/item/clothing/mask/facehugger/attack_self(mob/user)
	if(isxenocarrier(user))
		var/mob/living/carbon/xenomorph/carrier/C = user
		C.store_hugger(src)

/obj/item/clothing/mask/facehugger/examine(mob/user)
	. = ..()
	switch(stat)
		if(CONSCIOUS)
			to_chat(user, "<span class='warning'>[src] seems to be active.</span>")
		if(UNCONSCIOUS)
			to_chat(user, "<span class='warning'>[src] seems to be asleep.</span>")
		if(DEAD)
			to_chat(user, "<span class='danger'>[src] is not moving.</span>")
	if(initial(sterile))
		to_chat(user, "<span class='warning'>It looks like the proboscis has been removed.</span>")

/obj/item/clothing/mask/facehugger/dropped(mob/user)
	. = ..()
	// Whena  xeno removes the hugger from storage we don't want to start the active timer until they drop or throw it
	if(isxenocarrier(user))
		go_active(TRUE)

/obj/item/clothing/mask/facehugger/proc/go_idle(hybernate = FALSE, no_activate = FALSE)
	deltimer(jumptimer)
	deltimer(lifetimer)
	lifetimer = null
	jumptimer = null
	if(stat == CONSCIOUS)
		stat = UNCONSCIOUS
		update_icon()
	if(hybernate)
		stasis = TRUE
		lifecycle = initial(lifecycle)
	else if(!attached && !(stasis || no_activate))
		addtimer(CALLBACK(src, .proc/go_active), ACTIVATE_TIME)

/obj/item/clothing/mask/facehugger/proc/go_active(unhybernate = FALSE)
	if(unhybernate)
		stasis = FALSE
	if(stat == UNCONSCIOUS && !stasis)
		stat = CONSCIOUS
		lifetimer = addtimer(CALLBACK(src, .proc/check_lifecycle), FACEHUGGER_DEATH, TIMER_STOPPABLE|TIMER_UNIQUE)
		jumptimer = addtimer(CALLBACK(src, .proc/leap_at_nearest_target), JUMP_COOLDOWN, TIMER_STOPPABLE|TIMER_UNIQUE)
		update_icon()
		return TRUE
	return FALSE

/obj/item/clothing/mask/facehugger/proc/check_lifecycle()
	if(sterile)
		return TRUE
	if(isturf(loc))
		var/obj/effect/alien/egg/E = locate() in loc
		if(E?.status == EGG_BURST)
			visible_message("<span class='xenowarning'>[src] crawls back into [E]!</span>")
			forceMove(E)
			E.hugger = src
			E.update_status(EGG_GROWN)
			E.deploy_egg_triggers()
			go_idle(TRUE)
			return FALSE
		var/obj/effect/alien/resin/trap/T = locate() in loc
		if(T && !T.hugger)
			visible_message("<span class='xenowarning'>[src] crawls into [T]!</span>")
			forceMove(T)
			T.hugger = src
			T.icon_state = "trap1"
			go_idle(TRUE)
			return FALSE
		kill_hugger()
		return FALSE

	return TRUE

/obj/item/clothing/mask/facehugger/HasProximity(atom/movable/AM)
	if(iscarbon(AM))
		var/mob/living/carbon/M = AM
		if(M.can_be_facehugged(src))
			if(!Attach(M))
				go_idle()
			return TRUE
	return FALSE

/obj/item/clothing/mask/facehugger/proc/leap_at_nearest_target(forced = FALSE)
	if(!isturf(loc))
		return
	if(!forced)
		if(throwing || !lifetimer)//theres only a lifetimer as long as the huggers conscious
			return
	var/i = 10//So if we have a pile of dead bodies around, it doesn't scan everything, just ten iterations.
	for(var/mob/living/carbon/M in view(4,src))
		if(!i)
			break
		if(M.can_be_facehugged(src))
			visible_message("<span class='warning'>\The scuttling [src] leaps at [M]!</span>", null, null, 4)
			leaping = TRUE
			throw_at(M, 4, 1)
			break
		--i
	jumptimer = addtimer(CALLBACK(src, .proc/leap_at_nearest_target), JUMP_COOLDOWN, TIMER_STOPPABLE|TIMER_UNIQUE)

/obj/item/clothing/mask/facehugger/proc/fast_activate(unhybernate = FALSE)
	if(go_active(unhybernate) && !throwing)
		leap_at_nearest_target(TRUE)

/obj/item/clothing/mask/facehugger/Crossed(atom/target)
	. = ..()
	if(stat == CONSCIOUS)
		HasProximity(target)

/obj/item/clothing/mask/facehugger/Uncross(atom/movable/AM)
	. = ..()
	if(. && stat == CONSCIOUS && isxeno(AM)) //shuffle hug prevention, if a xeno steps off go_idle()
		go_idle()

/obj/item/clothing/mask/facehugger/on_found(mob/finder)
	if(stat == CONSCIOUS)
		HasProximity(finder)
		return TRUE
	return FALSE

/obj/item/clothing/mask/facehugger/throw_at(atom/target, range, speed)
	. = ..()
	update_icon()
	if(jumptimer)
		jumptimer = addtimer(CALLBACK(src, .proc/leap_at_nearest_target), JUMP_COOLDOWN, TIMER_STOPPABLE|TIMER_UNIQUE)

/obj/item/clothing/mask/facehugger/throw_impact(atom/hit_atom, speed)
	if(stat != CONSCIOUS)
		return ..()
	if(iscarbon(hit_atom))
		var/mob/living/carbon/M = hit_atom
		if(leaping && M.can_be_facehugged(src)) //Standard leaping behaviour, not attributable to being _thrown_ such as by a Carrier.
			if(!Attach(M))
				go_idle()
			return ..()
		else
			step(src, REVERSE_DIR(dir)) //We want the hugger to bounce off if it hits a mob.
			deltimer(jumptimer)
			jumptimer = addtimer(CALLBACK(src, .proc/fast_activate), 1.5 SECONDS, TIMER_STOPPABLE|TIMER_UNIQUE)
			return ..()
	else
		for(var/mob/living/carbon/M in loc)
			if(M.can_be_facehugged(src))
				if(!Attach(M))
					go_idle()
				return ..()
		deltimer(jumptimer)
		jumptimer = addtimer(CALLBACK(src, .proc/fast_activate), ACTIVATE_TIME, TIMER_STOPPABLE|TIMER_UNIQUE)
	. = ..()
	leaping = FALSE
	go_idle(FALSE)


//////////////////////
//  FACEHUG CHECKS
//////////////////////
/mob/proc/can_be_facehugged(obj/item/clothing/mask/facehugger/F, check_death = TRUE, check_mask = TRUE, provoked = FALSE)
	return FALSE

/mob/living/carbon/monkey/can_be_facehugged(obj/item/clothing/mask/facehugger/F, check_death = TRUE, check_mask = TRUE, provoked = FALSE)
	if(!istype(F))
		return FALSE

	if((status_flags & (XENO_HOST|GODMODE)) || F.stat == DEAD)
		return FALSE

	if(check_death && stat == DEAD)
		return FALSE

	if(check_mask)
		if(wear_mask)
			var/obj/item/W = wear_mask
			if(W.flags_item & NODROP)
				return FALSE
			if(istype(W, /obj/item/clothing/mask/facehugger))
				var/obj/item/clothing/mask/facehugger/hugger = W
				if(hugger.stat != DEAD)
					return FALSE
	else if (wear_mask && wear_mask != F)
		return FALSE

	return TRUE

/mob/living/carbon/human/can_be_facehugged(obj/item/clothing/mask/facehugger/F, check_death = TRUE, check_mask = TRUE, provoked = FALSE)
	if((status_flags & (XENO_HOST|GODMODE)) || F.stat == DEAD)
		return FALSE

	if(check_death && stat == DEAD)
		return FALSE

	if(!provoked)
		if(species?.species_flags & IS_SYNTHETIC)
			return FALSE

	if(on_fire)
		return FALSE

	if(check_mask)
		if(wear_mask)
			var/obj/item/W = wear_mask
			if(W.flags_item & NODROP)
				return FALSE
			if(istype(W, /obj/item/clothing/mask/facehugger))
				var/obj/item/clothing/mask/facehugger/hugger = W
				if(hugger.stat != DEAD)
					return FALSE
	else if (wear_mask && wear_mask != F)
		return FALSE

	return TRUE


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

	if(M.status_flags & XENO_HOST || isxeno(M))
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
			visible_message("<span class='warning'>[src] looks for a face to hug on [H], but finds none!</span>")
			return FALSE

		if(H.head)
			var/obj/item/clothing/head/D = H.head
			if(istype(D))
				if(D.anti_hug > 0 || D.flags_item & NODROP)
					blocked = D
					D.anti_hug = max(0, --D.anti_hug)
					H.visible_message("<span class='danger'>[src] smashes against [H]'s [D.name], damaging it!")
					return FALSE
				else
					if(istype(D, /obj/item/clothing/head/helmet/marine)) //Marine helmets now get a fancy overlay.
						var/obj/item/clothing/head/helmet/marine/m_helmet = D
						m_helmet.add_hugger_damage()
					H.update_inv_head()

	if(M.wear_mask)
		var/obj/item/clothing/mask/W = M.wear_mask
		if(istype(W))
			if(istype(W, /obj/item/clothing/mask/facehugger))
				var/obj/item/clothing/mask/facehugger/hugger = W
				if(hugger.stat != DEAD)
					return FALSE

			if(W.anti_hug > 0 || W.flags_item & NODROP)
				if(!blocked)
					blocked = W
				W.anti_hug = max(0, --W.anti_hug)
				M.visible_message("<span class='danger'>[src] smashes against [M]'s [blocked]!</span>")
				return FALSE

			if(!blocked)
				M.visible_message("<span class='danger'>[src] smashes against [M]'s [W.name] and rips it off!</span>")
				M.dropItemToGround(W)
			if(ishuman(M)) //Check for camera; if we have one, turn it off.
				var/mob/living/carbon/human/H = M
				if(istype(H.wear_ear, /obj/item/radio/headset/mainship/marine))
					var/obj/item/radio/headset/mainship/marine/R = H.wear_ear
					if(R.camera.status)
						R.camera.toggle_cam(null, FALSE) //Turn camera off.
						to_chat(H, "<span class='danger'>Your headset camera flickers off; you'll need to reactivate it by rebooting your headset HUD!<span>")

	if(blocked)
		M.visible_message("<span class='danger'>[src] smashes against [M]'s [blocked]!</span>")
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
	if(!sterile && !issynth(user) && !isIPC(user))
		if(user.disable_lights(sparks = TRUE, silent = TRUE)) //Knock out the lights so the victim can't be cam tracked/spotted as easily
			user.visible_message("<span class='danger'>[user]'s lights flicker and short out in a struggle!</span>", "<span class='danger'>Your equipment's lights flicker and short out in a struggle!</span>")
		var/stamina_dmg = user.maxHealth * 2 + user.max_stamina_buffer
		user.apply_damage(stamina_dmg, STAMINA) // complete winds the target
		user.Unconscious(6 SECONDS) //THIS MIGHT NEED TWEAKS // still might! // tweaked it
	addtimer(VARSET_CALLBACK(src, flags_item, flags_item|NODROP), IMPREGNATION_TIME) // becomes stuck after min-impreg time
	attached = TRUE
	go_idle(FALSE, TRUE)
	addtimer(CALLBACK(src, .proc/Impregnate, user), IMPREGNATION_TIME)

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/carbon/target)
	var/as_planned = target?.wear_mask == src ? TRUE : FALSE
	if(target.can_be_facehugged(src, FALSE, FALSE) && !sterile && as_planned) //is hugger still on face and can they still be impregnated
		if(!(locate(/obj/item/alien_embryo) in target))
			var/obj/item/alien_embryo/embryo = new(target)
			embryo.hivenumber = hivenumber
			GLOB.round_statistics.now_pregnant++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "now_pregnant")
			sterile = TRUE
		kill_hugger()
	else
		reset_attach_status(as_planned)
		playsound(loc, 'sound/voice/alien_facehugger_dies.ogg', 25, 1)
		addtimer(CALLBACK(src, .proc/go_active),ACTIVATE_TIME)
		update_icon()

	if(as_planned)
		if(sterile || target.status_flags & XENO_HOST)
			target.visible_message("<span class='danger'>[src] falls limp after violating [target]'s face!</span>")
		else //Huggered but not impregnated, deal damage.
			target.visible_message("<span class='danger'>[src] frantically claws at [target]'s face before falling down!</span>","<span class='danger'>[src] frantically claws at your face before falling down! Auugh!</span>")
			target.apply_damage(15, BRUTE, "head", updating_health = TRUE)


/obj/item/clothing/mask/facehugger/proc/kill_hugger()
	reset_attach_status()

	if(stat == DEAD)
		return
	stat = DEAD

	deltimer(jumptimer)
	deltimer(lifetimer)
	lifetimer = null
	jumptimer = null

	update_icon()
	visible_message("\icon[src] <span class='danger'>\The [src] curls up into a ball!</span>")
	playsound(loc, 'sound/voice/alien_facehugger_dies.ogg', 25, 1)

	layer = BELOW_MOB_LAYER //so dead hugger appears below live hugger if stacked on same tile.

	addtimer(CALLBACK(src, .proc/melt_away), 3 MINUTES)

/obj/item/clothing/mask/facehugger/proc/reset_attach_status(forcedrop = TRUE)
	flags_item &= ~NODROP
	attached = FALSE
	if(isliving(loc) && forcedrop) //Make it fall off the person so we can update their icons. Won't update if they're in containers thou
		var/mob/living/M = loc
		M.dropItemToGround(src)
	update_icon()

/obj/item/clothing/mask/facehugger/proc/melt_away()
	visible_message("[icon2html(src, viewers(src))] <span class='danger'>\The [src] decays into a mass of acid and chitin.</span>")
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

/obj/item/clothing/mask/facehugger/flamer_fire_act()
	kill_hugger()

/obj/item/clothing/mask/facehugger/dropped(mob/user)
	. = ..()
	go_idle()

/obj/item/clothing/mask/facehugger/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID) || CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_NEURO))
		go_idle()

/obj/item/clothing/mask/facehugger/dropped(mob/user)
	. = ..()
	go_idle()

/obj/item/clothing/mask/facehugger/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID) || CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_NEURO))
		go_idle()

/////////////////////////////
// SUBTYPES
/////////////////////////////
/obj/item/clothing/mask/facehugger/stasis
	stat = UNCONSCIOUS
	stasis = TRUE

/obj/item/clothing/mask/facehugger/stasis/Initialize()
	. = ..()
	update_icon()


/obj/item/clothing/mask/facehugger/dead
	desc = "It has some sort of a tube at the end of its tail. What the hell is this thing?"
	name = "????"
	stat = DEAD
	sterile = TRUE

/obj/item/clothing/mask/facehugger/dead/Initialize()
	. = ..()
	update_icon()

#undef FACEHUGGER_DEATH
#undef JUMP_COOLDOWN
#undef ACTIVATE_TIME
#undef IMPREGNATION_TIME
