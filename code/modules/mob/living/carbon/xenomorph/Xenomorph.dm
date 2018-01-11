//Xenomorph "generic" parent, does not actually appear in game
//Many of these defines aren't referenced in the castes and so are assumed to be defaulted
//Castes are all merely subchildren of this parent
//Just about ALL the procs are tied to the parent, not to the children
//This is so they can be easily transferred between them without copypasta

//All this stuff was written by Absynth.
//Edited by Apop - 11JUN16

#define DEBUG_XENO 0

#if DEBUG_XENO
/mob/verb/debug_xeno_mind()
	set name =  "Debug Xeno Mind"
	set category = "Debug"
	set desc = "Shows whether or not a mine is contained within the xenomorph list."

	if(!ticker || ticker.current_state != GAME_STATE_PLAYING || !ticker.mode)
		src << "<span class='warning'>The round is either not ready, or has already finished.</span>"
		return
	if(mind in ticker.mode.xenomorphs)
		src << "<span class='debuginfo'>[src] mind is in the xenomorph list. Mind key is [mind.key].</span>"
		src << "<span class='debuginfo'>Current mob is: [mind.current]. Original mob is: [mind.original].</span>"
	else src << "<span class='debuginfo'>This xenomorph is not in the xenomorph list.</span>"
#endif

#undef DEBUG_XENO

//This initial var allows the queen to turn on or off slashing. Slashing off means harm intent does much less damage.
var/global/slashing_allowed = 1
var/global/queen_time = 300 //5 minutes between queen deaths
var/global/hive_orders = "" //What orders should the hive have

/mob/living/carbon/Xenomorph
	name = "Drone"
	desc = "What the hell is THAT?"
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Drone Walking"
	voice_name = "xenomorph"
	speak_emote = list("hisses")
	melee_damage_lower = 5
	melee_damage_upper = 10 //Arbitrary damage values
	attacktext = "claws"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = 0
	universal_understand = 0
	universal_speak = 0
	health = 5
	maxHealth = 5
	mob_size = MOB_SIZE_XENO
	hand = 1 //Make right hand active by default. 0 is left hand, mob defines it as null normally
	see_in_dark = 8
	see_infrared = 1
	see_invisible = SEE_INVISIBLE_MINIMUM
	hud_possible = list(HEALTH_HUD_XENO, PLASMA_HUD, PHEROMONE_HUD,QUEEN_OVERWATCH_HUD)
	unacidable = TRUE


/mob/living/carbon/Xenomorph/New()
	..()
	//WO GAMEMODE
	if(ticker && istype(ticker.mode,/datum/game_mode/whiskey_outpost))
		hardcore = 1 //Prevents healing and queen evolution
	time_of_birth = world.time
	add_language("Xenomorph") //xenocommon
	add_language("Hivemind") //hivemind
	add_inherent_verbs()
	add_abilities()

	sight |= SEE_MOBS
	see_invisible = SEE_INVISIBLE_MINIMUM
	see_in_dark = 8


	if(spit_types && spit_types.len)
		ammo = ammo_list[spit_types[1]]

	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	gender = NEUTER

	round_statistics.total_xenos_created++

	if(adjust_size_x != 1)
		var/matrix/M = matrix()
		M.Scale(adjust_size_x, adjust_size_y)
		transform = M

	spawn(6) //Mind has to be transferred! Hopefully this will give it enough time to do so.
		generate_name()

	regenerate_icons()

//Off-load this proc so it can be called freely
//Since Xenos change names like they change shoes, we need somewhere to hammer in all those legos
//We set their name first, then update their real_name AND their mind name
/mob/living/carbon/Xenomorph/proc/generate_name()

	//We don't have a nicknumber yet, assign one to stick with us
	if(!nicknumber) nicknumber = rand(1, 999)

	//Larvas have their own, very weird naming conventions, let's not kick a beehive, not yet
	if(caste == "Larva")
		return

	//Queens have weird, hardcoded naming conventions based on upgrade levels. They also never get nicknumbers
	if(caste == "Queen")
		switch(upgrade)
			if(0) name = "\improper Queen"			 //Young
			if(1) name = "\improper Elite Queen"	 //Mature
			if(2) name = "\improper Elite Empress"	 //Elite
			if(3) name = "\improper Ancient Empress" //Ancient
	else if(caste == "Predalien") name = "\improper [name] ([nicknumber])"
	else name = "\improper [upgrade_name] [caste] ([nicknumber])"

	//Update linked data so they show up properly
	real_name = name
	if(mind) mind.name = name //This gives them the proper name in deadchat if they explode on death. It's always the small things

/mob/living/carbon/Xenomorph/examine(mob/user)
	..()
	if(isXeno(user) && caste_desc)
		user << caste_desc

	if(stat == DEAD)
		user << "It is DEAD. Kicked the bucket. Off to that great hive in the sky."
	else if(stat == UNCONSCIOUS)
		user << "It quivers a bit, but barely moves."
	else
		var/percent = (health / maxHealth * 100)
		switch(percent)
			if(95 to 101)
				user << "It looks quite healthy."
			if(75 to 94)
				user << "It looks slightly injured."
			if(50 to 74)
				user << "It looks injured."
			if(25 to 49)
				user << "It bleeds with sizzling wounds."
			if(1 to 24)
				user << "It is heavily injured and limping badly."
	return

/mob/living/carbon/Xenomorph/Dispose()
	if(mind) mind.name = name //Grabs the name when the xeno is getting deleted, to reference through hive status later.
	if(is_zoomed) zoom_out()
	if(living_xeno_queen && living_xeno_queen.observed_xeno == src)
		living_xeno_queen.set_queen_overwatch(src, TRUE)
	. = ..()


/mob/living/carbon/Xenomorph
	slip(slip_source_name, stun_level, weaken_level, run_only, override_noslip, slide_steps)
		return FALSE

	can_ventcrawl()
		return (mob_size != MOB_SIZE_BIG)

	ventcrawl_carry()
		return 1

	start_pulling(var/atom/movable/AM)
		if(isobj(AM))
			return
		..()

	pull_response(mob/puller)
		if(stat != DEAD && has_species(puller,"Human")) // If the Xeno is alive, fight back against a grab/pull
			puller.KnockDown(rand(tacklemin,tacklemax))
			playsound(puller.loc, 'sound/weapons/pierce.ogg', 25, 1)
			puller.visible_message("<span class='warning'>[puller] tried to pull [src] but instead gets a tail swipe to the head!</span>")
			puller.stop_pulling()

	resist_grab(moving_resist)
		if(pulledby.grab_level)
			visible_message("<span class='danger'>[src] has broken free of [pulledby]'s grip!</span>")
		pulledby.stop_pulling()
		. = 1



/mob/living/carbon/Xenomorph/prepare_huds()
	..()
	//updating all the mob's hud images
	med_hud_set_health()
	hud_set_plasma()
	hud_set_pheromone()
	//and display them
	add_to_all_mob_huds()
	var/datum/mob_hud/MH = huds[MOB_HUD_XENO_INFECTION]
	MH.add_hud_to(src)


