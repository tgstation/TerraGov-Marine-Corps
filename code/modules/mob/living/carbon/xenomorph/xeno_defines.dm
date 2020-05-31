/datum/xeno_caste
	var/caste_name = ""
	var/display_name = ""
	var/upgrade_name = "Young"
	var/caste_desc = null
	var/job_type = /datum/job/xenomorph

	var/caste_type_path = null

	var/ancient_message = ""

	var/tier = XENO_TIER_ZERO
	var/upgrade = XENO_UPGRADE_ZERO
	var/wound_type = "alien" //used to match appropriate wound overlays
	var/language = "Xenomorph"

	var/gib_anim = "gibbed-a-corpse"
	var/gib_flick = "gibbed-a"

	// *** Melee Attacks *** //
	var/melee_damage = 10
	var/attack_delay = CLICK_CD_MELEE

	var/savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	var/tacklemin = 1
	var/tacklemax = 1
	var/tackle_chance = 100
	var/tackle_damage = 20 //How much STAMINA damage a xeno deals when tackling

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

	///see_in_dark value while consicious
	var/conscious_see_in_dark = 8
	///see_in_dark value while unconscious
	var/unconscious_see_in_dark = 5

	// *** Flags *** //
	var/caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_LEADER

	var/can_hold_eggs = CANNOT_HOLD_EGGS

	// *** Defense *** //
	var/list/soft_armor
	var/list/hard_armor

	var/fire_resist = 1 //0 to 1; lower is better as it is a multiplier.

	// *** Sunder *** //
	var/sunder_recover = 0.5 // How much sunder is recovered per tick
	var/sunder_max = 100 // What is the max amount of sunder that can be applied to a xeno (100 = 100%)

	// *** Ranged Attack *** //
	var/spit_delay = 6 SECONDS //Delay timer for spitting
	var/list/spit_types //list of datum projectile types the xeno can use.

	var/charge_type = 0
	var/pounce_delay = 4 SECONDS

	var/acid_spray_range = 0

	// *** Pheromones *** //
	var/aura_strength = 0 //The strength of our aura. Zero means we can't emit one
	var/aura_allowed = list("frenzy", "warding", "recovery") //"Evolving" removed for the time being

	// *** Warrior Abilities *** //
	var/agility_speed_increase = 0 // this opens up possibilities for balancing

	// *** Boiler Abilities *** //
	var/max_ammo = 0
	var/bomb_strength = 0
	var/acid_delay = 0
	var/bomb_delay = 0

	// *** Carrier Abilities *** //
	var/huggers_max = 0
	var/hugger_delay = 0
	var/eggs_max = 0

	// *** Defender Abilities *** //
	var/crest_defense_armor = 0
	var/fortify_armor = 0

	// *** Queen Abilities *** //
	var/queen_leader_limit = 0 //Amount of leaders allowed

	var/list/actions

/mob/living/carbon/xenomorph
	name = "Drone"
	desc = "What the hell is THAT?"
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Drone Walking"
	speak_emote = list("hisses")
	melee_damage = 5 //Arbitrary damage value
	attacktext = "claws"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = FALSE
	health = 5
	maxHealth = 5
	rotate_on_lying = FALSE
	mob_size = MOB_SIZE_XENO
	hand = 1 //Make right hand active by default. 0 is left hand, mob defines it as null normally
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	sight = SEE_SELF|SEE_OBJS|SEE_TURFS|SEE_MOBS
	see_infrared = TRUE
	hud_type = /datum/hud/alien
	hud_possible = list(HEALTH_HUD_XENO, PLASMA_HUD, PHEROMONE_HUD, QUEEN_OVERWATCH_HUD, ARMOR_SUNDER_HUD)
	buckle_flags = NONE
	faction = FACTION_XENO
	initial_language_holder = /datum/language_holder/xeno
	gib_chance = 5

	var/hivenumber = XENO_HIVE_NORMAL

	var/datum/hive_status/hive

	var/list/overlays_standing[X_TOTAL_LAYERS]
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

	var/list/stomach_contents
	var/devour_timer = 0

	var/evolution_stored = 0 //How much evolution they have stored

	var/upgrade_stored = 0 //How much upgrade points they have stored.
	var/upgrade = XENO_UPGRADE_INVALID  //This will track their upgrade level.

	var/armor_bonus = 0
	var/armor_pheromone_bonus = 0
	var/sunder = 0 // sunder affects armour values and does a % removal before dmg is applied. 50 sunder == 50% effective armour values
	var/fire_resist_modifier = 0

	var/obj/structure/tunnel/start_dig = null
	var/datum/ammo/xeno/ammo = null //The ammo datum for our spit projectiles. We're born with this, it changes sometimes.
	var/pslash_delay = 0

	var/evo_points = 0 //Current # of evolution points. Max is 1000.
	var/list/upgrades_bought = list()

	var/current_aura = null //"frenzy", "warding", "recovery"
	var/frenzy_aura = 0 //Strength of aura we are affected by. NOT THE ONE WE ARE EMITTING
	var/warding_aura = 0
	var/recovery_aura = 0

	var/is_zoomed = 0
	var/zoom_turf = null
	var/attack_delay = 0 //Bonus or pen to time in between attacks. + makes slashes slower.
	var/tier = XENO_TIER_ONE //This will track their "tier" to restrict/limit evolutions

	var/emotedown = 0

	var/list/datum/action/xeno_abilities = list()
	var/datum/action/xeno_action/activable/selected_ability
	var/selected_resin = /obj/structure/bed/nest //which resin structure to build when we secrete resin

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

	//Charge vars
	var/is_charging = CHARGE_OFF //Will the mob charge when moving ? You need the charge verb to change this

	//Pounce vars
	var/usedPounce = 0

	// Warrior vars
	var/agility = 0		// 0 - upright, 1 - all fours
	var/ripping_limb = 0

	// Defender vars
	var/fortify = 0
	var/crest_defense = 0

	//Leader vars
	var/leader_aura_strength = 0 //Pheromone strength inherited from Queen
	var/leader_current_aura = "" //Pheromone type inherited from Queen

	//Runner vars
	var/savage = FALSE
	var/savage_used = FALSE

	//Notification spam controls
	var/recent_notice = 0
	var/notice_delay = 20 //2 second between notices

	var/fire_luminosity = 0 //Luminosity of the current fire while burning

	var/butchery_progress = 0
