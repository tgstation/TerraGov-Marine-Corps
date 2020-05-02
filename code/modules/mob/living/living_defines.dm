/mob/living
	see_invisible = SEE_INVISIBLE_LIVING
	flags_atom = CRITICAL_ATOM
	var/see_override = 0 //0 for no override, sets see_invisible = see_override in silicon & carbon life process via update_sight()

	var/resize = RESIZE_DEFAULT_SIZE //Badminnery resize

	/* Health and life related vars */
	/// Maximum health that should be possible.
	var/maxHealth = 100
	/// Mob's current health
	var/health = 100
	/// Health at which a mob dies
	var/health_threshold_dead = -100
	/// Health at which a mob goes into crit
	var/health_threshold_crit = 0

	/* Damage related vars, NOTE: THESE SHOULD ONLY BE MODIFIED BY PROCS */
	/// Brutal damage caused by brute force (punching, being clubbed by a toolbox ect... this also accounts for pressure damage)
	var/bruteloss = 0
	/// Burn damage caused by being way too hot, too cold or burnt.
	var/fireloss = 0
	/// Oxygen depravation damage (no air in lungs)
	var/oxyloss = 0
	/// Toxic damage caused by being poisoned or radiation
	var/toxloss = 0
	/// Stamina damage caused by running to much, or specific toxins
	var/staminaloss = 0
	/// Damage caused by being cloned or ejected from the cloner early
	var/cloneloss = 0
	/// Brain damage caused by someone hitting you in the head with a bible or being infected with brainrot.
	var/brainloss = 0
	/// Radition amount. Radiation slowly converts into {toxloss|cloneloss} over time in [/mob/living/carbon/human/handle_mutations_and_radiation]
	var/radiation = 0
	/// Drowsyness amount. Reduces movespeed and if inhaling smoke with a sleep trait [/mob/living/carbon/inhale_smoke] will cause them to fall asleep.
	var/drowsyness = 0

	var/last_staminaloss_dmg = 0
	var/max_stamina_buffer = 0
	var/is_dizzy = FALSE
	var/druggy = 0

	var/eye_blind = 0
	var/eye_blurry = 0
	var/ear_deaf = 0
	var/ear_damage = 0

	var/frozen = 0

	var/dizziness = 0
	var/jitteriness = 0

	var/hallucination = 0 //Directly affects how long a mob will hallucinate for
	var/disabilities = NONE

	var/restrained_flags = NONE

	var/now_pushing

	var/bubble_icon = "default" //what icon the mob uses for speechbubbles

	var/cameraFollow

	var/melee_damage = 0
	var/melee_accuracy = 100
	var/attacktext = "attacks"
	var/attack_sound
	var/friendly = "nuzzles"
	var/wall_smash
	var/ranged_accuracy_mod = 0

	var/on_fire //The "Are we on fire?" var
	var/fire_stacks = 0 //Tracks how many stacks of fire we have on, max is

	var/chestburst = 0 // 0: normal, 1: bursting, 2: bursted.
	var/metabolism_efficiency = 1 //more or less efficiency to metabolize helpful/harmful reagents and (TODO) regulate body temperature..

	var/tinttotal = TINT_NONE

	var/list/status_effects //a list of all status effects the mob has

	var/list/stun_absorption //lazy list

	//Speech
	var/stuttering = 0
	var/slurring = 0

	var/resting = FALSE

	var/list/icon/pipes_shown = list()
	var/is_ventcrawling

	var/pull_speed = 0 //How much slower or faster this mob drags as a base

	var/reagent_shock_modifier = 0 //negative values reduce shock/pain
	var/reagent_pain_modifier = 0 //same as above, except can potentially mask damage

	var/smoke_delay = FALSE
	var/smokecloaked = FALSE //For the new Smoke Grenade

	var/no_stun = FALSE

	var/fire_resist = 1 //0 to 1; lower is better as it is a multiplier.

	var/entangled_by

	var/ventcrawl_layer = PIPING_LAYER_DEFAULT

	var/grab_resist_level = 0 //Every time we try to resist a grab, we increment this by 1 until it exceeds the grab level, thereby breaking the grab.

	var/datum/job/job
	var/faction = "Neutral"
	var/comm_title = ""

	var/blood_volume = 0 //how much blood the mob has
	var/heart_multi = 1 //Multiplier.

	var/list/embedded_objects
