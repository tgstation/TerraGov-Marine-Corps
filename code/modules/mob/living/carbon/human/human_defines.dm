/mob/living/carbon/human
	name = "Unknown"
	real_name = "Unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "human_basic"
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ID_HUD,WANTED_HUD,IMPLOYAL_HUD,IMPCHEM_HUD,IMPTRACK_HUD, NANITE_HUD, DIAG_NANITE_FULL_HUD,ANTAG_HUD,GLAND_HUD,SENTIENT_DISEASE_HUD)
	hud_type = /datum/hud/human
	base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, INTENT_HARM)
	possible_mmb_intents = list(INTENT_STEAL, INTENT_JUMP, INTENT_KICK, INTENT_BITE, INTENT_GIVE)
	pressure_resistance = 25
	can_buckle = TRUE
	buckle_lying = FALSE
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID

	ambushable = 1

	var/footstep_type = FOOTSTEP_MOB_HUMAN

	var/last_sound //last emote so we have no doubles

	//Hair colour and style
	var/hair_color = "000"
	var/hairstyle = "Bald"

	//Facial hair colour and style
	var/facial_hair_color = "000"
	var/facial_hairstyle = "Shaved"

	//Eye colour
	var/eye_color = "000"

	var/voice_color = "a0a0a0"

	var/detail_color = "000"

	var/skin_tone = "caucasian1"	//Skin tone

	var/lip_style = null	//no lipstick by default- arguably misleading, as it could be used for general makeup
	var/lip_color = "white"

	var/age = "Adult"		//Player's age

	var/underwear = "Nude"	//Which underwear the player wants
	var/underwear_color
	var/undershirt = "Nude" //Which undershirt the player wants

	var/cached_underwear = "Nude"

	var/accessory = "None"
	var/detail = "None"
	var/marking = "None"

	var/shavelevel = 0

	var/socks = "Nude" //Which socks the player wants
	var/backpack = DBACKPACK		//Which backpack type the player has chosen.
	var/jumpsuit_style = PREF_SUIT		//suit/skirt

	//Equipment slots
	var/obj/item/clothing/skin_armor = null
	var/obj/item/clothing/wear_armor = null
	var/obj/item/clothing/wear_pants = null
	var/obj/item/belt = null
	var/obj/item/beltl = null
	var/obj/item/beltr = null
	var/obj/item/wear_ring = null
	var/obj/item/wear_wrists = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null
	var/obj/item/cloak = null
	var/obj/item/clothing/wear_shirt = null

	var/special_voice = "" // For changing our voice. Used by a symptom.

	var/name_override //For temporary visible name changes

	var/datum/physiology/physiology

	var/list/datum/bioware = list()

	var/static/list/can_ride_typecache = typecacheof(list(/mob/living/carbon/human, /mob/living/simple_animal/slime, /mob/living/simple_animal/parrot))
	var/lastpuke = 0
	var/last_fire_update
	var/account_id

	canparry = TRUE
	candodge = TRUE

	dodgecd = FALSE
	dodgetime = 0

	var/list/possibleclass
	var/advsetup = 0
	var/advpicking

//	var/alignment = ALIGNMENT_TN

	var/advjob = null
	var/canseebandits = FALSE

	var/marriedto

	var/has_stubble = TRUE

	var/original_name = null

	var/buried = FALSE // Whether the body is buried or not.
	var/funeral = FALSE // Whether the body has received rites or not.

	var/cleric = null // Used for cleric_holder for priests

	possible_rmb_intents = list(/datum/rmb_intent/feint,\
	/datum/rmb_intent/aimed,\
	/datum/rmb_intent/strong,\
	/datum/rmb_intent/swift,\
	/datum/rmb_intent/riposte,\
	/datum/rmb_intent/weak)

	rot_type = /datum/component/rot/corpse
