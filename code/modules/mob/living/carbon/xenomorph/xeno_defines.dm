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
	///used to match appropriate wound overlays
	var/wound_type = "alien"
	var/language = "Xenomorph"

	var/gib_anim = "gibbed-a-corpse"
	var/gib_flick = "gibbed-a"

	// *** Melee Attacks *** //
	///The amount of damage a xenomorph caste will do with a 'slash' attack.
	var/melee_damage = 10
	///number of ticks between attacks for a caste.
	var/attack_delay = CLICK_CD_MELEE

	///The amount of time between the 'savage' ability activations
	var/savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	///The minimum amount of random paralyze applied to a human upon being 'pulled' multiplied by 20 ticks
	var/tacklemin = 1
	///The maximum amount of random paralyze applied to a human upon being 'pulled' multiplied by 20 ticks
	var/tacklemax = 1
	///How much STAMINA damage a xeno deals when tackling
	var/tackle_damage = 20

	// *** Speed *** //
	var/speed = 1
	var/weeds_speed_mod = -0.4

	// *** Regeneration Delay ***//
	///Time after you take damage before a xenomorph can regen.
	var/regen_delay = 10 SECONDS
	///Regeneration power increases by this amount evey decisecond.
	var/regen_ramp_amount = 0.005

	// *** Plasma *** //
	///How much plasma a caste can have at max.
	var/plasma_max = 10
	///How much plasma a caste gains every life tick.
	var/plasma_gain = 5

	// *** Health *** //
	///Maximum health a caste has.
	var/max_health = 100
	///What negative health amount they die at.
	var/crit_health = -100

	///Set to TRUE in New() when Whiskey Outpost is active. Prevents healing and queen evolution
	var/hardcore = FALSE

	// *** Evolution *** //
	///Threshold amount of evo points to next evolution
	var/evolution_threshold = 0
	///Threshold amount of upgrade points to next maturity
	var/upgrade_threshold = 0

	///Type paths to the castes that this xenomorph can evolve to
	var/list/evolves_to = list()
	///Singular type path for the caste to deevolve to when forced to by the queen.
	var/deevolves_to

	///see_in_dark value while consicious
	var/conscious_see_in_dark = 8
	///see_in_dark value while unconscious
	var/unconscious_see_in_dark = 5

	// *** Flags *** //
	///bitwise flags denoting things a caste can and cannot do, or things a caste is or is not. uses defines.
	var/caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_LEADER

	///whether or not a caste can hold eggs, and either 1 or 2 eggs at a time.
	var/can_hold_eggs = CANNOT_HOLD_EGGS

	// *** Defense *** //
	var/list/soft_armor
	var/list/hard_armor

	///How effective fire is against this caste. From 0 to 1 as it is a multiplier.
	var/fire_resist = 1

	// *** Sunder *** //
	///How much sunder is recovered per tick
	var/sunder_recover = 0.5
	///What is the max amount of sunder that can be applied to a xeno (100 = 100%)
	var/sunder_max = 100

	// *** Ranged Attack *** //
	///Delay timer for spitting
	var/spit_delay = 6 SECONDS
	///list of datum projectile types the xeno can use.
	var/list/spit_types

	///numerical type of charge for a xenomorph caste
	var/charge_type = 0
	///amount of time between pounce ability uses
	var/pounce_delay = 4 SECONDS

	// *** Acid spray *** //
	///Number of tiles of the acid spray cone extends outward to. Not recommended to go beyond 4.
	var/acid_spray_range = 0
	///How long the acid spray stays on floor before it deletes itself, should be higher than 0 to avoid runtimes with timers.
	var/acid_spray_duration = 1
	///The damage acid spray causes on hit.
	var/acid_spray_damage_on_hit = 0
	///The damage acid spray causes over time.
	var/acid_spray_damage = 0
	///The damage acid spray causes to structure.
	var/acid_spray_structure_damage = 0

	// *** Pheromones *** //
	///The strength of our aura. Zero means we can't emit one
	var/aura_strength = 0
	///The 'types' of pheremones a xenomorph caste can emit.
	var/aura_allowed = list("frenzy", "warding", "recovery") //"Evolving" removed for the time being

	// *** Defiler Abilities *** //
	var/list/available_reagents_define = list() //reagents available for select reagent

	// *** Warrior Abilities *** //
	///speed increase afforded to the warrior caste when in 'agiility' mode. negative number means faster movement.
	var/agility_speed_increase = 0 // this opens up possibilities for balancing
	///amount of soft armor adjusted when in agility mode for the warrior caste. Flat integer amounts only.
	var/agility_speed_armor = 0 //Same as above

	// *** Boiler Abilities *** //
	///maximum number of 'globs' of boiler ammunition that can be stored by the boiler caste.
	var/max_ammo = 0
	///Multiplier to the effectiveness of the boiler glob. 1 by default.
	var/bomb_strength = 0
	///Delay between firing the bombard ability for boilers
	var/bomb_delay = 0

	// *** Carrier Abilities *** //
	///maximum amount of huggers a carrier can carry at one time.
	var/huggers_max = 0
	///delay between the throw hugger ability activation for carriers
	var/hugger_delay = 0
	///maximum amount of eggs a carrier can carry at one time.
	var/eggs_max = 0

	// *** Defender Abilities *** //
	///modifying amount to the crest defense ability for defenders. Positive integers only.
	var/crest_defense_armor = 0
	///modifying amount to the fortify ability for defenders. Positive integers only.
	var/fortify_armor = 0
	///amount of slowdown to apply when the crest defense is active. trading defense for speed. Positive numbers makes it slower.
	var/crest_defense_slowdown = 0

	// *** Crusher Abilities *** //
	///The damage the stomp causes, counts armor
	var/stomp_damage = 0
	///How many tiles the Crest toss ability throws the victim.
	var/crest_toss_distance = 0

	// *** Queen Abilities *** //
	///Amount of leaders allowed
	var/queen_leader_limit = 0

	///the 'abilities' available to a caste.
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
	appearance_flags = TILE_BOUND|PIXEL_SCALE|KEEP_TOGETHER
	see_infrared = TRUE
	hud_type = /datum/hud/alien
	hud_possible = list(HEALTH_HUD_XENO, PLASMA_HUD, PHEROMONE_HUD, QUEEN_OVERWATCH_HUD, ARMOR_SUNDER_HUD)
	buckle_flags = NONE
	faction = FACTION_XENO
	initial_language_holder = /datum/language_holder/xeno
	gib_chance = 5
	light_system = MOVABLE_LIGHT
	light_on = FALSE

	var/hivenumber = XENO_HIVE_NORMAL

	var/datum/hive_status/hive

	var/list/overlays_standing[X_TOTAL_LAYERS]
	var/atom/movable/vis_obj/xeno_wounds/wound_overlay
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

	var/regen_power = 0 //Resets to -xeno_caste.regen_delay when you take damage.
	//Negative values act as a delay while values greater than 0 act as a multiplier.
	//Will increase by 10 every decisecond if under 0. Increases by xeno_caste.regen_ramp_amount every decisecond.
	//If you want to balance this, look at the xeno_caste defines mentioned above.

	var/is_zoomed = 0
	var/zoom_turf = null
	var/attack_delay = 0 //Bonus or pen to time in between attacks. + makes slashes slower.
	var/tier = XENO_TIER_ONE //This will track their "tier" to restrict/limit evolutions

	var/emotedown = 0

	var/list/datum/action/xeno_abilities = list()
	var/datum/action/xeno_action/activable/selected_ability
	var/selected_resin = /obj/structure/bed/nest //which resin structure to build when we secrete resin
	var/selected_reagent = /datum/reagent/toxin/xeno_hemodile //which reagent to slash with using reagent slash

	//Naming variables
	var/nicknumber = 0 //The number/name after the xeno type. Saved right here so it transfers between castes.

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

	// Defender vars
	var/fortify = 0
	var/crest_defense = 0

	// Hivelord vars
	///Whether or not the Hivelord's healing infusion is active on this target.
	var/infusion_active = 0

	//Leader vars
	var/leader_aura_strength = 0 //Pheromone strength inherited from Queen
	var/leader_current_aura = "" //Pheromone type inherited from Queen

	//Runner vars
	var/savage = FALSE
	var/savage_used = FALSE

	// *** Ravager vars *** //
	var/ignore_pain = FALSE // when true the rav will not go into crit or take crit damage.
	var/ignore_pain_state = 0 // how far "dead" the rav has got while ignoring pain.

	//Notification spam controls
	var/recent_notice = 0
	var/notice_delay = 20 //2 second between notices

	var/fire_luminosity = 0 //Luminosity of the current fire while burning
	
	///The xenos/silo currently tracked by the xeno_tracker arrow
	var/tracked 

	COOLDOWN_DECLARE(xeno_health_alert_cooldown)
