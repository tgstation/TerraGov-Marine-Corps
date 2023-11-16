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
	if(!do_after(user, 0.5 SECONDS, TRUE, src, BUSY_ICON_DANGER, ignore_turf_checks = TRUE))
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
