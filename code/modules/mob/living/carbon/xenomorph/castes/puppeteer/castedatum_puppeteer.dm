/datum/xeno_caste/puppeteer
	caste_name = "Puppeteer"
	display_name = "Puppeteer"
	upgrade_name = ""
	caste_desc = "An alien creature of terrifying display, it has a tail adorned with needles that drips a strange chemical and elongated claws."
	caste_type_path = /mob/living/carbon/xenomorph/puppeteer
	ancient_message = "Their biomass will become ours for the taking. They will become nothing more than puppets pulled on strings."
	primordial_message = "The organics will tremble at our swarm. We are legion."

	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "puppeteer" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 13

	// *** Speed *** //
	speed = 0.2

	// *** Plasma *** //
	plasma_max = 450
	plasma_gain = 0
	plasma_regen_limit = 0
	plasma_icon_state = "fury"

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_YOUNG_THRESHOLD

	evolves_to = list(/mob/living/carbon/xenomorph/widow, /mob/living/carbon/xenomorph/warlock)
	deevolves_to = /mob/living/carbon/xenomorph/defender

	// *** Flags *** //
	caste_flags = CASTE_INNATE_PLASMA_REGEN|CASTE_PLASMADRAIN_IMMUNE|CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_LEADER
	caste_traits = null

	// *** Defense *** // [FIX THIS, THIS IS WORKING]
	soft_armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 10, BIO = 5, FIRE = 5, ACID = 5)

	// *** Minimap Icon *** //
	minimap_icon = "puppeteer"

	// *** Puppeteer Abilities *** //
	flay_plasma_gain = 100
	max_puppets = 2

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain/free,
		/datum/action/xeno_action/activable/flay,
		/datum/action/xeno_action/activable/pincushion,
		/datum/action/xeno_action/dreadful_presence,
		/datum/action/xeno_action/activable/refurbish_husk,
		/datum/action/xeno_action/activable/puppet,
		/datum/action/xeno_action/activable/organic_bomb,
		/datum/action/xeno_action/activable/mimicry,
		/datum/action/xeno_action/blessing,
		/datum/action/xeno_action/blessing/fury,
		/datum/action/xeno_action/blessing/ward,
		/datum/action/xeno_action/blessing/frenzy,
	)

/datum/xeno_caste/puppeteer/young
	upgrade_name = "Young"
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/puppeteer/mature
	upgrade_name = "Mature"
	caste_desc = "An alien creature of terrifying display, it has a tail adorned with needles that drips a strange chemical and elongated claws. It moves with an offputting fluidity."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = 0

	// *** Plasma *** //
	plasma_max = 550

	// *** Health *** //
	max_health = 275

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, FIRE = 10, ACID = 10)


/datum/xeno_caste/puppeteer/elder
	upgrade_name = "Elder"
	caste_desc = "An alien creature of terrifying display, it has a tail adorned with needles that drips a strange chemical and elongated claws. It moves with an offputting fluidity that displays ruthless efficiency."

	upgrade = XENO_UPGRADE_TWO

	// *** Speed *** //
	speed = -0.1

	// *** Melee Attacks *** //
	melee_damage = 18

	// *** Plasma *** //
	plasma_max = 650

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** // [FIX THIS, THIS IS WORKING]
	soft_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 10, BIO = 15, FIRE = 15, ACID = 15)

	// *** Puppeteer Abilities *** //
	max_puppets = 3

/datum/xeno_caste/puppeteer/ancient
	upgrade_name = "Ancient"
	caste_desc = "You could smell it before you could see it, you don't know what this is but you can tell it knows you inside and out."
	upgrade = XENO_UPGRADE_THREE

	// *** Speed *** //
	speed = -0.3

	// *** Melee Attacks *** //
	melee_damage = 18

	// *** Plasma *** //
	plasma_max = 750

	// *** Health *** //
	max_health = 350

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_ANCIENT_THRESHOLD

	// *** Defense *** // [FIX THIS, THIS IS WORKING]
	soft_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 10, BIO = 20, FIRE = 20, ACID = 20)

	// *** Puppeteer Abilities *** //
	max_puppets = 5

/datum/xeno_caste/puppeteer/primordial
	upgrade_name = "Primordial"
	caste_desc = "Being within mere eyeshot of this hulking monstrosity fills you with a deep, unshakeable sense of unease. You are unsure if you can even harm it."
	upgrade = XENO_UPGRADE_FOUR

	// *** Speed *** //
	speed = -0.4

	// *** Melee Attacks *** //
	melee_damage = 18

	// *** Plasma *** //
	plasma_max = 750

	// *** Health *** //
	max_health = 350

	// *** Defense *** // [FIX THIS, THIS IS WORKING]
	soft_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 10, BIO = 20, FIRE = 20, ACID = 20)

	// *** Puppeteer Abilities *** //
	max_puppets = 5

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain/free,
		/datum/action/xeno_action/activable/flay,
		/datum/action/xeno_action/activable/pincushion,
		/datum/action/xeno_action/dreadful_presence,
		/datum/action/xeno_action/activable/refurbish_husk,
		/datum/action/xeno_action/activable/puppet,
		/datum/action/xeno_action/activable/organic_bomb,
		/datum/action/xeno_action/activable/mimicry,
		/datum/action/xeno_action/activable/strings_attached,
		/datum/action/xeno_action/blessing,
		/datum/action/xeno_action/blessing/fury,
		/datum/action/xeno_action/blessing/ward,
		/datum/action/xeno_action/blessing/frenzy,
	)
