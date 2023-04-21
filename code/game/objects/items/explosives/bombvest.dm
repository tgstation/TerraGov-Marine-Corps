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
	RegisterSignal(user, COMSIG_MOB_SHIELD_DETACH, PROC_REF(shield_dropped))

/obj/item/clothing/suit/storage/marine/harness/boomvest/unequipped(mob/unequipper, slot)
	. = ..()
	UnregisterSignal(unequipper, COMSIG_MOB_SHIELD_DETACH)

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
		to_chat(activator, span_warning("Due to the rigging of this device, it can only be detonated while worn.")) //If you are going to use this, you have to accept death. No armor allowed.
		return FALSE
	if(istype(activator.l_hand, /obj/item/weapon/shield/riot) || istype(activator.r_hand, /obj/item/weapon/shield/riot) || istype(activator.back, /obj/item/weapon/shield/riot))
		to_chat(activator, span_warning("Your bulky shield prevents you from reaching the detonator!"))
		return FALSE
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_BOMBVEST_SHIELD_DROP))
		to_chat(activator, span_warning("You dropped a shield too recently to detonate, wait a few seconds!"))
		return FALSE
	if(LAZYACCESS(user.do_actions, src))
		return
	if(bomb_message)
		activator.say("[bomb_message]!!")
	if(!do_after(user, 2 SECONDS, TRUE, src, BUSY_ICON_DANGER, ignore_turf_checks = TRUE))
		return FALSE
	var/turf/target = get_turf(loc)
	if(bomb_message) //Checks for a non null bomb message.
		message_admins("[activator] has detonated an explosive vest with the warcry \"[bomb_message]\" at [ADMIN_VERBOSEJMP(target)]") //Incase disputes show up about marines killing themselves and others.
		log_game("[activator] has detonated an explosive vest with the warcry \"[bomb_message]\" at [AREACOORD(target)]")
	else
		message_admins("[activator] has detonated an explosive vest with no warcry at [ADMIN_VERBOSEJMP(target)]")
		log_game("[activator] has detonated an explosive vest with no warcry at [AREACOORD(target)]")

	for(var/datum/limb/appendage AS in activator.limbs) //Oops we blew all our limbs off
		if(istype(appendage, /datum/limb/chest) || istype(appendage, /datum/limb/groin) || istype(appendage, /datum/limb/head))
			continue
		appendage.droplimb()
	explosion(target, 2, 2, 6, 5, 5)
	qdel(src)

/obj/item/clothing/suit/storage/marine/harness/boomvest/attack_hand_alternate(mob/living/user)
	. = ..()
	var/new_bomb_message = stripped_input(user, "Select Warcry", "Warcry", null, 50)
	if(CHAT_FILTER_CHECK(new_bomb_message))
		to_chat(user, span_info("This warcry is prohibited from IC chat."))
		return
	if(findtext(new_bomb_message, regex(bad_warcries_regex, "i")))
		to_chat(user, span_info("This warcry is prohibited from IC chat."))
		return
	bomb_message = new_bomb_message
	to_chat(user, span_info("Warcry set to: \"[bomb_message]\"."))

//admin only
/obj/item/clothing/suit/storage/marine/harness/boomvest/ob_vest
	name = "orbital bombardment vest"
	desc = "This is your lieutenant speaking, I know exactly what those coordinates are for."

/obj/item/clothing/suit/storage/marine/harness/boomvest/ob_vest/attack_self(mob/user)
	var/mob/living/carbon/human/activator = user
	if(activator.wear_suit != src)
		to_chat(activator, span_warning("Due to the rigging of this device, it can only be detonated while worn."))
		return FALSE
	if(LAZYACCESS(user.do_actions, src))
		return
	if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_DANGER, ignore_turf_checks = TRUE))
		return FALSE
	var/turf/target = get_turf(loc)
	activator.say("I'M FIRING IT AS AN OB!!")
	message_admins("[activator] has detonated an Orbital Bombardment vest at [ADMIN_VERBOSEJMP(target)]")
	log_game("[activator] has detonated an Orbital Bombardment vest at [AREACOORD(target)]")

	for(var/datum/limb/appendage AS in activator.limbs) //Oops we blew all our limbs off
		if(istype(appendage, /datum/limb/chest) || istype(appendage, /datum/limb/groin) || istype(appendage, /datum/limb/head))
			continue
		appendage.droplimb()
	explosion(target, 15, 15, 15, 15, 15)
	qdel(src)
