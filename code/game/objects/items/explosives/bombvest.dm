/obj/item/clothing/suit/storage/marine/boomvest
	name = "tactical explosive vest"
	desc = "Obviously someone just strapped a bomb to a marine harness and called it tactical. The light has been removed, and its switch used as the detonator.<br><span class='notice'>Control-Click to set a warcry.</span> <span class='warning'>This harness has no light, toggling it will detonate the vest! Riot shields prevent detonation of the tactical explosive vest!!</span>"
	icon_state = "boom_vest"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	slowdown = 0
	flags_item_map_variant = NONE
	flags_armor_features = NONE
	///Warcry to yell upon detonation
	var/bomb_message
	///List of warcries that are not allowed.
	var/bad_warcries_regex = "allahu ackbar|allah|ackbar"

/obj/item/clothing/suit/storage/marine/boomvest/equipped(mob/user, slot)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_SHIELD_DETACH, PROC_REF(shield_dropped))

/obj/item/clothing/suit/storage/marine/boomvest/unequipped(mob/unequipper, slot)
	. = ..()
	UnregisterSignal(unequipper, COMSIG_MOB_SHIELD_DETACH)

///Updates the last shield drop time when one is dropped
/obj/item/clothing/suit/storage/marine/boomvest/proc/shield_dropped()
	SIGNAL_HANDLER
	TIMER_COOLDOWN_START(src, COOLDOWN_BOMBVEST_SHIELD_DROP, 5 SECONDS)

///Overwrites the parent function for activating a light. Instead it now detonates the bomb.
/obj/item/clothing/suit/storage/marine/boomvest/attack_self(mob/user)
	var/mob/living/carbon/human/activator = user
	if(issynth(activator) && !CONFIG_GET(flag/allow_synthetic_gun_use))
		balloon_alert(user, "Can't wear this")
		return TRUE
	if(user.alpha != 255)
		balloon_alert(user, "Can't, your cloak prevents you")
		return TRUE
	if(activator.wear_suit != src)
		balloon_alert(user, "Can only be detonated while worn")
		return FALSE
	if(istype(activator.l_hand, /obj/item/weapon/shield/riot) || istype(activator.r_hand, /obj/item/weapon/shield/riot) || istype(activator.back, /obj/item/weapon/shield/riot))
		balloon_alert(user, "Can't, your shield prevents you")
		return FALSE
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_BOMBVEST_SHIELD_DROP))
		balloon_alert(user, "Can't, dropped shield too recently")
		return FALSE
	if(LAZYACCESS(user.do_actions, src))
		return
	if(bomb_message)
		activator.say("[bomb_message]!!")
	if(!do_after(user, 2 SECONDS, IGNORE_USER_LOC_CHANGE, src, BUSY_ICON_DANGER))
		return FALSE
	var/turf/target = get_turf(loc)
	if(bomb_message) //Checks for a non null bomb message.
		message_admins("[activator] has detonated an explosive vest with the warcry \"[bomb_message]\" at [ADMIN_VERBOSEJMP(target)]") //Incase disputes show up about marines killing themselves and others.
		log_game("[activator] has detonated an explosive vest with the warcry \"[bomb_message]\" at [AREACOORD(target)]")
	else
		message_admins("[activator] has detonated an explosive vest with no warcry at [ADMIN_VERBOSEJMP(target)]")
		log_game("[activator] has detonated an explosive vest with no warcry at [AREACOORD(target)]")

	activator.record_tactical_unalive()

	for(var/datum/limb/appendage AS in activator.limbs) //Oops we blew all our limbs off
		if(istype(appendage, /datum/limb/chest) || istype(appendage, /datum/limb/groin) || istype(appendage, /datum/limb/head))
			continue
		appendage.droplimb()
	explosion(target, 2, 2, 6, 7, 5, 5)
	qdel(src)

/obj/item/clothing/suit/storage/marine/boomvest/attack_hand_alternate(mob/living/user)
	. = ..()
	var/new_bomb_message = stripped_input(user, "Select Warcry", "Warcry", null, 50)
	var/filter_result = CAN_BYPASS_FILTER(user) ? null : is_ic_filtered_for_bombvests(new_bomb_message)
	if(filter_result)
		to_chat(user, span_info("This warcry is prohibited from IC chat."))
		REPORT_CHAT_FILTER_TO_USER(src, filter_result)
		log_filter("Bombvest", new_bomb_message, filter_result)
		return
	var/soft_filter_result = CAN_BYPASS_FILTER(user) ? null : is_soft_ic_filtered_for_bombvests(new_bomb_message)
	if(soft_filter_result)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			SSblackbox.record_feedback("tally", "soft_ic_blocked_words", 1, lowertext(config.soft_ic_filter_regex.match))
			log_filter("Soft IC", new_bomb_message, filter_result)
			return FALSE
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[new_bomb_message]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[new_bomb_message]\"")
		SSblackbox.record_feedback("tally", "passed_soft_ic_blocked_words", 1, lowertext(config.soft_ic_filter_regex.match))
		log_filter("Soft IC (Passed)", new_bomb_message, filter_result)
	bomb_message = new_bomb_message
	to_chat(user, span_info("Warcry set to: \"[bomb_message]\"."))

//admin only
/obj/item/clothing/suit/storage/marine/boomvest/ob_vest
	name = "orbital bombardment vest"
	desc = "This is your lieutenant speaking, I know exactly what those coordinates are for."

/obj/item/clothing/suit/storage/marine/boomvest/ob_vest/attack_self(mob/user)
	var/mob/living/carbon/human/activator = user
	if(activator.wear_suit != src)
		balloon_alert(user, "Can only be detonated while worn")
		return FALSE
	if(LAZYACCESS(user.do_actions, src))
		return
	if(!do_after(user, 1 SECONDS, IGNORE_USER_LOC_CHANGE, src, BUSY_ICON_DANGER))
		return FALSE
	var/turf/target = get_turf(loc)
	activator.say("I'M FIRING IT AS AN OB!!")
	message_admins("[activator] has detonated an Orbital Bombardment vest at [ADMIN_VERBOSEJMP(target)]")
	log_game("[activator] has detonated an Orbital Bombardment vest at [AREACOORD(target)]")

	for(var/datum/limb/appendage AS in activator.limbs) //Oops we blew all our limbs off
		if(istype(appendage, /datum/limb/chest) || istype(appendage, /datum/limb/groin) || istype(appendage, /datum/limb/head))
			continue
		appendage.droplimb()
	explosion(target, 15, 0, 0, 0, 15, 15)
	qdel(src)
