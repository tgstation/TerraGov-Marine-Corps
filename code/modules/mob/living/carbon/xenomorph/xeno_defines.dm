/datum/xeno_caste
	var/caste_name = ""
	var/display_name = ""
	var/upgrade_name = "Young"
	var/caste_desc = null

	var/caste_type_path = null

	var/ancient_message = ""

	var/tier = 0
	var/upgrade = 0

	var/language = "Xenomorph"

	// *** Melee Attacks *** //
	var/melee_damage_lower = 10
	var/melee_damage_upper = 20
	var/attack_delay = 0 //Bonus or pen to time in between attacks. + makes slashes slower.

	var/savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	var/tacklemin = 1
	var/tacklemax = 1
	var/tackle_chance = 100
	var/tackle_damage = 20 //How much HALLOSS damage a xeno deals when tackling

	// *** RNG Attacks *** //
	var/bite_chance = 5 //Chance of doing a special bite attack in place of a claw. Set to 0 to disable.
	var/tail_chance = 10 //Chance of doing a special tail attack in place of a claw. Set to 0 to disable.
	var/rng_min_interval = 7 SECONDS // 7 seconds

	// *** Speed *** //
	var/speed = 1

	// *** Plasma *** //
	var/plasma_max = 10
	var/plasma_gain = 5

	// *** Health *** //
	var/max_health = 100
	var/crit_health = -100 // What negative healthy they die in.

	var/hardcore = FALSE //Set to 1 in New() when Whiskey Outpost is active. Prevents healing and queen evolution

	// *** Evolution *** //
	var/evolution_threshold = 0 //Threshold to next evolution
	var/upgrade_threshold = 0

	var/list/evolves_to = list() //type paths to the castes that can be evolved to
	var/deevolves_to // type path to the caste to deevolve to

	// *** Flags *** //
	var/caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_QUEEN_HEALED

	var/can_hold_eggs = CANNOT_HOLD_EGGS

	// *** Defense *** //
	var/armor_deflection = 0 //Chance of deflecting projectiles.

	var/fire_resist = 1 //0 to 1; lower is better as it is a multiplier.

	// *** Ranged Attack *** //
	var/spit_delay = 6 SECONDS //Delay timer for spitting
	var/list/spit_types //list of datum projectile types the xeno can use.

	var/charge_type = 0 //0: normal. 1: warrior/hunter style pounce. 2: ravager free attack.
	var/pounce_delay = 4 SECONDS

	var/acid_spray_range = 0
	var/acid_spray_cooldown = 0

	// *** Pheromones *** //	
	var/aura_strength = 0 //The strength of our aura. Zero means we can't emit one
	var/aura_allowed = list("frenzy", "warding", "recovery") //"Evolving" removed for the time being

	// *** Warrior Abilities *** //
	var/agility_speed_increase = 0 // this opens up possibilities for balancing
	var/lunge_cooldown = 0
	var/fling_cooldown = 0
	var/punch_cooldown = 0
	var/toggle_agility_cooldown = 0

	// *** Boiler Abilities *** //
	var/bomb_strength = 0 
	var/acid_delay = 0
	var/bomb_delay = 0

	// *** Carrier Abilities *** //
	var/huggers_max = 0
	var/hugger_delay = 0
	var/eggs_max = 0

	// *** Defender Abilities *** //
	var/headbutt_cooldown = 0
	var/tail_sweep_cooldown = 0
	var/crest_defense_cooldown = 0
	var/fortify_cooldown = 0
	var/crest_defense_armor = 0
	var/fortify_armor = 0
	var/cresttoss_cooldown = 0

	// *** Queen Abilities *** //
	var/queen_leader_limit = 0 //Amount of leaders allowed

/mob/living/carbon/Xenomorph
	var/datum/xeno_caste/xeno_caste
	var/caste_base_type
	var/language = "Xenomorph"
	var/obj/item/clothing/suit/wear_suit = null
	var/obj/item/clothing/head/head = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/plasma_stored = 0
	var/amount_grown = 0
	var/max_grown = 200
	var/time_of_birth

	var/devour_timer = 0

	var/evolution_stored = 0 //How much evolution they have stored

	var/upgrade_stored = 0 //How much upgrade points they have stored.
	var/upgrade = -1  //This will track their upgrade level. -1 means cannot upgrade
	var/gib_chance = 5 // % chance of them exploding when taking damage. Goes up with damage inflicted.
	var/critical_proc = 0
	var/critical_delay = 25

	var/has_spat = 0

	var/has_screeched = 0
	var/middle_mouse_toggle = TRUE //This toggles whether selected ability uses middle mouse clicking or shift clicking

	var/armor_bonus = 0 //Extra chance of deflecting projectiles due to temporary effects
	var/armor_pheromone_bonus = 0 //

	var/fire_resist_modifier = 0

	var/xeno_explosion_resistance = 0 //0 to 3. how explosions affects the xeno, can it stun it, etc...

	var/obj/structure/tunnel/start_dig = null
	var/tunnel_delay = 0
	var/datum/ammo/xeno/ammo = null //The ammo datum for our spit projectiles. We're born with this, it changes sometimes.
	var/pslash_delay = 0

	var/evo_points = 0 //Current # of evolution points. Max is 1000.
	var/list/upgrades_bought = list()

	var/current_aura = null //"claw", "armor", "regen", "speed"
	var/frenzy_aura = 0 //Strength of aura we are affected by. NOT THE ONE WE ARE EMITTING
	var/warding_aura = 0
	var/recovery_aura = 0

	var/is_zoomed = 0
	var/zoom_turf = null
	var/autopsied = 0
	var/attack_delay = 0 //Bonus or pen to time in between attacks. + makes slashes slower.
	var/speed = -0.5 //Regular xeno speed modifier. Positive makes you go slower. (1.5 is equivalent to FAT mutation)
	var/speed_modifier = 0 //Speed bonus/penalties. Positive makes you go slower.
	var/slowdown = 0 //Temporary penalty on movement. Regenerates each tick.
	var/stagger = 0 //Temporary inability to use special actions. Regenerates each tick.
	var/tier = 1 //This will track their "tier" to restrict/limit evolutions

	var/emotedown = 0

	var/datum/action/xeno_action/activable/selected_ability
	var/selected_resin = "resin wall" //which resin structure to build when we secrete resin

	//Naming variables
	var/nicknumber = 0 //The number after the name. Saved right here so it transfers between castes.

	//This list of inherent verbs lets us take any proc basically anywhere and add them.
	//If they're not a xeno subtype it might crash or do weird things, like using human verb procs
	//It should add them properly on New() and should reset/readd them on evolves
	var/list/inherent_verbs = list()

	//Lord forgive me for this horror, but Life code is awful
	//These are tally vars, yep. Because resetting the aura value directly leads to fuckups
	var/frenzy_new = 0
	var/warding_new = 0
	var/recovery_new = 0

	var/xeno_mobhud = FALSE //whether the xeno mobhud is activated or not.

	var/queen_chosen_lead //whether the xeno has been selected by the queen as a leader.

	//Old crusher specific vars, moved here so the Queen can use charge, and potential future Xenos
	var/charge_dir = 0 //Stores initial charge dir to immediately cut out any direction change shenanigans
	var/charge_timer = 0 //Has a small charge window. has to keep moving to build speed.
	var/turf/lastturf = null
	var/noise_timer = 0 // Makes a mech footstep, but only every 3 turfs.
	var/has_moved = 0
	var/is_charging = 0 //Will the mob charge when moving ? You need the charge verb to change this
	var/last_charge_move = 0 //Time of the last time the Crusher moved while charging. If it's too far apart, the charge is broken

	//New variables for how charges work, max speed, speed buildup, all that jazz
	var/charge_speed = 0 //Modifier on base move delay as charge builds up
	var/charge_speed_max = 2.1 //Can only gain this much speed before capping
	var/charge_speed_buildup = 0.15 //POSITIVE amount of speed built up during a charge each step
	var/charge_turfs_to_charge = 5 //Amount of turfs to build up before a charge begins
	var/charge_roar = 0 //Did we roar in our charge yet ?

	//Pounce vars
	var/usedPounce = 0

	// Warrior vars
	var/agility = 0		// 0 - upright, 1 - all fours
	var/ripping_limb = 0

	var/used_lunge = 0
	var/used_fling = 0
	var/used_punch = 0
	var/used_toggle_agility = 0

	// Defender vars
	var/fortify = 0
	var/crest_defense = 0

	var/used_headbutt = 0
	var/used_tail_sweep = 0
	var/used_crest_defense = 0
	var/used_fortify = 0

	//Praetorian vars
	var/used_acid_spray = 0

	//Leader vars
	var/leader_aura_strength = 0 //Pheromone strength inherited from Queen
	var/leader_current_aura = "" //Pheromone type inherited from Queen

	//Runner vars
	var/savage = FALSE
	var/savage_used = FALSE

	//Notification spam controls
	var/recent_notice = 0
	var/notice_delay = 20 //2 second between notices

	var/cresttoss_used = FALSE

/datum/hive_status
	var/hivenumber = XENO_HIVE_NORMAL
	var/mob/living/carbon/Xenomorph/Queen/living_xeno_queen
	var/slashing_allowed = 1 //This initial var allows the queen to turn on or off slashing. Slashing off means harm intent does much less damage.
	var/queen_time = QUEEN_DEATH_TIMER //5 minutes between queen deaths
	var/xeno_queen_timer
	var/hive_orders = "" //What orders should the hive have
	var/color = null
	var/prefix = ""
	var/list/xeno_leader_list = list()

/datum/hive_status/corrupted
	hivenumber = XENO_HIVE_CORRUPTED
	prefix = "Corrupted "
	color = "#00ff80"

/datum/hive_status/alpha
	hivenumber = XENO_HIVE_ALPHA
	prefix = "Alpha "
	color = "#cccc00"

/datum/hive_status/beta
	hivenumber = XENO_HIVE_BETA
	prefix = "Beta "
	color = "#9999ff"

/datum/hive_status/zeta
	hivenumber = XENO_HIVE_ZETA
	prefix = "Zeta "
	color = "#606060"

var/global/list/hive_datum = list(new /datum/hive_status(), new /datum/hive_status/corrupted(), new /datum/hive_status/alpha(), new /datum/hive_status/beta(), new /datum/hive_status/zeta())
