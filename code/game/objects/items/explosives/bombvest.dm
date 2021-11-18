/obj/item/clothing/suit/storage/marine/harness/boomvest
	name = "tactical explosive vest"
	desc = "Obviously someone just strapped a bomb to a marine harness and called it tactical. The light has been removed, and its switch used as the detonator.<br><span class='notice'>Control-Click to set a warcry.</span> <span class='warning'>This harness has no light, toggling it will detonate the vest!</span>"
	icon_state = "boom_vest"
	flags_item_map_variant = NONE
	flags_armor_features = NONE
	///Warcry to yell upon detonation
	var/bomb_message
	///List of warcries that are not allowed.
	var/bad_warcries_regex = "allahu ackbar|allah|ackbar"

/obj/item/clothing/suit/storage/marine/harness/boomvest/equipped(mob/user, slot)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_SHIELD_DETATCH, .proc/shield_dropped)

/obj/item/clothing/suit/storage/marine/harness/boomvest/unequipped(mob/unequipper, slot)
	. = ..()
	UnregisterSignal(unequipper, COMSIG_MOB_SHIELD_DETATCH)

///Updates the last shield drop time when one is dropped
/obj/item/clothing/suit/storage/marine/harness/boomvest/proc/shield_dropped()
	SIGNAL_HANDLER
	TIMER_COOLDOWN_START(src, COOLDOWN_BOMBVEST_SHIELD_DROP, 5 SECONDS)

///Overwrites the parent function for activating a light. Instead it now detonates the bomb.
/obj/item/clothing/suit/storage/marine/harness/boomvest/attack_self(mob/user)
	var/mob/living/carbon/human/activator = user
	if(issynth(activator) && !CONFIG_GET(flag/allow_synthetic_gun_use))
		to_chat(user, span_warning("Your programming restricts operating explosive devices."))
		return TRUE
	if(user.alpha != 255)
		to_chat(user, span_warning("Your cloak prevents you from detonating [src]!"))
		return TRUE
	if(activator.wear_suit != src)
		to_chat(activator, "Due to the rigging of this device, it can only be detonated while worn.") //If you are going to use this, you have to accept death. No armor allowed.
		return FALSE
	if(istype(activator.l_hand, /obj/item/weapon/shield/riot) || istype(activator.r_hand, /obj/item/weapon/shield/riot) || istype(activator.back, /obj/item/weapon/shield/riot))
		to_chat(activator, span_warning("Your bulky shield prevents you from reaching the detonator!"))
		return FALSE
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_BOMBVEST_SHIELD_DROP))
		to_chat(activator, span_warning("You dropped a shield too recently to detonate, wait a few seconds!"))
		return FALSE
	if(bomb_message)
		activator.say("[bomb_message]!!")
	if(!do_after(user, 2 SECONDS, TRUE, src, BUSY_ICON_DANGER, ignore_turf_checks = TRUE))
		return FALSE
	if(bomb_message) //Checks for a non null bomb message.
		message_admins("[activator] has detonated an explosive vest with the warcry \"[bomb_message]\".") //Incase disputes show up about marines killing themselves and others.
		log_game("[activator] has detonated an explosive vest with the warcry \"[bomb_message].\"")
	else
		message_admins("[activator] has detonated an explosive vest with no warcry.")
		log_game("[activator] has detonated an explosive vest with no warcry.")

	for(var/datum/limb/appendage AS in activator.limbs) //Oops we blew all our limbs off
		if(istype(appendage, /datum/limb/chest) || istype(appendage, /datum/limb/groin) || istype(appendage, /datum/limb/head))
			continue
		appendage.droplimb()
	explosion(loc, 2, 2, 6, 5, 5)
	qdel(src)

///Gets a warcry to scream on Control Click, checks for non allowed warcries.
/obj/item/clothing/suit/storage/marine/harness/boomvest/CtrlClick(mob/user)
	if(loc != user)
		return ..()
	var/new_bomb_message = stripped_input(user, "Select Warcry", "Warcry", null, 50)
	if(CHAT_FILTER_CHECK(new_bomb_message))
		to_chat(user, "This warcry is prohibited from IC chat.")
		return FALSE
	if(findtext_char(new_bomb_message, regex(bad_warcries_regex, "i")))
		to_chat(user, "This warcry is prohibited from IC chat.")
		return FALSE
	bomb_message = new_bomb_message
	to_chat(user, "Warcry set to: \"[bomb_message]\".")
	return ..()

/obj/item/clothing/suit/storage/marine/harness/boomvest/ob_vest
	name = "admeme oribital bombard vest"
	desc = "ORBITAL BOMBARDMENTS MADE CONVENIENT AND SUICIDAL"

///Detonation proc for the OB vest.
/obj/item/clothing/suit/storage/marine/harness/boomvest/ob_vest/attack_self(mob/user)
	var/mob/living/carbon/human/activator = user
	if(activator.wear_suit != src)
		to_chat(activator, "Due to the rigging of this device, it can only be detonated while worn.")
		return FALSE
	if(!do_after(user, 3, TRUE, src, BUSY_ICON_DANGER, ignore_turf_checks = TRUE))
		return FALSE
	activator.say("ORBITAL BOMBARDMENT INBOUND!!")
	message_admins("[activator] has detonated an Orbital Bombardment vest! Unga!")
	log_game("[activator] has detonated an Orbital Bombardment vest! Unga!")

	for(var/datum/limb/appendage AS in activator.limbs) //Oops we blew all our limbs off
		if(istype(appendage, /datum/limb/chest) || istype(appendage, /datum/limb/groin) || istype(appendage, /datum/limb/head))
			continue
		appendage.droplimb()
	explosion(loc, 15, 15, 15, 15, 15)
	qdel(src)
