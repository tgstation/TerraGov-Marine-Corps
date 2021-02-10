//Some debug variables. Uncomment in order to see the related debug messages. Helpful when testing out formulas.
//#ifdef TESTING
//	#define DEBUG_HIVELORD_ABILITIES
//#endif

// ***************************************
// *********** Resin building
// ***************************************
/datum/action/xeno_action/choose_resin/hivelord
	buildable_structures = list(
		/turf/closed/wall/resin/regenerating/thick,
		/obj/structure/bed/nest,
		/obj/effect/alien/resin/sticky,
		/obj/structure/mineral_door/resin/thick,
	)

/datum/action/xeno_action/activable/secrete_resin/hivelord
	plasma_cost = 100

GLOBAL_LIST_INIT(thickenable_resin, typecacheof(list(
	/turf/closed/wall/resin,
	/turf/closed/wall/resin/membrane,
	/obj/structure/mineral_door/resin), FALSE, TRUE))

/datum/action/xeno_action/activable/secrete_resin/hivelord/use_ability(atom/A)
	if(get_dist(owner, A) != 1)
		return ..()

	return build_resin(get_turf(A)) // TODO: (psykzz)

	// if(!is_type_in_typecache(A, GLOB.thickenable_resin))
	// 	return build_resin(get_turf(A))

	// if(istype(A, /turf/closed/wall/resin))
	// 	var/turf/closed/wall/resin/WR = A
	// 	var/oldname = WR.name
	// 	if(WR.thicken())
	// 		owner.visible_message("<span class='xenonotice'>\The [owner] regurgitates a thick substance and thickens [oldname].</span>","<span class='xenonotice'>You regurgitate some resin and thicken [oldname].</span>", null, 5)
	// 		playsound(owner.loc, "alien_resin_build", 25)
	// 		return succeed_activate()
	// 	to_chat(owner, "<span class='xenowarning'>[WR] can't be made thicker.</span>")
	// 	return fail_activate()

	// if(istype(A, /obj/structure/mineral_door/resin))
	// 	var/obj/structure/mineral_door/resin/DR = A
	// 	var/oldname = DR.name
	// 	if(DR.thicken())
	// 		owner.visible_message("<span class='xenonotice'>\The [owner] regurgitates a thick substance and thickens [oldname].</span>", "<span class='xenonotice'>We regurgitate some resin and thicken [oldname].</span>", null, 5)
	// 		playsound(owner.loc, "alien_resin_build", 25)
	// 		return succeed_activate()
	// 	to_chat(owner, "<span class='xenowarning'>[DR] can't be made thicker.</span>")
	// 	return fail_activate()
	// return fail_activate() //will never be reached but failsafe

// ***************************************
// *********** Resin walker
// ***************************************
/datum/action/xeno_action/toggle_speed
	name = "Resin Walker"
	action_icon_state = "toggle_speed"
	mechanics_text = "Move faster on resin."
	plasma_cost = 50
	keybind_signal = COMSIG_XENOABILITY_RESIN_WALKER
	var/speed_activated = FALSE
	var/speed_bonus_active = FALSE

/datum/action/xeno_action/toggle_speed/remove_action()
	resinwalk_off(TRUE) // Ensure we remove the movespeed
	return ..()

/datum/action/xeno_action/toggle_speed/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(speed_activated)
		return TRUE

/datum/action/xeno_action/toggle_speed/action_activate()
	if(speed_activated)
		resinwalk_off()
		return fail_activate()
	resinwalk_on()
	succeed_activate()


/datum/action/xeno_action/toggle_speed/proc/resinwalk_on(silent = FALSE)
	var/mob/living/carbon/xenomorph/walker = owner
	speed_activated = TRUE
	if(!silent)
		to_chat(owner, "<span class='notice'>We become one with the resin. We feel the urge to run!</span>")
	if(locate(/obj/effect/alien/weeds) in walker.loc)
		speed_bonus_active = TRUE
		walker.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, -1.5)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/resinwalk_on_moved)


/datum/action/xeno_action/toggle_speed/proc/resinwalk_off(silent = FALSE)
	var/mob/living/carbon/xenomorph/walker = owner
	if(!silent)
		to_chat(owner, "<span class='warning'>We feel less in tune with the resin.</span>")
	if(speed_bonus_active)
		walker.remove_movespeed_modifier(type)
		speed_bonus_active = FALSE
	speed_activated = FALSE
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)


/datum/action/xeno_action/toggle_speed/proc/resinwalk_on_moved(datum/source, atom/oldloc, direction, Forced = FALSE)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/walker = owner
	if(!isturf(walker.loc) || !walker.check_plasma(10, TRUE))
		to_chat(owner, "<span class='warning'>We feel dizzy as the world slows down.</span>")
		resinwalk_off(TRUE)
		return
	if(locate(/obj/effect/alien/weeds) in walker.loc)
		if(!speed_bonus_active)
			speed_bonus_active = TRUE
			walker.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, -1.5)
		walker.use_plasma(10)
		return
	if(!speed_bonus_active)
		return
	speed_bonus_active = FALSE
	walker.remove_movespeed_modifier(type)


// ***************************************
// *********** Tunnel
// ***************************************
/datum/action/xeno_action/build_tunnel
	name = "Dig Tunnel"
	action_icon_state = "build_tunnel"
	mechanics_text = "Create a tunnel entrance. Use again to create the tunnel exit."
	plasma_cost = 200
	cooldown_timer = 120 SECONDS
	keybind_signal = COMSIG_XENOABILITY_BUILD_TUNNEL

/datum/action/xeno_action/build_tunnel/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/turf/T = get_turf(owner)
	if(locate(/obj/structure/tunnel) in T)
		if(!silent)
			to_chat(owner, "<span class='warning'>There already is a tunnel here.</span>")
		return
	if(!T.can_dig_xeno_tunnel())
		if(!silent)
			to_chat(owner, "<span class='warning'>We scrape around, but we can't seem to dig through that kind of floor.</span>")
		return FALSE
	if(owner.get_active_held_item())
		if(!silent)
			to_chat(owner, "<span class='warning'>We need an empty claw for this!</span>")
		return FALSE

/datum/action/xeno_action/build_tunnel/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, "<span class='notice'>We are ready to dig a tunnel again.</span>")
	return ..()

/datum/action/xeno_action/build_tunnel/action_activate()
	var/turf/T = get_turf(owner)

	owner.visible_message("<span class='xenonotice'>[owner] begins digging out a tunnel entrance.</span>", \
	"<span class='xenonotice'>We begin digging out a tunnel entrance.</span>", null, 5)
	if(!do_after(owner, HIVELORD_TUNNEL_DIG_TIME, TRUE, T, BUSY_ICON_BUILD))
		to_chat(owner, "<span class='warning'>Our tunnel caves in as we stop digging it.</span>")
		return fail_activate()

	if(!can_use_action(TRUE))
		return fail_activate()

	var/mob/living/carbon/xenomorph/hivelord/X = owner
	X.visible_message("<span class='xenonotice'>\The [X] digs out a tunnel entrance.</span>", \
	"<span class='xenonotice'>We dig out a tunnel, connecting it to our network.</span>", null, 5)
	var/obj/structure/tunnel/newt = new(T)

	playsound(T, 'sound/weapons/pierce.ogg', 25, 1)


	newt.creator = X

	X.tunnels.Add(newt)

	add_cooldown()

	to_chat(X, "<span class='xenonotice'>We now have <b>[LAZYLEN(X.tunnels)] of [HIVELORD_TUNNEL_SET_LIMIT]</b> tunnels.</span>")

	var/msg = stripped_input(X, "Give your tunnel a descriptive name:", "Tunnel Name")
	newt.tunnel_desc = "[get_area(newt)] (X: [newt.x], Y: [newt.y])"
	newt.name += " [msg]"

	xeno_message("<span class='xenoannounce'>[X.name] has built a new tunnel named [newt.name] at [newt.tunnel_desc]!</span>", 2, X.hivenumber)

	if(LAZYLEN(X.tunnels) > HIVELORD_TUNNEL_SET_LIMIT) //if we exceed the limit, delete the oldest tunnel set.
		var/obj/structure/tunnel/old_tunnel = X.tunnels[1]
		old_tunnel.deconstruct(FALSE)
		to_chat(X, "<span class='xenodanger'>Having exceeding our tunnel limit, our oldest tunnel has collapsed.</span>")

	succeed_activate()
	playsound(T, 'sound/weapons/pierce.ogg', 25, 1)



// ***************************************
// *********** plasma transfer
// ***************************************
/datum/action/xeno_action/activable/transfer_plasma/improved
	plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT * 4
	transfer_delay = 0.5 SECONDS
	max_range = 7


/datum/action/xeno_action/place_jelly_pod
	name = "Place Resin Jelly pod"
	action_icon_state = "haunt"
	mechanics_text = "Place down a dispenser that allows xenos to retrieve fireproof jelly."
	plasma_cost = 500
	cooldown_timer = 3 MINUTES
	keybind_signal = COMSIG_XENOABILITY_PLACE_JELLY_POD

/datum/action/xeno_action/place_jelly_pod/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!T || !T.is_weedable() || T.density)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do that here.</span>")
		return FALSE

	if(!(locate(/obj/effect/alien/weeds) in T))
		if(!silent)
			to_chat(owner, "<span class='warning'>We can only shape on weeds. We must find some resin before we start building!</span>")
		return FALSE

	if(!T.check_disallow_alien_fortification(owner, silent))
		return FALSE

	if(!T.check_alien_construction(owner, silent))
		return FALSE

	if(locate(/obj/effect/alien/weeds/node) in T)
		if(!silent)
			to_chat(owner, "<span class='warning'>There is a resin node in the way!</span>")
		return FALSE

/datum/action/xeno_action/place_jelly_pod/action_activate()
	var/turf/T = get_turf(owner)

	succeed_activate()

	playsound(T, "alien_resin_build", 25)
	var/obj/structure/resin_jelly_pod/pod = new(T)
	to_chat(owner, "<span class='xenonotice'>We shape some resin into \a [pod].</span>")

/datum/action/xeno_action/create_jelly
	name = "Create Resin Jelly"
	action_icon_state = "gut"
	mechanics_text = "Create a fireproof jelly."
	plasma_cost = 100
	cooldown_timer = 1 MINUTES
	keybind_signal = COMSIG_XENOABILITY_CREATE_JELLY

/datum/action/xeno_action/create_jelly/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(owner.l_hand || owner.r_hand)
		if(!silent)
			to_chat(owner, "<span class='xenonotice'>We require free hands for this!</span>")
		return FALSE

/datum/action/xeno_action/create_jelly/action_activate()
	var/obj/item/resin_jelly/jelly = new(owner.loc)
	owner.put_in_hands(jelly)
	to_chat(owner, "<span class='xenonotice'>We create a globule of resin from our ovipostor.</span>")
	succeed_activate()

// ***************************************
// *********** Healing Infusion
// ***************************************
/datum/action/xeno_action/activable/healing_infusion
	name = "Healing Infusion"
	action_icon_state = "healing_infusion"
	mechanics_text = "Psychically infuses a friendly xeno with regenerative energies, greatly improving its natural healing. Doesn't work if the target can't naturally heal."
	cooldown_timer = 30 SECONDS
	plasma_cost = 200
	keybind_signal = COMSIG_XENOABILITY_HEALING_INFUSION
	var/heal_range = HIVELORD_HEAL_RANGE
	var/health_ticks_remaining = 0 //Buff ends whenever we run out of either health or sunder ticks, or time, whichever comes first
	var/sunder_ticks_remaining = 0
	///timer ID we can reference and delete old timers during clean up
	var/timer_id

/datum/action/xeno_action/activable/healing_infusion/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return

	if(!isxeno(target))
		if(!silent)
			to_chat(owner, "<span class='warning'>We can only target fellow sisters with [src]!</span>")
		return FALSE
	var/mob/living/carbon/xenomorph/patient = target

	if(!CHECK_BITFIELD(use_state_flags|override_flags, XACT_IGNORE_DEAD_TARGET) && patient.stat == DEAD)
		if(!silent)
			to_chat(owner, "<span class='warning'>It's too late. This sister won't be coming back.</span>")
		return FALSE

	if(!check_distance(target, silent))
		return FALSE

	if(patient.infusion_active)
		if(!silent)
			to_chat(owner, "<span class='warning'>[patient] is already benefitting from our [src]!</span>")
		return FALSE


/datum/action/xeno_action/activable/healing_infusion/proc/check_distance(atom/target, silent)
	var/dist = get_dist(owner, target)
	if(dist > heal_range)
		if(!silent)
			to_chat(owner, "<span class='warning'>Too far for our reach... We need to be [dist - heal_range] steps closer!</span>")
		return FALSE
	else if(!owner.line_of_sight(target))
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't focus properly without a clear line of sight!</span>")
		return FALSE
	return TRUE


/datum/action/xeno_action/activable/healing_infusion/use_ability(atom/target)
	if(owner.action_busy)
		return FALSE

	owner.face_atom(target) //Face the target so we don't look stupid

	owner.visible_message("<span class='xenodanger'>\the [owner] infuses [target] with mysterious energy!</span>", \
	"<span class='xenodanger'>We empower [target] with our [src]!</span>")

	playsound(target, 'sound/effects/magic.ogg', 25) //Cool SFX
	playsound(owner, 'sound/effects/magic.ogg', 25) //Cool SFX
	owner.beam(target,"medbeam",'icons/effects/beam.dmi',10, 10,/obj/effect/ebeam,1)
	new /obj/effect/temp_visual/telekinesis(get_turf(owner))
	new /obj/effect/temp_visual/telekinesis(get_turf(target))
	to_chat(target, "<span class='xenodanger'>Our wounds begin to knit and heal rapidly as [owner]'s healing energies infuse us.</span>") //Let the target know.

	var/mob/living/carbon/xenomorph/patient = target

	patient.add_filter("hivelord_healing_infusion_outline", 3, outline_filter(1, COLOR_VERY_PALE_LIME_GREEN)) //Set our cool aura; also confirmation we have the buff

	patient.infusion_active = TRUE //Indicate the infusion as being active

	health_ticks_remaining = HIVELORD_HEALING_INFUSION_TICKS
	sunder_ticks_remaining = HIVELORD_HEALING_INFUSION_TICKS

	timer_id = addtimer(CALLBACK(src, .proc/healing_infusion_deactivate, patient), HIVELORD_HEALING_INFUSION_DURATION, TIMER_STOPPABLE)

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.hivelord_healing_infusions++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "hivelord_healing_infusions")

	RegisterSignal(patient, COMSIG_XENOMORPH_HEALTH_REGEN, .proc/healing_infusion_regeneration) //Register so we apply the effect whenever the target heals
	RegisterSignal(patient, COMSIG_XENOMORPH_SUNDER_REGEN, .proc/healing_infusion_sunder_regeneration) //Register so we apply the effect whenever the target heals


///Called when the target xeno regains HP via heal_wounds in life.dm
/datum/action/xeno_action/activable/healing_infusion/proc/healing_infusion_regeneration(datum/source, mob/living/carbon/xenomorph/patient)
	SIGNAL_HANDLER

	if(!patient.infusion_active || !health_ticks_remaining)
		#ifdef DEBUG_HIVELORD_ABILITIES
		message_admins("<span class='danger'>HIVELORD_ABILITIES_DEBUG: healing_infusion_regeneration depleted. Infusion Status: [patient.infusion_active], Health Stacks: [health_ticks_remaining]</span>")
		#endif
		healing_infusion_deactivate(patient) //if we somehow lose the buff or run out of ticks; maybe there's a purge mechanic later, whatever
		return

	health_ticks_remaining-- //Decrement health ticks

	#ifdef DEBUG_HIVELORD_ABILITIES
	message_admins("<span class='danger'>HIVELORD_ABILITIES_DEBUG: healing_infusion_regeneration triggered successfully. Patient: [patient], Health Stacks: [health_ticks_remaining]</span>")
	#endif

	new /obj/effect/temp_visual/healing(get_turf(patient)) //Cool SFX

	var/total_heal_amount = 25 //Base amount 25 HP on our target.
	if(patient.recovery_aura)
		total_heal_amount *= (1 + patient.recovery_aura * 0.05) //Recovery aura multiplier; 5% bonus per full level

	#ifdef DEBUG_HIVELORD_ABILITIES
	message_admins("<span class='danger'>HIVELORD_ABILITIES_DEBUG: Healing pool from Healing Infusion Pre-Brute, Pre-Burn: [total_heal_amount]</span>")
	#endif

	//Healing pool has been calculated; now to decrement it
	var/brute_amount = min(patient.bruteloss, total_heal_amount)
	if(brute_amount)
		patient.adjustBruteLoss(-brute_amount, updating_health = TRUE)
		total_heal_amount = max(0, total_heal_amount - brute_amount) //Decrement from our heal pool the amount of brute healed

	#ifdef DEBUG_HIVELORD_ABILITIES
	message_admins("<span class='danger'>HIVELORD_ABILITIES_DEBUG: Healing pool from Healing Infusion Post-Brute, Pre-Burn: [total_heal_amount]</span>")
	#endif
	if(!total_heal_amount) //no healing left, no need to continue
		return

	var/burn_amount = min(patient.fireloss, total_heal_amount)
	if(burn_amount)
		patient.adjustFireLoss(-burn_amount, updating_health = TRUE)

	#ifdef DEBUG_HIVELORD_ABILITIES
	message_admins("<span class='danger'>HIVELORD_ABILITIES_DEBUG: Healing pool from Healing Infusion Post-Brute, Post-Burn: [max(0, total_heal_amount - burn_amount)]</span>")
	#endif

///Called when the target xeno regains Sunder via heal_wounds in life.dm
/datum/action/xeno_action/activable/healing_infusion/proc/healing_infusion_sunder_regeneration(datum/source, mob/living/carbon/xenomorph/patient)
	SIGNAL_HANDLER

	if(!patient.infusion_active || !sunder_ticks_remaining)
		#ifdef DEBUG_HIVELORD_ABILITIES
		message_admins("<span class='danger'>HIVELORD_ABILITIES_DEBUG: healing_infusion_sunder_regeneration depleted. Infusion Status: [patient.infusion_active], Sunder Stacks: [sunder_ticks_remaining]</span>")
		#endif
		healing_infusion_deactivate(patient) //if we somehow lose the buff or run out of ticks; maybe there's a purge mechanic later, whatever
		return

	sunder_ticks_remaining-- //Decrement sunder ticks

	#ifdef DEBUG_HIVELORD_ABILITIES
	message_admins("HIVELORD_ABILITIES_DEBUG: healing_infusion_sunder_regeneration triggered successfully. Patient: [patient], Sunder Stacks: [sunder_ticks_remaining]")
	#endif

	new /obj/effect/temp_visual/telekinesis(get_turf(patient)) //Visual confirmation

	patient.adjust_sunder(-3 * (0.5 + patient.recovery_aura * 0.05)) //5% bonus per rank of our recovery aura
	#ifdef DEBUG_HIVELORD_ABILITIES
	message_admins("HIVELORD_ABILITIES_DEBUG: Sunder reduction from Healing Infusion: [-3 * (1 + patient.recovery_aura * 0.1)]")
	#endif


///Called when the duration of healing infusion lapses
/datum/action/xeno_action/activable/healing_infusion/proc/healing_infusion_deactivate(mob/living/carbon/xenomorph/patient)

	UnregisterSignal(patient, list(COMSIG_XENOMORPH_HEALTH_REGEN, COMSIG_XENOMORPH_SUNDER_REGEN)) //unregister the signals; party's over

	patient.remove_filter("hivelord_healing_infusion_outline") //Remove the aura

	health_ticks_remaining = 0 //Null vars
	sunder_ticks_remaining = 0
	deltimer(timer_id) //Get rid of the timer so we don't have subsequent timer mismatches
	timer_id = null

	patient.infusion_active = FALSE

	new /obj/effect/temp_visual/telekinesis(get_turf(patient)) //Wearing off SFX
	new /obj/effect/temp_visual/healing(get_turf(patient)) //Wearing off SFX

	to_chat(patient, "<span class='xenodanger'>We are no longer benefitting from [src].</span>") //Let the target know
	patient.playsound_local(patient, 'sound/voice/hiss5.ogg', 25)

	#ifdef DEBUG_HIVELORD_ABILITIES
	message_admins("HIVELORD_ABILITIES_DEBUG: healing_infusion_deactivate: Infusion Status: [patient.infusion_active]")
	#endif

