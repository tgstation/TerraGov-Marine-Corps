/mob/living
	see_invisible = SEE_INVISIBLE_LIVING
	flags_atom = CRITICAL_ATOM|PREVENT_CONTENTS_EXPLOSION|BUMP_ATTACKABLE
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

	/// %-reduction-based armor.
	var/datum/armor/soft_armor
	/// Flat-damage-reduction-based armor.
	var/datum/armor/hard_armor

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
	/// Drowsyness amount. Reduces movespeed and if inhaling smoke with a sleep trait [/mob/living/carbon/inhale_smoke] will cause them to fall asleep.
	var/drowsyness = 0

	var/last_staminaloss_dmg = 0
	/// Maximum amount of stamina a mob can have. Different from the stamina buffer because stamina has a positive and negative part
	var/max_stamina = 0
	/// How much stamina can you regen
	var/max_stamina_buffer = 0
	/// How fast does a mob regen its stamina. Shouldn't go below 0.
	var/stamina_regen_multiplier = 1
	/// Maps modifiers by name to a value, applied additively to stamina_regen_multiplier
	var/list/stamina_regen_modifiers
	var/is_dizzy = FALSE
	var/druggy = 0

	var/eye_blind = 0
	var/eye_blurry = 0
	var/ear_deaf = 0
	var/ear_damage = 0

	var/dizziness = 0
	var/jitteriness = 0

	var/hallucination = 0 //Directly affects how long a mob will hallucinate for
	var/disabilities = NONE

	var/restrained_flags = NONE

	var/now_pushing

	var/bubble_icon = "default" //what icon the mob uses for speechbubbles

	var/cameraFollow

	var/melee_damage = 0
	var/attacktext = "attacks"
	var/attack_sound
	var/friendly = "nuzzles"
	var/wall_smash
	var/ranged_accuracy_mod = 0

	var/on_fire //The "Are we on fire?" var
	var/fire_stacks = 0 //Tracks how many stacks of fire we have on, max is

	var/chestburst = 0 // 0: normal, 1: bursting, 2: bursted.
	var/headbitten = FALSE //false: normal, true: brain removed
	var/metabolism_efficiency = 1 //more or less efficiency to metabolize helpful/harmful reagents and (TODO) regulate body temperature..

	var/tinttotal = TINT_NONE

	var/list/status_effects //a list of all status effects the mob has
	///Assoc list mapping aura types to strength, based on what we've received since the last life tick. Handled in handle_status_effects()
	var/list/received_auras
	///List of strings for auras this mob is currently emitting via ssAura
	var/list/emitted_auras
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

	///Lazy assoc list of smoke type mapped to the next world time that smoke can affect this mob
	var/list/smoke_delays
	var/smokecloaked = FALSE //For the new Smoke Grenade

	var/no_stun = FALSE

	var/ventcrawl_layer = PIPING_LAYER_DEFAULT

	var/grab_resist_level = 0 //Every time we try to resist a grab, we increment this by 1 until it exceeds the grab level, thereby breaking the grab.

	var/datum/job/job
	var/comm_title = ""

	var/blood_volume = 0 //how much blood the mob has
	var/heart_multi = 1 //Multiplier.

	var/list/embedded_objects

	/// How much friendly fire damage has this mob done in the last 30 seconds.
	var/list/friendly_fire = list()

	///Stagger and slow vars; Stagger penalizes projectile damage for non-Xenos and disables ability use for Xenos. Slowdown is obvious.
	///Temporary penalty on movement. Regenerates each tick.
	var/slowdown = 0
	///Temporary inability to use special actions; hurts projectile damage. Regenerates each tick.
	var/stagger = 0
	///Id of the timer to set the afk status to MOB_DISCONNECTED
	var/afk_timer_id
	///If this mob is afk
	var/afk_status = MOB_DISCONNECTED

	/// This is the cooldown on suffering additional effects for when we exhaust all stamina
	COOLDOWN_DECLARE(last_stamina_exhaustion)

	///This is the time after which the next gun can be fired in world time.
	var/last_gun_delay
	///This is a reference to the last gun that the mob fired.
	var/last_gun
