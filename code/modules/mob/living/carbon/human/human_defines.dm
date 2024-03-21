/mob/living/carbon/human
	name = "unknown"
	real_name = "unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "body_m_s"
	blocks_emissive = EMISSIVE_BLOCK_NONE
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
	///Whether we can use another command order yet. Either null or a timer ID.
	var/command_aura_cooldown

	///Strength of the move order aura affecting us
	var/mobility_aura = 0
	///Strength of the hold order aura affecting us
	var/protection_aura = 0
	///Strength of the focus order aura affecting us
	var/marksman_aura = 0

	///The squad this human is assigned to
	var/datum/squad/assigned_squad
	///Used to help determine the severity icon state for our damage hud overlays
	var/damageoverlaytemp = 0
	///The cooldown for being pushed by xenos on harm intent
	COOLDOWN_DECLARE(xeno_push_delay)

	/// This is the cooldown on suffering additional effects for when shock gets high
	COOLDOWN_DECLARE(last_shock_effect)

///copies over clothing preferences like underwear to another human
/mob/living/carbon/human/proc/copy_clothing_prefs(mob/living/carbon/human/destination)
	destination.underwear = underwear
	destination.undershirt = undershirt

///is this mob under their death threshold
/mob/living/carbon/human/proc/can_be_revived()
	if(health <= health_threshold_dead)
		return FALSE
	return TRUE

/// Proc to check for a mob's ghost.
/mob/living/proc/get_ghost()
	if(client) //Let's call up the correct ghost!
		return null
	for(var/mob/dead/observer/ghost AS in GLOB.observer_list)
		if(!ghost) //Observers hard del often so lets just be safe
			continue
		if(isnull(ghost.can_reenter_corpse))
			continue
		if(ghost.can_reenter_corpse.resolve() != src)
			continue
		if(ghost.client)
			return ghost
	return null

/**
 * Proc to check if a human has the required organs to sustain life.
 *
 * Returns false if this human is missing a heart, their current heart is broken, or they have no brain
 *
 * Returns true otherwise
 */
/mob/living/carbon/human/proc/has_working_organs()
	var/datum/internal_organ/heart/heart = internal_organs_by_name["heart"]

	if(!heart || heart.organ_status == ORGAN_BROKEN || !has_brain())
		return FALSE

	return TRUE

/**
 * proc that resuscitates a human, separated because it's better this way
 *
 * intended to be called by defibrillators
 */
/mob/living/carbon/human/proc/resuscitate()
	updatehealth() // so they don't die instantly
	if(stat == DEAD && can_be_revived())
		set_stat(UNCONSCIOUS)
		emote("gasp")
		chestburst = 0 // reset this so we don't have someone walk around with a hole in their chest (lol)
		regenerate_icons()
		reload_fullscreens()
		flash_act()
		apply_effect(10, EYE_BLUR)
		apply_effect(20 SECONDS, PARALYZE)
		handle_regular_hud_updates()
		updatehealth() // do this one more time for extra cleanup
		REMOVE_TRAIT(src, TRAIT_PSY_DRAINED, TRAIT_PSY_DRAINED)
		dead_ticks = 0 // reset DNR timer

///Checks brute/fire damage, heart status, having a head, death ticks and client for defibrillation
/mob/living/carbon/human/proc/check_defib()
	if((getBruteLoss() >= 180) || (getFireLoss() >= 180) && !HAS_TRAIT(src, TRAIT_IMMEDIATE_DEFIB)) // allow robots to bypass the damage threshold
		return DEFIB_FAIL_TISSUE_DAMAGE

	if(!has_working_organs() && !(species.species_flags & ROBOTIC_LIMBS)) // Ya organs dpmt wprl
		return DEFIB_FAIL_BAD_ORGANS

	var/datum/limb/head/head = get_limb("head")
	if(head.limb_status & LIMB_DESTROYED)
		return DEFIB_FAIL_DECAPITATED

	if((dead_ticks > TIME_BEFORE_DNR) && !issynth(src) || HAS_TRAIT(src, TRAIT_UNDEFIBBABLE))
		return DEFIB_FAIL_BRAINDEAD

	if(!client) // no client at all
		return DEFIB_FAIL_CLIENT_MISSING

	return DEFIB_POSSIBLE
