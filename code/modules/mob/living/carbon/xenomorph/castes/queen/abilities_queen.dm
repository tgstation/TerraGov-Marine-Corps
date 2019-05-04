// ***************************************
// *********** Hive orders
// ***************************************
/mob/living/carbon/Xenomorph/Queen/proc/set_orders()
	set category = "Alien"
	set name = "Set Hive Orders (50)"
	set desc = "Give some specific orders to the hive. They can see this on the status pane."

	if(hivenumber == XENO_HIVE_CORRUPTED)
		to_chat(src, "<span class='warning'>Only your masters can decide this!</span>")
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
/mob/living/carbon/Xenomorph/Queen/proc/hive_Message()
	set category = "Alien"
	set name = "Word of the Queen (50)"
	set desc = "Send a message to all aliens in the hive that is big and visible"
	if(!check_plasma(50))
		return
	plasma_stored -= 50
	if(health <= 0)
		to_chat(src, "<span class='warning'>You can't do that while unconcious.</span>")
		return 0
	var/input = stripped_multiline_input(src, "This message will be broadcast throughout the hive.", "Word of the Queen", "")
	if(!input)
		return

	var/queensWord = "<br><h2 class='alert'>The words of the queen reverberate in your head...</h2>"
	queensWord += "<br><span class='alert'>[input]</span><br>"

	INVOKE_ASYNC(src, .proc/do_hive_message, queensWord)

/mob/living/carbon/Xenomorph/Queen/proc/do_hive_message(queensWord)
	if(SSticker?.mode)
		hive.xeno_message("[queensWord]")
		for(var/i in hive.get_watchable_xenos())
			var/mob/living/carbon/Xenomorph/X = i
			SEND_SOUND(X, sound(get_sfx("queen"), wait = 0,volume = 50))

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/G = i
		SEND_SOUND(G, sound(get_sfx("queen"), wait = 0,volume = 50))
		to_chat(G, "[queensWord]")

	log_admin("[key_name(src)] has created a Word of the Queen report: [queensWord]")
	message_admins("[ADMIN_TPMONTY(src)] has created a Word of the Queen report.")

// ***************************************
// *********** Slashing permissions
// ***************************************
/mob/living/carbon/Xenomorph/proc/claw_toggle()
	set name = "Permit/Disallow Slashing"
	set desc = "Allows you to permit the hive to harm."
	set category = "Alien"

	if(hivenumber == XENO_HIVE_CORRUPTED)
		to_chat(src, "<span class='warning'>Only your masters can decide this!</span>")
		return

	if(stat)
		to_chat(src, "<span class='warning'>You can't do that now.</span>")
		return

	if(pslash_delay)
		to_chat(src, "<span class='warning'>You must wait a bit before you can toggle this again.</span>")
		return

	addtimer(CALLBACK(src, .slash_toggle_delay), 300)

	pslash_delay = TRUE

	var/choice = input("Choose which level of slashing hosts to permit to your hive.","Harming") as null|anything in list("Allowed", "Restricted - Less Damage", "Forbidden")

	if(choice == "Allowed")
		to_chat(src, "<span class='xenonotice'>You allow slashing.</span>")
		xeno_message("The Queen has <b>permitted</b> the harming of hosts! Go hog wild!")
		hive.slashing_allowed = XENO_SLASHING_ALLOWED
	else if(choice == "Restricted - Less Damage")
		to_chat(src, "<span class='xenonotice'>You restrict slashing.</span>")
		xeno_message("The Queen has <b>restricted</b> the harming of hosts. You will only slash when hurt.")
		hive.slashing_allowed = XENO_SLASHING_RESTRICTED
	else if(choice == "Forbidden")
		to_chat(src, "<span class='xenonotice'>You forbid slashing entirely.</span>")
		xeno_message("The Queen has <b>forbidden</b> the harming of hosts. You can no longer slash your enemies.")
		hive.slashing_allowed = XENO_SLASHING_FORBIDDEN

/mob/living/carbon/Xenomorph/proc/slash_toggle_delay()
	pslash_delay = FALSE

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

/datum/action/xeno_action/activable/screech/on_cooldown_finish()
	to_chat(owner, "<span class='warning'>You feel your throat muscles vibrate. You are ready to screech again.</span>")
	return ..()

/datum/action/xeno_action/activable/screech/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Queen/X = owner

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
	round_statistics.queen_screech++
	X.create_shriekwave() //Adds the visual effect. Wom wom wom
	//stop_momentum(charge_dir) //Screech kills a charge

	for(var/mob/living/L in range(world.view, X))
		if(L.stat == DEAD)
			continue
		L.screech_act(X)

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
	var/mob/living/carbon/Xenomorph/Queen/X = owner
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
			else if(istype(H) && !H.check_tod()) //Dead, but the host can still hatch, possibly.
				if(!silent)
					to_chat(owner, "<span class='xenowarning'>The child may still hatch! Not yet!</span>")
				return FALSE
	if(owner.issamexenohive(victim))
		if(!silent)
			to_chat(owner, "<span class='warning'>You can't bring yourself to harm a fellow sister to this magnitude.</span>")
		return FALSE

/datum/action/xeno_action/activable/gut/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	var/mob/living/carbon/victim = A

	succeed_activate()

	X.last_special = world.time + 5 SECONDS

	X.visible_message("<span class='xenowarning'>\The [X] begins slowly lifting \the [victim] into the air.</span>", \
	"<span class='xenowarning'>You begin focusing your anger as you slowly lift \the [victim] into the air.</span>")
	if(!do_mob(X, victim, 80, BUSY_ICON_HOSTILE))
		return fail_activate()
	if(!can_use_ability(victim,TRUE,XACT_IGNORE_PLASMA))
		return fail_activate()
	if(victim.loc != X.loc)
		return fail_activate()
	X.visible_message("<span class='xenodanger'>\The [X] viciously smashes and wrenches \the [victim] apart!</span>", \
	"<span class='xenodanger'>You suddenly unleash pure anger on \the [victim], instantly wrenching [victim.p_them()] apart!</span>")
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

/datum/action/xeno_action/grow_ovipositor/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return

	var/turf/current_turf = get_turf(X)
	if(!current_turf || !istype(current_turf))
		return

	if(X.ovipositor_cooldown > world.time)
		to_chat(X, "<span class='xenowarning'>You're still recovering from detaching your old ovipositor. Wait [round((X.ovipositor_cooldown-world.time)*0.1)] seconds</span>")
		return

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf

	if(!alien_weeds)
		to_chat(X, "<span class='xenowarning'>You need to be on resin to grow an ovipositor.</span>")
		return

	if(!current_turf.check_alien_construction(X))
		return

	if(X.action_busy)
		return

	if(X.check_plasma(plasma_cost))
		X.visible_message("<span class='xenowarning'>\The [X] starts to grow an ovipositor.</span>", \
		"<span class='xenowarning'>You start to grow an ovipositor...(takes 20 seconds, hold still)</span>")
		if(!do_after(X, 200, TRUE, 20, BUSY_ICON_FRIENDLY) && X.check_plasma(plasma_cost))
			return
		if(!X.check_state()) return
		if(!locate(/obj/effect/alien/weeds) in current_turf)
			return

		X.use_plasma(plasma_cost)
		X.visible_message("<span class='xenowarning'>\The [X] has grown an ovipositor!</span>", \
		"<span class='xenowarning'>You have grown an ovipositor!</span>")
		X.mount_ovipositor()

/datum/action/xeno_action/remove_eggsac
	name = "Remove Eggsac"
	action_icon_state = "grow_ovipositor"
	mechanics_text = "Get off your ovipositor, causing it to collapse. You must grow a new one the next time you wish to reattach."

/datum/action/xeno_action/remove_eggsac/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner

	var/answer = alert(X, "Are you sure you want to remove your ovipositor? (5min cooldown to grow a new one)", , "Yes", "No")
	if(answer != "Yes")
		return
	if(!can_use_action())
		return
	if(!X.ovipositor)
		return
	X.visible_message("<span class='xenowarning'>\The [X] starts detaching itself from its ovipositor!</span>", \
		"<span class='xenowarning'>You start detaching yourself from your ovipositor.</span>")
	if(!do_after(X, 50, FALSE, 10, BUSY_ICON_HOSTILE)) return
	if(!X.check_state())
		return
	if(!X.ovipositor)
		return
	X.dismount_ovipositor()

/mob/living/carbon/Xenomorph/Queen/proc/mount_ovipositor()
	if(ovipositor) return //sanity check
	ovipositor = TRUE

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
	resting = FALSE
	update_canmove()
	update_icons()

	hive?.update_leader_pheromones()

	hive?.xeno_message("<span class='xenoannounce'>The Queen has grown an ovipositor.</span>", 3)

/mob/living/carbon/Xenomorph/Queen/proc/dismount_ovipositor(instant_dismount)
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

/datum/action/xeno_action/watch_xeno/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.hive)
		return
	var/list/possible_xenos = X.hive.get_watchable_xenos()

	var/mob/living/carbon/Xenomorph/selected_xeno = input(X, "Target", "Watch which xenomorph?") as null|anything in possible_xenos
	if(!selected_xeno || selected_xeno.gc_destroyed || selected_xeno == X.observed_xeno || selected_xeno.stat == DEAD || is_centcom_level(selected_xeno.z) || !X.check_state())
		if(X.observed_xeno)
			X.set_queen_overwatch(X.observed_xeno, TRUE)
	else
		X.set_queen_overwatch(selected_xeno)

/mob/living/carbon/Xenomorph/Queen/proc/set_queen_overwatch(mob/living/carbon/Xenomorph/target, stop_overwatch)
	if(stop_overwatch)
		observed_xeno = null
	else
		var/mob/living/carbon/Xenomorph/old_xeno = observed_xeno
		observed_xeno = target
		if(old_xeno)
			old_xeno.hud_set_queen_overwatch()
	if(!target.gc_destroyed) //not cdel'd
		target.hud_set_queen_overwatch()
	reset_view()

// ***************************************
// *********** Psychic Whisper
// ***************************************
/datum/action/xeno_action/psychic_whisper
	name = "Psychic Whisper"
	action_icon_state = "psychic_whisper"

/datum/action/xeno_action/psychic_whisper/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	var/list/target_list = list()
	for(var/mob/living/possible_target in view(7, X))
		if(possible_target == X || !possible_target.client) continue
		target_list += possible_target

	var/mob/living/M = input("Target", "Send a Psychic Whisper to whom?") as null|anything in target_list
	if(!M) return

	if(!X.check_state())
		return

	var/msg = sanitize(input("Message:", "Psychic Whisper") as text|null)
	if(msg)
		log_directed_talk(X, M, msg, LOG_SAY, "psychic whisper")
		to_chat(M, "<span class='alien'>You hear a strange, alien voice in your head. \italic \"[msg]\"</span>")
		to_chat(X, "<span class='xenonotice'>You said: \"[msg]\" to [M]</span>")

// ***************************************
// *********** Queen zoom
// ***************************************
/datum/action/xeno_action/toggle_queen_zoom
	name = "Toggle Queen Zoom"
	action_icon_state = "toggle_queen_zoom"
	mechanics_text = "Zoom out for a larger view around wherever you are looking."
	plasma_cost = 0

/datum/action/xeno_action/toggle_queen_zoom/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
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

/datum/action/xeno_action/set_xeno_lead/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	if(!X.hive)
		return

	if(X.observed_xeno)
		if(!(X.observed_xeno.xeno_caste.caste_flags & CASTE_CAN_BE_LEADER))
			to_chat(X, "<span class='xenowarning'>This caste is unfit to lead.</span>")
			return
		if(X.queen_ability_cooldown > world.time)
			to_chat(X, "<span class='xenowarning'>You're still recovering from your last overwatch ability. Wait [round((X.queen_ability_cooldown-world.time)*0.1)] seconds.</span>")
			return
		if(X.xeno_caste.queen_leader_limit <= X.hive.xeno_leader_list.len && !X.observed_xeno.queen_chosen_lead)
			to_chat(X, "<span class='xenowarning'>You currently have [X.hive.xeno_leader_list.len] promoted leaders. You may not maintain additional leaders until your power grows.</span>")
			return
		var/mob/living/carbon/Xenomorph/T = X.observed_xeno
		X.queen_ability_cooldown = world.time + 150 //15 seconds
		if(!T.queen_chosen_lead)
			to_chat(X, "<span class='xenonotice'>You've selected [T] as a Hive Leader.</span>")
			to_chat(T, "<span class='xenoannounce'>[X] has selected you as a Hive Leader. The other Xenomorphs must listen to you. You will also act as a beacon for the Queen's pheromones.</span>")
			X.hive.add_leader(T)
		else
			to_chat(X, "<span class='xenonotice'>You've demoted [T] from Lead.</span>")
			to_chat(T, "<span class='xenoannounce'>[X] has demoted you from Hive Leader. Your leadership rights and abilities have waned.</span>")
			X.hive.remove_leader(T)
		T.hud_set_queen_overwatch()
		T.handle_xeno_leader_pheromones(X)
	else
		if(length(X.hive.xeno_leader_list) > 1) 
			var/mob/living/carbon/Xenomorph/selected_xeno = input(X, "Target", "Watch which xenomorph leader?") as null|anything in X.hive.xeno_leader_list
			if(!selected_xeno || !selected_xeno.queen_chosen_lead || selected_xeno == X.observed_xeno || selected_xeno.stat == DEAD || selected_xeno.z != X.z || !X.check_state())
				return
			X.set_queen_overwatch(selected_xeno)
		else if(X.hive.xeno_leader_list.len)
			X.set_queen_overwatch(X.hive.xeno_leader_list[1])
		else
			to_chat(X, "<span class='xenowarning'>There are no Xenomorph leaders. Overwatch a Xenomorph to make it a leader.</span>")

// ***************************************
// *********** Queen heal
// ***************************************
/datum/action/xeno_action/queen_heal
	name = "Heal Xenomorph (600)"
	action_icon_state = "heal_xeno"
	mechanics_text = "Heals a target Xenomorph (you must be overwatching them.)"
	plasma_cost = 600

/datum/action/xeno_action/queen_heal/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	if(X.queen_ability_cooldown > world.time)
		to_chat(X, "<span class='xenowarning'>You're still recovering from your last overwatch ability. Wait [round((X.queen_ability_cooldown-world.time)*0.1)] seconds.</span>")
		return
	if(!X.observed_xeno)
		to_chat(X, "<span class='warning'>You must overwatch the xeno you want to give healing to.</span>")
		return
	var/mob/living/carbon/Xenomorph/target = X.observed_xeno
	if(!(target.xeno_caste.caste_flags & CASTE_CAN_BE_QUEEN_HEALED))
		to_chat(X, "<span class='xenowarning'>You can't heal that caste.</span>")
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
		to_chat(X, "<span class='xenonotice'>You channel your plasma to heal [target]'s wounds.</span>")

// ***************************************
// *********** Queen plasma
// ***************************************
/datum/action/xeno_action/queen_give_plasma
	name = "Give Plasma (600)"
	action_icon_state = "queen_give_plasma"
	mechanics_text = "Give plasma to a target Xenomorph (you must be overwatching them.)"
	plasma_cost = 600

/datum/action/xeno_action/queen_give_plasma/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	if(X.queen_ability_cooldown > world.time)
		to_chat(X, "<span class='xenowarning'>You're still recovering from your last overwatch ability. Wait [round((X.queen_ability_cooldown-world.time)*0.1)] seconds.</span>")
		return
	if(!X.observed_xeno)
		to_chat(X, "<span class='warning'>You must overwatch the xeno you want to give plasma to.</span>")
		return
	var/mob/living/carbon/Xenomorph/target = X.observed_xeno
	if(target.stat == DEAD)
		return
	if(!(target.xeno_caste.caste_flags & CASTE_CAN_BE_GIVEN_PLASMA))
		to_chat(X, "<span class='warning'>You can't give that caste plasma.</span>")
		return
	if(target.plasma_stored >= target.xeno_caste.plasma_max)
		to_chat(X, "<span class='warning'>[target] is at full plasma.</span>")
		return
	if(X.check_plasma(600))
		X.use_plasma(600)
		target.gain_plasma(100)
		X.queen_ability_cooldown = world.time + 15 SECONDS //15 seconds
		to_chat(X, "<span class='xenonotice'>You transfer some plasma to [target].</span>")

// ***************************************
// *********** Queen order
// ***************************************
/datum/action/xeno_action/queen_order
	name = "Give Order (100)"
	action_icon_state = "queen_order"
	plasma_cost = 100

/datum/action/xeno_action/queen_order/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	if(X.observed_xeno)
		var/mob/living/carbon/Xenomorph/target = X.observed_xeno
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
					log_admin("[key_name(X)] has given the following Queen order to [key_name(target)]: [input]")
					message_admins("[ADMIN_TPMONTY(X)] has given the following Queen order to [ADMIN_TPMONTY(target)]: [input]")

	else
		to_chat(X, "<span class='warning'>You must overwatch the Xenomorph you want to give orders to.</span>")

// ***************************************
// *********** Queen deevolve
// ***************************************
/datum/action/xeno_action/deevolve
	name = "De-Evolve a Xenomorph"
	action_icon_state = "xeno_deevolve"
	mechanics_text = "De-evolve a target Xenomorph of Tier 2 or higher to the next lowest tier."
	plasma_cost = 600

/datum/action/xeno_action/deevolve/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	if(!X.observed_xeno)
		to_chat(X, "<span class='warning'>You must overwatch the xeno you want to de-evolve.</span>")
		return

	var/mob/living/carbon/Xenomorph/T = X.observed_xeno
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

	to_chat(T, "<span class='xenowarning'>The queen is deevolving you for the following reason: [reason]</span>")

	var/xeno_type = new_caste.caste_type_path

	//From there, the new xeno exists, hopefully
	var/mob/living/carbon/Xenomorph/new_xeno = new xeno_type(get_turf(T))

	if(!istype(new_xeno))
		//Something went horribly wrong!
		to_chat(X, "<span class='warning'>Something went terribly wrong here. Your new xeno is null! Tell a coder immediately!</span>")
		if(new_xeno)
			qdel(new_xeno)
		return

	if(T.mind)
		T.mind.transfer_to(new_xeno)
	else
		new_xeno.key = T.key
		if(new_xeno.client)
			new_xeno.client.change_view(world.view)
			new_xeno.client.pixel_x = 0
			new_xeno.client.pixel_y = 0

	//Pass on the unique nicknumber, then regenerate the new mob's name now that our player is inside
	new_xeno.nicknumber = T.nicknumber
	new_xeno.generate_name()

	if(T.xeno_mobhud)
		var/datum/mob_hud/H = huds[MOB_HUD_XENO_STATUS]
		H.add_hud_to(new_xeno) //keep our mobhud choice
		new_xeno.xeno_mobhud = TRUE

	new_xeno.middle_mouse_toggle = T.middle_mouse_toggle //Keep our toggle state

	for(var/obj/item/W in T.contents) //Drop stuff
		T.dropItemToGround(W)

	T.empty_gut()
	new_xeno.visible_message("<span class='xenodanger'>A [new_xeno.xeno_caste.caste_name] emerges from the husk of \the [T].</span>", \
	"<span class='xenodanger'>[X] makes you regress into your previous form.</span>")

	if(T.queen_chosen_lead)
		new_xeno.queen_chosen_lead = TRUE
		new_xeno.hud_set_queen_overwatch()

	if(X.hive.living_xeno_queen?.observed_xeno == T)
		X.hive.living_xeno_queen.set_queen_overwatch(new_xeno)

	// this sets the right datum
	new_xeno.upgrade_xeno(T.upgrade_next()) //a young Crusher de-evolves into a MATURE Hunter

	log_admin("[key_name(X)] has deevolved [key_name(T)]. Reason: [reason]")
	message_admins("[ADMIN_TPMONTY(X)] has deevolved [ADMIN_TPMONTY(T)]. Reason: [reason]")

	round_statistics.total_xenos_created-- //so an evolved xeno doesn't count as two.
	qdel(T)
	X.use_plasma(600)

// ***************************************
// *********** Larval growth
// ***************************************
/datum/action/xeno_action/activable/larva_growth
	name = "Advance Larval Growth (300)"
	action_icon_state = "larva_growth"
	mechanics_text = "Instantly cause the larva inside a host to grow a set amount."
	ability_name = "advance larval growth"

/datum/action/xeno_action/activable/larva_growth/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	if(world.time > X.last_larva_growth_used + XENO_LARVAL_ADVANCEMENT_COOLDOWN)
		return TRUE

/datum/action/xeno_action/activable/larva_growth/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state() || X.action_busy)
		return

	if(world.time < X.last_larva_growth_used + XENO_LARVAL_ADVANCEMENT_COOLDOWN)
		to_chat(X, "<span class='xenowarning'>You're still recovering from your previous larva growth advance. Wait [round((X.last_larva_growth_used + XENO_LARVAL_ADVANCEMENT_COOLDOWN - world.time) * 0.1)] seconds.</span>")
		return

	if(!istype(A, /mob/living/carbon/human))
		return

	var/mob/living/carbon/human/H = A

	var/obj/item/alien_embryo/E = locate(/obj/item/alien_embryo) in H

	if(!E)
		to_chat(X, "<span class='xenowarning'>[H] doesn't have a larva growing inside of them.</xenowarning>")
		return

	if(E.stage >= 3)
		to_chat(X, "<span class='xenowarning'>\The [E] inside of [H] is too old to be advanced.</xenowarning>")
		return

	if(X.check_plasma(300))
		X.visible_message("<span class='xenowarning'>\The [X] starts to advance larval growth inside of [H].</span>", \
		"<span class='xenowarning'>You start to advance larval growth inside of [H].</span>")
		if(!do_after(X, 50, TRUE, 20, BUSY_ICON_FRIENDLY) && X.check_plasma(300))
			return
		if(!X.check_state())
			return
		X.use_plasma(300)
		X.visible_message("<span class='xenowarning'>\The [E] inside of [H] grows a little!</span>", \
		"<span class='xenowarning'>\The [E] inside of [H] grows a little!</span>")

		E.stage++
		X.last_larva_growth_used = world.time
