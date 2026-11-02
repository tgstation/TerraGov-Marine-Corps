/datum/xeno_caste/ravager
	caste_name = "Ravager"
	display_name = "Ravager"
	upgrade_name = ""
	caste_desc = "A brutal, devastating front-line attacker."
	base_strain_type = /mob/living/carbon/xenomorph/ravager
	caste_type_path = /mob/living/carbon/xenomorph/ravager
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "ravager" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 25
	melee_ap = 15
	attack_delay = 7

	// *** Speed *** //
	speed = -1.0

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 15
	plasma_regen_limit = 0.5
	plasma_icon_state = "fury"

	// *** Health *** //
	max_health = 400

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD

	deevolves_to = /datum/xeno_caste/hunter

	// *** Flags *** //
	caste_flags = CASTE_INNATE_PLASMA_REGEN|CASTE_PLASMADRAIN_IMMUNE|CASTE_EVOLUTION_ALLOWED|CASTE_MUTATIONS_ALLOWED
	caste_traits = list(TRAIT_CAN_TEAR_HOLE, TRAIT_CAN_DISABLE_MINER)

	// *** Defense *** //
	soft_armor = list(MELEE = 50, BULLET = 55, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 40, FIRE = 70, ACID = 40)

	// *** Minimap Icon *** //
	minimap_icon = "ravager"

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/charge,
		/datum/action/ability/activable/xeno/ravage,
		/datum/action/ability/xeno_action/endure,
		/datum/action/ability/xeno_action/rage,
	)
	///multiplier on plasma amount vs damage that is recieved on attack
	var/plasma_damage_dealt_mult = 1.5
	///multiplier on plasma amount vs damage that is recieved on being attacked
	var/plasma_damage_recieved_mult = 0.5

	mutations = list(
		/datum/mutation_upgrade/shell/little_more,
		/datum/mutation_upgrade/shell/keep_going,
		/datum/mutation_upgrade/shell/inward_focus,
		/datum/mutation_upgrade/spur/deep_slash,
		/datum/mutation_upgrade/spur/super_cut,
		/datum/mutation_upgrade/spur/onslaught,
		/datum/mutation_upgrade/veil/recurring_rage,
		/datum/mutation_upgrade/veil/fight_in_flames,
		/datum/mutation_upgrade/veil/bloody_endure
	)

/datum/xeno_caste/ravager/on_caste_applied(mob/living/carbon/xenomorph/xenomorph)
	. = ..()
	xenomorph.AddElement(/datum/element/plasma_on_attack, plasma_damage_dealt_mult)
	xenomorph.AddElement(/datum/element/plasma_on_attacked, plasma_damage_recieved_mult)

/datum/xeno_caste/ravager/on_caste_removed(mob/living/carbon/xenomorph/xenomorph)
	. = ..()
	xenomorph.RemoveElement(/datum/element/plasma_on_attack, plasma_damage_dealt_mult)
	xenomorph.RemoveElement(/datum/element/plasma_on_attacked, plasma_damage_recieved_mult)

/datum/xeno_caste/ravager/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/ravager/primordial
	upgrade_name = "Primordial"
	caste_desc = "Red like the blood of those that try to stop its rampage."
	primordial_message = "Our frenzy is eternal. Rip and tear, until it is done."
	upgrade = XENO_UPGRADE_PRIMO

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/charge,
		/datum/action/ability/activable/xeno/ravage,
		/datum/action/ability/xeno_action/endure,
		/datum/action/ability/xeno_action/rage,
		/datum/action/ability/xeno_action/vampirism,
	)



/datum/xeno_caste/ravager/bloodthirster
	caste_name = "Bloodthirster"
	display_name = "Bloodthirster"
	upgrade_name = ""
	caste_desc = "A thirsting fighter that knows no rest."
	caste_type_path = /mob/living/carbon/xenomorph/ravager/bloodthirster
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "ravager" //used to match appropriate wound overlays

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 0
	plasma_icon_state = "fury"

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/charge,
		/datum/action/ability/activable/xeno/ravage,
		/datum/action/ability/xeno_action/endure,
		/datum/action/ability/xeno_action/rage/blood_thirster,
		/datum/action/ability/xeno_action/bloodthirst,
	)
	plasma_damage_dealt_mult = 2
	plasma_damage_recieved_mult = 0.75

	mutations = list(
		/datum/mutation_upgrade/shell/no_end,
		/datum/mutation_upgrade/spur/early_rage,
		/datum/mutation_upgrade/veil/safety_trap
	)

/datum/xeno_caste/ravager/bloodthirster/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/ravager/bloodthirster/primordial
	upgrade_name = "Primordial"
	caste_desc = "A blood caked merciless killer."
	primordial_message = "BLOOD FOR THE BLOOD GOD! SKULLS FOR THE SKULL THRONE!"
	upgrade = XENO_UPGRADE_PRIMO

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/charge,
		/datum/action/ability/activable/xeno/ravage,
		/datum/action/ability/xeno_action/endure,
		/datum/action/ability/xeno_action/rage/blood_thirster,
		/datum/action/ability/xeno_action/bloodthirst,
		/datum/action/ability/xeno_action/deathmark,
	)

/datum/xeno_caste/ravager/corruptor
	caste_name = "Corruptor"
	display_name = "Corruptor"
	upgrade_name = ""
	caste_desc = "A hulking, terrifying clawed beast dripping in glowing acid."
	caste_type_path = /mob/living/carbon/xenomorph/ravager/corruptor
	upgrade = XENO_UPGRADE_BASETYPE
	caste_flags = parent_type::caste_flags|CASTE_ACID_BLOOD
	wound_type = "ravager"

	melee_damage = 21

	acid_spray_duration = 3 SECONDS
	acid_spray_damage = 20
	acid_spray_damage_on_hit = 20
	acid_spray_structure_damage = 45

	plasma_damage_dealt_mult = 1.75 //higher mult to scale with its lower base damage

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/charge/acid,
		/datum/action/ability/activable/xeno/ravage/acid,
		/datum/action/ability/xeno_action/endure,
		/datum/action/ability/xeno_action/rage/acid,
	)

/datum/xeno_caste/ravager/corruptor/on_caste_applied(mob/living/carbon/xenomorph/xenomorph)
	. = ..()
	xenomorph.ammo = GLOB.ammo_list[/datum/ammo/xeno/acid/auto]
	xenomorph.gib_chance = 100

/datum/xeno_caste/ravager/corruptor/on_caste_removed(mob/living/carbon/xenomorph/xenomorph)
	if(!QDELETED(xenomorph))
		xenomorph.ammo = null
		xenomorph.gib_chance = initial(xenomorph.gib_chance)
	return ..()

/datum/xeno_caste/ravager/corruptor/on_owner_gib(mob/living/carbon/xenomorph/xenomorph)
	xenomorph.visible_message(span_danger("[xenomorph] begins to bulge grotesquely, and explodes in a cloud of corrosive gas!"))
	var/datum/effect_system/smoke_spread/xeno/smoke = new /datum/effect_system/smoke_spread/xeno/acid/opaque(xenomorph)
	smoke.set_up(2, get_turf(xenomorph))
	smoke.start()

	xenomorph.acid_burst(15)

/datum/xeno_caste/ravager/corruptor/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/ravager/corruptor/primordial
	upgrade_name = "Primordial"
	caste_desc = "An nightmarish, acid drenched destroyer."
	primordial_message = "Destroy the enemies of the hive! Burn everything away in cleansing acid!"
	upgrade = XENO_UPGRADE_PRIMO

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/charge/acid,
		/datum/action/ability/activable/xeno/ravage/acid,
		/datum/action/ability/xeno_action/endure,
		/datum/action/ability/xeno_action/rage/acid,
		/datum/action/ability/xeno_action/vampirism,
	)
