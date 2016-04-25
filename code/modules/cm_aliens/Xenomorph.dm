//Xenomorph "generic" parent, does not actually appear in game
//Many of these defines aren't referenced in the castes and so are assumed to be defaulted
//Castes are all merely subchildren of this parent
//Just about ALL the procs are tied to the parent, not to the children
//This is so they can be easily transferred between them without copypasta

//All this stuff was written by Absynth.


//This initial var allows the queen to turn on or off slashing. Slashing off means harm intent does much less damage.
var/global/slashing_allowed = 0
var/global/queen_time = 300 //5 minutes between queen deaths
var/global/hive_orders = "" //What orders should the hive have

/mob/living/carbon/Xenomorph
	var/caste = ""
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
	var/jelly = 0 //variable to check if they ate delicious jelly or not
	var/jellyGrow = 0 //how much the jelly has grown
	var/jellyMax = 0 //max amount jelly will grow till evolution
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
	var/fire_immune = 0 //boolean
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
	var/adjust_pixel_x = 0
	var/adjust_pixel_y = 0
	var/adjust_size_x = 1 //Adjust pixel size. 0.x is smaller, 1.x is bigger, percentage based.
	var/adjust_size_y = 1
	var/spit_type = 0 //0: normal, 1: heavy
	var/is_zoomed = 0
	var/zoom_turf = null
	var/big_xeno = 0 //Toggles pushing
	var/autopsied = 0
	var/nicknumber = -1 //The number after the name. Saved right here so it transfers between castes.
	var/attack_delay = 0 //Bonus or pen to time in between attacks. + makes slashes slower.
	var/speed = -0.5 //Speed bonus/penalties. Positive makes you go slower. (1.5 is equivalent to FAT mutation)

	//This list of inherent verbs lets us take any proc basically anywhere and add them.
	//If they're not a xeno subtype it might crash or do weird things, like using human verb procs
	//It should add them properly on New() and should reset/readd them on evolves
	var/list/inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate
		)

/mob/living/carbon/Xenomorph/New()
	..()
	time_of_birth = world.time
	add_language("Xenomorph") //xenocommon
	add_language("Hivemind") //hivemind
	add_inherent_verbs()

//	internal_organs += new /datum/organ/internal/xenos/hivenode(src)

//	sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
	sight |= SEE_MOBS
	see_invisible = SEE_INVISIBLE_MINIMUM
	see_in_dark = 8

	ammo = new /datum/ammo/xeno/spit() //Set up the initial spit projectile datum. It defaults to stun.
	if(istype(src,/mob/living/carbon/Xenomorph/Praetorian))
		//Bigger and badder!
		ammo.stun += 2
		ammo.weaken += 2
	else if(istype(src,/mob/living/carbon/Xenomorph/Spitter))
		ammo.stun += 1
		ammo.weaken += 1
		ammo.shell_speed = 2 //Super fast!

	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	gender = NEUTER
	if(adjust_pixel_x) //Adjust large 2x2 sprites
		src.pixel_x += adjust_pixel_x

	if(adjust_pixel_y) //Adjust large 2x2 sprites
		src.pixel_y += adjust_pixel_y

	if(adjust_size_x != 1)
		var/matrix/M = matrix()
		M.Scale(adjust_size_x, adjust_size_y)
//		M.Translate(0, 16*(adjust_size-1))
		src.transform = M


	spawn(6) //Mind has to be transferred! Hopefully this will give it enough time to do so.
		if(caste != "Queen")//This needed to be moved here because the re-naming was happening faster than the transfer. - Apop
			nicknumber = rand(1,999)
			name = "[caste] ([nicknumber])"
			real_name = name
		if(src.mind) //Are we not an NPC? Set us to actually be a xeno.
			src.mind.assigned_role = "MODE"
			src.mind.special_role = "Alien"
			src.mind.name  = real_name
			//Add them to the gametype xeno tracker
			if(ticker && ticker.current_state >= GAME_STATE_PLAYING && ticker.mode.aliens.len && !is_robotic) //Robots don't get added.
				if(!(src.mind in ticker.mode.aliens))
					ticker.mode.aliens += src.mind

	regenerate_icons()



/mob/living/carbon/Xenomorph/examine()
	if(!usr) return //Somehow?
	..()
	if(istype(usr,/mob/living/carbon/Xenomorph) && caste_desc)
		usr << caste_desc

	if(stat == DEAD)
		usr << "It is DEAD. Kicked the bucket. Off to that great hive in the sky."
	else if (stat == UNCONSCIOUS)
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

/mob/living/carbon/Xenomorph/Bumped(atom/AM)
	spawn(0)
		if(!istype(AM,/mob/living/carbon))
			return ..()
		if(big_xeno)
			return
		else
			return ..()

/mob/living/carbon/Xenomorph/Del() //If mob is deleted, remove it off the xeno list completely.
	if(!isnull(src) && !isnull(src.mind) && !isnull(ticker.mode) && ticker.mode.aliens.len && src.mind in ticker.mode.aliens)
		ticker.mode.aliens -= src.mind
	..()
