/obj/machinery/loadout_vendor
	name = "automated vendor"
	desc = "An advanced vendor used by the TGMC to rapidly equip their soldiers"
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "specialist"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	req_access = null
	req_one_access = null
	///The faction of this loadout vendor
	var/faction = FACTION_NEUTRAL

/obj/machinery/loadout_vendor/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(user))
		return FALSE

	var/mob/living/carbon/human/H = user
	if(!allowed(H))
		return FALSE

	if(!isidcard(H.get_idcard())) //not wearing an ID
		return FALSE

	var/obj/item/card/id/I = H.get_idcard()
	if(I.registered_name != H.real_name)
		return FALSE
	return TRUE


/obj/machinery/loadout_vendor/interact(mob/user)
	. = ..()
	user.client.prefs.loadout_manager.loadout_vendor = src
	user.client.prefs.loadout_manager.ui_interact(user)

/obj/machinery/loadout_vendor/loyalist
	faction = FACTION_TERRAGOV

/obj/machinery/loadout_vendor/rebel
	faction = FACTION_TERRAGOV_REBEL

/obj/machinery/loadout_vendor/valhalla
	resistance_flags = INDESTRUCTIBLE
	faction = FACTION_VALHALLA
