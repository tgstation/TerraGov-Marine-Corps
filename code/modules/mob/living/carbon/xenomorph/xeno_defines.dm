/datum/xeno_caste
	var/caste_name = ""
	var/display_name = ""
	var/upgrade_name = "Young"
	var/caste_desc = null
	var/job_type = /datum/job/xenomorph
	///The parent strain of this caste
	var/base_strain_type
	///The base caste typepath
	var/caste_type_path = null

	///primordial message that is shown when a caste becomes primordial
	var/primordial_message = ""

	var/tier = XENO_TIER_ZERO
	var/upgrade = XENO_UPGRADE_NORMAL
	///used to match appropriate wound overlays
	var/wound_type = "alien"
	var/language = "Xenomorph"

	var/gib_anim = "gibbed-a-corpse"
	var/gib_flick = "gibbed-a"

	// *** Melee Attacks *** //
	///The amount of damage a xenomorph caste will do with a 'slash' attack.
	var/melee_damage = 10
	/// The damage typing of the melee damage.
	var/melee_damage_type = BRUTE
	/// The armor typing of the melee damage.
	var/melee_damage_armor = MELEE
	///The amount of armour pen their melee attacks have
	var/melee_ap = 0
	///number of ticks between attacks for a caste.
	var/attack_delay = CLICK_CD_MELEE

	// *** Tackle *** //
	///The minimum amount of random paralyze applied to a human upon being 'pulled' multiplied by 20 ticks
	var/tacklemin = 1
	///The maximum amount of random paralyze applied to a human upon being 'pulled' multiplied by 20 ticks
	var/tacklemax = 1

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
	///up to how % much plasma regens in decimals, generally used if you have a special way of regeninng plasma.
	var/plasma_regen_limit = 1

	// *** Health *** //
	///Maximum health a caste has.
	var/max_health = 100
	///What negative health amount they die at.
	var/crit_health = -100

	// *** Evolution *** //
	///Threshold amount of evo points to next evolution
	var/evolution_threshold = 0
	///Threshold amount of upgrade points to next maturity
	var/upgrade_threshold = 0
	// The amount of xenos that must be alive in the hive for this caste to be able to evolve
	var/evolve_min_xenos = 0
	// Starting Population lock, equivalent to assault crewman availability.
	var/evolve_population_lock = 0
	// How many of this caste may be alive at once
	var/maximum_active_caste = INFINITY

	///Singular type path for the caste to deevolve to when forced to by the queen.
	var/deevolves_to

	// *** Flags *** //
	///Bitwise flags denoting things a caste is or is not. Uses defines.
	var/caste_flags = CASTE_EVOLUTION_ALLOWED
	///Bitwise flags denoting things a caste can and cannot do. Uses defines.
	var/can_flags = CASTE_CAN_BE_LEADER
	///list of traits granted to the owner by becoming this caste
	var/list/caste_traits = list()
	// How long the hive must wait before a new one of this caste can evolve
	var/death_evolution_delay = 0
	///whether or not a caste can hold eggs, and either 1 or 2 eggs at a time.
	var/can_hold_eggs = CANNOT_HOLD_EGGS

	// *** Defense *** //
	var/list/soft_armor
	var/list/hard_armor

	// *** Sunder *** //
	///How much sunder is recovered per tick
	var/sunder_recover = 0.5
	///What is the max amount of sunder that can be applied to a xeno (100 = 100%)
	var/sunder_max = 100
	///Multiplier on the weapons sunder, e.g 10 sunder on a projectile is reduced to 5 with a 0.5 multiplier.
	var/sunder_multiplier = 1

	// *** Ranged Attack *** //
	///Delay timer for spitting
	var/spit_delay = 6 SECONDS
	///list of datum projectile types the xeno can use.
	var/list/spit_types

	// *** Acid spray *** //
	///How long the acid spray stays on floor before it deletes itself, should be higher than 0 to avoid runtimes with timers.
	var/acid_spray_duration = 1
	///The damage acid spray causes on hit.
	var/acid_spray_damage_on_hit = 0
	///The damage acid spray causes over time.
	var/acid_spray_damage = 0
	///The damage acid spray causes to structure.
	var/acid_spray_structure_damage = 0

	// *** Secrete resin *** //
	///The maximum number of tiles to where a xeno can build.
	var/resin_max_range = 0

	// *** Pheromones *** //
	///The strength of our aura. Zero means we can't emit any.
	var/aura_strength = 0

	// *** Defiler Abilities *** //
	var/list/available_reagents_define = list() //reagents available for select reagent

	// *** Boiler Abilities *** //
	///maximum number of 'globs' of boiler ammunition that can be stored by the boiler caste.
	var/max_ammo = 0
	///Multiplier to the effectiveness of the boiler glob. 1 by default.
	var/bomb_strength = 0

	// *** Carrier Abilities *** //
	///maximum amount of huggers a carrier can carry at one time.
	var/huggers_max = 0
	///delay between the throw hugger ability activation for carriers
	var/hugger_delay = 0

	// *** Widow Abilities *** //
	///maximum amount of spiderlings a widow can carry at one time.
	var/max_spiderlings = 0

	// *** Defender Abilities *** //
	///modifying amount to the crest defense ability for defenders. Positive integers only.
	var/crest_defense_armor = 0
	///modifying amount to the fortify ability for defenders. Positive integers only.
	var/fortify_armor = 0
	///amount of slowdown to apply when the crest defense is active. trading defense for speed. Positive numbers makes it slower.
	var/crest_defense_slowdown = 0

	// *** Puppeteer Abilities *** //
	var/flay_plasma_gain = 0
	var/max_puppets = 0

	// *** Crusher Abilities *** //
	///How many tiles the Crest toss ability throws the victim.
	var/crest_toss_distance = 0

	// *** Gorger Abilities *** //
	///Maximum amount of overheal that can be gained
	var/overheal_max = 150
	///Amount of plasma gained from draining someone
	var/drain_plasma_gain = 0
	///Amount of plasma gained from clashing after activating carnage
	var/carnage_plasma_gain = 0
	///Amount of plasma drained each tick while feast buff is actuve
	var/feast_plasma_drain = 0

	// *** Queen Abilities *** //
	///Amount of leaders allowed
	var/queen_leader_limit = 0

	// *** Wraith Abilities *** //


	// *** Hunter Abilities ***
	///Damage breakpoint to knock out of stealth
	var/stealth_break_threshold = 0

	// *** Sentinel Abilities ***
	/// The additional amount of stacks that the Sentinel will apply on eligible abilities.
	var/additional_stacks = 0

	// *** Behemoth Abilities ***
	/// The maximum amount of Wrath that we can have stored at a time.
	var/wrath_max = 0

	///the 'abilities' available to a caste.
	var/list/actions

	///The iconstate for the xeno on the minimap
	var/minimap_icon = "xenominion"
	///The iconstate for leadered xenos on the minimap, added as overlay
	var/minimap_leadered_overlay = "xenoleader"
	///The iconstate of the plasma bar, format used is "[plasma_icon_state][amount]"
	var/plasma_icon_state = "plasma"

	///How quickly the caste enters vents
	var/vent_enter_speed = XENO_DEFAULT_VENT_ENTER_TIME
	///How quickly the caste exits vents
	var/vent_exit_speed = XENO_DEFAULT_VENT_EXIT_TIME
	///Whether the caste enters and crawls through vents silently
	var/silent_vent_crawl = FALSE
	// Accuracy malus, 0 by default. Should NOT go over 70.
	var/accuracy_malus = 0

	/// All mutations that this caste can view and potentially purchase.
	var/list/datum/mutation_upgrade/mutations = list()

///Add needed component to the xeno
/datum/xeno_caste/proc/on_caste_applied(mob/xenomorph)
	for(var/trait in caste_traits)
		ADD_TRAIT(xenomorph, trait, XENO_TRAIT)
	xenomorph.AddComponent(/datum/component/bump_attack)
	xenomorph.RegisterSignal(xenomorph,COMSIG_XENOMORPH_ATTACK_LIVING, TYPE_PROC_REF(/mob/living/carbon/xenomorph, onhithuman))

/datum/xeno_caste/proc/on_caste_removed(mob/xenomorph)
	xenomorph.remove_component(/datum/component/bump_attack)
	xenomorph.UnregisterSignal(xenomorph, COMSIG_XENOMORPH_ATTACK_LIVING)
	for(var/trait in caste_traits)
		REMOVE_TRAIT(xenomorph, trait, XENO_TRAIT)

///returns the basetype caste from this caste or typepath to get what the base caste is (e.g base rav not primo or strain rav)
/proc/get_base_caste_type(datum/xeno_caste/current_type)
	while(current_type::upgrade != XENO_UPGRADE_BASETYPE)
		current_type = current_type::parent_type
	return current_type

///returns the parent caste type for the given caste (e.g. bloodthirster would return base rav)
/proc/get_parent_caste_type(datum/xeno_caste/root_type)
	while(initial(root_type.parent_type) != /datum/xeno_caste)
		root_type = root_type::parent_type
	return root_type

/// basetype = list(strain1, strain2)
GLOBAL_LIST_INIT(strain_list, init_glob_strain_list())
/proc/init_glob_strain_list()
	var/list/strain_list = list()
	for(var/datum/xeno_caste/root_caste AS in GLOB.xeno_caste_datums)
		if(root_caste.parent_type != /datum/xeno_caste)
			continue
		strain_list[root_caste] = list()
		for(var/datum/xeno_caste/typepath AS in subtypesof(root_caste))
			if(typepath::upgrade != XENO_UPGRADE_BASETYPE)
				continue
			if(typepath::caste_flags & CASTE_EXCLUDE_STRAINS)
				continue
			strain_list[root_caste] += typepath
	return strain_list

///returns a list of strains(xeno castedatum paths) that this caste can currently evolve to
/proc/get_strain_options(datum/xeno_caste/root_type)
	RETURN_TYPE(/list)

	ASSERT(ispath(root_type), "Bad root type passed to get_strain_options")
	while(initial(root_type.parent_type) != /datum/xeno_caste)
		root_type = root_type::parent_type
	return GLOB.strain_list[root_type] + root_type

/mob/living/carbon/xenomorph
	name = "Drone"
	desc = "What the hell is THAT?"
	icon = 'icons/Xeno/castes/larva.dmi'
	icon_state = "Drone Walking"
	speak_emote = list("hisses")
	melee_damage = 5 //Arbitrary damage value
	attacktext = "claws"
	attack_sound = SFX_ALIEN_CLAW_FLESH
	wall_smash = FALSE
	health = 5
	maxHealth = 5
	rotate_on_lying = FALSE
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	mob_size = MOB_SIZE_XENO
	hand = 1 //Make right hand active by default. 0 is left hand, mob defines it as null normally
	lighting_cutoff =  LIGHTING_CUTOFF_HIGH
	sight = SEE_SELF|SEE_OBJS|SEE_TURFS|SEE_MOBS
	appearance_flags = TILE_BOUND|PIXEL_SCALE|KEEP_TOGETHER|LONG_GLIDE
	see_infrared = TRUE
	hud_type = /datum/hud/alien
	hud_possible = list(HEALTH_HUD_XENO, PLASMA_HUD, PHEROMONE_HUD, XENO_RANK_HUD, QUEEN_OVERWATCH_HUD, ARMOR_SUNDER_HUD, XENO_DEBUFF_HUD, XENO_FIRE_HUD, XENO_BLESSING_HUD, XENO_EVASION_HUD)
	buckle_flags = NONE
	faction = FACTION_XENO
	initial_language_holder = /datum/language_holder/xeno
	voice_filter = @{"[0:a] asplit [out0][out2]; [out0] asetrate=%SAMPLE_RATE%*0.8,aresample=%SAMPLE_RATE%,atempo=1/0.8,aformat=channel_layouts=mono [p0]; [out2] asetrate=%SAMPLE_RATE%*1.2,aresample=%SAMPLE_RATE%,atempo=1/1.2,aformat=channel_layouts=mono[p2]; [p0][0][p2] amix=inputs=3"}
	gib_chance = 5
	light_system = MOVABLE_LIGHT

	///Hive name define
	var/hivenumber = XENO_HIVE_NORMAL
	///Hive datum we belong to
	var/datum/hive_status/hive
	///Xeno mob specific flags
	var/xeno_flags = NONE

	///State tracking of hive status toggles
	var/status_toggle_flags = HIVE_STATUS_DEFAULTS
	///Handles displaying the various wound states of the xeno.
	var/atom/movable/vis_obj/xeno_wounds/wound_overlay
	///Handles displaying the various fire states of the xeno
	var/atom/movable/vis_obj/xeno_wounds/fire_overlay/fire_overlay
	///Handles displaying any equipped backpack item, such as a saddle
	var/atom/movable/vis_obj/xeno_wounds/backpack_overlay/backpack_overlay
	var/datum/xeno_caste/xeno_caste
	/// /datum/xeno_caste that we will be on init
	var/caste_base_type
	var/language = "Xenomorph"
	///Plasma currently stored
	var/plasma_stored = 0

	///A mob the xeno ate
	var/mob/living/carbon/eaten_mob
	///How much evolution they have stored
	var/evolution_stored = 0
	///How much upgrade points they have stored.
	var/upgrade_stored = 0
	///This will track their upgrade level.
	var/upgrade = XENO_UPGRADE_INVALID
	///sunder affects armour values and does a % removal before dmg is applied. 50 sunder == 50% effective armour values
	var/sunder = 0
	///The ammo datum for our spit projectiles. We're born with this, it changes sometimes.
	var/datum/ammo/xeno/ammo = null
	///The aura we're currently emitted. Destroyed whenever we change or stop pheromones.
	var/datum/aura_bearer/current_aura
	/// If we're chosen as leader, this is the leader aura we emit.
	var/datum/aura_bearer/leader_current_aura
	///Passive plasma cost per tick for enabled personal (not leadership) pheromones.
	var/pheromone_cost = 5
	///Strength of aura we are affected by. NOT THE ONE WE ARE EMITTING
	var/frenzy_aura = 0
	///Strength of aura we are affected by. NOT THE ONE WE ARE EMITTING
	var/warding_aura = 0
	///Strength of aura we are affected by. NOT THE ONE WE ARE EMITTING
	var/recovery_aura = 0
	///Resets to -xeno_caste.regen_delay when you take damage.
	///Negative values act as a delay while values greater than 0 act as a multiplier.
	///Will increase by 10 every decisecond if under 0.
	///Increases by xeno_caste.regen_ramp_amount every decisecond. If you want to balance this, look at the xeno_caste defines mentioned above.
	var/regen_power = 0

	var/zoom_turf = null

	///Type of weeds the xeno is standing on, null when not on weeds
	var/obj/alien/weeds/loc_weeds_type
	///This will track their "tier" to restrict/limit evolutions
	var/tier = XENO_TIER_ONE
	///which resin structure to build when we secrete resin
	var/selected_resin = /turf/closed/wall/resin/regenerating
	//which special resin structure to build when we secrete special resin
	var/selected_special_resin = /turf/closed/wall/resin/regenerating/special/bulletproof
	/// Which reagent to slash with using reagent slash. Use `set_selected_reagent` when changing this.
	var/selected_reagent = /datum/reagent/toxin/xeno_hemodile
	///which plant to place when we use sow
	var/obj/structure/xeno/plant/selected_plant = /obj/structure/xeno/plant/heal_fruit
	///Naming variables
	var/nicknumber = 0 //The number/name after the xeno type. Saved right here so it transfers between castes.

	///This list of inherent verbs lets us take any proc basically anywhere and add them.
	///If they're not a xeno subtype it might crash or do weird things, like using human verb procs
	///It should add them properly on New() and should reset/readd them on evolves
	var/list/inherent_verbs = list()

	///The xenomorph that this source is currently overwatching
	var/mob/living/carbon/xenomorph/observed_xeno

	///Multiplicative melee damage modifier; referenced by attack_alien.dm, most notably attack_alien_harm
	var/xeno_melee_damage_modifier = 1

	/// Visual effect that appears when doing a normal attack.
	var/attack_effect = ATTACK_EFFECT_REDSLASH

	//Charge vars
	///Will the mob charge when moving ? You need the charge verb to change this
	var/is_charging = CHARGE_OFF

	// Gorger vars
	var/overheal = 0

	// Defender vars
	var/fortify = 0
	var/crest_defense = 0

	// *** Ravager vars *** //
	/// when true the rav will not go into crit or take crit damage.
	var/endure = FALSE
	///when true the rav leeches healing off of hitting marines
	var/vampirism

	// *** Carrier vars *** //
	var/selected_hugger_type = /obj/item/clothing/mask/facehugger

	// *** Boiler vars *** //
	/// If their stored globs (corrosive + neurotoxin) surpasses this amount, they begin to glow at an increasing intensity.
	var/glob_luminosity_threshold = BOILER_LUMINOSITY_THRESHOLD
	/// Should the glow be replaced with a movement modifier? If so, how much for each glob above the threshold?
	var/glob_luminosity_slowing = 0
	/// Stored corrosive globs created from Boiler's Create Bomb.
	var/corrosive_ammo = 0
	/// Stored neurotoxin globs created from Boiler's Create Bomb.
	var/neurotoxin_ammo = 0

	// *** Globadier vars *** //
	var/obj/item/explosive/grenade/globadier/selected_grenade = /obj/item/explosive/grenade/globadier

	// *** Behemoth vars *** //
	/// Whether we are currently charging or not.
	var/behemoth_charging = FALSE
	/// The amount of Wrath currently stored.
	var/wrath_stored = 0

	// *** Conqueror vars *** //
	/// If Endurance is currently active.
	var/endurance_active = FALSE
	/// The amount of remaining health that Endurance has.
	var/endurance_health = 1
	/// The maximum amount of health that Endurance can have.
	var/endurance_health_max = 1
	/// Whether our Endurance has been broken, due to losing all of its health.
	var/endurance_broken = FALSE

	//Notification spam controls
	var/recent_notice = 0
	var/notice_delay = 20 //2 second between notices

	var/fire_luminosity = 0 //Luminosity of the current fire while burning

	///The xenos/silo/nuke currently tracked by the xeno_tracker arrow
	var/atom/tracked

	/// The type of footstep this xeno has.
	var/footstep_type = FOOTSTEP_XENO_MEDIUM

	//list of active tunnels
	var/list/tunnels = list()
	///Number of huggers the xeno is currently carrying
	var/huggers = 0

	/// All active mutations they own.
	var/list/datum/mutation_upgrade/owned_mutations = list()

	COOLDOWN_DECLARE(xeno_health_alert_cooldown)

	///The resting cooldown
	COOLDOWN_DECLARE(xeno_resting_cooldown)
	///The unresting cooldown
	COOLDOWN_DECLARE(xeno_unresting_cooldown)

///Called whenever a xeno slashes a human
/mob/living/carbon/xenomorph/proc/onhithuman(attacker, target) //For globadiers lifesteal debuff
	SIGNAL_HANDLER
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/victim = target
	if(!victim.has_status_effect(STATUS_EFFECT_LIFEDRAIN))
		return
	var/mob/living/carbon/xenomorph/xeno = attacker
	var/healamount = xeno.maxHealth * 0.06 //% of the xenos max health
	HEAL_XENO_DAMAGE(xeno, healamount, FALSE)

/// Sets the xenomorph's selected reagent & sends a signal indicating that it happened.
/mob/living/carbon/xenomorph/proc/set_selected_reagent(datum/reagent/new_reagent_typepath)
	if(selected_reagent == new_reagent_typepath)
		return
	SEND_SIGNAL(src, COMSIG_XENO_SELECTED_REAGENT_CHANGED, selected_reagent, new_reagent_typepath)
	selected_reagent = new_reagent_typepath
