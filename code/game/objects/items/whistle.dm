/obj/item/whistle
	name = "\improper whistle"
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


/obj/item/whistle/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(user.wear_mask == src)
		whistle_playsound(user)


/obj/item/whistle/proc/whistle_playsound(mob/user as mob)
	if (spamcheck)
		return

	user.visible_message("<span class='warning'>[user] blows into [src]!</span>")
	playsound(get_turf(src), 'sound/items/whistle.ogg', volume, 1)

	spamcheck = TRUE
	addtimer(CALLBACK(src, .proc/spam_cooldown), 3 SECONDS)


/obj/item/whistle/proc/spam_cooldown()
	spamcheck = FALSE


/obj/item/hailer
	name = "hailer"
	desc = "Used by obese officers to save their breath for running."
	icon_state = "voice0"
	item_state = "flashbang"	//looks exactly like a flash (and nothing like a flashbang)
	w_class = WEIGHT_CLASS_TINY
	flags_atom = CONDUCT

	var/spamcheck = FALSE
	var/insults = 0


/obj/item/hailer/attack_self(mob/user)
	if(spamcheck)
		return

	if(CHECK_BITFIELD(obj_flags, EMAGGED))
		if(insults >= 1)
			playsound(get_turf(src), 'sound/voice/binsult.ogg', 25, 1)
			user.audible_message("<span class='warning'>[user]'s [name] gurgles, \"FUCK YOUR CUNT YOU SHIT EATING CUNT TILL YOU ARE A MASS EATING SHIT CUNT. EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS TO FUCK UP SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FROM THE DEPTHS OF SHIT\"</span>")
			insults--
		else
			to_chat(user, "<span class='warning'>*BZZZZcuntZZZZT*</span>")
	else
		playsound(get_turf(src), 'sound/voice/halt.ogg', 25, 1)
		user.audible_message("<span class='warning'>[user]'s [name] rasps, \"Halt! Security!\"</span>")

	spamcheck = TRUE
	addtimer(CALLBACK(src, .proc/spam_cooldown), 2 SECONDS)


/obj/item/hailer/proc/spam_cooldown()
	spamcheck = FALSE


/obj/item/hailer/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/card/emag) && !CHECK_BITFIELD(obj_flags, EMAGGED))
		to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
		ENABLE_BITFIELD(obj_flags, EMAGGED)
		insults = rand(1, 3)