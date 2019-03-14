/datum/xeno_caste/queen
	caste_name = "Queen"
	display_name = "Queen"
	caste_type_path = /mob/living/carbon/Xenomorph/Queen
	caste_desc = "The biggest and baddest xeno. The Queen controls the hive and plants eggs"

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_ZERO

	// *** Melee Attacks *** //
	melee_damage_lower = 45
	melee_damage_upper = 55

	// *** Tackle *** //
	tackle_damage = 55

	// *** Speed *** //
	speed = 0.6

	// *** Plasma *** //
	plasma_max = 700
	plasma_gain = 30

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_FIRE_IMMUNE

	can_hold_eggs = CAN_HOLD_TWO_HANDS

	// *** Defense *** //
	armor_deflection = 45

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/medium, /datum/ammo/xeno/acid/medium)

	// *** Pheromones *** //
	aura_strength = 3 //The Queen's aura is strong and stays so, and gets devastating late game. Climbs by 1 to 5
	aura_allowed = list("frenzy", "warding", "recovery")

	// *** Queen Abilities *** //
	queen_leader_limit = 1 //Amount of leaders allowed

/datum/xeno_caste/queen/mature
	caste_desc = "The biggest and baddest xeno. The Queen controls the hive and plants eggs"

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage_lower = 50
	melee_damage_upper = 60

	// *** Tackle *** //
	tackle_damage = 60

	// *** Speed *** //
	speed = 0.5

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 40

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor_deflection = 50

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/medium/upgrade1, /datum/ammo/xeno/acid/medium)

	// *** Pheromones *** //
	aura_strength = 4

	// *** Queen Abilities *** //
	queen_leader_limit = 2

/datum/xeno_caste/queen/elder
	caste_desc = "The biggest and baddest xeno. The Empress controls multiple hives and planets."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage_lower = 55
	melee_damage_upper = 65

	// *** Tackle *** //
	tackle_damage = 65

	// *** Speed *** //
	speed = 0.4

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 50

	// *** Health *** //
	max_health = 350

	// *** Evolution *** //
	upgrade_threshold = 3200

	// *** Defense *** //
	armor_deflection = 55

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/medium/upgrade2, /datum/ammo/xeno/acid/medium)

	// *** Pheromones *** //
	aura_strength = 4.7

	// *** Queen Abilities *** //
	queen_leader_limit = 3

/datum/xeno_caste/queen/ancient
	caste_desc = "The most perfect Xeno form imaginable."
	ancient_message = "You are the Alpha and the Omega. The beginning and the end."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage_lower = 60
	melee_damage_upper = 70

	// *** Tackle *** //
	tackle_damage = 70

	// *** Speed *** //
	speed = 0.3

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 375

	// *** Evolution *** //
	upgrade_threshold = 3200

	// *** Defense *** //
	armor_deflection = 60

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/medium/upgrade3, /datum/ammo/xeno/acid/medium)

	// *** Pheromones *** //
	aura_strength = 5

	// *** Queen Abilities *** //
	queen_leader_limit = 4

/mob/living/carbon/Xenomorph/Queen/handle_decay()
	if(prob(20+abs(3*upgrade)))
		use_plasma(min(rand(1,2), plasma_stored))

/mob/living/carbon/Xenomorph/Queen
	caste_base_type = /mob/living/carbon/Xenomorph/Queen
	name = "Queen"
	desc = "A huge, looming alien creature. The biggest and the baddest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Queen Walking"
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = 0
	health = 300
	maxHealth = 300
	amount_grown = 0
	max_grown = 10
	plasma_stored = 300
	speed = 0.6
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = XENO_TIER_FOUR //Queen doesn't count towards population limit.
	upgrade = XENO_UPGRADE_ZERO
	xeno_explosion_resistance = 3 //some resistance against explosion stuns.

	var/breathing_counter = 0
	var/ovipositor = FALSE //whether the Queen is attached to an ovipositor
	var/ovipositor_cooldown = 0
	var/queen_ability_cooldown = 0
	var/mob/living/carbon/Xenomorph/observed_xeno //the Xenomorph the queen is currently overwatching
	var/egg_amount = 0 //amount of eggs inside the queen
	var/last_larva_time = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/grow_ovipositor,
		/datum/action/xeno_action/activable/screech,
		/datum/action/xeno_action/activable/corrosive_acid,
		// /datum/action/xeno_action/activable/gut, We're taking this out for now.
		/datum/action/xeno_action/psychic_whisper,
		/datum/action/xeno_action/shift_spits,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/larva_growth,
		/datum/action/xeno_action/toggle_pheromones
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/claw_toggle,
		/mob/living/carbon/Xenomorph/Queen/proc/set_orders,
		/mob/living/carbon/Xenomorph/Queen/proc/hive_Message
		)

/mob/living/carbon/Xenomorph/Queen/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/Xenomorph/Queen/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/Xenomorph/Queen/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/Xenomorph/Queen/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/Xenomorph/Queen/Initialize()
	. = ..()
	if(!is_centcom_level(z))//so admins can safely spawn Queens in Thunderdome for tests.
		hive.update_queen()
	playsound(loc, 'sound/voice/alien_queen_command.ogg', 75, 0)

/mob/living/carbon/Xenomorph/Queen/Destroy()
	. = ..()
	if(observed_xeno)
		set_queen_overwatch(observed_xeno, TRUE)

/mob/living/carbon/Xenomorph/Queen/Life()
	. = ..()

	if(stat == DEAD)
		return

	if(++breathing_counter >= rand(12, 17)) //Increase the breathing variable each tick. Play it at random intervals.
		playsound(loc, pick('sound/voice/alien_queen_breath1.ogg', 'sound/voice/alien_queen_breath2.ogg'), 15, 1, 4)
		breathing_counter = 0 //Reset the counter

	if(observed_xeno)
		if(observed_xeno.stat == DEAD || observed_xeno.gc_destroyed)
			set_queen_overwatch(observed_xeno, TRUE)

	if(!ovipositor || is_mob_incapacitated(TRUE))
		return

	egg_amount += 0.07 //one egg approximately every 30 seconds
	if(egg_amount < 1)
		return

	if(isturf(loc))
		var/turf/T = loc
		if(length(T.contents) <= 25) //so we don't end up with a million object on that turf.
			egg_amount--
			var/obj/item/xeno_egg/newegg = new /obj/item/xeno_egg(loc)
			newegg.hivenumber = hivenumber

	if(!isdistress(SSticker?.mode))
		return

	var/datum/game_mode/distress/D = SSticker.mode

	if(hivenumber != XENO_HIVE_NORMAL || !is_ground_level(loc.z))
		return

	if(!D.stored_larva)
		return

	if((last_larva_time + 1 MINUTES) > world.time)
		return

	last_larva_time = world.time
	var/picked = get_alien_candidate()
	if(!picked)
		return

	var/mob/living/carbon/Xenomorph/Larva/new_xeno = new /mob/living/carbon/Xenomorph/Larva(loc)
	new_xeno.visible_message("<span class='xenodanger'>A larva suddenly burrows out of the ground!</span>",
	"<span class='xenodanger'>You burrow out of the ground and awaken from your slumber. For the Hive!</span>")

	new_xeno.key = picked

	to_chat(new_xeno, "<span class='xenoannounce'>You are a xenomorph larva awakened from slumber!</span>")
	SEND_SOUND(new_xeno, sound('sound/effects/xeno_newlarva.ogg'))

	D.stored_larva--


//Custom bump for crushers. This overwrites normal bumpcode from carbon.dm
/mob/living/carbon/Xenomorph/Queen/Bump(atom/A, yes)
	set waitfor = 0

	//if(charge_speed < charge_speed_buildup * charge_turfs_to_charge || !is_charging) return ..()

	if(stat || !A || !istype(A) || A == src || !yes) return FALSE

	if(now_pushing) return FALSE//Just a plain ol turf, let's return.

	/*if(dir != charge_dir) //We aren't facing the way we're charging.
		stop_momentum()
		return ..()

	if(!handle_collision(A))
		if(!A.charge_act(src)) //charge_act is depricated and only here to handle cases that have not been refactored as of yet.
			return ..()*/

	var/turf/T = get_step(src, dir)
	if(!T || !get_step_to(src, T)) //If it still exists, try to push it.
		return ..()

	lastturf = null //Reset this so we can properly continue with momentum.
	return TRUE

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

/mob/living/carbon/Xenomorph/Queen/proc/queen_screech()
	if(!check_state())
		return

	if(has_screeched)
		to_chat(src, "<span class='warning'>You are not ready to screech again.</span>")
		return

	if(!check_plasma(250))
		return

	//screech is so powerful it kills huggers in our hands
	if(istype(r_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = r_hand
		if(FH.stat != DEAD)
			FH.Die()

	if(istype(l_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = l_hand
		if(FH.stat != DEAD)
			FH.Die()

	has_screeched = TRUE
	use_plasma(250)
	addtimer(CALLBACK(src, .screech_cooldown), 500)
	playsound(loc, 'sound/voice/alien_queen_screech.ogg', 75, 0)
	visible_message("<span class='xenohighdanger'>\The [src] emits an ear-splitting guttural roar!</span>")
	round_statistics.queen_screech++
	create_shriekwave() //Adds the visual effect. Wom wom wom
	//stop_momentum(charge_dir) //Screech kills a charge

	for(var/mob/M in view())
		if(M && M.client)
			if(isxeno(M))
				shake_camera(M, 10, 1)
			else
				shake_camera(M, 30, 1) //50 deciseconds, SORRY 5 seconds was way too long. 3 seconds now

	for(var/mob/living/carbon/human/H in oview(7, src))
		var/dist = get_dist(src,H)
		var/reduction = max(1 - 0.1 * H.protection_aura, 0) //Hold orders will reduce the Halloss; 10% per rank.
		var/halloss_damage = (max(0,140 - dist * 10)) * reduction //Max 130 beside Queen, 70 at the edge
		var/stun_duration = max(0,1.1 - dist * 0.1) * reduction //Max 1 beside Queen, 0.4 at the edge.

		if(dist < 8)
			to_chat(H, "<span class='danger'>An ear-splitting guttural roar tears through your mind and makes your world convulse!</span>")
			H.stunned += stun_duration
			H.KnockDown(stun_duration)
			H.apply_damage(halloss_damage, HALLOSS)
			if(!H.ear_deaf)
				H.ear_deaf += stun_duration * 20  //Deafens them temporarily
			//Perception distorting effects of the psychic scream
			addtimer(CALLBACK(GLOBAL_PROC, /proc/shake_camera, H, stun_duration * 10, 0.75), 31)

/mob/living/carbon/Xenomorph/Queen/proc/screech_cooldown()
	has_screeched = FALSE
	to_chat(src, "<span class='warning'>You feel your throat muscles vibrate. You are ready to screech again.</span>")
	update_action_buttons()

/mob/living/carbon/Xenomorph/Queen/proc/queen_gut(atom/A)

	if(!iscarbon(A))
		return

	var/mob/living/carbon/victim = A

	if(get_dist(src, victim) > 1)
		return

	if(!check_state())
		return

	if(last_special > world.time)
		return

	if(issynth(victim))
		var/datum/limb/head/synthhead = victim.get_limb("head")
		if(synthhead.limb_status & LIMB_DESTROYED)
			return

	if(locate(/obj/item/alien_embryo) in victim) //Maybe they ate it??
		var/mob/living/carbon/human/H = victim
		if(H.status_flags & XENO_HOST)
			if(victim.stat != DEAD) //Not dead yet.
				to_chat(src, "<span class='xenowarning'>The host and child are still alive!</span>")
				return
			else if(istype(H) && !H.check_tod()) //Dead, but the host can still hatch, possibly.
				to_chat(src, "<span class='xenowarning'>The child may still hatch! Not yet!</span>")
				return

	if(isxeno(victim))
		var/mob/living/carbon/Xenomorph/xeno = victim
		if(hivenumber == xeno.hivenumber)
			to_chat(src, "<span class='warning'>You can't bring yourself to harm a fellow sister to this magnitude.</span>")
			return

	var/turf/cur_loc = victim.loc
	if(!istype(cur_loc))
		return

	if(action_busy)
		return

	if(!check_plasma(200))
		return
	use_plasma(200)
	last_special = world.time + 50

	visible_message("<span class='xenowarning'>\The [src] begins slowly lifting \the [victim] into the air.</span>", \
	"<span class='xenowarning'>You begin focusing your anger as you slowly lift \the [victim] into the air.</span>")
	if(do_mob(src, victim, 80, BUSY_ICON_HOSTILE))
		if(!victim)
			return
		if(victim.loc != cur_loc)
			return
		visible_message("<span class='xenodanger'>\The [src] viciously smashes and wrenches \the [victim] apart!</span>", \
		"<span class='xenodanger'>You suddenly unleash pure anger on \the [victim], instantly wrenching [victim.p_them()] apart!</span>")
		emote("roar")
		log_combat(victim, src, "gibbed")
		victim.gib() //Splut
		stop_pulling()

/mob/living/carbon/Xenomorph/Queen/generate_name()
	switch(upgrade)
		if(0) 
			name = "[hive.prefix]Queen"			 //Young
		if(1) 
			name = "[hive.prefix]Elder Queen"	 //Mature
		if(2) 
			name = "[hive.prefix]Elder Empress"	 //Elder
		if(3) 
			name = "[hive.prefix]Ancient Empress" //Ancient

	real_name = name
	if(mind) mind.name = name 

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

/mob/living/carbon/Xenomorph/Queen/update_canmove()
	. = ..()
	if(ovipositor)
		lying = FALSE
		density = TRUE
		canmove = FALSE
		return canmove

/mob/living/carbon/Xenomorph/Queen/reset_view(atom/A)
	if (client)
		if(ovipositor && observed_xeno && !stat)
			client.perspective = EYE_PERSPECTIVE
			client.eye = observed_xeno
		else
			if (ismovableatom(A))
				client.perspective = EYE_PERSPECTIVE
				client.eye = A
			else
				if (isturf(loc))
					client.eye = client.mob
					client.perspective = MOB_PERSPECTIVE
				else
					client.perspective = EYE_PERSPECTIVE
					client.eye = loc

/mob/living/carbon/Xenomorph/Queen/update_icons()
	icon = initial(icon)
	if(stat == DEAD)
		icon_state = "Queen Dead"
	else if(ovipositor)
		icon = 'icons/Xeno/Ovipositor.dmi'
		icon_state = "Queen Ovipositor"
	else if(lying)
		if((resting || sleeping) && (!knocked_down && !knocked_out && health > 0))
			icon_state = "Queen Sleeping"
		else
			icon_state = "Queen Knocked Down"
	else
		if(m_intent == MOVE_INTENT_RUN)
			/*if(charge_speed > charge_speed_buildup * charge_turfs_to_charge) //Let it build up a bit so we're not changing icons every single turf
				icon_state = "Queen Charging"
			else*/
			icon_state = "Queen Running"
		else
			icon_state = "Queen Walking"

	update_fire() //the fire overlay depends on the xeno's stance, so we must update it.
	update_wounds()

/mob/living/carbon/Xenomorph/Queen/Topic(href, href_list)

	if(href_list["queentrack"])
		if(!check_state())
			return
		if(!ovipositor)
			return
		var/mob/living/carbon/Xenomorph/target = locate(href_list["queentrack"]) in GLOB.alive_xeno_list
		if(!istype(target))
			return
		if(target.stat == DEAD || is_centcom_level(target.z))
			return
		if(target == observed_xeno)
			set_queen_overwatch(target, TRUE)
		else
			set_queen_overwatch(target)

	if (href_list["watch_xeno_number"])
		if(!check_state())
			return
		var/xeno_num = text2num(href_list["watch_xeno_number"])
		for(var/mob/living/carbon/Xenomorph/X in GLOB.alive_xeno_list)
			if(!is_centcom_level(X.z) && X.nicknumber == xeno_num)
				if(observed_xeno == X)
					set_queen_overwatch(X, TRUE)
				else
					set_queen_overwatch(X)
				break
		return
	..()

//proc to modify which xeno, if any, the queen is observing.
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


/mob/living/carbon/Xenomorph/Queen/gib()
	death(1) //we need the body to show the queen's name at round end.

/mob/living/carbon/Xenomorph/Queen/death_cry()
	playsound(loc, 'sound/voice/alien_queen_died.ogg', 75, 0)

/mob/living/carbon/Xenomorph/Queen/xeno_death_alert()
	return

/mob/living/carbon/Xenomorph/Queen/death(gibbed)
	if(hive)
		hive.on_queen_death(src)
	. = ..()
	if(observed_xeno)
		set_queen_overwatch(observed_xeno, TRUE)
	if(ovipositor)
		dismount_ovipositor(TRUE)
