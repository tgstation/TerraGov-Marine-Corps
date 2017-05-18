//Xenomorph - Queen- Colonial Marines - Apophis775 - Last Edit: 11JUN16

/mob/living/carbon/Xenomorph/Queen
	caste = "Queen"
	name = "Queen"
	desc = "A huge, looming alien creature. The biggest and the baddest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Queen Walking"
	melee_damage_lower = 30
	melee_damage_upper = 46
	tacklemin = 4
	tacklemax = 6
	tackle_chance = 80
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = 0
	health = 300
	maxHealth = 300
	amount_grown = 0
	max_grown = 10
	storedplasma = 300
	maxplasma = 700
	plasma_gain = 30
	is_intelligent = 1
	speed = 0.8
	jelly = 1
	jellyMax = 800
	pixel_x = -16
	fire_immune = 1
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	jelly = 1
	armor_deflection = 45
	tier = 0 //Queen doesn't count towards population limit.
	upgrade = 0
	caste_desc = "The biggest and baddest xeno. The Queen controls the hive and plants eggs and royal jelly."
	var/breathing_counter = 0
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/plant,
		/mob/living/carbon/Xenomorph/Queen/proc/lay_egg,
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/psychic_whisper,
		/mob/living/carbon/Xenomorph/Queen/proc/gut,
		/mob/living/carbon/Xenomorph/proc/build_resin,
		/mob/living/carbon/Xenomorph/proc/corrosive_acid,
		/mob/living/carbon/Xenomorph/Queen/proc/screech,
		// /mob/living/carbon/Xenomorph/Queen/proc/produce_jelly, // Disabling this because the jelly system is clunky and relies on a competent Queen player
		/mob/living/carbon/Xenomorph/proc/claw_toggle,
		// /mob/living/carbon/Xenomorph/proc/bestial_roar,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/toggle_auras,
		/mob/living/carbon/Xenomorph/Queen/proc/set_orders,
	//	/mob/living/carbon/Xenomorph/proc/secure_host,
		/mob/living/carbon/Xenomorph/Queen/proc/hive_Message
		)

/mob/living/carbon/Xenomorph/Queen/New()

	..()

	xeno_message("<span class='xenoannounce'>A new Queen has risen to lead the Hive! Rejoice!</span>",3)
	playsound(loc, 'sound/voice/alien_queen_command.ogg', 75, 0, 20)

/mob/living/carbon/Xenomorph/Queen/Life()
	..()

	if(stat != DEAD && ++breathing_counter >= rand(12, 17)) //Increase the breathing variable each tick. Play it at random intervals.
		playsound(loc, pick('sound/voice/alien_queen_breath1.ogg', 'sound/voice/alien_queen_breath2.ogg'), 15, 1, -3)
		breathing_counter = 0 //Reset the counter

/mob/living/carbon/Xenomorph/Queen/gib()
	death(1) //Prevents resetting queen death timer.

/mob/living/carbon/Xenomorph/Queen/proc/lay_egg()

	set name = "Lay Egg (500)"
	set desc = "Lay an egg to produce huggers to impregnate prey with."
	set category = "Alien"

	if(!check_state())
		return

	var/turf/current_turf = get_turf(src)
	if(!current_turf || !istype(current_turf))
		return

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf

	if(!alien_weeds)
		src << "<span class='warning'>Your eggs wouldn't grow well enough here. Lay them on resin.</span>"
		return

	if(!check_alien_construction(current_turf))
		return

	if(check_plasma(500)) //New plasma check proc, removes/updates plasma automagically
		visible_message("<span class='xenowarning'>\The [src] has laid an egg!</span>", \
		"<span class='xenowarning'>You have laid an egg!</span>")
		new /obj/effect/alien/egg(current_turf)
	return

/obj/royaljelly
	name = "royal jelly"
	desc = "A greenish-yellow blob of slime that encourages xenomorph evolution."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "jelly"
	anchored = 1
	opacity = 0
	density = 0
	layer = 3.4 //On top of most things

/obj/royaljelly/attack_alien(mob/living/carbon/Xenomorph/M)
	if(!isXeno(M) || isXenoLarva(M))
		return

	if(M.jelly)
		M << "<span class='warning'>Royal jelly is already seeping in your veins.</span>"
		return

	if(!M.jellyMax)
		M << "<span class='warning'>The jelly gives off a revulsing smell. Something instinctively draws you away from it.</span>"
		return

	M.jelly = 1
	visible_message("<span class='xenonotice'>\The [M] greedily gulps down \the [src].", \
	"<span class='xenonotice'>You greedily gulp down \the [src].")
	del(src)

/mob/living/carbon/Xenomorph/Queen/proc/produce_jelly()

	set name = "Produce Jelly (350)"
	set desc = "Squirt out some royal jelly for hive advancement."
	set category = "Alien"

	if(!check_state())
		return

	var/turf/current_turf = get_turf(src)
	if(!current_turf || !istype(current_turf))
		return

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf

	if(!alien_weeds)
		src << "<span class='warning'>Your jelly would dry and dirty instantly there. Squirt it on resin.</span>"
		return

	if(!check_alien_construction(current_turf))
		return

	if(check_plasma(350)) //New plasma check proc, removes/updates plasma automagically
		visible_message("<span class='xenonotice'>\The [src] squirts out a greenish blob of jelly.</span>", \
		"<span class='xenonotice'>You squirt out a greenish blob of jelly.</span>")
		new /obj/royaljelly(current_turf)
	return

/mob/living/carbon/Xenomorph/Queen/proc/screech()
	set name = "Screech (250)"
	set desc = "Emit a screech that stuns prey."
	set category = "Alien"

	if(!check_state())
		return

	if(has_screeched)
		src << "<span class='warning'>You are not ready to screech again.</span>"
		return

	if(!check_plasma(250))
		return

	has_screeched = 1
	spawn(500)
		has_screeched = 0
		src << "<span class='warning'>You feel your throat muscles vibrate. You are ready to screech again.</span>"

	playsound(loc, 'sound/voice/alien_queen_screech.ogg', 75, 0)
	// playsound(loc, 'sound/voice/alien_cena.ogg', 75, 0)  //XMAS ONLY
	visible_message("<span class='xenohighdanger'>\The [src] emits an ear-splitting guttural roar!</span>")
	create_shriekwave() //Adds the visual effect. Wom wom wom

	for(var/mob/M in view())
		if(M && M.client)
			if(isXeno(M))
				shake_camera(M, 10, 1)
			else
				shake_camera(M, 30, 1) //50 deciseconds, SORRY 5 seconds was way too long. 3 seconds now

	for(var/mob/living/carbon/human/M in oview())
		if(istype(M.l_ear, /obj/item/clothing/ears/earmuffs) || istype(M.r_ear, /obj/item/clothing/ears/earmuffs))
			continue
		var/dist = get_dist(src,M)
		if(dist <= 4)
			M << "<span class='danger'>An ear-splitting guttural roar shakes the ground beneath your feet!</span>"
			M.stunned += 4 //Seems the effect lasts between 3-8 seconds.
			M.Weaken(4)
			if(!M.ear_deaf)
				M.ear_deaf += 8 //Deafens them temporarily
		else if(dist >= 5 && dist < 7)
			M.stunned += 3
			M << "<span class='danger'>The roar shakes your body to the core, freezing you in place!</span>"
	return

/mob/living/carbon/Xenomorph/Queen/proc/gut()
	set category = "Alien"
	set name = "Gut (200)"
	set desc = "While pulling someone, rip their guts out or tear them apart."

	if(!check_state())
		return

	if(last_special > world.time)
		return

	var/mob/living/carbon/victim = src.pulling
	if(!victim || isnull(victim) || !istype(victim))
		src << "<span class='warning'>You're not pulling anyone that can be gutted.</span>"
		return

	if(locate(/obj/item/alien_embryo) in victim) //Maybe they ate it??
		var/mob/living/carbon/human/H = victim
		if(victim.stat != DEAD) //Not dead yet.
			src << "<span class='xenowarning'>The host and child are still alive!</span>"
			return
		else if(istype(H) && ( world.time <= H.timeofdeath + H.revive_grace_period )) //Dead, but the host can still hatch, possibly.
			src << "<span class='xenowarning'>The child may still hatch! Not yet!</span>"
			return

	if(isXeno(victim))
		src << "<span class='warning'>You can't bring yourself to harm a fellow sister to this magnitude.</span>"
		return

	var/turf/cur_loc = victim.loc
	if(!cur_loc)
		return //logic
	if(!cur_loc || !istype(cur_loc))
		return

	if(!check_plasma(200))
		return

	last_special = world.time + 50

	visible_message("<span class='xenowarning'>\The [src] begins slowly lifting \the [victim] into the air.</span>", \
	"<span class='xenowarning'>You begin focusing your anger as you slowly lift \the [victim] into the air.</span>")
	if(do_after(src, 80, FALSE))
		if(!victim || isnull(victim))
			return
		if(victim.loc != cur_loc)
			return
		visible_message("<span class='xenodanger'>\The [src] viciously smashes and wrenches \the [victim] apart!</span>", \
		"<span class='xenodanger'>You suddenly unleash pure anger on \the [victim], instantly wrenching \him apart!</span>")
		emote("roar")
		attack_log += text("\[[time_stamp()]\] <font color='red'>gibbed [victim.name] ([victim.ckey])</font>")
		victim.attack_log += text("\[[time_stamp()]\] <font color='orange'>was gibbed by [src.name] ([src.ckey])</font>")
		victim.gib() //Splut

/mob/living/carbon/Xenomorph/Queen/proc/set_orders()
	set category = "Alien"
	set name = "Set Hive Orders (50)"
	set desc = "Give some specific orders to the hive. They can see this on the status pane."

	if(!check_state())
		return
	if(!check_plasma(50))
		return
	if(last_special > world.time)
		return

	var/txt = copytext(sanitize(input("Set the hive's orders to what? Leave blank to clear it.", "Hive Orders","")), 1, MAX_MESSAGE_LEN)

	if(txt)
		xeno_message("<B>The Queen has given a new order. Check Status pane for details.</B>")
		hive_orders = txt
	else
		hive_orders = ""

	last_special = world.time + 150

/mob/living/carbon/Xenomorph/Queen/proc/hive_Message()
	set category = "Alien"
	set name = "Word of the Queen (50)"
	set desc = "Send a message to all aliens in the hive that is big and visible"
	if(!check_plasma(50))
		return
	if(health <= 0)
		src << "<span class='warning'>You can't do that while unconcious.</span>"
		return 0
	var/input = input(src, "This message will be broadcast throughout the hive.", "Word of the Queen", "") as message|null
	if(!input)
		return

	var/queensWord = "<br><h2 class='alert'>The words of the queen reverberate in your head...</h2>"
	queensWord += "<br><span class='alert'>[input]</span><br>"

	if(ticker && ticker.mode)
		for(var/datum/mind/L in ticker.mode.xenomorphs)
			var/mob/living/carbon/Xenomorph/X = L.current
			if(X && X.client && istype(X) && !X.stat)
				X << sound(get_sfx("queen"),wait = 0,volume = 50)
				X << "[queensWord]"

	log_admin("[key_name(src)] has created a Word of the Queen report:")
	log_admin("[queensWord]")
	message_admins("[key_name_admin(src)] has created a Word of the Queen report.", 1)
