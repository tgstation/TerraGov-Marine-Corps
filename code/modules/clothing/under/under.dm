
/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS
	flags_cold_protection = CHEST|GROIN|LEGS|ARMS
	flags_heat_protection = CHEST|GROIN|LEGS|ARMS
	permeability_coefficient = 0.90
	flags_equip_slot = ITEM_SLOT_ICLOTHING
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	w_class = WEIGHT_CLASS_NORMAL
	var/has_sensor = 1//For the crew computer 2 = unable to change mode
	var/sensor_mode = 3
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/
	var/obj/item/clothing/tie/hastie = null
	var/displays_id = 1
	var/rollable_sleeves = FALSE //can we roll the sleeves on this uniform?
	var/rolled_sleeves = FALSE //are the sleeves currently rolled?
	blood_sprite_state = "uniformblood"
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/uniform.dmi')




/obj/item/clothing/under/Destroy()
	if(hastie)
		qdel(hastie)
		hastie = null
	. = ..()



/obj/item/clothing/under/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_w_uniform()

/obj/item/clothing/under/attackby(obj/item/I, mob/user, params)
	if(hastie)
		hastie.attackby(I, user, params)
		return TRUE

	else if(!ishuman(user))
		return ..()

	var/mob/living/carbon/human/H = user
	if(!hastie && istype(I, /obj/item/clothing/tie))
		var/obj/item/clothing/tie/T = I
		if(!T.tie_check(src, user))
			return ..()
		user.drop_held_item()
		hastie = T
		hastie.on_attached(src, user)
		H.update_inv_w_uniform()

	else if(loc == user && istype(I, /obj/item/clothing/under) && src != I)
		if(H.w_uniform != src)
			return ..()

		H.dropItemToGround(src)
		if(!H.equip_to_appropriate_slot(I))
			return ..()
		H.put_in_active_hand(src)

	else
		return ..()

/obj/item/clothing/under/attack_hand(mob/living/user)
	//only forward to the attached accessory if the clothing is equipped (not in a storage)
	if(hastie && src.loc == user)
		hastie.attack_hand(user)
		return

	if ((ishuman(usr) || ismonkey(usr)) && src.loc == user)	//make it harder to accidentally undress yourself
		return

	return ..()

/obj/item/clothing/under/MouseDrop(obj/over_object as obj)
	if (ishuman(usr) || ismonkey(usr))
		//makes sure that the clothing is equipped so that we can't drag it into our hand from miles away.
		if ((flags_item & NODROP) || loc != usr)
			return

		if (!usr.incapacitated() && !(usr.buckled && usr.lying_angle))
			if(over_object)
				switch(over_object.name)
					if("r_hand")
						usr.dropItemToGround(src)
						usr.put_in_r_hand(src)
					if("l_hand")
						usr.dropItemToGround(src)
						usr.put_in_l_hand(src)


/obj/item/clothing/under/examine(mob/user)
	..()
	if(has_sensor)
		switch(sensor_mode)
			if(0)
				to_chat(user, "Its sensors appear to be disabled.")
			if(1)
				to_chat(user, "Its binary life sensors appear to be enabled.")
			if(2)
				to_chat(user, "Its vital tracker appears to be enabled.")
			if(3)
				to_chat(user, "Its vital tracker and tracking beacon appear to be enabled.")
	if(hastie)
		to_chat(user, "\A [hastie] is clipped to it.")

/obj/item/clothing/under/proc/set_sensors(mob/living/user)
	if (!istype(user))
		return
	if (user.incapacitated(TRUE))
		return
	if(has_sensor >= 2)
		to_chat(user, "The sensors in [src] can't be modified.")
		return FALSE
	if(has_sensor <= 0)
		to_chat(user, "[src] does not have any sensors.")
		return FALSE

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = tgui_input_list(user, "Select a sensor mode:", "Suit Sensor Mode", modes)
	if(get_dist(user, src) > 1)
		to_chat(user, "You have moved too far away.")
		return
	sensor_mode = modes.Find(switchMode) - 1

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.w_uniform == src)
			H.update_suit_sensors()

	if (loc == user)
		switch(sensor_mode)
			if(0)
				to_chat(user, "You disable your suit's remote sensing equipment.")
			if(1)
				to_chat(user, "Your suit will now report whether you are live or dead.")
			if(2)
				to_chat(user, "Your suit will now report your vital lifesigns.")
			if(3)
				to_chat(user, "Your suit will now report your vital lifesigns as well as your coordinate position.")
	else if (ismob(loc))
		switch(sensor_mode)
			if(0)
				visible_message("<span class='warning'>[user] disables [loc]'s remote sensing equipment.</span>", null, null, 1)
			if(1)
				visible_message("[user] turns [loc]'s remote sensors to binary.", null, null, 1)
			if(2)
				visible_message("[user] sets [loc]'s sensors to track vitals.", null, null, 1)
			if(3)
				visible_message("[user] sets [loc]'s sensors to maximum.", null, null, 1)

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	set src in usr
	set_sensors(usr)


/obj/item/clothing/under/verb/rollsuit()
	set name = "Roll Down Jumpsuit"
	set category = "Object"
	set src in usr
	if(!isliving(usr)) return
	if(usr.stat) return

	if(rollable_sleeves)
		rolled_sleeves = !rolled_sleeves
		var/full_coverage = CHEST|GROIN|LEGS|ARMS
		if(rolled_sleeves)
			var/partial_coverage = CHEST|GROIN|LEGS
			var/final_coverage
			//Marine uniforms can only roll up the sleeves, not wear it at the waist.
			if(istype(src,/obj/item/clothing/under/marine))
				final_coverage = copytext(icon_state,1,3) == "s_" ? full_coverage : partial_coverage
			else final_coverage = partial_coverage & ~CHEST
			flags_armor_protection = final_coverage
		else
			flags_armor_protection = full_coverage

		flags_cold_protection = flags_armor_protection
		flags_heat_protection = flags_armor_protection
		update_clothing_icon()
	else
		to_chat(usr, "<span class='warning'>You cannot roll down the uniform!</span>")

//proper proc to remove the uniform's tie (user optional)
/obj/item/clothing/under/proc/remove_accessory(mob/user)
	if(!hastie)
		return

	hastie.on_removed()
	if(user)
		user.put_in_hands(hastie)
	hastie = null
	update_clothing_icon()

/obj/item/clothing/under/verb/removetie()
	set name = "Remove Accessory"
	set category = "Object"
	set src in usr
	if(!isliving(usr))
		return
	if(usr.stat) return

	src.remove_accessory(usr)

/obj/item/clothing/under/emp_act(severity)
	if (hastie)
		hastie.emp_act(severity)
	..()
