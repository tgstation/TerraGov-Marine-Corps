/obj/item/radio/ntc_listener
	name = "NTC frequency decrypter"
	desc = "An all-freq radio and terminal connected to a cutting edge set up within the ship that decrypts enemy communications using an AI from the great war, integrated into ship systems, need to be adjacent to this to listen in."
	//icon = 'ntf_modular/icons/obj/machines/radio.dmi'
	//icon_state = "intercom"
	icon = 'icons/obj/structures/prop/mainship.dmi'
	icon_state = "blacksensor_comp_b2"
	anchored = TRUE
	w_class = WEIGHT_CLASS_BULKY
	canhear_range = 2
	atom_flags = CONDUCT|NOBLOODY
	density = TRUE
	broadcasting = FALSE
	freerange = TRUE
	independent = TRUE

/obj/item/radio/ntc_listener/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, span_warning("No way, this is connected into the ship's systems in an intricate way."))
	return FALSE

/obj/item/radio/ntc_listener/set_broadcasting(new_broadcasting, actual_setting)
	playsound(loc,'sound/machines/buzz-two.ogg', 25, 1)
	return
