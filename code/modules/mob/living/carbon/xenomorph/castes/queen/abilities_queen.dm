// ***************************************
// *********** Hive orders
// ***************************************
/mob/living/carbon/xenomorph/queen/proc/set_orders()
	set category = "Alien"
	set name = "Set Hive Orders (50)"
	set desc = "Give some specific orders to the hive. They can see this on the status pane."

	if(hivenumber == XENO_HIVE_CORRUPTED)
		to_chat(src, "<span class='warning'>Only our masters can decide this!</span>")
		return

	if(!check_state())
		return
	if(!check_plasma(50))
		return
	if(cooldowns[COOLDOWN_ORDER])
		return
	plasma_stored -= 50
	var/txt = copytext(sanitize(input("Set the hive's orders to what? Leave blank to clear it.", "Hive Orders","")), 1, MAX_MESSAGE_LEN)

	if(txt)
		xeno_message("<B>The Queen has given a new order. Check Status panel for details.</B>",3,hivenumber)
		hive.hive_orders = txt
	else
		hive.hive_orders = ""

	cooldowns[COOLDOWN_ORDER] = addtimer(VARSET_LIST_CALLBACK(cooldowns, COOLDOWN_ORDER, null), 15 SECONDS)

// ***************************************
// *********** Hive message
// ***************************************
/mob/living/carbon/xenomorph/queen/proc/hive_Message()
	set category = "Alien"
	set name = "Word of the Queen (50)"
	set desc = "Send a message to all aliens in the hive that is big and visible"
	if(!check_plasma(50))
		return
	plasma_stored -= 50
	if(health <= 0)
		to_chat(src, "<span class='warning'>We can't do that while unconcious.</span>")
		return 0
	var/input = stripped_multiline_input(src, "This message will be broadcast throughout the hive.", "Word of the Queen", "")
	if(!input)
		return

	var/queensWord = "<br><h2 class='alert'>The words of the queen reverberate in your head...</h2>"
	queensWord += "<br><span class='alert'>[input]</span><br>"

	INVOKE_ASYNC(src, .proc/do_hive_message, queensWord)

/mob/living/carbon/xenomorph/queen/proc/do_hive_message(queensWord)
	var/sound/queen_sound = sound(get_sfx("queen"), wait = 0,volume = 50, channel = CHANNEL_ANNOUNCEMENTS)
	if(SSticker?.mode)
		hive.xeno_message("[queensWord]")
		for(var/i in hive.get_watchable_xenos())
			var/mob/living/carbon/xenomorph/X = i
			SEND_SOUND(X, queen_sound)

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/G = i
		SEND_SOUND(G, queen_sound)
		to_chat(G, "[queensWord]")

	log_game("[key_name(src)] has created a Word of the Queen report: [queensWord]")
	message_admins("[ADMIN_TPMONTY(src)] has created a Word of the Queen report.")

// ***************************************
// *********** Slashing permissions
// ***************************************
/mob/living/carbon/xenomorph/proc/claw_toggle()
	set name = "Permit/Disallow Slashing"
	set desc = "Allows you to permit the hive to harm."
	set category = "Alien"

	if(hivenumber == XENO_HIVE_CORRUPTED)
		to_chat(src, "<span class='warning'>Only our masters can decide this!</span>")
		return

	if(stat)
		to_chat(src, "<span class='warning'>We can't do that now.</span>")
		return

	if(pslash_delay)
		to_chat(src, "<span class='warning'>We must wait a bit before we can toggle this again.</span>")
		return

	addtimer(VARSET_CALLBACK(src, pslash_delay, FALSE), 30 SECONDS)

	pslash_delay = TRUE

	var/choice = input("Choose which level of slashing hosts to permit to your hive.","Harming") as null|anything in list("Allowed", "Restricted - Less Damage", "Forbidden")

	if(choice == "Allowed")
		to_chat(src, "<span class='xenonotice'>We allow slashing.</span>")
		xeno_message("The Queen has <b>permitted</b> the harming of hosts! Go hog wild!")
		hive.slashing_allowed = XENO_SLASHING_ALLOWED
	else if(choice == "Restricted - Less Damage")
		to_chat(src, "<span class='xenonotice'>We restrict slashing.</span>")
		xeno_message("The Queen has <b>restricted</b> the harming of hosts. We will only slash when hurt.")
		hive.slashing_allowed = XENO_SLASHING_RESTRICTED
	else if(choice == "Forbidden")
		to_chat(src, "<span class='xenonotice'>We forbid slashing entirely.</span>")
		xeno_message("The Queen has <b>forbidden</b> the harming of hosts. We can no longer slash your enemies.")
		hive.slashing_allowed = XENO_SLASHING_FORBIDDEN


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
	to_chat(owner, "<span class='warning'>We feel our throat muscles vibrate. We are ready to screech again.</span>")
	return ..()

/datum/action/xeno_action/activable/screech/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/queen/X = owner

	//screech is so powerful it kills huggers in our hands
	if(istype(X.r_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = X.r_hand
		if(FH.stat != DEAD)
			FH.Die()

	if(istype(X.l_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = X.l_hand
		if(FH.stat != DEAD)
			FH.Die()

	succeed_activate()
	add_cooldown()

	playsound(X.loc, 'sound/voice/alien_queen_screech.ogg', 75, 0)
	X.visible_message("<span class='xenohighdanger'>\The [X] emits an ear-splitting guttural roar!</span>")
	GLOB.round_statistics.queen_screech++
	X.create_shriekwave() //Adds the visual effect. Wom wom wom
	//stop_momentum(charge_dir) //Screech kills a charge

	var/list/nearby_living = list()
	for(var/mob/living/L in hearers(world.view, X))
		nearby_living.Add(L)

	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		if(get_dist(L, X) > world.view)
			continue
		L.screech_act(X, world.view, L in nearby_living)

// ***************************************
// *********** Gut
// ***************************************
/datum/action/xeno_action/activable/gut
	name = "Gut"
	action_icon_state = "gut"
	ability_name = "gut"
	plasma_cost = 200

/datum/action/xeno_action/activable/gut/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/queen/X = owner
	if(X.cooldowns[COOLDOWN_GUT])
		return FALSE
	if(!iscarbon(A))
		return FALSE
	if(!owner.Adjacent(A))
		return FALSE
	var/mob/living/carbon/victim = A
	if(issynth(victim))
		var/datum/limb/head/synthhead = victim.get_limb("head")
		if(synthhead.limb_status & LIMB_DESTROYED)
			return FALSE
	if(locate(/obj/item/alien_embryo) in victim) //Maybe they ate it??
		var/mob/living/carbon/human/H = victim
		if(CHECK_BITFIELD(H.status_flags, XENO_HOST))
			if(victim.stat != DEAD) //Not dead yet.
				if(!silent)
					to_chat(owner, "<span class='xenowarning'>The host and child are still alive!</span>")
				return FALSE
			else if(istype(H) && !check_tod(H)) //Dead, but the host can still hatch, possibly.
				if(!silent)
					to_chat(owner, "<span class='xenowarning'>The child may still hatch! Not yet!</span>")
				return FALSE
	if(owner.issamexenohive(victim))
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't bring ourselves to harm a fellow sister to this magnitude.</span>")
		return FALSE

/datum/action/xeno_action/activable/gut/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/queen/X = owner
	var/mob/living/carbon/victim = A

	succeed_activate()

	X.cooldowns[COOLDOWN_GUT] = addtimer(VARSET_LIST_CALLBACK(X.cooldowns, COOLDOWN_GUT, null), 5 SECONDS)

	X.visible_message("<span class='xenowarning'>\The [X] begins slowly lifting \the [victim] into the air.</span>", \
	"<span class='xenowarning'>We begin focusing our anger as we slowly lift \the [victim] into the air.</span>")
	if(!do_mob(X, victim, 80, BUSY_ICON_DANGER, BUSY_ICON_DANGER))
		return fail_activate()
	if(!can_use_ability(victim,TRUE,XACT_IGNORE_PLASMA))
		return fail_activate()
	if(victim.loc != X.loc)
		return fail_activate()
	X.visible_message("<span class='xenodanger'>\The [X] viciously smashes and wrenches \the [victim] apart!</span>", \
	"<span class='xenodanger'>We suddenly unleash pure anger on \the [victim], instantly wrenching [victim.p_them()] apart!</span>")
	X.emote("roar")
	log_combat(victim, X, "gibbed")
	victim.gib() //Splut
	X.stop_pulling()


// ***************************************
// *********** Overwatch
// ***************************************
/datum/action/xeno_action/watch_xeno
	name = "Watch Xenomorph"
	action_icon_state = "watch_xeno"
	mechanics_text = "See from the target Xenomorphs vision."
	plasma_cost = 0
	keybind_signal = COMSIG_XENOABILITY_WATCH_XENO
	var/overwatch_active = FALSE


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
	select_xeno()


/datum/action/xeno_action/watch_xeno/proc/select_xeno(mob/living/carbon/xenomorph/selected_xeno)
	var/mob/living/carbon/xenomorph/queen/X = owner
	if(!X.hive)
		return

	if(QDELETED(selected_xeno))
		var/list/possible_xenos = X.hive.get_watchable_xenos()

		selected_xeno = input(X, "Target", "Watch which xenomorph?") as null|anything in possible_xenos
		if(QDELETED(selected_xeno) || selected_xeno == X.observed_xeno || selected_xeno.stat == DEAD || is_centcom_level(selected_xeno.z) || !X.check_state())
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
	watcher.reset_perspective()
	RegisterSignal(target, COMSIG_HIVE_XENO_DEATH, .proc/on_xeno_death)
	RegisterSignal(target, list(COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED), .proc/on_xeno_evolution)
	RegisterSignal(watcher, COMSIG_MOVABLE_MOVED, .proc/on_movement)
	overwatch_active = TRUE


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
	select_xeno(selected_xeno)

/datum/action/xeno_action/watch_xeno/proc/on_xeno_evolution(datum/source, mob/living/carbon/xenomorph/new_xeno)
	start_overwatch(new_xeno)

/datum/action/xeno_action/watch_xeno/proc/on_xeno_death(datum/source, mob/living/carbon/xenomorph/dead_xeno)
	if(overwatch_active)
		stop_overwatch()

/datum/action/xeno_action/watch_xeno/proc/on_owner_death(datum/source, gibbed)
	if(overwatch_active)
		stop_overwatch()

/datum/action/xeno_action/watch_xeno/proc/on_movement(datum/source, atom/oldloc, direction, Forced)
	if(overwatch_active)
		stop_overwatch()

/datum/action/xeno_action/watch_xeno/proc/on_ctrl_middle_click(datum/source, atom/A)
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
	if(xeno.action_busy)
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
		xeno.visible_message("<span class='notice'>[xeno] emits a broad and weak psychic aura.</span>",
		"<span class='notice'>We start focusing our psychic energy to expand the reach of our senses.</span>", null, 5)
	xeno.zoom_in(0, 12)


/datum/action/xeno_action/toggle_queen_zoom/proc/zoom_xeno_out(message = TRUE)
	var/mob/living/carbon/xenomorph/xeno = owner
	UnregisterSignal(xeno, COMSIG_MOVABLE_MOVED)
	if(message)
		xeno.visible_message("<span class='notice'>[xeno] stops emitting its broad and weak psychic aura.</span>",
		"<span class='notice'>We stop the effort of expanding our senses.</span>", null, 5)
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
	plasma_cost = 0
	keybind_signal = COMSIG_XENOABILITY_XENO_LEADERS


/datum/action/xeno_action/set_xeno_lead/action_activate()
	var/mob/living/carbon/xenomorph/queen/X = owner
	if(!X.check_state())
		return
	if(!X.hive)
		return

	select_xeno_leader()


/datum/action/xeno_action/set_xeno_lead/proc/select_xeno_leader(mob/living/carbon/xenomorph/selected_xeno, feedback = TRUE)
	var/mob/living/carbon/xenomorph/queen/xeno_ruler = owner
	if(QDELETED(selected_xeno))
		var/list/possible_xenos = xeno_ruler.hive.get_leaderable_xenos()

		selected_xeno = input(xeno_ruler, "Target", "Watch which xenomorph?") as null|anything in possible_xenos
		if(QDELETED(selected_xeno) || selected_xeno.stat == DEAD || is_centcom_level(selected_xeno.z) || !xeno_ruler.check_state())
			return

	if(selected_xeno.queen_chosen_lead)
		unset_xeno_leader(selected_xeno, feedback)
		return

	if(xeno_ruler.queen_ability_cooldown > world.time)
		if(feedback)
			to_chat(xeno_ruler, "<span class='xenowarning'>We're still recovering from our last hive managment ability. We must wait [round((xeno_ruler.queen_ability_cooldown-world.time)*0.1)] seconds.</span>")
		return

	if(xeno_ruler.xeno_caste.queen_leader_limit <= length(xeno_ruler.hive.xeno_leader_list))
		if(feedback)
			to_chat(xeno_ruler, "<span class='xenowarning'>We currently have [length(xeno_ruler.hive.xeno_leader_list)] promoted leaders. We may not maintain additional leaders until our power grows.</span>")
		return

	xeno_ruler.queen_ability_cooldown = world.time + 15 SECONDS

	set_xeno_leader(selected_xeno, feedback)


/datum/action/xeno_action/set_xeno_lead/proc/unset_xeno_leader(mob/living/carbon/xenomorph/selected_xeno, feedback = TRUE)
	var/mob/living/carbon/xenomorph/xeno_ruler = owner
	if(feedback)
		to_chat(xeno_ruler, "<span class='xenonotice'>We've demoted [selected_xeno] from Lead.</span>")
		to_chat(selected_xeno, "<span class='xenoannounce'>[xeno_ruler] has demoted us from Hive Leader. Our leadership rights and abilities have waned.</span>")
	selected_xeno.hive.remove_leader(selected_xeno)
	selected_xeno.hud_set_queen_overwatch()
	selected_xeno.handle_xeno_leader_pheromones(xeno_ruler)


/datum/action/xeno_action/set_xeno_lead/proc/set_xeno_leader(mob/living/carbon/xenomorph/selected_xeno, feedback = TRUE)
	var/mob/living/carbon/xenomorph/xeno_ruler = owner
	if(!(selected_xeno.xeno_caste.caste_flags & CASTE_CAN_BE_LEADER))
		if(feedback)
			to_chat(xeno_ruler, "<span class='xenowarning'>This caste is unfit to lead.</span>")
		return
	if(feedback)
		to_chat(xeno_ruler, "<span class='xenonotice'>We've selected [selected_xeno] as a Hive Leader.</span>")
		to_chat(selected_xeno, "<span class='xenoannounce'>[xeno_ruler] has selected us as a Hive Leader. The other Xenomorphs must listen to us. We will also act as a beacon for the Queen's pheromones.</span>")
	xeno_ruler.hive.add_leader(selected_xeno)
	selected_xeno.hud_set_queen_overwatch()
	selected_xeno.handle_xeno_leader_pheromones(xeno_ruler)


// ***************************************
// *********** Queen heal
// ***************************************
/datum/action/xeno_action/activable/queen_heal
	name = "Heal Xenomorph"
	action_icon_state = "heal_xeno"
	mechanics_text = "Heals a target Xenomorph"
	plasma_cost = 600
	cooldown_timer = 15 SECONDS
	keybind_signal = COMSIG_XENOABILITY_QUEEN_HEAL


/datum/action/xeno_action/activable/queen_heal/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!isxeno(target))
		return FALSE
	var/mob/living/carbon/xenomorph/patient = target
	if(!CHECK_BITFIELD(use_state_flags|override_flags, XACT_IGNORE_DEAD_TARGET) && patient.stat == DEAD)
		if(!silent)
			to_chat(owner, "<span class='warning'>It's too late. This sister won't be coming back.</span>")
		return FALSE
	if(!(patient.xeno_caste.caste_flags & CASTE_CAN_BE_QUEEN_HEALED))
		if(!silent)
			to_chat(owner, "<span class='xenowarning'>We can't heal that caste.</span>")
			return FALSE
	var/mob/living/carbon/xenomorph/healer = owner
	if(healer.z != patient.z)
		if(!silent)
			to_chat(healer, "<span class='xenowarning'>They are too far away to do this.</span>")
		return FALSE
	if(patient.health >= patient.maxHealth)
		if(!silent)
			to_chat(healer, "<span class='warning'>[patient] is at full health.</span>")
		return FALSE


/datum/action/xeno_action/activable/queen_heal/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/patient = target
	add_cooldown()
	patient.adjustBruteLoss(-50)
	patient.adjustFireLoss(-50)
	succeed_activate()
	to_chat(owner, "<span class='xenonotice'>We channel our plasma to heal [target]'s wounds.</span>")
	to_chat(patient, "<span class='xenonotice'>We feel our wounds heal. Bless the Queen!</span>")


// ***************************************
// *********** Queen plasma
// ***************************************
/datum/action/xeno_action/activable/queen_give_plasma
	name = "Give Plasma"
	action_icon_state = "queen_give_plasma"
	mechanics_text = "Give plasma to a target Xenomorph (you must be overwatching them.)"
	plasma_cost = 600
	cooldown_timer = 15 SECONDS
	keybind_signal = COMSIG_XENOABILITY_QUEEN_GIVE_PLASMA


/datum/action/xeno_action/activable/queen_give_plasma/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!isxeno(target))
		return FALSE
	var/mob/living/carbon/xenomorph/receiver = target
	if(!CHECK_BITFIELD(use_state_flags|override_flags, XACT_IGNORE_DEAD_TARGET) && receiver.stat == DEAD)
		if(!silent)
			to_chat(owner, "<span class='warning'>It's too late, this one has already kicked the bucket.</span>")
		return FALSE
	if(!(receiver.xeno_caste.caste_flags & CASTE_CAN_BE_GIVEN_PLASMA))
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't give that caste plasma.</span>")
			return FALSE
	var/mob/living/carbon/xenomorph/giver = owner
	if(giver.z != receiver.z)
		if(!silent)
			to_chat(giver, "<span class='warning'>They are too far away to do this.</span>")
		return FALSE
	if(receiver.plasma_stored >= receiver.xeno_caste.plasma_max)
		if(!silent)
			to_chat(giver, "<span class='warning'>[receiver] is at full plasma.</span>")
		return FALSE


/datum/action/xeno_action/activable/queen_give_plasma/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/receiver = target
	add_cooldown()
	receiver.gain_plasma(300)
	succeed_activate()
	to_chat(owner, "<span class='xenonotice'>We transfer some plasma to [target].</span>")
	to_chat(receiver, "<span class='xenonotice'>We feel our plasma reserves increase. Bless the Queen!</span>")


// ***************************************
// *********** Queen order
// ***************************************
/datum/action/xeno_action/queen_order
	name = "Give Order"
	action_icon_state = "queen_order"
	plasma_cost = 100
	keybind_signal = COMSIG_XENOABILITY_QUEEN_GIVE_ORDER

/datum/action/xeno_action/queen_order/action_activate()
	var/mob/living/carbon/xenomorph/queen/X = owner
	if(!X.check_state())
		return
	if(X.observed_xeno)
		var/mob/living/carbon/xenomorph/target = X.observed_xeno
		if(target.stat != DEAD && target.client)
			if(X.check_plasma(100))
				var/input = stripped_input(X, "This message will be sent to the overwatched xeno.", "Queen Order", "")
				if(!input)
					return
				var/queen_order = "<span class='xenoannounce'><b>[X]</b> reaches you:\"[input]\"</span>"
				if(!X.check_state() || !X.check_plasma(100) || X.observed_xeno != target || target.stat == DEAD)
					return
				if(target.client)
					X.use_plasma(100)
					to_chat(target, "[queen_order]")
					log_game("[key_name(X)] has given the following Queen order to [key_name(target)]: [input]")
					message_admins("[ADMIN_TPMONTY(X)] has given the following Queen order to [ADMIN_TPMONTY(target)]: [input]")

	else
		to_chat(X, "<span class='warning'>We must overwatch the Xenomorph we want to give orders to.</span>")

// ***************************************
// *********** Queen deevolve
// ***************************************
/datum/action/xeno_action/deevolve
	name = "De-Evolve a Xenomorph"
	action_icon_state = "xeno_deevolve"
	mechanics_text = "De-evolve a target Xenomorph of Tier 2 or higher to the next lowest tier."
	plasma_cost = 600
	keybind_signal = COMSIG_XENOABILITY_DEEVOLVE

/datum/action/xeno_action/deevolve/action_activate()
	var/mob/living/carbon/xenomorph/queen/X = owner
	if(!X.check_state())
		return
	if(!X.observed_xeno)
		to_chat(X, "<span class='warning'>We must overwatch the xeno we want to de-evolve.</span>")
		return

	var/mob/living/carbon/xenomorph/T = X.observed_xeno
	if(!X.check_plasma(600)) // check plasma gives an error message itself
		return

	if(T.is_ventcrawling)
		to_chat(X, "<span class='warning'>[T] can't be deevolved here.</span>")
		return

	if(!isturf(T.loc))
		to_chat(X, "<span class='warning'>[T] can't be deevolved here.</span>")
		return

	if(T.health <= 0)
		to_chat(X, "<span class='warning'>[T] is too weak to be deevolved.</span>")
		return

	if(!T.xeno_caste.deevolves_to)
		to_chat(X, "<span class='xenowarning'>[T] can't be deevolved.</span>")
		return

	var/datum/xeno_caste/new_caste = GLOB.xeno_caste_datums[T.xeno_caste.deevolves_to][XENO_UPGRADE_ZERO]

	var/confirm = alert(X, "Are you sure you want to deevolve [T] from [T.xeno_caste.caste_name] to [new_caste.caste_name]?", , "Yes", "No")
	if(confirm == "No")
		return

	var/reason = stripped_input(X, "Provide a reason for deevolving this xenomorph, [T]")
	if(isnull(reason))
		to_chat(X, "<span class='xenowarning'>You must provide a reason for deevolving [T].</span>")
		return

	if(!X.check_state() || !X.check_plasma(600) || X.observed_xeno != T)
		return

	if(T.is_ventcrawling)
		return

	if(!isturf(T.loc))
		return

	if(T.health <= 0)
		return

	to_chat(T, "<span class='xenowarning'>The queen is deevolving us for the following reason: [reason]</span>")

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

	T.empty_gut(FALSE, TRUE)

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

	new_xeno.middle_mouse_toggle = T.middle_mouse_toggle //Keep our toggle state
	new_xeno.visible_message("<span class='xenodanger'>A [new_xeno.xeno_caste.caste_name] emerges from the husk of \the [T].</span>", \
	"<span class='xenodanger'>[X] makes us regress into our previous form.</span>")

	if(T.queen_chosen_lead)
		new_xeno.queen_chosen_lead = TRUE
		new_xeno.hud_set_queen_overwatch()

	SEND_SIGNAL(T, COMSIG_XENOMORPH_DEEVOLVED, new_xeno)

	// this sets the right datum
	new_xeno.upgrade_xeno(T.upgrade_next()) //a young Crusher de-evolves into a MATURE Hunter

	log_game("[key_name(X)] has deevolved [key_name(T)]. Reason: [reason]")
	message_admins("[ADMIN_TPMONTY(X)] has deevolved [ADMIN_TPMONTY(T)]. Reason: [reason]")

	GLOB.round_statistics.total_xenos_created-- //so an evolved xeno doesn't count as two.
	qdel(T)
	X.use_plasma(600)
