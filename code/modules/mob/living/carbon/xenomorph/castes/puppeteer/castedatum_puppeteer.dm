/datum/xeno_caste/puppeteer
	caste_name = "Puppeteer"
	display_name = "Puppeteer"
	upgrade_name = ""
	caste_desc = "An alien creature of terrifying display, it has a tail adorned with needles that drips a strange chemical and elongated claws."
	caste_type_path = /mob/living/carbon/xenomorph/puppeteer
	primordial_message = "The organics will tremble at our swarm. We are legion."

	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "puppeteer"
	speed = -0.8
	melee_damage = 18
	plasma_max = 750
	plasma_gain = 0
	plasma_regen_limit = 0
	plasma_icon_state = "fury"
	max_health = 365
	upgrade_threshold = TIER_TWO_THRESHOLD
	evolution_threshold = 225

	evolves_to = list(/mob/living/carbon/xenomorph/widow, /mob/living/carbon/xenomorph/warlock)
	deevolves_to = list(/mob/living/carbon/xenomorph/defender)
	caste_flags = CASTE_INNATE_PLASMA_REGEN|CASTE_PLASMADRAIN_IMMUNE|CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_LEADER
	caste_traits = null
	soft_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 10, BIO = 20, FIRE = 20, ACID = 20)
	minimap_icon = "puppeteer"
	flay_plasma_gain = 100
	max_puppets = 3
	aura_strength = 2.8

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain/free,
		/datum/action/ability/activable/xeno/flay,
		/datum/action/ability/activable/xeno/pincushion,
		/datum/action/ability/xeno_action/dreadful_presence,
		/datum/action/ability/activable/xeno/refurbish_husk,
		/datum/action/ability/activable/xeno/puppet,
		/datum/action/ability/activable/xeno/organic_bomb,
		/datum/action/ability/xeno_action/puppeteer_orders,
		/datum/action/ability/activable/xeno/articulate,
		/datum/action/ability/activable/xeno/puppet_blessings,
	)

/datum/xeno_caste/puppeteer/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/puppeteer/primordial
	upgrade_name = "Primordial"
	caste_desc = "Being within mere eyeshot of this hulking monstrosity fills you with a deep, unshakeable sense of unease. You are unsure if you can even harm it."
	upgrade = XENO_UPGRADE_PRIMO
	speed = -0.8
	melee_damage = 18
	plasma_max = 750
	max_health = 385
	soft_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 10, BIO = 20, FIRE = 20, ACID = 20)
	max_puppets = 3

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain/free,
		/datum/action/ability/activable/xeno/flay,
		/datum/action/ability/activable/xeno/pincushion,
		/datum/action/ability/xeno_action/dreadful_presence,
		/datum/action/ability/activable/xeno/refurbish_husk,
		/datum/action/ability/activable/xeno/puppet,
		/datum/action/ability/activable/xeno/organic_bomb,
		/datum/action/ability/activable/xeno/tendril_patch,
		/datum/action/ability/xeno_action/puppeteer_orders,
		/datum/action/ability/activable/xeno/articulate,
		/datum/action/ability/activable/xeno/puppet_blessings,
	)

	aura_strength = 3
