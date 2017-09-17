
var/mob/living/carbon/Xenomorph/Queen/living_xeno_queen //global reference to the Xeno Queen if there's one alive.

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
	speed = 0.3
	evolution_threshold = 800
	pixel_x = -16
	fire_immune = 1
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	armor_deflection = 45
	tier = 0 //Queen doesn't count towards population limit.
	upgrade = 0
	aura_strength = 2 //The Queen's aura is strong and stays so, and gets devastating late game. Climbs by 1 to 5
	caste_desc = "The biggest and baddest xeno. The Queen controls the hive and plants eggs"
	xeno_explosion_resistance = 1 //some resistance against explosion stuns.
	var/breathing_counter = 0
	actions = list(
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/secrete_resin,
		/datum/action/xeno_action/lay_egg,
		/datum/action/xeno_action/activable/screech,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/emit_pheromones,
		/datum/action/xeno_action/activable/gut,
		/datum/action/xeno_action/psychic_whisper,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/claw_toggle,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/Queen/proc/set_orders,
		/mob/living/carbon/Xenomorph/Queen/proc/hive_Message
		)

/mob/living/carbon/Xenomorph/Queen/New()

	..()
	if(!living_xeno_queen)
		living_xeno_queen = src
	xeno_message("<span class='xenoannounce'>A new Queen has risen to lead the Hive! Rejoice!</span>",3)
	playsound(loc, 'sound/voice/alien_queen_command.ogg', 75, 0)

/mob/living/carbon/Xenomorph/Queen/Dispose()
	. = ..()
	if(living_xeno_queen == src)
		living_xeno_queen = null

/mob/living/carbon/Xenomorph/Queen/Life()
	..()

	if(stat != DEAD && ++breathing_counter >= rand(12, 17)) //Increase the breathing variable each tick. Play it at random intervals.
		playsound(loc, pick('sound/voice/alien_queen_breath1.ogg', 'sound/voice/alien_queen_breath2.ogg'), 15, 1, 4)
		breathing_counter = 0 //Reset the counter

/mob/living/carbon/Xenomorph/Queen/gib()
	death(1) //Prevents resetting queen death timer.





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
	storedplasma -= 50
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
	storedplasma -= 50
	if(health <= 0)
		src << "<span class='warning'>You can't do that while unconcious.</span>"
		return 0
	var/input = input(src, "This message will be broadcast throughout the hive.", "Word of the Queen", "") as message|null
	input = html_encode(input)
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


/mob/living/carbon/Xenomorph/proc/claw_toggle()
	set name = "Permit/Disallow Slashing"
	set desc = "Allows you to permit the hive to harm."
	set category = "Alien"

	if(stat)
		src << "<span class='warning'>You can't do that now.</span>"
		return

	if(pslash_delay)
		src << "<span class='warning'>You must wait a bit before you can toggle this again.</span>"
		return

	spawn(300)
		pslash_delay = 0

	pslash_delay = 1


	var/choice = input("Choose which level of slashing hosts to permit to your hive.","Harming") as null|anything in list("Allowed", "Restricted - Less Damage", "Forbidden")

	if(choice == "Allowed")
		src << "<span class='xenonotice'>You allow slashing.</span>"
		xeno_message("The Queen has <b>permitted</b> the harming of hosts! Go hog wild!", 3)
		slashing_allowed = 1
	else if(choice == "Restricted - Less Damage")
		src << "<span class='xenonotice'>You restrict slashing.</span>"
		xeno_message("The Queen has <b>restricted</b> the harming of hosts. You will only slash when hurt.", 3)
		slashing_allowed = 2
	else if(choice == "Forbidden")
		src << "<span class='xenonotice'>You forbid slashing entirely.</span>"
		xeno_message("The Queen has <b>forbidden</b> the harming of hosts. You can no longer slash your enemies.", 3)
		slashing_allowed = 0

/mob/living/carbon/Xenomorph/Queen/proc/queen_screech()
	if(!check_state())
		return

	if(has_screeched)
		src << "<span class='warning'>You are not ready to screech again.</span>"
		return

	if(!check_plasma(250))
		return

	has_screeched = 1
	use_plasma(250)
	spawn(500)
		has_screeched = 0
		src << "<span class='warning'>You feel your throat muscles vibrate. You are ready to screech again.</span>"
		for(var/Z in actions)
			var/datum/action/A = Z
			A.update_button_icon()
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

	for(var/mob/living/carbon/human/M in oview(7, src))
		if(istype(M.wear_ear, /obj/item/clothing/ears/earmuffs))
			continue
		var/dist = get_dist(src,M)
		if(dist <= 4)
			M << "<span class='danger'>An ear-splitting guttural roar shakes the ground beneath your feet!</span>"
			M.stunned += 4 //Seems the effect lasts between 3-8 seconds.
			M.KnockDown(4)
			if(!M.ear_deaf)
				M.ear_deaf += 8 //Deafens them temporarily
		else if(dist >= 5 && dist < 7)
			M.stunned += 3
			M << "<span class='danger'>The roar shakes your body to the core, freezing you in place!</span>"



/mob/living/carbon/Xenomorph/Queen/proc/queen_gut(atom/A)

	if(!iscarbon(A))
		return

	var/mob/living/carbon/victim = A

	if(!check_state())
		return

	if(last_special > world.time)
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
	if(!istype(cur_loc))
		return

	if(!check_plasma(200))
		return
	use_plasma(200)
	last_special = world.time + 50

	visible_message("<span class='xenowarning'>\The [src] begins slowly lifting \the [victim] into the air.</span>", \
	"<span class='xenowarning'>You begin focusing your anger as you slowly lift \the [victim] into the air.</span>")
	if(do_mob(src, victim, 80, BUSY_ICON_CLOCK))
		if(!victim)
			return
		if(victim.loc != cur_loc)
			return
		visible_message("<span class='xenodanger'>\The [src] viciously smashes and wrenches \the [victim] apart!</span>", \
		"<span class='xenodanger'>You suddenly unleash pure anger on \the [victim], instantly wrenching \him apart!</span>")
		emote("roar")
		attack_log += text("\[[time_stamp()]\] <font color='red'>gibbed [victim.name] ([victim.ckey])</font>")
		victim.attack_log += text("\[[time_stamp()]\] <font color='orange'>was gibbed by [name] ([ckey])</font>")
		victim.gib() //Splut