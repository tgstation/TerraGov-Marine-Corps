/obj/item/whistle
	name = "\improper whistle"
	desc = "A metal pea-whistle. Can be blown while held, or worn in the mouth"
	icon_state = "whistle"
	w_class = 1.0
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_MASK

	var/volume = 60
	var/spamcheck = 0

/obj/item/whistle/attack_self(mob/user as mob)
	whistle_playsound(user)
	add_fingerprint(user)
	return

/obj/item/whistle/attackby(obj/item/W as obj, mob/user as mob)
	if(user.wear_mask == src)
		whistle_playsound(user)
	else
		..()

/obj/item/whistle/attack_hand(mob/user)
	if(user.wear_mask == src)
		whistle_playsound(user)
	else
		..()

/obj/item/whistle/proc/whistle_playsound(mob/user as mob)
	if (spamcheck)
		return

	user.visible_message("<span class='warning'>[user] blows into [src]!</span>")
	playsound(get_turf(src), 'sound/items/whistle.ogg', volume, 1, vary = 0)

	spamcheck = 1
	spawn(30)
		spamcheck = 0

/obj/item/whistle/MouseDrop(obj/over_object as obj)
	if(ishuman(usr) || ismonkey(usr) || iscyborg(usr))

		if(!usr.restrained() && !usr.stat && usr.wear_mask == src)
			switch(over_object.name)
				if("r_hand")
					usr.dropItemToGround(src)
					usr.put_in_r_hand(src)
				if("l_hand")
					usr.dropItemToGround(src)
					usr.put_in_l_hand(src)
			add_fingerprint(usr)


/obj/item/hailer
	name = "hailer"
	desc = "Used by obese officers to save their breath for running."
	icon_state = "voice0"
	item_state = "flashbang"	//looks exactly like a flash (and nothing like a flashbang)
	w_class = 1.0
	flags_atom = CONDUCT

	var/spamcheck = 0
	var/emagged = 0
	var/insults = 0//just in case

/obj/item/hailer/attack_self(mob/living/carbon/user as mob)
	if (spamcheck)
		return

	if(emagged)
		if(insults >= 1)
			playsound(get_turf(src), 'sound/voice/binsult.ogg', 25, 1, vary = 0)//hueheuheuheuheuheuhe
			user.show_message("<span class='warning'>[user]'s [name] gurgles, \"FUCK YOUR CUNT YOU SHIT EATING CUNT TILL YOU ARE A MASS EATING SHIT CUNT. EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS TO FUCK UP SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FROM THE DEPTHS OF SHIT\"</span>",2) //It's a hearable message silly!
			insults--
		else
			to_chat(user, "<span class='warning'>*BZZZZcuntZZZZT*</span>")
	else
		playsound(get_turf(src), 'sound/voice/halt.ogg', 25, 1, vary = 0)
		user.show_message("<span class='warning'>[user]'s [name] rasps, \"Halt! Security!\"</span>",1)

	spamcheck = 1
	spawn(20)
		spamcheck = 0

/obj/item/hailer/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/card/emag) && !emagged)
		to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
		emagged = 1
		insults = rand(1, 3)//to prevent dickflooding
		return
	return