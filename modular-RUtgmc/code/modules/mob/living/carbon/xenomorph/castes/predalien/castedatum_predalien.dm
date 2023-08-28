/datum/xeno_caste/predalien
	caste_name = "Predalien"
	display_name = "Abomination"
	caste_type_path = /mob/living/carbon/xenomorph/predalien
	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "Predalien"

	charge_type = CHARGE_TYPE_LARGE

	// *** Melee Attacks *** //
	melee_damage = 40

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 5

	soft_armor = list(MELEE = 60, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 80, BIO = 60, FIRE = 30, ACID = 60)

	// *** Health *** //
	max_health = 650

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	// *** Minimap Icon *** //
	minimap_icon = "predalien"

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/pounce/predalien,
		/datum/action/xeno_action/activable/predalien_roar,
		/datum/action/xeno_action/activable/smash,
		/datum/action/xeno_action/activable/devastate,
	)

/mob/living/carbon/xenomorph/predalien
	caste_base_type = /mob/living/carbon/xenomorph/predalien
	name = "Abomination" //snowflake name
	desc = "A strange looking creature with fleshy strands on its head. It appears like a mixture of armor and flesh, smooth, but well carapaced."
	icon = 'icons/Xeno/predalien.dmi'
	icon_state = "Predalien Walking"
	wall_smash = TRUE
	pixel_x = -16
	old_x = -16
	bubble_icon = "alienroyal"
	talk_sound = "predalien_talk"
	mob_size = MOB_SIZE_BIG

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_ZERO

	var/max_bonus_life_kills = 10
	var/butcher_time = 6 SECONDS

/mob/living/carbon/xenomorph/predalien/Initialize(mapload, mob/living/carbon/xenomorph/oldxeno, h_number)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(announce_spawn)), 3 SECONDS)
	hunter_data.dishonored = TRUE
	hunter_data.dishonored_reason = "An abomination upon the honor of us all!"
	hunter_data.dishonored_set = src
	hud_set_hunter()

/mob/living/carbon/xenomorph/predalien/Stat()
	. = ..()
	if(statpanel("Game"))
		stat("Life Kills Bonus:", "[min(life_kills_total, max_bonus_life_kills)] / [max_bonus_life_kills]")

/mob/living/carbon/xenomorph/predalien/proc/announce_spawn()
	if(!loc)
		return FALSE

	to_chat(src, {"
<span class='role_body'>|______________________|</span>
<span class='role_header'>You are a predator-alien hybrid!</span>
<span class='role_body'>You are a very powerful xenomorph creature that was born of a Yautja warrior body.
You are stronger, faster, and smarter than a regular xenomorph, but you must still listen to the hive ruler.
You have a degree of freedom to where you can hunt and claim the heads of the hive's enemies, so check your verbs.
Your health meter will not regenerate normally, so kill and die for the hive!</span>
<span class='role_body'>|______________________|</span>
"})
	emote("roar")

/datum/xeno_caste/predalien/young
	upgrade_name = "Young"
	upgrade = XENO_UPGRADE_ZERO

	// *** Melee Attacks *** //
	melee_damage = 45

/datum/xeno_caste/predalien/mature
	upgrade_name = "Mature"
	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 50

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

/datum/xeno_caste/predalien/elder
	upgrade_name = "Elder"
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 55

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

/datum/xeno_caste/predalien/ancient
	upgrade_name = "Ancient"
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 60

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

/datum/xeno_caste/predalien/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 65
