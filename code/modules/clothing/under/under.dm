
/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	permeability_coefficient = 0.90
	flags_pass = PASSTABLE
	flags_equip_slot = SLOT_ICLOTHING
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	w_class = 3
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
	var/list/suit_restricted //for uniforms that only accept to be combined with certain suits
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/uniform.dmi')




/obj/item/clothing/under/Dispose()
	if(hastie)
		cdel(hastie)
		hastie = null
	. = ..()



/obj/item/clothing/under/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_w_uniform()

/obj/item/clothing/under/attackby(obj/item/I, mob/user)
	if(hastie)
		hastie.attackby(I, user)
		return 1

	if(!hastie && istype(I, /obj/item/clothing/tie))
		var/obj/item/clothing/tie/T = I
		if(!T.tie_check(src, user)) return
		user.drop_held_item()
		hastie = T
		hastie.on_attached(src, user)

		if(istype(loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = loc
			H.update_inv_w_uniform()

		return

	if(loc == user && istype(I,/obj/item/clothing/under) && src != I)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.w_uniform == src)
				H.drop_inv_item_on_ground(src)
				if(H.equip_to_appropriate_slot(I))
					H.put_in_active_hand(src)

	..()

/obj/item/clothing/under/attack_hand(mob/user as mob)
	//only forward to the attached accessory if the clothing is equipped (not in a storage)
	if(hastie && src.loc == user)
		hastie.attack_hand(user)
		return

	if ((ishuman(usr) || ismonkey(usr)) && src.loc == user)	//make it harder to accidentally undress yourself
		return

	..()

/obj/item/clothing/under/MouseDrop(obj/over_object as obj)
	if (ishuman(usr) || ismonkey(usr))
		//makes sure that the clothing is equipped so that we can't drag it into our hand from miles away.
		if ((flags_item & NODROP) || loc != usr)
			return

		if (!usr.is_mob_incapacitated() && !(usr.buckled && usr.lying))
			if(over_object)
				switch(over_object.name)
					if("r_hand")
						usr.drop_inv_item_on_ground(src)
						usr.put_in_r_hand(src)
					if("l_hand")
						usr.drop_inv_item_on_ground(src)
						usr.put_in_l_hand(src)
				add_fingerprint(usr)


/obj/item/clothing/under/examine(mob/user)
	..()
	if(has_sensor)
		switch(sensor_mode)
			if(0)
				user << "Its sensors appear to be disabled."
			if(1)
				user << "Its binary life sensors appear to be enabled."
			if(2)
				user << "Its vital tracker appears to be enabled."
			if(3)
				user << "Its vital tracker and tracking beacon appear to be enabled."
	if(hastie)
		user << "\A [hastie] is clipped to it."

/obj/item/clothing/under/proc/set_sensors(mob/user)
	if (istype(user, /mob/dead/)) return
	if (user.stat || user.is_mob_restrained()) return
	if(has_sensor >= 2)
		user << "The controls are locked."
		return 0
	if(has_sensor <= 0)
		user << "This suit does not have any sensors."
		return 0

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes
	if(get_dist(user, src) > 1)
		user << "You have moved too far away."
		return
	sensor_mode = modes.Find(switchMode) - 1

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.w_uniform == src)
			H.update_suit_sensors()

	if (loc == user)
		switch(sensor_mode)
			if(0)
				user << "You disable your suit's remote sensing equipment."
			if(1)
				user << "Your suit will now report whether you are live or dead."
			if(2)
				user << "Your suit will now report your vital lifesigns."
			if(3)
				user << "Your suit will now report your vital lifesigns as well as your coordinate position."
	else if (ismob(loc))
		switch(sensor_mode)
			if(0)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("\red [user] disables [src.loc]'s remote sensing equipment.", 1)
			if(1)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("[user] turns [src.loc]'s remote sensors to binary.", 1)
			if(2)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("[user] sets [src.loc]'s sensors to track vitals.", 1)
			if(3)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("[user] sets [src.loc]'s sensors to maximum.", 1)

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
		var/full_coverage = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
		if(rolled_sleeves)
			var/partial_coverage = UPPER_TORSO|LOWER_TORSO|LEGS
			var/final_coverage
			//Marine uniforms can only roll up the sleeves, not wear it at the waist.
			if(istype(src,/obj/item/clothing/under/marine))
				final_coverage = copytext(icon_state,1,3) == "s_" ? full_coverage : partial_coverage
			else final_coverage = partial_coverage & ~UPPER_TORSO
			flags_armor_protection = final_coverage
		else
			flags_armor_protection = full_coverage

		flags_cold_protection = flags_armor_protection
		flags_heat_protection = flags_armor_protection
		update_clothing_icon()

	else usr << "<span class='warning'>You cannot roll down the uniform!</span>"

//proper proc to remove the uniform's tie (user optional)
/obj/item/clothing/under/proc/remove_accessory(mob/user)
	if(!hastie)
		return

	hastie.on_removed()
	if(user)
		user.put_in_hands(hastie)
		hastie.add_fingerprint(user)
	hastie = null
	update_clothing_icon()

/obj/item/clothing/under/verb/removetie()
	set name = "Remove Accessory"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	src.remove_accessory(usr)

/obj/item/clothing/under/emp_act(severity)
	if (hastie)
		hastie.emp_act(severity)
	..()
