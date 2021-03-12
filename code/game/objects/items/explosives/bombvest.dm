/obj/item/clothing/suit/storage/marine/harness/boomvest
	name = "tactical explosive vest"
	desc = "Obviously someone just strapped a bomb to a marine harness and called it tactical. The light has been removed, and its switch used as the detonator.<br><span class='notice'>Control-Click to set a warcry.</span> <span class='warning'>This harness has no light, toggling it will detonate the vest!</span>"
	icon_state = "boom_vest"
	flags_item_map_variant = NONE
	flags_armor_features = NONE
	///Warcry to yell upon detonation
	var/bomb_message
	///List of warcries that are not allowed.
	var/list/bad_warcries = list("allahu ackbar", "allah", "ackbar")

///Overwrites the parent function for activating a light. Instead it now detonates the bomb.
/obj/item/clothing/suit/storage/marine/harness/boomvest/attack_self(mob/user)
	var/mob/living/carbon/human/activator = user
	if(activator.wear_suit != src)
		to_chat(activator, "Due to the rigging of this device, it can only be detonated while worn.") //If you are going to use this, you have to accept death. No armor allowed.
		return FALSE
	if(bomb_message) //Checks for a non null bomb message.
		activator.say("[bomb_message]!!")
		message_admins("[activator] has detonated an explosive vest with the warcry \"[bomb_message]\".") //Incase disputes show up about marines killing themselves and others.
		log_game("[activator] has detonated an explosive vest with the warcry \"[bomb_message].\"")
	else
		message_admins("[activator] has detonated an explosive vest with no warcry.")
		log_game("[activator] has detonated an explosive vest with no warcry.")
	explosion(loc, 0, 2, 6, 5, 5) 
	qdel(src)

///Gets a warcry to scream on Control Click, checks for non allowed warcries.
/obj/item/clothing/suit/storage/marine/harness/boomvest/CtrlClick(mob/user)
	if(loc == user)
		var/new_bomb_message = sanitize(input(user, "Select Warcry", "Warcry", null) as text|null)
		new_bomb_message = sanitize(new_bomb_message)
		for(var/warcry in bad_warcries)
			if(findtext(new_bomb_message, regex(warcry, "i")))
				to_chat(user, "Come on, why can't you be original?")
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
	activator.say("ORBITAL BOMBARDMENT INBOUND!!")
	message_admins("[activator] has detonated an Orbital Bombardment vest! Unga!")
	log_game("[activator] has detonated an Orbital Bombatdment vest! Unga!")
	explosion(loc, 15, 15, 15, 15, 15)
	qdel(src)
