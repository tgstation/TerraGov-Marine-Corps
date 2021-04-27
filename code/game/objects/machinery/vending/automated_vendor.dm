/obj/machinery/automated_vendor
	name = "\improper automated vendor"
	desc = ""
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "marinearmory"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	req_access = null
	req_one_access = null

	idle_power_usage = 60
	active_power_usage = 3000

/obj/machinery/automated_vendor/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!allowed(H))
			return FALSE

		var/obj/item/card/id/I = H.get_idcard()
		if(!istype(I)) //not wearing an ID
			return FALSE

		if(I.registered_name != H.real_name)
			return FALSE

	return TRUE

/obj/machinery/automated_vendor/interact(mob/user)
	. = ..()
	user.client.prefs.loadout_manager.ui_interact(user)
