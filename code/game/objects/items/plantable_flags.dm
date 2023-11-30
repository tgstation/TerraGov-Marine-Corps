/obj/item/flag_base
	name = "basic flag"
	desc = "It's a one time use flag built into a telescoping pole ripe for planting."
	icon = 'icons/obj/items/plantable_flag.dmi'
	icon_state = "flag_collapsed"
	force = 3
	throwforce = 2
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_SMALL
	var/is_collapsed = TRUE
	var/country_name = "TGMC" //presume it is prefaced with 'the'

/obj/item/flag_base/examine(mob/user)
	. = ..()
	. += "It has a flag made for the [country_name] inside it."


/obj/item/flag_base/attack_self(mob/user)
	to_chat(user, "<span class='warning'>You start to deploy the flag between your feet...")
	if(!do_after(usr, 1 SECONDS, NONE, src, BUSY_ICON_BUILD))
		to_chat(user, "<span class='warning'>You decide against deploying the flag here.")
		return

	playsound(loc, 'sound/effects/thud.ogg', 100)
	user.dropItemToGround(src)
	is_collapsed = FALSE
	update_icon_state()


/obj/item/flag_base/attack_hand(mob/living/user)
	if(!is_collapsed)
		if(!do_after(usr, 1 SECONDS, NONE, src, BUSY_ICON_BUILD))
			to_chat(user, "<span class='warning'>You decide against removing the flag here.")
			return
		is_collapsed = TRUE
		update_icon_state()
	. = ..()


/obj/item/flag_base/update_icon_state()
	. = ..()
	if(!is_collapsed)
		layer = ABOVE_OBJ_LAYER
		icon_state = "flag_[country_name]"
	else
		layer = OBJ_LAYER
		icon_state = "flag_collapsed"

/obj/item/flag_base/tgmc_flag
	name = "Flag of TGMC"
	country_name = "TGMC"

/obj/item/flag_base/upp_flag
	name = "Flag of UPP"
	country_name = "UPP"

/obj/item/flag_base/xeno_flag
	name = "Flag of Xenomorphs"
	country_name = "Xenomorph"
