/obj/item/clothing/glasses/ru
	name = "ru glasses"
	desc = "ru glasses"
	icon = 'modular_RUtgmc/icons/obj/clothing/glasses.dmi'
	item_icons = list(
		slot_glasses_str = 'modular_RUtgmc/icons/mob/clothing/eyes.dmi')

/obj/item/clothing/glasses/ru/orange
	name = "Orange glasses"
	desc = "Just orange glasses."
	icon_state = "og"
	item_state = "og"

/obj/item/clothing/glasses/ru/orange/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/clothing/glasses/hud/health))
		var/obj/item/clothing/glasses/hud/og/P = new
		to_chat(user, span_notice("You fasten the medical hud projector to the inside of the glasses."))
		qdel(I)
		qdel(src)
		user.put_in_hands(P)
	else if(istype(I, /obj/item/clothing/glasses/night/imager_goggles))
		var/obj/item/clothing/glasses/night/imager_goggles/og/P = new
		to_chat(user, span_notice("You fasten the optical imager scaner to the inside of the glasses."))
		qdel(I)
		qdel(src)
		user.put_in_hands(P)
	else if(istype(I, /obj/item/clothing/glasses/meson))
		var/obj/item/clothing/glasses/meson/og/P = new
		to_chat(user, span_notice("You fasten the optical meson scaner to the inside of the glasses."))
		qdel(I)
		qdel(src)
		user.put_in_hands(P)

		update_icon(user)

/obj/item/clothing/glasses/meson/og
	name = "Orange glasses"
	desc = "Just orange glasses. This pair has been fitted with an optical meson scanner."
	icon = 'modular_RUtgmc/icons/obj/clothing/glasses.dmi'
	item_icons = list(
		slot_glasses_str = 'modular_RUtgmc/icons/mob/clothing/eyes.dmi')
	icon_state = "mesonog"
	item_state = "mesonog"
	deactive_state = "d_og"
	prescription = TRUE

/obj/item/clothing/glasses/night/imager_goggles/og
	name = "Orange glasses"
	desc = "Just orange glasses. This pair has been fitted with an internal optical imager scanner."
	icon = 'modular_RUtgmc/icons/obj/clothing/glasses.dmi'
	item_icons = list(
		slot_glasses_str = 'modular_RUtgmc/icons/mob/clothing/eyes.dmi')
	icon_state = "optog"
	item_state = "optog"
	deactive_state = "d_og"
	prescription = TRUE

/obj/item/clothing/glasses/hud/og
	name = "Orange glasses"
	desc = "Just orange glasses. This pair has been fitted with an internal HealthMate HUD projector."
	icon = 'modular_RUtgmc/icons/obj/clothing/glasses.dmi'
	item_icons = list(
		slot_glasses_str = 'modular_RUtgmc/icons/mob/clothing/eyes.dmi')
	icon_state = "medog"
	item_state = "medog"
	deactive_state = "d_og"
	prescription = TRUE
	toggleable = TRUE
	hud_type = DATA_HUD_MEDICAL_ADVANCED
	actions_types = list(/datum/action/item_action/toggle)
