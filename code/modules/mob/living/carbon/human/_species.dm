/**
 * # The base species datum
 *
 * This datum handles different species in the game, such as synthetics, mothmen, combat robots, skeletons, etc.
 * It is used in [mob/living/carbon/human] to determine many things about them, including damage resistance, appearance, special behaviors, and more.
*/
/datum/species
	///Species name
	var/name
	///what kind of species it is considered (See: Species defines)
	var/species_type = SPECIES_HUMAN
	///Special effects that are inherent to our species
	var/species_flags = NONE
	///used in limb code to find which bodytype files to pull from, yes this code can defenitely be improved
	var/limb_type = SPECIES_LIMB_GENERIC

	//----Icon stuff here
	///Normal icon file
	var/icobase = 'icons/mob/human_races/r_human.dmi'
	///icon state for calculating brute damage icons
	var/brute_damage_icon_state = "human_brute"
	///icon state for calculating brute damage icons
	var/burn_damage_icon_state = "human_burn"
	///damage mask icon we want to use when drawing wounds
	var/damage_mask_icon = 'icons/mob/dam_mask.dmi'
	///icon for eyes
	var/eyes = "eyes_s"
	///Color of the blood specific to our species
	var/blood_color = "#A10808"
	///Color of the gibs that spawn from our species [/mob/living/carbon/human/spawn_gibs]
	var/flesh_color = "#FFC896"
	///Used when setting species
	var/base_color
	///If the species only has one hair color
	var/hair_color
	///Used in icon caching
	var/race_key = 0
	///Used in icon caching
	var/icon/icon_template

	//----Grouped these because they get set on New()
	///hud that our mob uses, gets given the type stored in hud_type on New()
	var/datum/hud_data/hud
	///type that our hud gets set to on New()
	var/hud_type
	///For empty hand harm-intent attack
	var/datum/unarmed_attack/unarmed
	///type that our unarmed gets set to on New()
	var/unarmed_type = /datum/unarmed_attack
	///For empty hand harm-intent attack if the first fails
	var/datum/unarmed_attack/secondary_unarmed
	///type that our secondary_unarmed gets set to on New()
	var/secondary_unarmed_type = /datum/unarmed_attack/bite

	//----Health/Stamina + Modifiers
	///new maxHealth [/mob/living/carbon/human/var/maxHealth] of the human mob once species is applied
	var/total_health = 100
	///Brute damage modifier
	var/brute_mod = null
	///Burn damage modifier
	var/burn_mod = null
	///new max_stamina [/mob/living/var/max_stamina] of the human mob once species is applied
	var/max_stamina = 50

	//----Somewhat "gameplay" relevant
	///how much the knocked_down effect is reduced per Life call
	var/knock_down_reduction = 1
	///how much the stunned effect is reduced per Life call
	var/stun_reduction = 1
	///how much the stunned effect is reduced per Life call
	var/knock_out_reduction = 1
	///How much slowdown is innate to our species
	var/slowdown = 0
	///Inventory slots the race can't equip stuff to. Golems cannot wear jumpsuits, for example
	var/list/no_equip = list()

	//----Related to dying in some way
	///species-specific gibbing animation
	var/gibbed_anim
	///species-specific dusting animation
	var/dusted_anim = "dust-h"
	///used to determine what item is left behind in /spawn_dust_remains()
	var/remains_type = /obj/effect/decal/cleanable/ash
	///Sound that gets played on death()
	var/death_sound
	///Message that gets sent on death()
	var/death_message = "seizes up and falls limp, their eyes dead and lifeless..."
	///Special death message that gets overwritten if possible
	var/special_death_message = "You have perished."

	//----Temperature/Pressure
	///Cold damage level 1 below this point
	var/cold_level_1 = BODYTEMP_COLD_DAMAGE_LIMIT_ONE
	///Cold damage level 2 below this point
	var/cold_level_2 = BODYTEMP_COLD_DAMAGE_LIMIT_TWO
	///Cold damage level 3 below this point
	var/cold_level_3 = BODYTEMP_COLD_DAMAGE_LIMIT_THREE
	///Heat damage level 1 above this point
	var/heat_level_1 = BODYTEMP_HEAT_DAMAGE_LIMIT_ONE
	///Heat damage level 2 above this point
	var/heat_level_2 = BODYTEMP_HEAT_DAMAGE_LIMIT_TWO
	///Heat damage level 2 above this point
	var/heat_level_3 = BODYTEMP_HEAT_DAMAGE_LIMIT_THREE
	///non-IS_SYNTHETIC species will try to stabilize at this temperature. (also affects temperature processing)
	var/body_temperature = BODYTEMP_NORMAL
	///Dangerously high pressure
	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE
	///High pressure warning
	var/warning_high_pressure = WARNING_HIGH_PRESSURE
	///Low pressure warning
	var/warning_low_pressure = WARNING_LOW_PRESSURE
	///Dangerously low pressure
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE

	///used in mob/living/proc/taste
	var/taste_sensitivity = TASTE_NORMAL
	///type that gets set as our language_holder on proc/set_species
	var/default_language_holder = /datum/language_holder

	///Sets our mobs lighting_alpha on [/mob/living/carbon/human/update_sight]
	var/lighting_cutoff

	///Used for metabolizing reagents
	var/reagent_tag

	///List of sounds for certain emotes [/datum/emote/living/carbon/human/scream/get_sound]
	var/list/screams = list()
	///List of sounds for certain emotes [/datum/emote/living/carbon/human/pain/get_sound]
	var/list/paincries = list()
	///List of sounds for certain emotes [/datum/emote/living/carbon/human/gored/get_sound]
	var/list/goredcries = list()
	///List of sounds for certain emotes [/datum/emote/living/carbon/human/gasp/get_sound]
	var/list/gasps = list()
	///List of sounds for certain emotes [/datum/emote/living/carbon/human/cough/get_sound]
	var/list/coughs = list()
	///List of sounds for certain emotes [/datum/emote/living/carbon/human/burstscream/get_sound]
	var/list/burstscreams = list()
	///List of sounds for certain emotes [/datum/emote/living/carbon/human/warcry/get_sound]
	var/list/warcries = list()

	///Generic traits tied to having the species
	var/list/inherent_traits = list()
	///inherent Species-specific verbs
	var/list/inherent_verbs
	///inherent species-specific actions
	var/list/inherent_actions
	///Associated list of our organs
	var/list/has_organ = list(
		"heart" = /datum/internal_organ/heart,
		"lungs" = /datum/internal_organ/lungs,
		"liver" = /datum/internal_organ/liver,
		"kidneys" = /datum/internal_organ/kidneys,
		"brain" = /datum/internal_organ/brain,
		"appendix" = /datum/internal_organ/appendix,
		"eyes" = /datum/internal_organ/eyes
		)

	///List of names for random generation based on a given pool
	var/datum/namepool/namepool = /datum/namepool
	///Whether it is possible to select this species and join as it
	var/joinable_roundstart = FALSE
	///If this species counts as a human
	var/count_human = FALSE

/datum/species/New()
	if(hud_type)
		hud = new hud_type()
	else
		hud = new()

	if(unarmed_type)
		unarmed = new unarmed_type()
	if(secondary_unarmed_type)
		secondary_unarmed = new secondary_unarmed_type()
	if(species_flags & GREYSCALE_BLOOD)
		brute_damage_icon_state = "grayscale"

///Handles creation of mob organs and limbs
/datum/species/proc/create_organs(mob/living/carbon/human/organless_human)
	organless_human.limbs = list()
	organless_human.internal_organs = list()
	organless_human.internal_organs_by_name = list()

	//This is a basic humanoid limb setup
	var/datum/limb/chest/new_chest = new(null, organless_human)
	organless_human.limbs += new_chest
	var/datum/limb/groin/new_groin = new(new_chest, organless_human)
	organless_human.limbs += new_groin
	organless_human.limbs += new/datum/limb/head(new_chest, organless_human)
	var/datum/limb/l_arm/new_l_arm = new(new_chest, organless_human)
	organless_human.limbs += new_l_arm
	var/datum/limb/r_arm/new_r_arm = new(new_chest, organless_human)
	organless_human.limbs += new_r_arm
	var/datum/limb/l_leg/new_l_leg = new(new_groin, organless_human)
	organless_human.limbs += new_l_leg
	var/datum/limb/r_leg/new_r_leg = new(new_groin, organless_human)
	organless_human.limbs += new_r_leg
	organless_human.limbs += new/datum/limb/hand/l_hand(new_l_arm, organless_human)
	organless_human.limbs += new/datum/limb/hand/r_hand(new_r_arm, organless_human)
	organless_human.limbs += new/datum/limb/foot/l_foot(new_l_leg, organless_human)
	organless_human.limbs += new/datum/limb/foot/r_foot(new_r_leg, organless_human)

	for(var/organ in has_organ)
		var/organ_type = has_organ[organ]
		organless_human.internal_organs_by_name[organ] = new organ_type(organless_human)

	if(species_flags & ROBOTIC_LIMBS)
		for(var/datum/limb/robotic_limb AS in organless_human.limbs)
			if(robotic_limb.limb_status & LIMB_DESTROYED)
				continue
			robotic_limb.add_limb_flags(LIMB_ROBOT)
		for(var/datum/internal_organ/my_cold_heart in organless_human.internal_organs)
			my_cold_heart.mechanize()

///Called by [/mob/living/carbon/proc/help_shake_act], the act of hugging someone
/datum/species/proc/hug(mob/living/carbon/human/H, mob/living/target)
	if(H.zone_selected == "head")
		H.visible_message(span_notice("[H] pats [target] on the head."), \
					span_notice("You pat [target] on the head."), null, 4)
	else if(H.zone_selected == "l_hand" && CONFIG_GET(flag/fun_allowed))
		H.visible_message(span_notice("[H] holds [target] 's left hand."), \
					span_notice("You hold [target]'s left hand."), null, 4)
	else if (H.zone_selected == "r_hand" && CONFIG_GET(flag/fun_allowed))
		H.visible_message(span_notice("[H] holds [target] 's right hand."), \
					span_notice("You hold [target]'s right hand."), null, 4)
	else
		H.visible_message(span_notice("[H] hugs [target] to make [target.p_them()] feel better!"), \
					span_notice("You hug [target] to make [target.p_them()] feel better!"), null, 4)

///Generates a random name from namepool
/datum/species/proc/random_name(gender)
	return GLOB.namepool[namepool].get_random_name(gender)

///Returns the name if there is one in prefs
/datum/species/proc/prefs_name(datum/preferences/prefs)
	return prefs.real_name

///Called when we turn into a species, called by [/mob/living/carbon/human/proc/set_species()]
///drops things we shouldn't be allowed to equip, adds relevant traits, and adjusts the max health of our mob
/datum/species/proc/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	SHOULD_CALL_PARENT(TRUE)
	for(var/slot_id in no_equip)
		var/obj/item/thing = H.get_item_by_slot(slot_id)
		if(thing && !is_type_in_list(src,thing.species_exception))
			H.dropItemToGround(thing)
	for(var/newtrait in inherent_traits)
		ADD_TRAIT(H, newtrait, SPECIES_TRAIT)
	H.maxHealth += total_health - (old_species ? old_species.total_health : initial(H.maxHealth))

///special things to change after we're no longer that species
/datum/species/proc/post_species_loss(mob/living/carbon/human/H)
	SHOULD_CALL_PARENT(TRUE)
	for(var/oldtrait in inherent_traits)
		REMOVE_TRAIT(H, oldtrait, SPECIES_TRAIT)

///Removes all species-specific verbs and actions
/datum/species/proc/remove_inherent_abilities(mob/living/carbon/human/H)
	if(inherent_verbs)
		remove_verb(H, inherent_verbs)
	if(inherent_actions)
		for(var/action_path in inherent_actions)
			var/datum/action/old_species_action = H.actions_by_path[action_path]
			qdel(old_species_action)
	return

///Adds all species-specific verbs and actions
/datum/species/proc/add_inherent_abilities(mob/living/carbon/human/H)
	if(inherent_verbs)
		add_verb(H, inherent_verbs)
	if(inherent_actions)
		for(var/action_path in inherent_actions)
			var/datum/action/new_species_action = new action_path(H)
			new_species_action.give_action(H)
	return

///Handles anything not already covered by basic species assignment
/datum/species/proc/handle_post_spawn(mob/living/carbon/human/H)
	add_inherent_abilities(H)

///Handles any species-specific death events
/datum/species/proc/handle_death(mob/living/carbon/human/H)
	return

///Called on Life(), used for special behavior when the carbon human with this species is alive
/datum/species/proc/handle_unique_behavior(mob/living/carbon/human/H)
	return

///Used to update alien icons for aliens
/datum/species/proc/handle_login_special(mob/living/carbon/human/H)
	return

///As above
/datum/species/proc/handle_logout_special(mob/living/carbon/human/H)
	return

///Builds the HUD using species-specific icons and usable slots
/datum/species/proc/build_hud(mob/living/carbon/human/H)
	return

///Grabs the window recieved when you click-drag someone onto you
/datum/species/proc/get_inventory_dialogue(mob/living/carbon/human/H)
	return

///Used by xenos understanding larvae and dionaea understanding nymphs
/datum/species/proc/can_understand(mob/other)
	return

///Called on Life(), special behaviour if we are on fire
/datum/species/proc/handle_fire(mob/living/carbon/human/H)
	return

///Basically just used to update moth wings
/datum/species/proc/update_body(mob/living/carbon/human/H)
	return

///Basically just used to update moth wings
/datum/species/proc/update_inv_head(mob/living/carbon/human/H)
	return

///Basically just used to update moth wings
/datum/species/proc/update_inv_w_uniform(mob/living/carbon/human/H)
	return

///Basically just used to update moth wings //Man moths are giga shitcoded
/datum/species/proc/update_inv_wear_suit(mob/living/carbon/human/H)
	return

///Called by [/mob/living/carbon/human/reagent_check]
///Returns TRUE if we can't metabolize chems, or can't be poisoned by a toxin
/datum/species/proc/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(CHECK_BITFIELD(species_flags, NO_CHEM_METABOLIZATION)) //explicit
		H.reagents.del_reagent(chem.type) //for the time being
		return TRUE
	if(CHECK_BITFIELD(species_flags, NO_POISON) && istype(chem, /datum/reagent/toxin))
		H.reagents.remove_reagent(chem.type, chem.custom_metabolism * H.metabolism_efficiency)
		return TRUE
	if(CHECK_BITFIELD(species_flags, NO_OVERDOSE)) //no stacking
		if(chem.overdose_threshold && chem.volume > chem.overdose_threshold)
			H.reagents.remove_reagent(chem.type, chem.volume - chem.overdose_threshold)
	return FALSE

///Called when using the shredding behavior
/datum/species/proc/can_shred(mob/living/carbon/human/H)
	if(H.a_intent != INTENT_HARM)
		return FALSE

	if(unarmed.is_usable(H))
		if(unarmed.shredding)
			return TRUE
	else if(secondary_unarmed.is_usable(H))
		if(secondary_unarmed.shredding)
			return TRUE
	return FALSE

//Species unarmed attacks
/datum/unarmed_attack
	///Empty hand hurt intent verb
	var/attack_verb = list("attacks")
	///Extra empty hand attack damage
	var/damage = 0
	///Sound that plays when you land a punch
	var/attack_sound = SFX_PUNCH
	///Sound that plays when you miss a punch
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	///Calls the old attack_alien() behavior on objects/mobs when on harm intent
	var/shredding = 0
	///whether our unarmed attack cuts
	var/sharp = 0
	// whether our unarmed attack is more likely to dismember
	var/edge = 0

/datum/unarmed_attack/proc/is_usable(mob/living/carbon/human/user)
	if(user.restrained())
		return FALSE

	// Check if they have a functioning hand
	var/datum/limb/E = user.get_limb("l_hand")
	if(E?.is_usable())
		return TRUE

	E = user.get_limb("r_hand")
	if(E?.is_usable())
		return TRUE
	return FALSE

/datum/unarmed_attack/bite
	attack_verb = list("bites")
	attack_sound = 'sound/weapons/bite.ogg'
	shredding = 0
	damage = 5
	sharp = 1
	edge = 1

/datum/unarmed_attack/bite/is_usable(mob/living/carbon/human/user)
	if (user.wear_mask && istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
		return FALSE
	return TRUE

/datum/unarmed_attack/punch
	attack_verb = list("punches")
	damage = 3

/datum/unarmed_attack/punch/strong
	attack_verb = list("punches","busts","jabs")
	damage = 10

/datum/unarmed_attack/claws
	attack_verb = list("scratches", "claws")
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	damage = 5
	sharp = 1
	edge = 1

/datum/unarmed_attack/claws/strong
	attack_verb = list("slashes")
	damage = 10
	shredding = 1

/datum/unarmed_attack/bite/strong
	attack_verb = list("mauls")
	damage = 15
	shredding = 1

/datum/hud_data
	///If set, overrides ui_style
	var/icon
	///Set to draw intent box
	var/has_a_intent = TRUE
	///Set to draw move intent box
	var/has_m_intent = TRUE
	///Set to draw environment warnings
	var/has_warnings = TRUE
	///Set to draw shand
	var/has_hands = TRUE
	///Set to draw drop button
	var/has_drop = TRUE
	///Set to draw throw button
	var/has_throw = TRUE
	///Set to draw resist button
	var/has_resist = TRUE
	///Checked by mob_can_equip()
	var/list/equip_slots = list()

	/**
	 * Contains information on the position and tag for all inventory slots
	 * to be drawn for the mob. This is fairly delicate, try to avoid messing with it
	 * unless you know exactly what it does
	 */
	var/list/gear = list(
		"i_clothing" = list("loc" = ui_iclothing, "slot" = SLOT_W_UNIFORM, "state" = "uniform", "toggle" = TRUE),
		"o_clothing" = list("loc" = ui_oclothing, "slot" = SLOT_WEAR_SUIT, "state" = "suit", "toggle" = TRUE),
		"mask" = list("loc" = ui_mask, "slot" = SLOT_WEAR_MASK, "state" = "mask", "toggle" = TRUE),
		"gloves" = list("loc" = ui_gloves, "slot" = SLOT_GLOVES, "state" = "gloves", "toggle" = TRUE),
		"eyes" = list("loc" = ui_glasses, "slot" = SLOT_GLASSES, "state" = "glasses","toggle" = TRUE),
		"wear_ear" = list("loc" = ui_wear_ear, "slot" = SLOT_EARS, "state" = "ears", "toggle" = TRUE),
		"head" = list("loc" = ui_head, "slot" = SLOT_HEAD, "state" = "head", "toggle" = TRUE),
		"shoes" = list("loc" = ui_shoes, "slot" = SLOT_SHOES, "state" = "shoes", "toggle" = TRUE),
		"suit storage" = list("loc" = ui_sstore1, "slot" = SLOT_S_STORE, "state" = "suit_storage"),
		"back" = list("loc" = ui_back, "slot" = SLOT_BACK, "state" = "back"),
		"id" = list("loc" = ui_id, "slot" = SLOT_WEAR_ID, "state" = "id"),
		"storage1" = list("loc" = ui_storage1, "slot" = SLOT_L_STORE, "state" = "pocket"),
		"storage2" = list("loc" = ui_storage2, "slot" = SLOT_R_STORE, "state" = "pocket"),
		"belt" = list("loc" = ui_belt, "slot" = SLOT_BELT, "state" = "belt")
		)

/datum/hud_data/New()
	. = ..()
	for(var/slot in gear)
		equip_slots |= gear[slot]["slot"]

	if(has_hands)
		equip_slots |= SLOT_L_HAND
		equip_slots |= SLOT_R_HAND
		equip_slots |= SLOT_HANDCUFFED
	if(SLOT_HEAD in equip_slots)
		equip_slots |= SLOT_IN_HEAD
	if(SLOT_BACK in equip_slots)
		equip_slots |= SLOT_IN_BACKPACK
		equip_slots |= SLOT_IN_B_HOLSTER
	if(SLOT_BELT in equip_slots)
		equip_slots |= SLOT_IN_HOLSTER
		equip_slots |= SLOT_IN_BELT
	if(SLOT_WEAR_SUIT in equip_slots)
		equip_slots |= SLOT_IN_S_HOLSTER
		equip_slots |= SLOT_IN_SUIT
	if(SLOT_SHOES in equip_slots)
		equip_slots |= SLOT_IN_BOOT
	if(SLOT_W_UNIFORM in equip_slots)
		equip_slots |= SLOT_IN_STORAGE
		equip_slots |= SLOT_IN_L_POUCH
		equip_slots |= SLOT_IN_R_POUCH
		equip_slots |= SLOT_ACCESSORY
		equip_slots |= SLOT_IN_ACCESSORY

///damage override at the species level, called by /mob/living/proc/apply_damage
/datum/species/proc/apply_damage(damage = 0, damagetype = BRUTE, def_zone, blocked = 0, sharp = FALSE, edge = FALSE, updating_health = FALSE, penetration, mob/living/attacker, mob/living/carbon/human/victim)
	var/datum/limb/organ = null
	if(isorgan(def_zone)) //Got sent a limb datum, convert to a zone define
		organ = def_zone
		def_zone = organ.name

	if(!def_zone)
		def_zone = ran_zone(def_zone)
	if(!organ)
		organ = victim.get_limb(check_zone(def_zone))
	if(!organ)
		return FALSE

	if(isnum(blocked))
		damage -= clamp(damage * (blocked - penetration) * 0.01, 0, damage)
	else
		damage = victim.modify_by_armor(damage, blocked, penetration, def_zone)

	if(victim.protection_aura)
		damage = round(damage * ((20 - victim.protection_aura) / 20), 0.1)

	if(!damage)
		return 0

	switch(damagetype)
		if(BRUTE)
			victim.damageoverlaytemp = 20
			if(brute_mod)
				damage *= brute_mod
			var/old_status = organ.limb_status
			if(organ.take_damage_limb(damage, 0, sharp, edge))
				victim.UpdateDamageIcon()
				record_internal_injury(victim, attacker, old_status, organ.limb_status)
		if(BURN)
			victim.damageoverlaytemp = 20
			if(burn_mod)
				damage *= burn_mod
			if(organ.take_damage_limb(0, damage, sharp, edge))
				victim.UpdateDamageIcon()
				return
			switch(damage)
				if(-INFINITY to 0)
					return FALSE
				if(25 to 50)
					if(prob(20))
						victim.emote("pain")
				if(50 to INFINITY)
					if(prob(60))
						victim.emote("pain")
		if(TOX)
			victim.adjustToxLoss(damage)
		if(OXY)
			victim.adjustOxyLoss(damage)
		if(CLONE)
			victim.adjustCloneLoss(damage)
		if(STAMINA)
			if(species_flags & NO_STAMINA)
				return
			victim.adjustStaminaLoss(damage)

	// Will set our damageoverlay icon to the next level, which will then be set back to the normal level the next mob.Life()
	SEND_SIGNAL(victim, COMSIG_HUMAN_DAMAGE_TAKEN, damage, attacker) //add attacker arg everywhere needed

	if(updating_health)
		victim.updatehealth()
	return damage
