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
	var/dead_icon = "Drone Dead"
	var/language = "Xenomorph"
	var/obj/item/clothing/suit/wear_suit = null
	var/obj/item/clothing/head/head = null
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null
	var/storedplasma = 0
	var/maxplasma = 10
	var/amount_grown = 0
	var/max_grown = 200
	var/time_of_birth
	var/plasma_gain = 5
	var/jelly = 0 //Variable to check if they ate delicious jelly or not
	var/jellyGrow = 0 //How much the jelly has grown
	var/jellyMax = 0 //Max amount jelly will grow till evolution
	var/list/evolves_to = list() //This is where you add castes to evolve into. "Seperated", "by", "commas"
	var/tacklemin = 2
	var/tacklemax = 4
	var/tackle_chance = 50
	var/is_intelligent = 0 //If they can use consoles, etc. Set on Queen
	var/caste_desc = null
	var/usedPounce = 0
	var/has_spat = 0
	var/spit_delay = 60 //Delay timer for spitting
	var/has_screeched = 0
	var/middle_mouse_toggle = 1 //This toggles middle mouse clicking for certain abilities.
	var/shift_mouse_toggle = 0 //The same, but for shift clicking.
	var/charge_type = 0 //0: normal. 1: warrior/hunter style pounce. 2: ravager free attack.
	var/armor_deflection = 0 //Chance of deflecting projectiles.
	var/fire_immune = 0 //Boolean
	var/obj/structure/tunnel/start_dig = null
	var/tunnel_delay = 0
	var/datum/ammo/ammo = null //The ammo datum for our spit projectiles. We're born with this, it changes sometimes.
	var/pslash_delay = 0
	var/bite_chance = 5 //Chance of doing a special bite attack in place of a claw. Set to 0 to disable.
	var/readying_tail = 0 //'charges' up to 10, next attack does a tail stab.
	var/evo_points = 0 //Current # of evolution points. Max is 1000.
	var/list/upgrades_bought = list()
	var/is_robotic = 0 //Robots use charge, not plasma (same thing sort of), and can only be healed with welders.
	var/frenzy_aura = 0
	var/guard_aura = 0
	var/recovery_aura = 0
	var/current_aura = null //"claw", "armor", "regen", "speed"
	var/adjust_size_x = 1 //Adjust pixel size. 0.x is smaller, 1.x is bigger, percentage based.
	var/adjust_size_y = 1
	var/spit_type = 0 //0: normal, 1: heavy
	var/is_zoomed = 0
	var/zoom_turf = null
	var/autopsied = 0
	var/attack_delay = 0 //Bonus or pen to time in between attacks. + makes slashes slower.
	var/speed = -0.5 //Speed bonus/penalties. Positive makes you go slower. (1.5 is equivalent to FAT mutation)
	var/tier = 1 //This will track their "tier" to restrict/limit evolutions
	var/upgrade = -1  //This will track their upgrade level.  Once they can no longer upgrade, it will set to -1
	var/hardcore = 0 //Set to 1 in New() when Whiskey Outpost is active. Prevents healing and queen evolution
	var/crit_health = -100 // What negative healthy they die in.
	var/gib_chance  = 5 // % chance of them exploding when taking damage. Goes up with damage inflicted.

	//Naming variables
	var/caste = ""
	var/upgrade_name = "Young"
	var/nicknumber = 0 //The number after the name. Saved right here so it transfers between castes.

	//This list of inherent verbs lets us take any proc basically anywhere and add them.
	//If they're not a xeno subtype it might crash or do weird things, like using human verb procs
	//It should add them properly on New() and should reset/readd them on evolves
	var/list/inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate
		)

/mob/living/carbon/Xenomorph/New()
	..()
	//WO GAMEMODE
	if(ticker && istype(ticker.mode,/datum/game_mode/whiskey_outpost))
		hardcore = 1 //Prevents healing and queen evolution
	time_of_birth = world.time
	add_language("Xenomorph") //xenocommon
	add_language("Hivemind") //hivemind
	add_inherent_verbs()

	sight |= SEE_MOBS
	see_invisible = SEE_INVISIBLE_MINIMUM
	see_in_dark = 8

	switch(type)
		if(/mob/living/carbon/Xenomorph/Praetorian)
			ammo = ammo_list[/datum/ammo/xeno/toxin/heavy]
		if(/mob/living/carbon/Xenomorph/Spitter)
			ammo = ammo_list[/datum/ammo/xeno/toxin/medium]
		else ammo = ammo_list[/datum/ammo/xeno/toxin]

	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	gender = NEUTER

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

/mob/living/carbon/Xenomorph/examine()
	if(!usr) return //Somehow?
	..()
	if(isXeno(usr) && caste_desc)
		usr << caste_desc

	if(stat == DEAD)
		usr << "It is DEAD. Kicked the bucket. Off to that great hive in the sky."
	else if(stat == UNCONSCIOUS)
		usr << "It quivers a bit, but barely moves."
	else
		var/percent = (health / maxHealth * 100)
		switch(percent)
			if(95 to 101)
				usr << "It looks quite healthy."
			if(75 to 94)
				usr << "It looks slightly injured."
			if(50 to 74)
				usr << "It looks injured."
			if(25 to 49)
				usr << "It bleeds with sizzling wounds."
			if(1 to 24)
				usr << "It is heavily injured and limping badly."
	return

/mob/living/carbon/Xenomorph/Del()
	if(mind) mind.name = name //Grabs the name when the xeno is getting deleted, to reference through hive status later.
	..()


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
			puller.Weaken(rand(tacklemin,tacklemax))
			playsound(puller.loc, 'sound/weapons/pierce.ogg', 25, 1)
			puller.visible_message("<span class='warning'>[puller] tried to pull [src] but instead gets a tail swipe to the head!</span>")
			puller.stop_pulling()

	resist_grab(moving_resist)
		if(pulledby.grab_level)
			visible_message("<span class='danger'>[src] has broken free of [pulledby]'s grip!</span>")
		pulledby.stop_pulling()
		. = 0