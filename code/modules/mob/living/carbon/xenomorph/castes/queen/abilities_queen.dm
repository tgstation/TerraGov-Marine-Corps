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
	if(last_special > world.time)
		return
	plasma_stored -= 50
	var/txt = copytext(sanitize(input("Set the hive's orders to what? Leave blank to clear it.", "Hive Orders","")), 1, MAX_MESSAGE_LEN)

	if(txt)
		xeno_message("<B>The Queen has given a new order. Check Status panel for details.</B>",3,hivenumber)
		hive.hive_orders = txt
	else
		hive.hive_orders = ""

	last_special = world.time + 150

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
	if(SSticker?.mode)
		hive.xeno_message("[queensWord]")
		for(var/i in hive.get_watchable_xenos())
			var/mob/living/carbon/xenomorph/X = i
			SEND_SOUND(X, sound(get_sfx("queen"), wait = 0,volume = 50))

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/G = i
		SEND_SOUND(G, sound(get_sfx("queen"), wait = 0,volume = 50))
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
	cooldown_timer = 50 SECONDS
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
	if(X.last_special > world.time)
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

	X.last_special = world.time + 5 SECONDS

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
// *********** Ovipositor
// ***************************************
/datum/action/xeno_action/grow_ovipositor
	name = "Grow Ovipositor"
	action_icon_state = "grow_ovipositor"
	mechanics_text = "Grow an ovipositor to lay eggs and access new abilities. Takes 20 seconds and you cannot move while on the ovipositor."
	plasma_cost = 700
	keybind_signal = COMSIG_XENOABILITY_GROW_OVIPOSITOR

/datum/action/xeno_action/grow_ovipositor/action_activate()
	var/mob/living/carbon/xenomorph/queen/X = owner
	if(!X.check_state())
		return

	var/turf/current_turf = get_turf(X)
	if(!current_turf || !istype(current_turf))
		return

	if(X.ovipositor_cooldown > world.time)
		to_chat(X, "<span class='xenowarning'>We're still recovering from detaching our old ovipositor. We must wait [round((X.ovipositor_cooldown-world.time)*0.1)] seconds</span>")
		return

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf

	if(!alien_weeds)
		to_chat(X, "<span class='xenowarning'>We need to be on resin to grow an ovipositor.</span>")
		return

	if(!current_turf.check_alien_construction(X))
		return

	if(X.action_busy)
		return

	if(X.check_plasma(plasma_cost))
		X.visible_message("<span class='xenowarning'>\The [X] starts to grow an ovipositor.</span>", \
		"<span class='xenowarning'>We start to grow an ovipositor...(takes 20 seconds, hold still)</span>")

		notify_ghosts("\The <b>[X]</b> has started growing an ovipositor!", source = X, action = NOTIFY_ORBIT)

		if(!do_after(X, 200, TRUE, alien_weeds, BUSY_ICON_BUILD) || !X.check_plasma(plasma_cost) || !X.check_state())
			return

		X.use_plasma(plasma_cost)
		X.visible_message("<span class='xenowarning'>\The [X] has grown an ovipositor!</span>", \
		"<span class='xenowarning'>We have grown an ovipositor!</span>")
		X.mount_ovipositor()

/datum/action/xeno_action/remove_eggsac
	name = "Remove Eggsac"
	action_icon_state = "grow_ovipositor"
	mechanics_text = "Get off your ovipositor, causing it to collapse. You must grow a new one the next time you wish to reattach."
	keybind_signal = COMSIG_XENOABILITY_REMOVE_EGGSAC

/datum/action/xeno_action/remove_eggsac/action_activate()
	var/mob/living/carbon/xenomorph/queen/X = owner

	var/answer = alert(X, "Are you sure you want to remove your ovipositor? (5min cooldown to grow a new one)", , "Yes", "No")
	if(answer != "Yes")
		return
	if(!can_use_action())
		return
	if(!X.ovipositor)
		return
	X.visible_message("<span class='xenowarning'>\The [X] starts detaching itself from its ovipositor!</span>", \
		"<span class='xenowarning'>We start detaching ourselves from our ovipositor.</span>")
	if(!do_after(X, 50, FALSE, null, BUSY_ICON_BUILD) || !X.check_state() || !X.ovipositor)
		return
	X.dismount_ovipositor()

/mob/living/carbon/xenomorph/queen/proc/mount_ovipositor()
	if(ovipositor) return //sanity check
	ovipositor = TRUE
	RegisterSignal(hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK), .proc/is_burrowed_larva_host)

	for(var/datum/action/A in actions)
		qdel(A)

	var/list/immobile_abilities = list(\
		/datum/action/xeno_action/regurgitate,\
		/datum/action/xeno_action/remove_eggsac,\
		/datum/action/xeno_action/activable/screech,\
		/datum/action/xeno_action/psychic_whisper,\
		/datum/action/xeno_action/watch_xeno,\
		/datum/action/xeno_action/toggle_queen_zoom,\
		/datum/action/xeno_action/set_xeno_lead,\
		/datum/action/xeno_action/queen_heal,\
		/datum/action/xeno_action/queen_give_plasma,\
		/datum/action/xeno_action/queen_order,\
		/datum/action/xeno_action/deevolve, \
		/datum/action/xeno_action/toggle_pheromones, \
		)

	for(var/path in immobile_abilities)
		var/datum/action/xeno_action/A = new path()
		A.give_action(src)

	anchored = TRUE
	set_resting(FALSE)
	update_icons()

	hive?.update_leader_pheromones()

	hive?.xeno_message("<span class='xenoannounce'>The Queen has grown an ovipositor.</span>", 3)

/mob/living/carbon/xenomorph/queen/proc/dismount_ovipositor(instant_dismount)
	set waitfor = 0
	if(!instant_dismount)
		if(observed_xeno)
			set_queen_overwatch(observed_xeno, TRUE)
		flick("ovipositor_dismount", src)
		sleep(5)
	else
		flick("ovipositor_dismount_destroyed", src)
		sleep(5)

	if(!ovipositor)
		return
	ovipositor = FALSE
	UnregisterSignal(hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK))
	update_icons()
	new /obj/ovipositor(loc)

	if(observed_xeno)
		set_queen_overwatch(observed_xeno, TRUE)
	zoom_out()

	for(var/datum/action/A in actions)
		qdel(A)

	var/list/mobile_abilities = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/grow_ovipositor,
		/datum/action/xeno_action/activable/screech,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/psychic_whisper,
		/datum/action/xeno_action/shift_spits,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/larva_growth,
		/datum/action/xeno_action/toggle_pheromones
		)

	for(var/path in mobile_abilities)
		var/datum/action/xeno_action/A = new path()
		A.give_action(src)


	egg_amount = 0
	ovipositor_cooldown = world.time + 5 MINUTES
	anchored = FALSE
	update_canmove()

	hive?.update_leader_pheromones()

	if(!instant_dismount)
		hive?.xeno_message("<span class='xenoannounce'>The Queen has shed her ovipositor.</span>", 3)

// ***************************************
// *********** Overwatch
// ***************************************
/datum/action/xeno_action/watch_xeno
	name = "Watch Xenomorph"
	action_icon_state = "watch_xeno"
	mechanics_text = "See from the target Xenomorphs vision."
	plasma_cost = 0
	keybind_signal = COMSIG_XENOABILITY_WATCH_XENO

/datum/action/xeno_action/watch_xeno/action_activate()
	var/mob/living/carbon/xenomorph/queen/X = owner
	if(!X.hive)
		return
	var/list/possible_xenos = X.hive.get_watchable_xenos()

	var/mob/living/carbon/xenomorph/selected_xeno = input(X, "Target", "Watch which xenomorph?") as null|anything in possible_xenos
	if(!selected_xeno || selected_xeno.gc_destroyed || selected_xeno == X.observed_xeno || selected_xeno.stat == DEAD || is_centcom_level(selected_xeno.z) || !X.check_state())
		if(X.observed_xeno)
			X.set_queen_overwatch(X.observed_xeno, TRUE)
	else
		X.set_queen_overwatch(selected_xeno)

/mob/living/carbon/xenomorph/queen/proc/set_queen_overwatch(mob/living/carbon/xenomorph/target, stop_overwatch)
	if(stop_overwatch)
		observed_xeno = null
	else
		var/mob/living/carbon/xenomorph/old_xeno = observed_xeno
		observed_xeno = target
		if(old_xeno)
			old_xeno.hud_set_queen_overwatch()
	if(!target.gc_destroyed) //not cdel'd
		target.hud_set_queen_overwatch()
	reset_perspective()

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
	var/mob/living/carbon/xenomorph/queen/X = owner
	if(!X.check_state())
		return
	if(X.is_zoomed)
		X.zoom_out()
	else
		X.zoom_in(0, 12)

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

	if(X.observed_xeno)
		if(!(X.observed_xeno.xeno_caste.caste_flags & CASTE_CAN_BE_LEADER))
			to_chat(X, "<span class='xenowarning'>This caste is unfit to lead.</span>")
			return
		if(X.queen_ability_cooldown > world.time)
			to_chat(X, "<span class='xenowarning'>We're still recovering from our last overwatch ability. We must wait [round((X.queen_ability_cooldown-world.time)*0.1)] seconds.</span>")
			return
		if(X.xeno_caste.queen_leader_limit <= X.hive.xeno_leader_list.len && !X.observed_xeno.queen_chosen_lead)
			to_chat(X, "<span class='xenowarning'>We currently have [X.hive.xeno_leader_list.len] promoted leaders. We may not maintain additional leaders until our power grows.</span>")
			return
		var/mob/living/carbon/xenomorph/T = X.observed_xeno
		X.queen_ability_cooldown = world.time + 150 //15 seconds
		if(!T.queen_chosen_lead)
			to_chat(X, "<span class='xenonotice'>We've selected [T] as a Hive Leader.</span>")
			to_chat(T, "<span class='xenoannounce'>[X] has selected us as a Hive Leader. The other Xenomorphs must listen to us. We will also act as a beacon for the Queen's pheromones.</span>")
			X.hive.add_leader(T)
		else
			to_chat(X, "<span class='xenonotice'>We've demoted [T] from Lead.</span>")
			to_chat(T, "<span class='xenoannounce'>[X] has demoted us from Hive Leader. Our leadership rights and abilities have waned.</span>")
			X.hive.remove_leader(T)
		T.hud_set_queen_overwatch()
		T.handle_xeno_leader_pheromones(X)
	else
		if(length(X.hive.xeno_leader_list) > 1)
			var/mob/living/carbon/xenomorph/selected_xeno = input(X, "Target", "Watch which xenomorph leader?") as null|anything in X.hive.xeno_leader_list
			if(!selected_xeno || !selected_xeno.queen_chosen_lead || selected_xeno == X.observed_xeno || selected_xeno.stat == DEAD || selected_xeno.z != X.z || !X.check_state())
				return
			X.set_queen_overwatch(selected_xeno)
		else if(X.hive.xeno_leader_list.len)
			X.set_queen_overwatch(X.hive.xeno_leader_list[1])
		else
			to_chat(X, "<span class='xenowarning'>There are no Xenomorph leaders. We must overwatch a Xenomorph to make it a leader.</span>")

// ***************************************
// *********** Queen heal
// ***************************************
/datum/action/xeno_action/queen_heal
	name = "Heal Xenomorph"
	action_icon_state = "heal_xeno"
	mechanics_text = "Heals a target Xenomorph (you must be overwatching them.)"
	plasma_cost = 600
	keybind_signal = COMSIG_XENOABILITY_QUEEN_HEAL

/datum/action/xeno_action/queen_heal/action_activate()
	var/mob/living/carbon/xenomorph/queen/X = owner
	if(!X.check_state())
		return
	if(X.queen_ability_cooldown > world.time)
		to_chat(X, "<span class='xenowarning'>We're still recovering from our last overwatch ability. Wait [round((X.queen_ability_cooldown-world.time)*0.1)] seconds.</span>")
		return
	if(!X.observed_xeno)
		to_chat(X, "<span class='warning'>We must overwatch the xeno we want to give healing to.</span>")
		return
	var/mob/living/carbon/xenomorph/target = X.observed_xeno
	if(!(target.xeno_caste.caste_flags & CASTE_CAN_BE_QUEEN_HEALED))
		to_chat(X, "<span class='xenowarning'>We can't heal that caste.</span>")
		return
	if(X.loc.z != target.loc.z)
		to_chat(X, "<span class='xenowarning'>They are too far away to do this.</span>")
		return
	if(target.stat == DEAD)
		return
	if(target.health >= target.maxHealth)
		to_chat(X, "<span class='warning'>[target] is at full health.</span>")
		return
	if(X.check_plasma(600))
		X.use_plasma(600)
		target.adjustBruteLoss(-50)
		X.queen_ability_cooldown = world.time + 15 SECONDS //15 seconds
		to_chat(X, "<span class='xenonotice'>We channel our plasma to heal [target]'s wounds.</span>")

// ***************************************
// *********** Queen plasma
// ***************************************
/datum/action/xeno_action/queen_give_plasma
	name = "Give Plasma"
	action_icon_state = "queen_give_plasma"
	mechanics_text = "Give plasma to a target Xenomorph (you must be overwatching them.)"
	plasma_cost = 600
	keybind_signal = COMSIG_XENOABILITY_QUEEN_GIVE_PLASMA

/datum/action/xeno_action/queen_give_plasma/action_activate()
	var/mob/living/carbon/xenomorph/queen/X = owner
	if(!X.check_state())
		return
	if(X.queen_ability_cooldown > world.time)
		to_chat(X, "<span class='xenowarning'>We're still recovering from our last overwatch ability. Wait [round((X.queen_ability_cooldown-world.time)*0.1)] seconds.</span>")
		return
	if(!X.observed_xeno)
		to_chat(X, "<span class='warning'>We must overwatch the xeno we want to give plasma to.</span>")
		return
	var/mob/living/carbon/xenomorph/target = X.observed_xeno
	if(target.stat == DEAD)
		return
	if(!(target.xeno_caste.caste_flags & CASTE_CAN_BE_GIVEN_PLASMA))
		to_chat(X, "<span class='warning'>We can't give that caste plasma.</span>")
		return
	if(target.plasma_stored >= target.xeno_caste.plasma_max)
		to_chat(X, "<span class='warning'>[target] is at full plasma.</span>")
		return
	if(X.check_plasma(600))
		X.use_plasma(600)
		target.gain_plasma(100)
		X.queen_ability_cooldown = world.time + 15 SECONDS //15 seconds
		to_chat(X, "<span class='xenonotice'>We transfer some plasma to [target].</span>")

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

	if(X.hive.living_xeno_queen?.observed_xeno == T)
		X.hive.living_xeno_queen.set_queen_overwatch(new_xeno)

	// this sets the right datum
	new_xeno.upgrade_xeno(T.upgrade_next()) //a young Crusher de-evolves into a MATURE Hunter

	log_game("[key_name(X)] has deevolved [key_name(T)]. Reason: [reason]")
	message_admins("[ADMIN_TPMONTY(X)] has deevolved [ADMIN_TPMONTY(T)]. Reason: [reason]")

	GLOB.round_statistics.total_xenos_created-- //so an evolved xeno doesn't count as two.
	qdel(T)
	X.use_plasma(600)

// ***************************************
// *********** Larval growth
// ***************************************
/datum/action/xeno_action/activable/larva_growth
	name = "Advance Larval Growth"
	action_icon_state = "larva_growth"
	mechanics_text = "Instantly cause the larva inside a host to grow a set amount."
	ability_name = "advance larval growth"
	plasma_cost = 300
	cooldown_timer = 15 SECONDS
	keybind_signal = COMSIG_XENOABILITY_QUEEN_LARVAL_GROWTH

/datum/action/xeno_action/activable/larva_growth/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(A) && !ismonkey(A))
		if(!silent)
			to_chat(owner, "<span class='xenowarning'>We can't accelerate the growth of that host")
		return FALSE

	var/obj/item/alien_embryo/E = locate(/obj/item/alien_embryo) in A

	if(!E)
		if(!silent)
			to_chat(owner, "<span class='xenowarning'>[A] doesn't have a larva growing inside of them.</xenowarning>")
		return FALSE

	if(E.stage >= 3)
		if(!silent)
			to_chat(owner, "<span class='xenowarning'>\The [E] inside of [A] is too old to be advanced.</xenowarning>")
		return FALSE


/datum/action/xeno_action/activable/larva_growth/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/queen/X = owner

	var/obj/item/alien_embryo/E = locate(/obj/item/alien_embryo) in A

	X.visible_message("<span class='xenowarning'>\The [X] begins buzzing menacingly at [A].</span>", \
	"<span class='xenowarning'>We start to advance larval growth inside of [A].</span>", \
	"<span class='italics'>You hear an angry buzzing...</span>")
	if(!do_after(X, 50, TRUE, A, BUSY_ICON_CLOCK_ALT) && X.check_plasma(300))
		return fail_activate()

	if(!can_use_ability(A, TRUE))
		return fail_activate()

	succeed_activate()
	X.visible_message("<span class='xenowarning'>\The [X] finishes buzzing, [X.p_their()] echo slowly waning away!</span>", \
	"<span class='xenowarning'>We advance the larval growth inside of [A] a little!</span>", \
	"<span class='italics'>You hear buzzing waning away...</span>")

	E.stage++
	add_cooldown()
