// ***************************************
// *********** Hive message
// ***************************************
/datum/action/xeno_action/hive_message
	name = "Hive Message" // Also known as Word of Queen.
	action_icon_state = "queen_order"
	desc = "Announces a message to the hive."
	plasma_cost = 50
	cooldown_timer = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_QUEEN_HIVE_MESSAGE,
	)
	use_state_flags = XACT_USE_LYING

//Parameters used when displaying hive message to all xenos
/atom/movable/screen/text/screen_text/queen_order
	maptext_height = 128 //Default 64 doubled in height
	maptext_width = 456 //Default 480 shifted right by 12
	maptext_x = 12 //Half of 24
	maptext_y = -64 //Shifting expanded map text downwards to display below buttons.
	screen_loc = "LEFT,TOP-3"

	letters_per_update = 2
	fade_out_delay = 5 SECONDS
	style_open = "<span class='maptext' style=font-size:16pt;text-align:center valign='top'>"
	style_close = "</span>"

/datum/action/xeno_action/hive_message/action_activate()
	var/mob/living/carbon/xenomorph/queen/Q = owner

	//Preferring the use of multiline input as the message box is larger and easier to quickly proofread before sending to hive.
	var/input = stripped_multiline_input(Q, "Maximum message length: [MAX_BROADCAST_LEN]", "Hive Message", "", MAX_BROADCAST_LEN, TRUE)
	//Newlines are of course stripped and replaced with a space.
	input = capitalize(trim(replacetext(input, "\n", " ")))
	if(!input)
		return
	if(CHAT_FILTER_CHECK(input))
		to_chat(Q, span_warning("That announcement contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[input]\"</span>"))
		SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		return FALSE
	if(NON_ASCII_CHECK(input))
		to_chat(Q, span_warning("That announcement contained characters prohibited in IC chat! Consider reviewing the server rules."))
		return FALSE

	log_game("[key_name(Q)] has messaged the hive with: \"[input]\"")
	deadchat_broadcast(" has messaged the hive: \"[input]\"", Q, Q)
	var/queens_word = "<span class='maptext' style=font-size:18pt;text-align:center valign='top'><u>HIVE MESSAGE:</u><br></span>" + input

	var/sound/queen_sound = sound(get_sfx("queen"), channel = CHANNEL_ANNOUNCEMENTS)
	for(var/mob/living/carbon/xenomorph/X AS in Q.hive.get_all_xenos())
		SEND_SOUND(X, queen_sound)
		//Display the queen's hive message at the top of the game screen.
		X.play_screen_text(queens_word, /atom/movable/screen/text/screen_text/queen_order)
		//In case in combat, couldn't read fast enough, or needs to copy paste into a translator. Here's the old hive message.
		to_chat(X, span_xenoannounce("<h2 class='alert'>The words of the queen reverberate in your head...</h2><br>[span_alert(input)]<br><br>"))

	succeed_activate()
	add_cooldown()


// ***************************************
// *********** Screech
// ***************************************

#define SCREECH_RANGE 7
#define SCREECH_ANGLE 90
#define SCREECH_SPEED 0.5 //Simulates soundwave propagation, looks cool
#define SCREECH_DAMAGE 140
/datum/action/xeno_action/activable/screech
	name = "Screech"
	action_icon_state = "screech"
	desc = "A large area knockdown that causes pain and screen-shake."
	ability_name = "screech"
	plasma_cost = 5 //TEST VALUE
	cooldown_timer = 5 SECONDS //TEST VALUE PLEASE REMEMBER TO BALANCE AFTER CODE WORKS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SCREECH,
	)

/datum/action/xeno_action/activable/screech/on_cooldown_finish()
	to_chat(owner, span_warning("We feel our throat muscles vibrate. We are ready to screech again."))
	return ..()

/datum/action/xeno_action/activable/screech/use_ability(atom/target)
	if(!target)
		return
	owner.dir = get_cardinal_dir(owner, target)
	var/mob/living/carbon/xenomorph/queen/X = owner

	playsound(X.loc, 'sound/voice/alien_queen_screech.ogg', 75, 0)
	X.visible_message(span_xenohighdanger("\The [X] emits an ear-splitting guttural roar!"))
	GLOB.round_statistics.queen_screech++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "queen_screech")
	X.create_shriekwave() //Adds the visual effect. Wom wom wom
	//stop_momentum(charge_dir) //Screech kills a charge

	var/source = get_turf(owner)
	var/dir_to_target = Get_Angle(source, target)
	var/list/turf/turfs_to_screech = generate_true_cone(source, SCREECH_RANGE, 1, SCREECH_ANGLE, dir_to_target, bypass_xeno = TRUE, air_pass = TRUE)
	execute_attack(1, turfs_to_screech, SCREECH_DAMAGE, target, source)

	succeed_activate()
	add_cooldown()

/datum/action/xeno_action/activable/screech/proc/execute_attack(iteration, list/turf/turfs_to_screech, range, target, turf/source)
	if(iteration > range)
		return

	for(var/turf/turf AS in turfs_to_screech)
		if(get_dist(turf, source) == iteration)
			attack_turf(turf, LERP(1, 0.4, iteration / SCREECH_RANGE)) //Severity decreases by 10% per tile away from adjacency.

	iteration++
	addtimer(CALLBACK(src, .proc/execute_attack, iteration, turfs_to_screech, range, target, source), SCREECH_SPEED)

/datum/action/xeno_action/activable/screech/proc/attack_turf(turf/turf_victim, severity)
	new /obj/effect/temp_visual/screech(turf_victim)
	for(var/victim in turf_victim)
		if(iscarbon(victim))
			var/mob/living/carbon/carbon_victim = victim
			if(carbon_victim.stat == DEAD || isxeno(carbon_victim))
				continue
			//Hearing damage check
			if(ishuman(carbon_victim))
				var/mob/living/carbon/human/H = carbon_victim
				if(!istype(H.wear_ear, /obj/item/clothing/ears/earmuffs))
					carbon_victim.adjust_ear_damage(10 * severity, 10 * severity)
			carbon_victim.apply_damage(SCREECH_DAMAGE * severity, STAMINA)
			carbon_victim.adjust_stagger(15 * severity)
			carbon_victim.add_slowdown(15 * severity)
			shake_camera(carbon_victim, 3 SECONDS * severity, 3 * severity)
		//Screech is so loud it breaks glass
		else if(istype(victim, /obj/structure/window))
			var/obj/structure/window/window_victim = victim
			if(window_victim.damageable)
				window_victim.ex_act(EXPLODE_DEVASTATE)

/obj/effect/temp_visual/screech //Placeholder
	name = "shattering_roar"
	icon = 'icons/effects/effects.dmi'
	duration = 4

/obj/effect/temp_visual/screech/Initialize()  //Placeholder
	. = ..()
	flick("smash", src)

/datum/action/xeno_action/activable/screech/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/screech/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > 4)
		return FALSE
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

// ***************************************
// *********** Overwatch
// ***************************************
/datum/action/xeno_action/watch_xeno
	name = "Watch Xenomorph"
	action_icon_state = "watch_xeno"
	desc = "See from the target Xenomorphs vision. Click again the ability to stop observing"
	plasma_cost = 0
	use_state_flags = XACT_USE_LYING
	var/overwatch_active = FALSE

/datum/action/xeno_action/watch_xeno/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_MOB_DEATH, .proc/on_owner_death)
	RegisterSignal(L, COMSIG_XENOMORPH_WATCHXENO, .proc/on_list_xeno_selection)

/datum/action/xeno_action/watch_xeno/remove_action(mob/living/L)
	if(overwatch_active)
		stop_overwatch()
	UnregisterSignal(L, list(COMSIG_MOB_DEATH, COMSIG_XENOMORPH_WATCHXENO))
	return ..()

/datum/action/xeno_action/watch_xeno/should_show()
	return FALSE // Overwatching now done through hive status UI!

/datum/action/xeno_action/watch_xeno/proc/start_overwatch(mob/living/carbon/xenomorph/target)
	if(!can_use_action()) // Check for action now done here as action_activate pipeline has been bypassed with signal activation.
		return

	var/mob/living/carbon/xenomorph/watcher = owner
	var/mob/living/carbon/xenomorph/old_xeno = watcher.observed_xeno
	if(old_xeno == target)
		stop_overwatch(TRUE)
		return
	if(old_xeno)
		stop_overwatch(FALSE)
	watcher.observed_xeno = target
	if(isxenoqueen(watcher)) // Only queen needs the eye shown.
		target.hud_set_queen_overwatch()
	watcher.reset_perspective()
	RegisterSignal(target, COMSIG_HIVE_XENO_DEATH, .proc/on_xeno_death)
	RegisterSignal(target, list(COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED), .proc/on_xeno_evolution)
	RegisterSignal(watcher, COMSIG_MOVABLE_MOVED, .proc/on_movement)
	RegisterSignal(watcher, COMSIG_XENOMORPH_TAKING_DAMAGE, .proc/on_damage_taken)
	overwatch_active = TRUE
	set_toggle(TRUE)

/datum/action/xeno_action/watch_xeno/proc/stop_overwatch(do_reset_perspective = TRUE)
	var/mob/living/carbon/xenomorph/watcher = owner
	var/mob/living/carbon/xenomorph/observed = watcher.observed_xeno
	watcher.observed_xeno = null
	if(!QDELETED(observed))
		UnregisterSignal(observed, list(COMSIG_HIVE_XENO_DEATH, COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED))
		if(isxenoqueen(watcher)) // Only queen has to reset the eye overlay.
			observed.hud_set_queen_overwatch()
	if(do_reset_perspective)
		watcher.reset_perspective()
	UnregisterSignal(watcher, list(COMSIG_MOVABLE_MOVED, COMSIG_XENOMORPH_TAKING_DAMAGE))
	overwatch_active = FALSE
	set_toggle(FALSE)

/datum/action/xeno_action/watch_xeno/proc/on_list_xeno_selection(datum/source, mob/living/carbon/xenomorph/selected_xeno)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/start_overwatch, selected_xeno)

/datum/action/xeno_action/watch_xeno/proc/on_xeno_evolution(datum/source, mob/living/carbon/xenomorph/new_xeno)
	SIGNAL_HANDLER
	start_overwatch(new_xeno)

/datum/action/xeno_action/watch_xeno/proc/on_xeno_death(datum/source, mob/living/carbon/xenomorph/dead_xeno)
	SIGNAL_HANDLER
	if(overwatch_active)
		stop_overwatch()

/datum/action/xeno_action/watch_xeno/proc/on_owner_death(mob/source, gibbing)
	SIGNAL_HANDLER
	if(overwatch_active)
		stop_overwatch()

/datum/action/xeno_action/watch_xeno/proc/on_movement(datum/source, atom/oldloc, direction, Forced)
	SIGNAL_HANDLER
	if(overwatch_active)
		stop_overwatch()

/datum/action/xeno_action/watch_xeno/proc/on_damage_taken(datum/source, damage)
	SIGNAL_HANDLER
	if(overwatch_active)
		stop_overwatch()


// ***************************************
// *********** Queen zoom
// ***************************************
/datum/action/xeno_action/toggle_queen_zoom
	name = "Toggle Queen Zoom"
	action_icon_state = "toggle_queen_zoom"
	desc = "Zoom out for a larger view around wherever you are looking."
	plasma_cost = 0
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOGGLE_QUEEN_ZOOM,
	)


/datum/action/xeno_action/toggle_queen_zoom/action_activate()
	var/mob/living/carbon/xenomorph/queen/xeno = owner
	if(xeno.do_actions)
		return
	if(xeno.is_zoomed)
		zoom_xeno_out(xeno.observed_xeno ? FALSE : TRUE)
		return
	if(!do_after(xeno, 1 SECONDS, FALSE, null, BUSY_ICON_GENERIC) || xeno.is_zoomed)
		return
	zoom_xeno_in(xeno.observed_xeno ? FALSE : TRUE) //No need for feedback message if our eye is elsewhere.


/datum/action/xeno_action/toggle_queen_zoom/proc/zoom_xeno_in(message = TRUE)
	var/mob/living/carbon/xenomorph/xeno = owner
	RegisterSignal(xeno, COMSIG_MOVABLE_MOVED, .proc/on_movement)
	if(message)
		xeno.visible_message(span_notice("[xeno] emits a broad and weak psychic aura."),
		span_notice("We start focusing our psychic energy to expand the reach of our senses."), null, 5)
	xeno.zoom_in(0, 12)


/datum/action/xeno_action/toggle_queen_zoom/proc/zoom_xeno_out(message = TRUE)
	var/mob/living/carbon/xenomorph/xeno = owner
	UnregisterSignal(xeno, COMSIG_MOVABLE_MOVED)
	if(message)
		xeno.visible_message(span_notice("[xeno] stops emitting its broad and weak psychic aura."),
		span_notice("We stop the effort of expanding our senses."), null, 5)
	xeno.zoom_out()


/datum/action/xeno_action/toggle_queen_zoom/proc/on_movement(datum/source, atom/oldloc, direction, Forced)
	zoom_xeno_out()


// ***************************************
// *********** Set leader
// ***************************************
/datum/action/xeno_action/set_xeno_lead
	name = "Choose/Follow Xenomorph Leaders"
	action_icon_state = "xeno_lead"
	desc = "Make a target Xenomorph a leader."
	plasma_cost = 200
	use_state_flags = XACT_USE_LYING

/datum/action/xeno_action/set_xeno_lead/should_show()
	return FALSE // Leadership now set through hive status UI!

/datum/action/xeno_action/set_xeno_lead/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_XENOMORPH_LEADERSHIP, .proc/try_use_action)

/datum/action/xeno_action/set_xeno_lead/remove_action(mob/living/L)
	. = ..()
	UnregisterSignal(L, COMSIG_XENOMORPH_LEADERSHIP)

/// Signal handler for the set_xeno_lead action that checks can_use
/datum/action/xeno_action/set_xeno_lead/proc/try_use_action(datum/source, mob/living/carbon/xenomorph/target)
	SIGNAL_HANDLER
	if(!can_use_action())
		return
	INVOKE_ASYNC(src, .proc/select_xeno_leader, target)

/// Check if there is an empty slot and promote the passed xeno to a hive leader
/datum/action/xeno_action/set_xeno_lead/proc/select_xeno_leader(mob/living/carbon/xenomorph/selected_xeno)
	var/mob/living/carbon/xenomorph/queen/xeno_ruler = owner

	if(selected_xeno.queen_chosen_lead)
		unset_xeno_leader(selected_xeno)
		return

	if(xeno_ruler.xeno_caste.queen_leader_limit <= length(xeno_ruler.hive.xeno_leader_list))
		xeno_ruler.balloon_alert(xeno_ruler, "No more leadership slots")
		return

	set_xeno_leader(selected_xeno)

/// Remove the passed xeno's leadership
/datum/action/xeno_action/set_xeno_lead/proc/unset_xeno_leader(mob/living/carbon/xenomorph/selected_xeno)
	var/mob/living/carbon/xenomorph/xeno_ruler = owner
	xeno_ruler.balloon_alert(xeno_ruler, "Xeno demoted")
	selected_xeno.balloon_alert(selected_xeno, "Leadership removed")
	selected_xeno.hive.remove_leader(selected_xeno)
	selected_xeno.hud_set_queen_overwatch()
	selected_xeno.handle_xeno_leader_pheromones(xeno_ruler)

	selected_xeno.update_leader_icon(FALSE)

/// Promote the passed xeno to a hive leader, should not be called direct
/datum/action/xeno_action/set_xeno_lead/proc/set_xeno_leader(mob/living/carbon/xenomorph/selected_xeno)
	var/mob/living/carbon/xenomorph/xeno_ruler = owner
	if(!(selected_xeno.xeno_caste.can_flags & CASTE_CAN_BE_LEADER))
		xeno_ruler.balloon_alert(xeno_ruler, "Xeno cannot lead")
		return
	xeno_ruler.balloon_alert(xeno_ruler, "Xeno promoted")
	selected_xeno.balloon_alert(selected_xeno, "Promoted to leader")
	to_chat(selected_xeno, span_xenoannounce("[xeno_ruler] has selected us as a Hive Leader. The other Xenomorphs must listen to us. We will also act as a beacon for the Queen's pheromones."))

	xeno_ruler.hive.add_leader(selected_xeno)
	selected_xeno.hud_set_queen_overwatch()
	selected_xeno.handle_xeno_leader_pheromones(xeno_ruler)
	notify_ghosts("\ [xeno_ruler] has designated [selected_xeno] as a Hive Leader", source = selected_xeno, action = NOTIFY_ORBIT)

	selected_xeno.update_leader_icon(TRUE)

// ***************************************
// *********** Queen Acidic Salve
// ***************************************
/datum/action/xeno_action/activable/psychic_cure/queen_give_heal
	name = "Heal"
	action_icon_state = "heal_xeno"
	desc = "Apply a minor heal to the target."
	cooldown_timer = 5 SECONDS
	plasma_cost = 150
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_QUEEN_HEAL,
	)
	heal_range = HIVELORD_HEAL_RANGE
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/psychic_cure/queen_give_heal/use_ability(atom/target)
	if(owner.do_actions)
		return FALSE
	if(!do_mob(owner, target, 1 SECONDS, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		return FALSE
	target.visible_message(span_xenowarning("\the [owner] vomits acid over [target], mending their wounds!"))
	playsound(target, "alien_drool", 25)
	new /obj/effect/temp_visual/telekinesis(get_turf(target))
	var/mob/living/carbon/xenomorph/patient = target
	patient.salve_healing()
	owner.changeNext_move(CLICK_CD_RANGE)
	succeed_activate()
	add_cooldown()

/// Heals the target.
/mob/living/carbon/xenomorph/proc/salve_healing()
	var/amount = 50
	if(recovery_aura)
		amount += recovery_aura * maxHealth * 0.01
	var/remainder = max(0, amount - getBruteLoss())
	adjustBruteLoss(-amount)
	adjustFireLoss(-remainder, updating_health = TRUE)
	adjust_sunder(-amount/10)

// ***************************************
// *********** Queen plasma
// ***************************************
/datum/action/xeno_action/activable/queen_give_plasma
	name = "Give Plasma"
	action_icon_state = "queen_give_plasma"
	desc = "Give plasma to a target Xenomorph"
	plasma_cost = 150
	cooldown_timer = 8 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_QUEEN_GIVE_PLASMA,
	)
	use_state_flags = XACT_USE_LYING
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/queen_give_plasma/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!isxeno(target))
		return FALSE
	var/mob/living/carbon/xenomorph/receiver = target
	if(!CHECK_BITFIELD(use_state_flags|override_flags, XACT_IGNORE_DEAD_TARGET) && receiver.stat == DEAD)
		if(!silent)
			receiver.balloon_alert(owner, "Cannot give plasma, dead")
		return FALSE
	if(!CHECK_BITFIELD(receiver.xeno_caste.can_flags, CASTE_CAN_BE_GIVEN_PLASMA))
		if(!silent)
			receiver.balloon_alert(owner, "Cannot give plasma")
			return FALSE
	var/mob/living/carbon/xenomorph/giver = owner
	if(giver.z != receiver.z)
		if(!silent)
			receiver.balloon_alert(owner, "Cannot give plasma, too far")
		return FALSE
	if(receiver.plasma_stored >= receiver.xeno_caste.plasma_max)
		if(!silent)
			receiver.balloon_alert(owner, "Cannot give plasma, full")
		return FALSE


/datum/action/xeno_action/activable/queen_give_plasma/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_XENOMORPH_QUEEN_PLASMA, .proc/try_use_ability)

/datum/action/xeno_action/activable/queen_give_plasma/remove_action(mob/living/L)
	. = ..()
	UnregisterSignal(L, COMSIG_XENOMORPH_QUEEN_PLASMA)

/// Signal handler for the queen_give_plasma action that checks can_use
/datum/action/xeno_action/activable/queen_give_plasma/proc/try_use_ability(datum/source, mob/living/carbon/xenomorph/target)
	SIGNAL_HANDLER
	if(!can_use_ability(target, FALSE, XACT_IGNORE_SELECTED_ABILITY))
		return
	use_ability(target)

/datum/action/xeno_action/activable/queen_give_plasma/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/receiver = target
	add_cooldown()
	receiver.gain_plasma(300)
	succeed_activate()
	receiver.balloon_alert_to_viewers("Queen plasma", ignored_mobs = GLOB.alive_human_list)
	if (get_dist(owner, receiver) > 7)
		// Out of screen transfer.
		owner.balloon_alert(owner, "Transferred plasma")

// ***************************************
// *********** Queen deevolve
// ***************************************
/datum/action/xeno_action/deevolve
	name = "De-Evolve a Xenomorph"
	action_icon_state = "xeno_deevolve"
	desc = "De-evolve a target Xenomorph of Tier 2 or higher to the next lowest tier."
	plasma_cost = 600
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DEEVOLVE,
	)
	use_state_flags = XACT_USE_LYING

/datum/action/xeno_action/deevolve/action_activate()
	var/mob/living/carbon/xenomorph/queen/X = owner
	if(!X.observed_xeno)
		X.balloon_alert(X, "Must overwatch to deevolve")
		return

	var/mob/living/carbon/xenomorph/T = X.observed_xeno

	if(T.is_ventcrawling)
		T.balloon_alert(X, "Cannot deevolve, ventcrawling")
		return

	if(!isturf(T.loc))
		T.balloon_alert(X, "Cannot deevolve here")
		return

	if((T.health < T.maxHealth) || (T.plasma_stored < (T.xeno_caste.plasma_max * T.xeno_caste.plasma_regen_limit)))
		T.balloon_alert(X, "Cannot deevolve, too weak")
		return

	if(!T.xeno_caste.deevolves_to)
		T.balloon_alert(X, "Cannot deevolve")
		return

	var/datum/xeno_caste/new_caste = GLOB.xeno_caste_datums[T.xeno_caste.deevolves_to][XENO_UPGRADE_ZERO]

	var/confirm = tgui_alert(X, "Are you sure you want to deevolve [T] from [T.xeno_caste.caste_name] to [new_caste.caste_name]?", null, list("Yes", "No"))
	if(confirm != "Yes")
		return

	var/reason = stripped_input(X, "Provide a reason for deevolving this xenomorph, [T]")
	if(isnull(reason))
		T.balloon_alert(X, "De-evolution reason required")
		return

	if(!X.check_concious_state() || X.observed_xeno != T)
		return

	if(T.is_ventcrawling)
		return

	if(!isturf(T.loc))
		return

	if((T.health < T.maxHealth) || (T.plasma_stored < (T.xeno_caste.plasma_max * T.xeno_caste.plasma_regen_limit)))
		return

	T.balloon_alert(T, "Queen deevolution")
	to_chat(T, span_xenowarning("The Queen deevolved us for the following reason: [reason]"))

	T.do_evolve(new_caste.caste_type_path, new_caste.caste_name, TRUE)

	log_game("[key_name(X)] has deevolved [key_name(T)]. Reason: [reason]")
	message_admins("[ADMIN_TPMONTY(X)] has deevolved [ADMIN_TPMONTY(T)]. Reason: [reason]")

	GLOB.round_statistics.total_xenos_created-- //so an evolved xeno doesn't count as two.
	SSblackbox.record_feedback("tally", "round_statistics", -1, "total_xenos_created")
	qdel(T)
	succeed_activate()
