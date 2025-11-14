/mob/living/carbon/human
	name = "unknown"
	real_name = "unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "body_m_s"
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	hud_possible = list(HEALTH_HUD, STATUS_HUD_SIMPLE, STATUS_HUD, XENO_EMBRYO_HUD, XENO_REAGENT_HUD, WANTED_HUD, SQUAD_HUD_TERRAGOV, SQUAD_HUD_SOM, ORDER_HUD, PAIN_HUD, XENO_DEBUFF_HUD, HEART_STATUS_HUD)
	health_threshold_crit = -50
	melee_damage = 5
	m_intent = MOVE_INTENT_WALK
	buckle_flags = CAN_BE_BUCKLED|CAN_BUCKLE
	resistance_flags = XENO_DAMAGEABLE|PORTAL_IMMUNE
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE|LONG_GLIDE

	hud_type = /datum/hud/human

	//Hair colour and style
	var/r_hair = 0
	var/g_hair = 0
	var/b_hair = 0
	var/h_style = "Crewcut"

	// Gradient color and style
	var/r_grad = 0
	var/g_grad = 0
	var/b_grad = 0
	var/grad_style = "None"

	//Facial hair colour and style
	var/r_facial = 0
	var/g_facial = 0
	var/b_facial = 0
	var/f_style = "Shaved"

	//Eye colour
	var/r_eyes = 0
	var/g_eyes = 0
	var/b_eyes = 0

	///The character's ethnicity
	var/ethnicity = "Western"

	//Skin colour
	var/r_skin = 0
	var/g_skin = 0
	var/b_skin = 0

	//Species specific
	var/moth_wings = "Plain"

	///The style of the makeup the mob currently has applied. Used to determine the right icon state for on the mob.
	var/makeup_style = ""

	///Character's age (pure fluff)
	var/age = 30

	/// Which body type to use
	var/physique = MALE

	///Which underwear the player wants
	var/underwear = 1
	///Which undershirt the player wants.
	var/undershirt = 0

	//The character's citizenship. Fluff.
	var/citizenship = ""
	///The character's religion. Fluff.
	var/religion = ""

	//Equipment slots. These are all references to items.

	///The item currently being worn in the suit slot (usually armor)
	var/obj/item/wear_suit
	///The item currently inside the suit storage slot (not inside the armor itself)
	var/obj/item/s_store
	///The jumpsuit/uniform that's currently being worn.
	var/obj/item/clothing/under/w_uniform
	///The shoes currently being worn.
	var/obj/item/clothing/shoes/shoes
	///The belt being worn.
	var/obj/item/belt
	///The gloves being worn.
	var/obj/item/clothing/gloves/gloves
	///The glasses being worn.
	var/obj/item/clothing/glasses/glasses
	///The item currently on the character's head.
	var/obj/item/head
	///The headset/ear item being worn.
	var/obj/item/wear_ear
	///The ID being worn.
	var/obj/item/card/id/wear_id
	///The item currently in the right pocket
	var/obj/item/r_store
	///The item currently in the left pocket
	var/obj/item/l_store

	///The current standing icon
	var/icon/stand_icon

	///Used for determining if we need to process all limbs or just some or even none.
	var/last_dam = -1

	///This human's flavor text. Shows up when they're examined.
	var/flavor_text = ""
	///This human's custom medical record. Fluff.
	var/med_record = ""
	///This human's custom security record. Fluff.
	var/sec_record = ""
	///This human's custom employment record. Fluff.
	var/gen_record = ""
	///This human's custom exploit record. Fluff.
	var/exploit_record = ""


	//Life variables

	///How long the human is dead, in life ticks, which is 2 seconds
	var/dead_ticks = 0

	///Which color type of holocard is printed on us
	var/holo_card_color = ""

	///A list of our limb datums
	var/list/limbs = list()
	///A list of internal organs by name ["organ name"] = /datum/internal_organ
	var/list/internal_organs_by_name = list()
	///How much dirt the mob's accumulated. Harmless by itself, but can trigger issues with open wounds or surgery.
	var/germ_level = 0

	///Auras we can create, used for the order choice UI.
	var/static/list/command_aura_allowed = list(AURA_HUMAN_MOVE, AURA_HUMAN_HOLD, AURA_HUMAN_FOCUS)
	///Strength of the move order aura affecting us
	var/mobility_aura = 0
	///Strength of the hold order aura affecting us
	var/protection_aura = 0
	///Strength of the focus order aura affecting us
	var/marksman_aura = 0
	///Strength of the flag aura affecting us
	var/flag_aura = 0

	///The squad this human is assigned to
	var/datum/squad/assigned_squad
	///Used to help determine the severity icon state for our damage hud overlays
	var/damageoverlaytemp = 0
	///chestburst state
	var/chestburst = CARBON_NO_CHEST_BURST
	///The cooldown for being pushed by xenos on harm intent
	COOLDOWN_DECLARE(xeno_push_delay)

	/// This is the cooldown on suffering additional effects for when shock gets high
	COOLDOWN_DECLARE(last_shock_effect)

	/// Height of the mob
	VAR_PROTECTED/mob_height = HUMAN_HEIGHT_MEDIUM

///copies over clothing preferences like underwear to another human
/mob/living/carbon/human/proc/copy_clothing_prefs(mob/living/carbon/human/destination)
	destination.underwear = underwear
	destination.undershirt = undershirt

/mob/living/carbon/human/replace_by_ai()
	to_chat(src, span_warning("Sorry, your skill level was deemed too low by our automatic skill check system. Your body has as such been given to a more capable brain, our state of the art AI technology piece. Do not hesitate to take back your body after you've improved!"))
	ghostize(TRUE)//Can take back its body
	GLOB.offered_mob_list -= src
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/human)
