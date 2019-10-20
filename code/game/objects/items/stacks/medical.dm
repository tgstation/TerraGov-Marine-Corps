/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	amount = 10
	max_amount = 10
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 20
	var/heal_brute = 0
	var/heal_burn = 0

/obj/item/stack/medical/proc/radial_medical(mob/living/carbon/M as mob, mob/user as mob)
	var/mob/living/carbon/human/H = M
	var/radial_state = ""
	var/datum/limb/part = null
	
	part = H.get_limb(BODY_ZONE_HEAD)
	if(!part.burn_dam)
		if(!part.brute_dam)
			radial_state = "radial_head_un"
		else
			radial_state = "radial_head_brute"
	else
		if(part.brute_dam)
			radial_state = "radial_head_both"
		else
			radial_state = "radial_head_burn"
	var/radial_head = image(icon = 'icons/mob/radial.dmi', icon_state = radial_state)

	part = H.get_limb(BODY_ZONE_CHEST)
	if(!part.burn_dam)
		if(!part.brute_dam)
			radial_state = "radial_chest_un"
		else
			radial_state = "radial_chest_brute"
	else
		if(part.brute_dam)
			radial_state = "radial_chest_both"
		else
			radial_state = "radial_chest_burn"
	var/radial_chest = image(icon = 'icons/mob/radial.dmi', icon_state = radial_state)

	part = H.get_limb(BODY_ZONE_PRECISE_GROIN)
	if(!part.burn_dam)
		if(!part.brute_dam)
			radial_state = "radial_groin_un"
		else
			radial_state = "radial_groin_brute"
	else
		if(part.brute_dam)
			radial_state = "radial_groin_both"
		else
			radial_state = "radial_groin_burn"
	var/radial_groin = image(icon = 'icons/mob/radial.dmi', icon_state = radial_state)

	part = H.get_limb(BODY_ZONE_L_ARM)
	if(!part.burn_dam)
		if(!part.brute_dam)
			radial_state = "radial_Larm_un"
		else
			radial_state = "radial_Larm_brute"
	else
		if(part.brute_dam)
			radial_state = "radial_Larm_both"
		else
			radial_state = "radial_Larm_burn"
	var/radial_Larm = image(icon = 'icons/mob/radial.dmi', icon_state = radial_state)

	part = H.get_limb(BODY_ZONE_PRECISE_L_HAND)
	if(!part.burn_dam)
		if(!part.brute_dam)
			radial_state = "radial_Lhand_un"
		else
			radial_state = "radial_Lhand_brute"
	else
		if(part.brute_dam)
			radial_state = "radial_Lhand_both"
		else
			radial_state = "radial_Lhand_burn"
	var/radial_Lhand = image(icon = 'icons/mob/radial.dmi', icon_state = radial_state)

	part = H.get_limb(BODY_ZONE_R_ARM)
	if(!part.burn_dam)
		if(!part.brute_dam)
			radial_state = "radial_Rarm_un"
		else
			radial_state = "radial_Rarm_brute"
	else
		if(part.brute_dam)
			radial_state = "radial_Rarm_both"
		else
			radial_state = "radial_Rarm_burn"
	var/radial_Rarm = image(icon = 'icons/mob/radial.dmi', icon_state = radial_state)

	part = H.get_limb(BODY_ZONE_PRECISE_R_HAND)
	if(!part.burn_dam)
		if(!part.brute_dam)
			radial_state = "radial_Rhand_un"
		else
			radial_state = "radial_Rhand_brute"
	else
		if(part.brute_dam)
			radial_state = "radial_Rhand_both"
		else
			radial_state = "radial_Rhand_burn"
	var/radial_Rhand = image(icon = 'icons/mob/radial.dmi', icon_state = radial_state)

	part = H.get_limb(BODY_ZONE_L_LEG)
	if(!part.burn_dam)
		if(!part.brute_dam)
			radial_state = "radial_Lleg_un"
		else
			radial_state = "radial_Lleg_brute"
	else
		if(part.brute_dam)
			radial_state = "radial_Lleg_both"
		else
			radial_state = "radial_Lleg_burn"
	var/radial_Lleg = image(icon = 'icons/mob/radial.dmi', icon_state = radial_state)

	part = H.get_limb(BODY_ZONE_PRECISE_L_FOOT)
	if(!part.burn_dam)
		if(!part.brute_dam)
			radial_state = "radial_Lfoot_un"
		else
			radial_state = "radial_Lfoot_brute"
	else
		if(part.brute_dam)
			radial_state = "radial_Lfoot_both"
		else
			radial_state = "radial_Lfoot_burn"
	var/radial_Lfoot = image(icon = 'icons/mob/radial.dmi', icon_state = radial_state)

	part = H.get_limb(BODY_ZONE_R_LEG)
	if(!part.burn_dam)
		if(!part.brute_dam)
			radial_state = "radial_Rleg_un"
		else
			radial_state = "radial_Rleg_brute"
	else
		if(part.brute_dam)
			radial_state = "radial_Rleg_both"
		else
			radial_state = "radial_Rleg_burn"
	var/radial_Rleg = image(icon = 'icons/mob/radial.dmi', icon_state = radial_state)

	part = H.get_limb(BODY_ZONE_PRECISE_R_FOOT)
	if(!part.burn_dam)
		if(!part.brute_dam)
			radial_state = "radial_Rfoot_un"
		else
			radial_state = "radial_Rfoot_brute"
	else
		if(part.brute_dam)
			radial_state = "radial_Rfoot_both"
		else
			radial_state = "radial_Rfoot_burn"
	var/radial_Rfoot = image(icon = 'icons/mob/radial.dmi', icon_state = radial_state)


	//the list of the above
	var/list/radial_options = list("head" = radial_head,
									"chest" = radial_chest,
									"groin" = radial_groin,
									"Larm" = radial_Larm,
									"Lhand" = radial_Lhand,
									"Rarm" = radial_Rarm,
									"Rhand" = radial_Rhand,
									"Lleg" = radial_Lleg,
									"Lfoot" = radial_Lfoot,
									"Rleg" = radial_Rleg,
									"Rfoot" = radial_Rfoot)

	var/datum/limb/affecting = null
	var/choice = show_radial_menu(user, H, radial_options, null, 48, null, TRUE)
	switch(choice)
		if("head")
			affecting = H.get_limb(BODY_ZONE_HEAD)
		if("chest")
			affecting = H.get_limb(BODY_ZONE_CHEST)
		if("groin")
			affecting = H.get_limb(BODY_ZONE_PRECISE_GROIN)
		if("Larm")
			affecting = H.get_limb(BODY_ZONE_L_ARM)
		if("Lhand")
			affecting = H.get_limb(BODY_ZONE_PRECISE_L_HAND)
		if("Rarm")
			affecting = H.get_limb(BODY_ZONE_R_ARM)
		if("Rhand")
			affecting = H.get_limb(BODY_ZONE_PRECISE_R_HAND)
		if("Lleg")
			affecting = H.get_limb(BODY_ZONE_L_LEG)
		if("Lfoot")
			affecting = H.get_limb(BODY_ZONE_PRECISE_L_FOOT)
		if("Rleg")
			affecting = H.get_limb(BODY_ZONE_R_LEG)
		if("Rfoot")
			affecting = H.get_limb(BODY_ZONE_PRECISE_R_FOOT)
	return affecting

/obj/item/stack/medical/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!istype(M))
		to_chat(user, "<span class='warning'>\The [src] cannot be applied to [M]!</span>")
		return TRUE

	if(!ishuman(user))
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return TRUE

	var/mob/living/carbon/human/H = M
	var/datum/limb/affecting = radial_medical(H, user)

	if(!affecting)
		return TRUE

	if(affecting.body_part == HEAD)
		if(H.head && istype(H.head,/obj/item/clothing/head/helmet/space))
			to_chat(user, "<span class='warning'>You can't apply [src] through [H.head]!</span>")
			return TRUE
	else
		if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/space))
			to_chat(user, "<span class='warning'>You can't apply [src] through [H.wear_suit]!</span>")
			return TRUE

	if(affecting.limb_status & LIMB_ROBOT)
		to_chat(user, "<span class='warning'>This isn't useful at all on a robotic limb.</span>")
		return TRUE

	H.UpdateDamageIcon()
	return affecting

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "medical gauze"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon_state = "brutepack"
	heal_brute = 1


/obj/item/stack/medical/bruise_pack/attack(mob/living/carbon/M as mob, mob/user as mob)
	. = ..()
	if(. == TRUE)
		return TRUE

	if (ishuman(M))
		var/mob/living/carbon/human/H = M

		if(user.skills.getRating("medical") < SKILL_MEDICAL_PRACTICED && !do_mob(user, M, 1 SECONDS, BUSY_ICON_UNSKILLED, BUSY_ICON_MEDICAL))
			return TRUE

		var/datum/limb/affecting = .

		if(affecting.surgery_open_stage == 0)
			if(!affecting.bandage())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been bandaged.</span>")
				return TRUE
			else
				for (var/datum/wound/W in affecting.wounds)
					if (W.internal)
						continue
					if (W.current_stage <= W.max_bleeding_stage)
						user.visible_message("<span class='notice'>[user] bandages [W.desc] on [M]'s [affecting.display_name].</span>",
						"<span class='notice'>You bandage [W.desc] on [M]'s [affecting.display_name].</span>" )
					else if (istype(W,/datum/wound/bruise))
						user.visible_message("<span class='notice'>[user] places bruise patch over [W.desc] on [M]'s [affecting.display_name].</span>",
						"<span class='notice'>You place bruise patch over [W.desc] on [M]'s [affecting.display_name].</span>" )
					else
						user.visible_message("<span class='notice'>[user] places bandaid over [W.desc] on [M]'s [affecting.display_name].</span>",
						"<span class='notice'>You place bandaid over [W.desc] on [M]'s [affecting.display_name].</span>" )
				use(1)
		else
			if(H.can_be_operated_on()) //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>The [affecting.display_name] is cut open, you'll need more than a bandage!</span>")

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat burns, infected wounds, and relieve itching in unusual places."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	heal_burn = 3


/obj/item/stack/medical/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	. = ..()
	if(. == TRUE)
		return TRUE

	if (ishuman(M))
		var/mob/living/carbon/human/H = M

		if(user.skills.getRating("medical") < SKILL_MEDICAL_PRACTICED && !do_mob(user, M, 1 SECONDS, BUSY_ICON_UNSKILLED, BUSY_ICON_MEDICAL))
			return TRUE

		var/datum/limb/affecting = .

		if(affecting.surgery_open_stage == 0)
			if(!affecting.salve())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been salved.</span>")
				return TRUE
			else
				user.visible_message("<span class='notice'>[user] salves wounds on [M]'s [affecting.display_name].</span>",
				"<span class='notice'>You salve wounds on [M]'s [affecting.display_name].</span>")
				use(1)
		else
			if (H.can_be_operated_on())        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>The [affecting.display_name] is cut open, you'll need more than a bandage!</span>")

/obj/item/stack/medical/bruise_pack/tajaran
	name = "\improper S'rendarr's Hand leaf"
	singular_name = "S'rendarr's Hand leaf"
	desc = "A poultice made of soft leaves that is rubbed on bruises."
	icon = 'icons/obj/items/harvest.dmi'
	icon_state = "shandp"
	heal_brute = 7


/obj/item/stack/medical/ointment/tajaran
	name = "\improper Messa's Tear petals"
	singular_name = "Messa's Tear petal"
	desc = "A poultice made of cold, blue petals that is rubbed on burns."
	icon = 'icons/obj/items/harvest.dmi'
	icon_state = "mtearp"
	heal_burn = 7



/obj/item/stack/medical/advanced
	dir = NORTH
	flags_atom = DIRLOCK

/obj/item/stack/medical/advanced/update_icon()
	if(max_amount < 1 || amount > max_amount)
		return
	var/percentage = round(amount / max_amount) * 100
	switch(percentage)
		if(1 to 20)
			setDir(SOUTH)
		if(21 to 40)
			setDir(EAST)
		if(41 to 60)
			setDir(SOUTHEAST)
		if(61 to 80)
			setDir(WEST)
		if(81 to INFINITY)
			setDir(NORTH)

/obj/item/stack/medical/advanced/bruise_pack
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"
	heal_brute = 12


/obj/item/stack/medical/advanced/bruise_pack/attack(mob/living/carbon/M, mob/user)
	. = ..()
	if(. == TRUE)
		return TRUE


	if (ishuman(M))
		var/mob/living/carbon/human/H = M

		var/heal_amt = heal_brute
		if(user.skills.getRating("medical") < SKILL_MEDICAL_PRACTICED) //untrained marines have a hard time using it
			to_chat(user, "<span class='warning'>You start fumbling with [src].</span>")
			if(!do_mob(user, M, 3 SECONDS, BUSY_ICON_UNSKILLED, BUSY_ICON_MEDICAL))
				return
			heal_amt = heal_brute * 0.5 //non optimal application means less healing

		var/datum/limb/affecting = .

		if(affecting.surgery_open_stage == 0)
			var/bandaged = affecting.bandage()
			var/disinfected = affecting.disinfect()

			if(!(bandaged || disinfected))
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been treated.</span>")
				return TRUE
			else
				for(var/datum/wound/W in affecting.wounds)
					if(W.internal)
						continue
					if(W.current_stage <= W.max_bleeding_stage)
						user.visible_message("<span class='notice'>[user] cleans [W.desc] on [M]'s [affecting.display_name] and seals edges with bioglue.</span>",
						"<span class='notice'>You clean and seal [W.desc] on [M]'s [affecting.display_name].</span>")
					else if (istype(W,/datum/wound/bruise))
						user.visible_message("<span class='notice'>[user] places medicine patch over [W.desc] on [M]'s [affecting.display_name].</span>",
						"<span class='notice'>You place medicine patch over [W.desc] on [M]'s [affecting.display_name].</span>")
					else
						user.visible_message("<span class='notice'>[user] smears some bioglue over [W.desc] on [M]'s [affecting.display_name].</span>",
						"<span class='notice'>You smear some bioglue over [W.desc] on [M]'s [affecting.display_name].</span>")
				if(bandaged)
					affecting.heal_limb_damage(heal_amt, updating_health = TRUE)
				use(1)
		else
			if(H.can_be_operated_on())        //Checks if mob is lying down on table for surgery
				if(do_surgery(H, user, src))
					return
			else
				to_chat(user, "<span class='notice'>The [affecting.display_name] is cut open, you'll need more than a bandage!</span>")


/obj/item/stack/medical/advanced/ointment
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"
	heal_burn = 12


/obj/item/stack/medical/advanced/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	. = ..()
	if(. == TRUE)
		return TRUE

	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		var/heal_amt = heal_burn
		if(user.skills.getRating("medical") < SKILL_MEDICAL_PRACTICED) //untrained marines have a hard time using it
			to_chat(user, "<span class='warning'>You start fumbling with [src].</span>")
			if(!do_mob(user, M, 3 SECONDS, BUSY_ICON_UNSKILLED, BUSY_ICON_MEDICAL))
				return
			heal_amt = heal_burn * 0.5 //non optimal application means less healing

		var/datum/limb/affecting = .

		if(affecting.surgery_open_stage == 0)
			if(!affecting.salve())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been salved.")
				return TRUE
			else
				user.visible_message("<span class='notice'>[user] covers wounds on [M]'s [affecting.display_name] with regenerative membrane.</span>",
				"<span class='notice'>You cover wounds on [M]'s [affecting.display_name] with regenerative membrane.</span>")
				affecting.heal_limb_damage(burn = heal_amt, updating_health = TRUE)
				use(1)
		else
			if(H.can_be_operated_on()) //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>The [affecting.display_name] is cut open, you'll need more than a bandage!</span>")

/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	icon_state = "splint"
	amount = 5
	max_amount = 5


/obj/item/stack/medical/splint/attack(mob/living/carbon/M, mob/user)
	. = ..()
	if(. == TRUE)
		return TRUE

	if(user.action_busy)
		return

	if(ishuman(M))
		var/datum/limb/affecting = .
		var/limb = affecting.display_name

		if(!(affecting.name in list("l_arm", "r_arm", "l_leg", "r_leg", "r_hand", "l_hand", "r_foot", "l_foot", "chest", "groin", "head")))
			to_chat(user, "<span class='warning'>You can't apply a splint there!</span>")
			return

		if(affecting.limb_status & LIMB_DESTROYED)
			to_chat(user, "<span class='warning'>[user == M ? "You don't" : "[M] doesn't"] have \a [limb]!</span>")
			return

		if(affecting.limb_status & LIMB_SPLINTED)
			to_chat(user, "<span class='warning'>[user == M ? "Your" : "[M]'s"] [limb] is already splinted!</span>")
			return

		if(M != user)
			user.visible_message("<span class='warning'>[user] starts to apply [src] to [M]'s [limb].</span>",
			"<span class='notice'>You start to apply [src] to [M]'s [limb], hold still.</span>")
		else
			if((!user.hand && affecting.body_part == ARM_RIGHT) || (user.hand && affecting.body_part == ARM_LEFT))
				to_chat(user, "<span class='warning'>You can't apply a splint to the arm you're using!</span>")
				return
			user.visible_message("<span class='warning'>[user] starts to apply [src] to their [limb].</span>",
			"<span class='notice'>You start to apply [src] to your [limb], hold still.</span>")

		if(affecting.apply_splints(src, user, M)) // Referenced in external organ helpers.
			use(1)
