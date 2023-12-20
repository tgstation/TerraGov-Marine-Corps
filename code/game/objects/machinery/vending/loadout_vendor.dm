/obj/machinery/loadout_vendor
	name = "automated loadout vendor"
	desc = "An advanced vendor used by the TGMC to rapidly equip their marines"
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "specialist"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	req_access = null
	req_one_access = null
	light_range = 1
	light_power = 0.5
	light_color = LIGHT_COLOR_BLUE
	///The faction of this loadout vendor
	var/faction = VENDOR_FACTION_NEUTRAL

/obj/machinery/loadout_vendor/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/loadout_vendor/update_icon()
	. = ..()
	if(is_operational())
		set_light(initial(light_range))
	else
		set_light(0)

/obj/machinery/loadout_vendor/update_icon_state()
	if(is_operational())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/loadout_vendor/update_overlays()
	. = ..()
	if(!is_operational())
		return
	. += emissive_appearance(icon, "[icon_state]_emissive")

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

/obj/machinery/loadout_vendor/crash
	faction = VENDOR_FACTION_CRASH

/obj/machinery/loadout_vendor/valhalla
	resistance_flags = INDESTRUCTIBLE
	faction = VENDOR_FACTION_VALHALLA
