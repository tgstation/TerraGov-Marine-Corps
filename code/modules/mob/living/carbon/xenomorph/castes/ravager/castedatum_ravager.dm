/datum/xeno_caste/ravager
	caste_name = "Ravager"
	display_name = "Ravager"
	upgrade_name = ""
	caste_desc = "A brutal, devastating front-line attacker."
	caste_type_path = /mob/living/carbon/xenomorph/ravager
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "ravager" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 28
	attack_delay = 7

	// *** Speed *** //
	speed = -0.7

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 5
	plasma_regen_limit = 0.5
	plasma_icon_state = "fury"

	// *** Health *** //
	max_health = 290

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/hunter

	// *** Flags *** //
	caste_flags = CASTE_INNATE_PLASMA_REGEN|CASTE_PLASMADRAIN_IMMUNE
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING

	// *** Defense *** //
	soft_armor = list("melee" = 35, "bullet" = 40, "laser" = 30, "energy" = 30, "bomb" = 10, "bio" = 30, "rad" = 30, "fire" = 50, "acid" = 30)

	// *** Ranged Attack *** //
	charge_type = CHARGE_TYPE_LARGE

	// *** Minimap Icon *** //
	minimap_icon = "ravager"

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/show_hivestatus,
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/charge,
		/datum/action/xeno_action/activable/ravage,
		/datum/action/xeno_action/endure,
		/datum/action/xeno_action/rage,
	)

/datum/xeno_caste/ravager/on_caste_applied(mob/xenomorph)
	. = ..()
	xenomorph.AddElement(/datum/element/plasma_on_attack, 1.5)
	xenomorph.AddElement(/datum/element/plasma_on_attacked, 0.5)

/datum/xeno_caste/ravager/on_caste_removed(mob/xenomorph)
	. = ..()
	xenomorph.RemoveElement(/datum/element/plasma_on_attack, 1.5)
	xenomorph.RemoveElement(/datum/element/plasma_on_attacked, 0.5)

/datum/xeno_caste/ravager/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/ravager/mature
	upgrade_name = "Mature"
	caste_desc = "A brutal, devastating front-line attacker. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 700 //Enables using either both abilities at once or one after another
	plasma_gain = 5

	// *** Health *** //
	max_health = 310

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 40, "bullet" = 45, "laser" = 40, "energy" = 40, "bomb" = 10, "bio" = 35, "rad" = 35, "fire" = 55, "acid" = 35)

/datum/xeno_caste/ravager/elder
	upgrade_name = "Elder"
	caste_desc = "A brutal, devastating front-line attacker. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 30

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 750
	plasma_gain = 10
	plasma_regen_limit = 0.6

	// *** Health *** //
	max_health = 330

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 45, "bullet" = 50, "laser" = 45, "energy" = 45, "bomb" = 10, "bio" = 38, "rad" = 38, "fire" = 65, "acid" = 38)

/datum/xeno_caste/ravager/ancient
	upgrade_name = "Ancient"
	caste_desc = "As I walk through the valley of the shadow of death."
	ancient_message = "We are death incarnate. All will tremble before us."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 30

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 15

	// *** Health *** //
	max_health = 350

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 50, "bullet" = 55, "laser" = 50, "energy" = 50, "bomb" = 10, "bio" = 40, "rad" = 40, "fire" = 70, "acid" = 40)

/datum/xeno_caste/ravager/primordial
	upgrade_name = "Primordial"
	caste_desc = "Red like the blood of those that try to stop its rampage."
	primordial_message = "Our frenzy is eternal. Rip and tear, until it is done."
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 30

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 15

	// *** Health *** //
	max_health = 350

	// *** Defense *** //
	soft_armor = list("melee" = 50, "bullet" = 55, "laser" = 50, "energy" = 50, "bomb" = 10, "bio" = 40, "rad" = 40, "fire" = 70, "acid" = 40)

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/show_hivestatus,
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/charge,
		/datum/action/xeno_action/activable/ravage,
		/datum/action/xeno_action/endure,
		/datum/action/xeno_action/rage,
		/datum/action/xeno_action/vampirism,
	)
