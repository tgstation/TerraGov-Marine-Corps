/obj/item/jetpack_marine
	name = "marine jetpack"
	desc = "Allows for fast and agile movement on the battlefield"
	icon = 'icons/obj/items/jetpack.dmi'
	icon_state = "jetpack_marine"
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK

/obj/item/jetpack_marine/equipped(mob/user, slot)
	if(slot == SLOT_BACK)
		user.client.click_intercept |= src

/obj/item/jetpack_marine/dropped(mob/user)
	. = ..()
	user.client.click_intercept -= src

/obj/item/jetpack_marine/InterceptClickOn(mob/user, params, atom/object)
	var/list/pa = params2list(params)
	if (pa["alt"])
		var/mob/living/carbon/human/human_user = user
		toggle_flame(user, TRUE)
		human_user.fly_at(object,5,1.2)
		toggle_flame(user, FALSE)

/obj/item/jetpack_marine/proc/toggle_flame(mob/user, on)
	var/image/I = image('icons/obj/items/jetpack.dmi', src, "+jetpacklit")

	if (on)
		overlays += I
		playsound(user,'sound/items/jetpack_sound.ogg',25)
	else
		overlays -= I
		qdel(I)

	return TRUE
