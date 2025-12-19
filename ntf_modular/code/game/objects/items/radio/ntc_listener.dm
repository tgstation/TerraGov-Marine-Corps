/obj/item/radio/headset/ntc_listener
	name = "NTC frequency decrypter"
	desc = "An all-freq radio and terminal connected to a cutting edge set up within the ship that decrypts enemy communications using an AI from the great war, integrated into ship systems. It cannot decrypt enemy command frequency unfortunately as they tend to be on a more secure channel that changes encryption constantly. You need to be adjacent to this to listen in."
	//icon = 'ntf_modular/icons/obj/machines/radio.dmi'
	//icon_state = "intercom"
	icon = 'icons/obj/structures/prop/mainship.dmi'
	icon_state = "blacksensor_comp_b2"
	anchored = TRUE
	w_class = WEIGHT_CLASS_BULKY
	canhear_range = 1
	atom_flags = CONDUCT|NOBLOODY|CAN_BE_HIT
	density = TRUE
	broadcasting = FALSE
	freerange = TRUE
	independent = TRUE
	keyslot = /obj/item/encryptionkey/commai

/obj/item/radio/headset/ntc_listener/possibly_deactivate_in_loc()
	return

/obj/item/radio/headset/ntc_listener/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I))
		to_chat(user, span_warning("There is not much to screwdriver."))
		return
	else if(istype(I, /obj/item/encryptionkey))
		to_chat(user, span_warning("There is no slot."))
		return
	. = ..()

/obj/item/radio/headset/ntc_listener/Initialize(mapload)
	. = ..()
	pixel_y = 0
	pixel_x = 0
	set_broadcasting(FALSE)
	set_listening(TRUE)

/obj/item/radio/headset/ntc_listener/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, span_warning("No way, this is connected into the ship's systems in an intricate way."))
	return FALSE

/obj/item/radio/headset/ntc_listener/set_broadcasting(new_broadcasting, actual_setting)
	balloon_alert_to_viewers("This is not designed to send signals.")
	playsound(loc,'sound/machines/buzz-two.ogg', 25, 1)
	return
