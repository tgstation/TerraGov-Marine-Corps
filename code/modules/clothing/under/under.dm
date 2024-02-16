
/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms/uniforms.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/clothing/uniforms_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/uniforms_right.dmi',
	)
	name = "under"
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS
	flags_cold_protection = CHEST|GROIN|LEGS|ARMS
	flags_heat_protection = CHEST|GROIN|LEGS|ARMS
	permeability_coefficient = 0.90
	flags_equip_slot = ITEM_SLOT_ICLOTHING
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	w_class = WEIGHT_CLASS_BULKY
	blood_sprite_state = "uniformblood"
	var/has_sensor = 1//For the crew computer 2 = unable to change mode
	var/sensor_mode = 3
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/
	var/displays_id = 1
	attachments_allowed = list(
		/obj/item/armor_module/storage/uniform/webbing,
		/obj/item/armor_module/storage/uniform/black_vest,
		/obj/item/armor_module/storage/uniform/brown_vest,
		/obj/item/armor_module/storage/uniform/white_vest,
		/obj/item/armor_module/storage/uniform/surgery_webbing,
		/obj/item/armor_module/storage/uniform/holster,
		/obj/item/armor_module/storage/uniform/holster/armpit,
		/obj/item/armor_module/storage/uniform/holster/waist,
		/obj/item/armor_module/storage/uniform/holster/freelancer,
		/obj/item/armor_module/storage/uniform/holster/vp,
		/obj/item/armor_module/storage/uniform/holster/highpower,
		/obj/item/armor_module/storage/uniform/holster/deathsquad,
		/obj/item/armor_module/armor/badge,
		/obj/item/armor_module/armor/cape,
		/obj/item/armor_module/armor/cape/kama,
		/obj/item/armor_module/module/pt_belt,
		/obj/item/clothing/tie,
		/obj/item/clothing/tie/blue,
		/obj/item/clothing/tie/red,
		/obj/item/clothing/tie/horrible,
		/obj/item/clothing/tie/stethoscope,
		/obj/item/clothing/tie/medal,
		/obj/item/clothing/tie/medal/conduct,
		/obj/item/clothing/tie/medal/bronze_heart,
		/obj/item/clothing/tie/medal/nobel_science,
		/obj/item/clothing/tie/medal/silver,
		/obj/item/clothing/tie/medal/silver/valor,
		/obj/item/clothing/tie/medal/silver/security,
		/obj/item/clothing/tie/medal/gold,
		/obj/item/clothing/tie/medal/gold/captain,
		/obj/item/clothing/tie/medal/gold/heroism,
		/obj/item/clothing/tie/medal/letter/commendation,
		/obj/item/clothing/tie/armband,
		/obj/item/clothing/tie/armband/cargo,
		/obj/item/clothing/tie/armband/engine,
		/obj/item/clothing/tie/armband/science,
		/obj/item/clothing/tie/armband/hydro,
		/obj/item/clothing/tie/armband/med,
		/obj/item/clothing/tie/armband/medgreen,
		/obj/item/clothing/tie/holobadge,
		/obj/item/clothing/tie/holobadge/cord,
	)

	///Assoc list of available slots.
	attachments_by_slot = list(
		ATTACHMENT_SLOT_UNIFORM,
		ATTACHMENT_SLOT_UNIFORM_TIE,
		ATTACHMENT_SLOT_BADGE,
		ATTACHMENT_SLOT_CAPE,
		ATTACHMENT_SLOT_KAMA,
		ATTACHMENT_SLOT_BELT,
	)
	///Typepath list of uniform variants.
	var/list/adjustment_variants = list(
		"Down" = "_d",
	)
	var/adjustment_variant

/obj/item/clothing/under/Initialize(mapload)
	. = ..()
	attachments_allowed = string_list(attachments_allowed)

/obj/item/clothing/under/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_w_uniform()


/obj/item/clothing/under/get_worn_icon_state(slot_name, inhands)
	. = ..()
	. += adjustment_variant

/obj/item/clothing/under/attackby(obj/item/I, mob/user, params)
	if(!ishuman(user))
		return ..()

	var/mob/living/carbon/human/H = user
	if(loc == user && istype(I, /obj/item/clothing/under) && src != I)
		if(H.w_uniform != src)
			return ..()

		H.dropItemToGround(src)
		if(!H.equip_to_appropriate_slot(I))
			return ..()
		H.put_in_active_hand(src)

	else
		return ..()

/obj/item/clothing/under/MouseDrop(obj/over_object as obj)
	if(!ishuman(usr))
		return
	//makes sure that the clothing is equipped so that we can't drag it into our hand from miles away.
	if(HAS_TRAIT(src, TRAIT_NODROP) || loc != usr)
		return
	if(usr.incapacitated() || usr.buckled || usr.lying_angle)
		return
	if(!over_object)
		return
	switch(over_object.name)
		if("r_hand")
			usr.dropItemToGround(src)
			usr.put_in_r_hand(src)
		if("l_hand")
			usr.dropItemToGround(src)
			usr.put_in_l_hand(src)


/obj/item/clothing/under/examine(mob/user)
	. = ..()
	if(!has_sensor)
		return
	switch(sensor_mode) // todo this should use defines
		if(0)
			. += "Its sensors appear to be disabled."
		if(1)
			. += "Its binary life sensors appear to be enabled."
		if(2)
			. += "Its vital tracker appears to be enabled."
		if(3)
			. += "Its vital tracker and tracking beacon appear to be enabled."

//we only want to quick equip from actual 'holster' type webbings
/obj/item/clothing/under/do_quick_equip(mob/user)
	for(var/attachment_slot in attachments_by_slot)
		if(istype(attachments_by_slot[attachment_slot], /obj/item/armor_module/storage/uniform/holster))
			var/obj/item/armor_module/storage/storage_attachment = attachments_by_slot[attachment_slot]
			return storage_attachment.storage.do_quick_equip(user)
	return src

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
				visible_message(span_warning("[user] disables [loc]'s remote sensing equipment."), null, null, 1)
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
	if(!isliving(usr))
		return
	if(usr.stat)
		return
	if(!length(adjustment_variants))
		to_chat(usr, span_warning("You cannot roll down the uniform!"))
		return
	var/variant = null
	if(!adjustment_variant || length(adjustment_variants) > 1)
		if(length(adjustment_variants) == 1)
			variant = adjustment_variants[1]
		else
			var/list/selection_list = list("Normal" = null)
			selection_list += adjustment_variants
			variant = tgui_input_list(usr, "Select Variant", "Variants", selection_list)
	if(variant)
		adjustment_variant = adjustment_variants[variant]
	else
		adjustment_variant = null
	update_icon()
	update_clothing_icon()
