/obj/item/whistle
	name = "\improper whistle"
	icon = 'icons/Marine/marine-navigation.dmi'
	desc = "A metal pea-whistle. Can be blown while held, or worn in the mouth"
	icon_state = "whistle"
	w_class = WEIGHT_CLASS_TINY
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_MASK

	var/volume = 60
	var/spamcheck = FALSE


/obj/item/whistle/attack_self(mob/user)
	. = ..()
	whistle_playsound(user)


/obj/item/whistle/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(user.wear_mask == src)
		whistle_playsound(user)


/obj/item/whistle/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.wear_mask == src)
		whistle_playsound(user)


/obj/item/whistle/proc/whistle_playsound(mob/user as mob)
	if (spamcheck)
		return

	user.visible_message(span_warning("[user] blows into [src]!"))
	playsound(get_turf(src), 'sound/items/whistle.ogg', volume, 1)

	spamcheck = TRUE
	addtimer(VARSET_CALLBACK(src, spamcheck, FALSE), 3 SECONDS)


/obj/item/hailer
	name = "hailer"
	desc = "Used by obese officers to save their breath for running."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "voice"
	item_state = "flashbang"	//looks exactly like a flash (and nothing like a flashbang)
	w_class = WEIGHT_CLASS_TINY
	flags_atom = CONDUCT
	var/spamcheck = FALSE


/obj/item/hailer/attack_self(mob/user)
	if(spamcheck)
		return

	playsound(get_turf(src), 'sound/voice/halt.ogg', 25, 1)
	user.audible_message(span_warning("[user]'s [name] rasps, \"Halt! Security!\""))

	spamcheck = TRUE
	addtimer(VARSET_CALLBACK(src, spamcheck, FALSE), 2 SECONDS)
