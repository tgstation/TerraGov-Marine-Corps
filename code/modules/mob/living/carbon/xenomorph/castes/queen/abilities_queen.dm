// ***************************************
// *********** Hive orders
// ***************************************
/mob/living/carbon/xenomorph/queen/proc/set_orders()
	set category = "Alien"
	set name = "Set Hive Orders (50)"
	set desc = "Give some specific orders to the hive. They can see this on the status pane."

	if(hivenumber == XENO_HIVE_CORRUPTED)
		to_chat(src, span_warning("Only our masters can decide this!"))
		return

	if(!check_state())
		return
	if(!check_plasma(50))
		return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_ORDER))
		return
	plasma_stored -= 50
	var/txt = stripped_input(src, "Set the hive's orders to what? Leave blank to clear it.", "Hive Orders")

	if(txt)
		xeno_message("<B>The Queen has given a new order. Check Status panel for details.</B>", "xenoannounce", 6,hivenumber)
		hive.hive_orders = txt
	else
		hive.hive_orders = ""

	TIMER_COOLDOWN_START(src, COOLDOWN_ORDER, 15 SECONDS)

// ***************************************
// *********** Hive message
// ***************************************
/datum/action/xeno_action/hive_message
	name = "Hive Message" // Also known as Word of Queen.
	action_icon_state = "queen_order"
	mechanics_text = "Announces a message to the hive."
	plasma_cost = 50
	keybind_signal = COMSIG_XENOABILITY_QUEEN_HIVE_MESSAGE
	use_state_flags = XACT_USE_LYING

/datum/action/xeno_action/hive_message/action_activate()
	var/mob/living/carbon/xenomorph/queen/xeno = owner
	if(!xeno.check_concious_state())
		to_chat(xeno, span_warning("We can't do that while unconcious."))
		return

	var/input = stripped_multiline_input(xeno, "This message will be broadcast throughout the hive.", "Hive Message", "")
	if(!input)
		return

	if(CHAT_FILTER_CHECK(input))
		to_chat(xeno, span_warning("That announcement contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[input]\"</span>"))
		SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		return FALSE

	var/queensWord = "<br><h2 class='alert'>The words of the queen reverberate in your head...</h2>"
	queensWord += "<br>[span_alert("[input]")]<br><br>"

	INVOKE_ASYNC(xeno, /mob/living/carbon/xenomorph/queen/proc/do_hive_message, queensWord)

/mob/living/carbon/xenomorph/queen/proc/do_hive_message(queensWord)
	var/sound/queen_sound = sound(get_sfx("queen"), channel = CHANNEL_ANNOUNCEMENTS)
	if(SSticker?.mode)
		hive.xeno_message("[queensWord]")
		for(var/i in hive.get_watchable_xenos())
			var/mob/living/carbon/xenomorph/X = i
			SEND_SOUND(X, queen_sound)

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/G = i
		SEND_SOUND(G, queen_sound)
		to_chat(G, "[queensWord]")

	log_game("[key_name(src)] has created a Hive Message: [queensWord]")
	message_admins("[ADMIN_TPMONTY(src)] has created a Hive Message.")


// ***************************************
// *********** Screech
// ***************************************
/datum/action/xeno_action/activable/screech
	name = "Screech"
	action_icon_state = "screech"
	mechanics_text = "A large area knockdown that causes pain and screen-shake."
	ability_name = "screech"
	plasma_cost = 250
	cooldown_timer = 100 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_SCREECH

/datum/action/xeno_action/activable/screech/on_cooldown_finish()
	to_chat(owner, span_warning("We feel our throat muscles vibrate. We are ready to screech again."))
	return ..()

/datum/action/xeno_action/activable/screech/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/queen/X = owner

	//screech is so powerful it kills huggers in our hands
	if(istype(X.r_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = X.r_hand
		if(FH.stat != DEAD)
			FH.kill_hugger()

	if(istype(X.l_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = X.l_hand
		if(FH.stat != DEAD)
			FH.kill_hugger()

	succeed_activate()
	add_cooldown()

	playsound(X.loc, 'sound/voice/alien_queen_screech.ogg', 75, 0)
	X.visible_message(span_xenohighdanger("\The [X] emits an ear-splitting guttural roar!"))
	GLOB.round_statistics.queen_screech++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "queen_screech")
	X.create_shriekwave() //Adds the visual effect. Wom wom wom
	//stop_momentum(charge_dir) //Screech kills a charge

	var/list/nearby_living = list()
	for(var/mob/living/L in hearers(WORLD_VIEW, X))
		nearby_living.Add(L)

	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		if(get_dist(L, X) > WORLD_VIEW_NUM)
			continue
		L.screech_act(X, WORLD_VIEW_NUM, L in nearby_living)

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
	mechanics_text = "See from the target Xenomorphs vision. Click again the ability to stop observing"
	plasma_cost = 0
	keybind_signal = COMSIG_XENOABILITY_WATCH_XENO
	var/overwatch_active = FALSE
	use_state_flags = XACT_USE_LYING


/datum/action/xeno_action/watch_xeno/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_MOB_DEATH, .proc/on_owner_death)
	RegisterSignal(L, COMSIG_XENOMORPH_WATCHXENO, .proc/on_list_xeno_selection)
	RegisterSignal(L, COMSIG_CLICK_CTRL_MIDDLE, .proc/on_ctrl_middle_click)


/datum/action/xeno_action/watch_xeno/remove_action(mob/living/L)
	if(overwatch_active)
		stop_overwatch()
	UnregisterSignal(L, list(COMSIG_MOB_DEATH, COMSIG_XENOMORPH_WATCHXENO, COMSIG_CLICK_CTRL_MIDDLE))
	return ..()


/datum/action/xeno_action/watch_xeno/action_activate()
	if(overwatch_active)
		stop_overwatch()
		remove_selected_frame()
		return
	add_selected_frame()
	select_xeno()


/datum/action/xeno_action/watch_xeno/proc/select_xeno(mob/living/carbon/xenomorph/selected_xeno)
	var/mob/living/carbon/xenomorph/queen/X = owner
	if(!X.hive)
		return

	if(QDELETED(selected_xeno))
		var/list/possible_xenos = X.hive.get_watchable_xenos()

		selected_xeno = tgui_input_list(X, "Target", "Watch which xenomorph?", possible_xenos)
		if(QDELETED(selected_xeno) || selected_xeno == X.observed_xeno || selected_xeno.stat == DEAD || is_centcom_level(selected_xeno.z))
			if(!X.observed_xeno)
				return
			stop_overwatch()
			return

	start_overwatch(selected_xeno)


/datum/action/xeno_action/watch_xeno/proc/start_overwatch(mob/living/carbon/xenomorph/target)
	var/mob/living/carbon/xenomorph/queen/watcher = owner
	var/mob/living/carbon/xenomorph/old_xeno = watcher.observed_xeno
	if(old_xeno)
		stop_overwatch(FALSE)
	watcher.observed_xeno = target
	target.hud_set_queen_overwatch()
	watcher.reset_perspective()
	RegisterSignal(target, COMSIG_HIVE_XENO_DEATH, .proc/on_xeno_death)
	RegisterSignal(target, list(COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED), .proc/on_xeno_evolution)
	RegisterSignal(watcher, COMSIG_MOVABLE_MOVED, .proc/on_movement)
	overwatch_active = TRUE
	to_chat(owner, span_notice("Click again on overwatch ability button to stop overwatching"))


/datum/action/xeno_action/watch_xeno/proc/stop_overwatch(do_reset_perspective = TRUE)
	var/mob/living/carbon/xenomorph/queen/watcher = owner
	var/mob/living/carbon/xenomorph/observed = watcher.observed_xeno
	watcher.observed_xeno = null
	if(!QDELETED(observed))
		UnregisterSignal(observed, list(COMSIG_HIVE_XENO_DEATH, COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED))
		observed.hud_set_queen_overwatch()
	if(do_reset_perspective)
		watcher.reset_perspective()
	UnregisterSignal(watcher, COMSIG_MOVABLE_MOVED)
	overwatch_active = FALSE


/datum/action/xeno_action/watch_xeno/proc/on_list_xeno_selection(datum/source, mob/living/carbon/xenomorph/selected_xeno)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/select_xeno, selected_xeno)

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

/datum/action/xeno_action/watch_xeno/proc/on_ctrl_middle_click(datum/source, atom/A)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/queen/watcher = owner
	if(!watcher.check_state())
		return
	if(!isxeno(A))
		return
	var/mob/living/carbon/xenomorph/observation_candidate = A
	if(observation_candidate.stat == DEAD)
		return
	if(observation_candidate == watcher.observed_xeno)
		stop_overwatch()
		return
	start_overwatch(observation_candidate)


// ***************************************
// *********** Queen zoom
// ***************************************
/datum/action/xeno_action/toggle_queen_zoom
	name = "Toggle Queen Zoom"
	action_icon_state = "toggle_queen_zoom"
	mechanics_text = "Zoom out for a larger view around wherever you are looking."
	plasma_cost = 0
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_QUEEN_ZOOM


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
	mechanics_text = "Make a target Xenomorph a leader."
	plasma_cost = 200
	keybind_signal = COMSIG_XENOABILITY_XENO_LEADERS
	use_state_flags = XACT_USE_LYING


/datum/action/xeno_action/set_xeno_lead/action_activate()
	var/mob/living/carbon/xenomorph/queen/X = owner
	if(!X.hive)
		return

	select_xeno_leader()


/datum/action/xeno_action/set_xeno_lead/proc/select_xeno_leader(mob/living/carbon/xenomorph/selected_xeno, feedback = TRUE)
	var/mob/living/carbon/xenomorph/queen/xeno_ruler = owner
	if(QDELETED(selected_xeno))
		var/list/possible_xenos = xeno_ruler.hive.get_leaderable_xenos()

		selected_xeno = tgui_input_list(xeno_ruler, "Target", "Watch which xenomorph?", possible_xenos)
		if(QDELETED(selected_xeno) || selected_xeno.stat == DEAD || is_centcom_level(selected_xeno.z))
			return

	if(selected_xeno.queen_chosen_lead)
		unset_xeno_leader(selected_xeno, feedback)
		return

	if(xeno_ruler.xeno_caste.queen_leader_limit <= length(xeno_ruler.hive.xeno_leader_list))
		if(feedback)
			to_chat(xeno_ruler, span_xenowarning("We currently have [length(xeno_ruler.hive.xeno_leader_list)] promoted leaders. We may not maintain additional leaders until our power grows."))
		return

	set_xeno_leader(selected_xeno, feedback)


/datum/action/xeno_action/set_xeno_lead/proc/unset_xeno_leader(mob/living/carbon/xenomorph/selected_xeno, feedback = TRUE)
	var/mob/living/carbon/xenomorph/xeno_ruler = owner
	if(feedback)
		to_chat(xeno_ruler, span_xenonotice("We've demoted [selected_xeno] from Lead."))
		to_chat(selected_xeno, span_xenoannounce("[xeno_ruler] has demoted us from Hive Leader. Our leadership rights and abilities have waned."))
	selected_xeno.hive.remove_leader(selected_xeno)
	selected_xeno.hud_set_queen_overwatch()
	selected_xeno.handle_xeno_leader_pheromones(xeno_ruler)

	var/datum/xeno_caste/original = /datum/xeno_caste
	// Xenos with specialized icons (Queen, King, Shrike) do not need to have their icon returned to normal
	if(selected_xeno.xeno_caste.minimap_icon != initial(original.minimap_icon))
		return

	SSminimaps.remove_marker(selected_xeno)
	SSminimaps.add_marker(selected_xeno, selected_xeno.z, MINIMAP_FLAG_XENO, selected_xeno.xeno_caste.minimap_icon)


/datum/action/xeno_action/set_xeno_lead/proc/set_xeno_leader(mob/living/carbon/xenomorph/selected_xeno, feedback = TRUE)
	var/mob/living/carbon/xenomorph/xeno_ruler = owner
	if(!(selected_xeno.xeno_caste.caste_flags & CASTE_CAN_BE_LEADER))
		if(feedback)
			to_chat(xeno_ruler, span_xenowarning("This caste is unfit to lead."))
		return
	if(feedback)
		to_chat(xeno_ruler, span_xenonotice("We've selected [selected_xeno] as a Hive Leader."))
		to_chat(selected_xeno, span_xenoannounce("[xeno_ruler] has selected us as a Hive Leader. The other Xenomorphs must listen to us. We will also act as a beacon for the Queen's pheromones."))

	xeno_ruler.hive.add_leader(selected_xeno)
	selected_xeno.hud_set_queen_overwatch()
	selected_xeno.handle_xeno_leader_pheromones(xeno_ruler)
	notify_ghosts("\ [xeno_ruler] has designated [selected_xeno] as a Hive Leader", source = selected_xeno, action = NOTIFY_ORBIT)

	var/datum/xeno_caste/original = /datum/xeno_caste
	// Xenos with specialized icons (Queen, King, Shrike) do not get their icon changed
	if(selected_xeno.xeno_caste.minimap_icon != initial(original.minimap_icon))
		return

	SSminimaps.remove_marker(selected_xeno)
	SSminimaps.add_marker(selected_xeno, selected_xeno.z, MINIMAP_FLAG_XENO, selected_xeno.xeno_caste.minimap_leadered_icon)

// ***************************************
// *********** Queen plasma
// ***************************************
/datum/action/xeno_action/activable/queen_give_plasma
	name = "Give Plasma"
	action_icon_state = "queen_give_plasma"
	mechanics_text = "Give plasma to a target Xenomorph (you must be overwatching them.)"
	plasma_cost = 150
	cooldown_timer = 8 SECONDS
	keybind_signal = COMSIG_XENOABILITY_QUEEN_GIVE_PLASMA
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
			to_chat(owner, span_warning("It's too late, this one has already kicked the bucket."))
		return FALSE
	if(!(receiver.xeno_caste.caste_flags & CASTE_CAN_BE_GIVEN_PLASMA))
		if(!silent)
			to_chat(owner, span_warning("We can't give that caste plasma."))
			return FALSE
	var/mob/living/carbon/xenomorph/giver = owner
	if(giver.z != receiver.z)
		if(!silent)
			to_chat(giver, span_warning("They are too far away to do this."))
		return FALSE
	if(receiver.plasma_stored >= receiver.xeno_caste.plasma_max)
		if(!silent)
			to_chat(giver, span_warning("[receiver] is at full plasma."))
		return FALSE


/datum/action/xeno_action/activable/queen_give_plasma/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/receiver = target
	add_cooldown()
	receiver.gain_plasma(300)
	succeed_activate()
	to_chat(owner, span_xenonotice("We transfer some plasma to [target]."))
	to_chat(receiver, span_xenonotice("We feel our plasma reserves increase. Bless the Queen!"))


// ***************************************
// *********** Queen order
// ***************************************
/datum/action/xeno_action/queen_order
	name = "Give Order"
	action_icon_state = "queen_order"
	plasma_cost = 100
	use_state_flags = XACT_USE_LYING

/datum/action/xeno_action/queen_order/action_activate()
	var/mob/living/carbon/xenomorph/queen/X = owner
	if(!X.check_concious_state())
		return
	if(X.observed_xeno)
		var/mob/living/carbon/xenomorph/target = X.observed_xeno
		if(target.stat != DEAD && target.client)
			if(X.check_plasma(100))
				var/input = stripped_input(X, "This message will be sent to the overwatched xeno.", "Queen Order", "")
				if(!input)
					return
				var/queen_order = span_xenoannounce("<b>[X]</b> reaches you:\"[input]\"")
				if(!X.check_state() || !X.check_plasma(100) || X.observed_xeno != target || target.stat == DEAD)
					return
				if(target.client)
					X.use_plasma(100)
					to_chat(target, "[queen_order]")
					log_game("[key_name(X)] has given the following Queen order to [key_name(target)]: [input]")
					message_admins("[ADMIN_TPMONTY(X)] has given the following Queen order to [ADMIN_TPMONTY(target)]: [input]")

	else
		to_chat(X, span_warning("We must overwatch the Xenomorph we want to give orders to."))

// ***************************************
// *********** Queen deevolve
// ***************************************
/datum/action/xeno_action/deevolve
	name = "De-Evolve a Xenomorph"
	action_icon_state = "xeno_deevolve"
	mechanics_text = "De-evolve a target Xenomorph of Tier 2 or higher to the next lowest tier."
	plasma_cost = 600
	keybind_signal = COMSIG_XENOABILITY_DEEVOLVE
	use_state_flags = XACT_USE_LYING

/datum/action/xeno_action/deevolve/action_activate()
	var/mob/living/carbon/xenomorph/queen/X = owner
	if(!X.observed_xeno)
		to_chat(X, span_warning("We must overwatch the xeno we want to de-evolve."))
		return

	var/mob/living/carbon/xenomorph/T = X.observed_xeno
	if(!X.check_plasma(600)) // check plasma gives an error message itself
		return

	if(T.is_ventcrawling)
		to_chat(X, span_warning("[T] can't be deevolved here."))
		return

	if(!isturf(T.loc))
		to_chat(X, span_warning("[T] can't be deevolved here."))
		return

	if(T.health <= 0)
		to_chat(X, span_warning("[T] is too weak to be deevolved."))
		return

	if(!T.xeno_caste.deevolves_to)
		to_chat(X, span_xenowarning("[T] can't be deevolved."))
		return

	var/datum/xeno_caste/new_caste = GLOB.xeno_caste_datums[T.xeno_caste.deevolves_to][XENO_UPGRADE_ZERO]

	var/confirm = tgui_alert(X, "Are you sure you want to deevolve [T] from [T.xeno_caste.caste_name] to [new_caste.caste_name]?", null, list("Yes", "No"))
	if(confirm != "Yes")
		return

	var/reason = stripped_input(X, "Provide a reason for deevolving this xenomorph, [T]")
	if(isnull(reason))
		to_chat(X, span_xenowarning("You must provide a reason for deevolving [T]."))
		return

	if(!X.check_concious_state() || !X.check_plasma(600) || X.observed_xeno != T)
		return

	if(T.is_ventcrawling)
		return

	if(!isturf(T.loc))
		return

	if(T.health <= 0)
		return

	to_chat(T, span_xenowarning("The queen is deevolving us for the following reason: [reason]"))

	var/xeno_type = new_caste.caste_type_path

	//From there, the new xeno exists, hopefully
	var/mob/living/carbon/xenomorph/new_xeno = new xeno_type(get_turf(T))

	if(!istype(new_xeno))
		//Something went horribly wrong!
		stack_trace("[X] tried to deevolve [X.observed_xeno] but their new_xeno wasn't a xeno at all.")
		if(new_xeno)
			qdel(new_xeno)
		return

	for(var/obj/item/W in T.contents) //Drop stuff
		T.dropItemToGround(W)

	if(T.mind)
		T.mind.transfer_to(new_xeno)
	else
		new_xeno.key = T.key

	//Pass on the unique nicknumber, then regenerate the new mob's name now that our player is inside
	new_xeno.nicknumber = T.nicknumber
	new_xeno.generate_name()

	if(T.xeno_mobhud)
		var/datum/atom_hud/H = GLOB.huds[DATA_HUD_XENO_STATUS]
		H.add_hud_to(new_xeno) //keep our mobhud choice
		new_xeno.xeno_mobhud = TRUE

	new_xeno.visible_message(span_xenodanger("A [new_xeno.xeno_caste.caste_name] emerges from the husk of \the [T]."), \
	span_xenodanger("[X] makes us regress into our previous form."))

	if(T.queen_chosen_lead)
		new_xeno.queen_chosen_lead = TRUE
		new_xeno.hud_set_queen_overwatch()

	SEND_SIGNAL(T, COMSIG_XENOMORPH_DEEVOLVED, new_xeno)

	// this sets the right datum
	new_xeno.upgrade_xeno(T.upgrade_next()) //a young Crusher de-evolves into a MATURE Hunter

	log_game("[key_name(X)] has deevolved [key_name(T)]. Reason: [reason]")
	message_admins("[ADMIN_TPMONTY(X)] has deevolved [ADMIN_TPMONTY(T)]. Reason: [reason]")

	GLOB.round_statistics.total_xenos_created-- //so an evolved xeno doesn't count as two.
	SSblackbox.record_feedback("tally", "round_statistics", -1, "total_xenos_created")
	qdel(T)
	X.use_plasma(600)
