/mob/living
	see_invisible = SEE_INVISIBLE_LIVING

	var/resize = 1 //Badminnery resize

	//Health and life related vars
	var/maxHealth = 100 //Maximum health that should be possible.
	var/health = 100 	//A mob's health

	//Damage related vars, NOTE: THESE SHOULD ONLY BE MODIFIED BY PROCS
	var/bruteloss = 0.0	//Brutal damage caused by brute force (punching, being clubbed by a toolbox ect... this also accounts for pressure damage)
	var/oxyloss = 0.0	//Oxygen depravation damage (no air in lungs)
	var/toxloss = 0.0	//Toxic damage caused by being poisoned or radiated
	var/fireloss = 0.0	//Burn damage caused by being way too hot, too cold or burnt.
	var/cloneloss = 0	//Damage caused by being cloned or ejected from the cloner early
	var/brainloss = 0	//'Retardation' damage caused by someone hitting you in the head with a bible or being infected with brainrot.

	var/confused = 0	//Makes the mob move in random directions.
	var/is_dizzy = FALSE
	var/druggy = 0

	var/hallucination = 0 //Directly affects how long a mob will hallucinate for
	var/list/atom/hallucinations = list() //A list of hallucinated people that try to attack the mob. See /obj/effect/fake_attacker in hallucinations.dm

	var/last_special = 0 //Used by the resist verb, likely used to prevent players from bypassing next_move by logging in/out.

	var/t_phoron = null
	var/t_oxygen = null
	var/t_sl_gas = null
	var/t_n2 = null

	var/now_pushing = null

	var/cameraFollow = null

	var/tod = null // Time of death

	var/silent = null 		//Can't talk. Value goes down every life proc.

	// Putting these here for attack_animal().
	var/melee_damage_lower = 0
	var/melee_damage_upper = 0
	var/attacktext = "attacks"
	var/attack_sound = null
	var/friendly = "nuzzles"
	var/wall_smash = 0

	var/on_fire = 0 //The "Are we on fire?" var
	var/fire_stacks = 0 //Tracks how many stacks of fire we have on, max is

	var/is_being_hugged = 0 //Is there a hugger humping our face?
	var/chestburst = 0 // 0: normal, 1: bursting, 2: bursted.
	var/in_stasis = FALSE //Is the mob in stasis bag?
	var/metabolism_efficiency = 1 //more or less efficiency to metabolize helpful/harmful reagents and (TODO) regulate body temperature..

	var/tinttotal = TINT_NONE

	//Speech
	var/stuttering = 0
	var/slurring = 0

	var/list/icon/pipes_shown = list()
	var/last_played_vent
	var/is_ventcrawling = 0

	var/pull_speed = 0 //How much slower or faster this mob drags as a base

	var/image/attack_icon = null //the image used as overlay on the things we attack.

	var/list/datum/action/actions = list()

	var/zoom_cooldown = 0 //Cooldown on using zooming items, to limit spam
	var/do_bump_delay = 0	// Flag to tell us to delay movement because of being bumped

	var/reagent_move_delay_modifier = 0 //negative values increase movement speed
	var/reagent_shock_modifier = 0 //negative values reduce shock/pain
	var/reagent_pain_modifier = 0 //same as above, except can potentially mask damage

	var/smokecloaked = FALSE //For the new Smoke Grenade

	var/no_stun = FALSE

	var/fire_immune = FALSE
	var/fire_resist = 1 //0 to 1; lower is better as it is a multiplier.

	var/entangle_delay = null
	var/entangled_by = null

	var/ventcrawl_layer = PIPING_LAYER_DEFAULT

	var/ventcrawl_message_busy