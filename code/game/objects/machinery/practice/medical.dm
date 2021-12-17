/obj/machinery/practice/medical/surgery
	name = "Practice Button (Surgery)"
	desc = "A button used to simulate situations for training purposes."
	icon = 'icons/obj/machines/buttons.dmi'
	icon_state = "doorctrl"
	resistance_flags = RESIST_ALL
	var/mob/living/carbon/human/humanspawned = null

/obj/machinery/practice/medical/surgery/Initialize(mapload, ndir = 0)
	. = ..()
	setDir(ndir)
	pixel_x = ( (dir & 3) ? 0 : (dir == 4 ? -24 : 24) )
	pixel_y = ( (dir & 3) ? (dir == 1 ? -24 : 24) : 0 )
	update_icon()

/obj/machinery/practice/medical/surgery/attack_hand(mob/living/user)
	if(user.a_intent == INTENT_HARM)
		to_chat(user, span_warning("You are unable to damage the button."))
		return
	if(humanspawned)
		QDEL_NULL(humanspawned)
		visible_message(span_notice("The dummy vanishes, ending the simulation."))
		return
	else
		var/choice = tgui_input_list(user, "What surgery would you like to simulate?", null, list("larval host", "broken bones", "missing limbs", "damaged organs"))
		if(!choice)
			to_chat(user, span_notice("You must select a surgery to start the simulation."))
			return
		switch(choice)
			if("larval host")
				humanspawned = new /mob/living/carbon/human(get_turf(src))
				new /obj/item/clothing/mask/facehugger(get_turf(src))
			if("broken bones")
				humanspawned = new /mob/living/carbon/human(get_turf(src))
				var/list/bones_to_break = list()
				for(var/datum/limb/E in humanspawned.limbs)
					bones_to_break += E
				if(bones_to_break.len)
					var/datum/limb/L = pick(bones_to_break)
					var/limb_name = L.display_name
					L.fracture()
					return limb_name
			if("missing limbs")
				humanspawned = new /mob/living/carbon/human(get_turf(src))
				humanspawned.remove_random_limb()
			if("damaged organs")
				humanspawned = new /mob/living/carbon/human(get_turf(src))
				var/list/organs_to_hurt = list()
				for(var/datum/internal_organ/I in humanspawned.internal_organs)
					organs_to_hurt += I
				if(organs_to_hurt.len)
					var/datum/internal_organ/O = pick(organs_to_hurt)
					O.take_damage(40)
