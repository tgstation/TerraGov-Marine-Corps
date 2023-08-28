/datum/xeno_caste/hellhound
	caste_name = "Hellhound"
	display_name = "Hellhound"
	caste_type_path = /mob/living/carbon/xenomorph/hellhound
	caste_desc = "A fast, four-legged terror, but weak in sustained combat."
	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = ""
	upgrade_name = ""

	caste_flags = CASTE_INNATE_HEALING|CASTE_INNATE_PLASMA_REGEN

	charge_type = CHARGE_TYPE_SMALL

	// *** Melee Attacks *** //
	melee_damage = 35

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 10

	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 40, BIO = 55, FIRE = 55, ACID = 55)

	// *** Health *** //
	max_health = 290

	// *** Minimap Icon *** //
	minimap_icon = "hellhound"

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/activable/pounce/hellhound,
		/datum/action/xeno_action/toggle_long_range,
	)

/mob/living/carbon/xenomorph/hellhound
	caste_base_type = /mob/living/carbon/xenomorph/hellhound
	name = "Hellhound"
	desc = "A disgusting beast from hell, it has four menacing spikes growing from its head."
	icon = 'icons/Xeno/hellhound.dmi'
	icon_state = "Hellhound Walking"
	health = 290
	maxHealth = 290
	plasma_stored = 100
	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE
	bubble_icon = "alien"

	layer = MOB_LAYER
	pull_speed = -0.5

	mob_size = MOB_SIZE_XENO

	hivenumber = XENO_HIVE_YAUTJA

/mob/living/carbon/xenomorph/hellhound/Initialize(mapload, mob/living/carbon/xenomorph/oldXeno, h_number)
	. = ..(mapload, oldXeno, h_number || XENO_HIVE_YAUTJA)

	language_holder = get_language_holder()
	language_holder.grant_language(/datum/language/hellhound)
	language_holder.only_speaks_language = /datum/language/hellhound
	language_holder.grant_language(/datum/language/yautja)

	GLOB.alive_xeno_list -= src
	GLOB.xeno_mob_list -= src
	GLOB.hellhound_list += src

/mob/living/carbon/xenomorph/hellhound/prepare_huds()
	..()
	var/image/health_holder = hud_list[HEALTH_HUD_XENO]
	health_holder.pixel_x = -12
	var/image/plasma_holder = hud_list[PLASMA_HUD]
	plasma_holder.pixel_x = -12
	var/image/banished_holder = hud_list[XENO_BANISHED_HUD]
	banished_holder.pixel_x = -12
	banished_holder.pixel_y = -6

/mob/living/carbon/xenomorph/hellhound/Login()
	. = ..()
	to_chat(src, "<span style='font-weight: bold; color: red;'>Attention!! You are playing as a hellhound. You can get server banned if you are shitty so listen up!</span>")
	to_chat(src, "<span style='color: red;'>You MUST listen to and obey the Predator's commands at all times. Die if they demand it. Not following them is unthinkable to a hellhound.</span>")
	to_chat(src, "<span style='color: red;'>You are not here to go hog wild rambo. You're here to be part of something rare, a Predator hunt.</span>")
	to_chat(src, "<span style='color: red;'>The Predator players must follow a strict code of role-play and you are expected to as well.</span>")
	to_chat(src, "<span style='color: red;'>The Predators cannot understand your speech. They can only give you orders and expect you to follow them.</span>")
	to_chat(src, "<span style='color: red;'>Hellhounds are fiercely protective of their masters and will never leave their side if under attack.</span>")
	to_chat(src, "<span style='color: red;'>Note that ANY Predator can give you orders. If they conflict, follow the latest one. If they dislike your performance they can ask for another ghost and everyone will mock you. So do a good job!</span>")

/mob/living/carbon/xenomorph/hellhound/death(cause, gibbed)
	. = ..(cause, gibbed, "lets out a horrible roar as it collapses and stops moving...")
	if(!.)
		return
	emote("roar")
	GLOB.hellhound_list -= src
	GLOB.alive_xeno_list -= src

/mob/living/carbon/xenomorph/hellhound/Destroy()
	GLOB.hellhound_list -= src
	GLOB.alive_xeno_list -= src
	return ..()
