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

/obj/item/stack/medical/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!istype(M))
		to_chat(user, span_warning("\The [src] cannot be applied to [M]!"))
		return TRUE

	if(M.status_flags & INCORPOREAL || user.status_flags & INCORPOREAL) //Incorporeal beings cannot attack or be attacked
		return TRUE

	if(!ishuman(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return TRUE

	var/mob/living/carbon/human/H = M
	var/datum/limb/affecting = user.client.prefs.toggles_gameplay & RADIAL_MEDICAL ? radial_medical(H, user) : H.get_limb(user.zone_selected)

	if(!affecting)
		return TRUE

	if(affecting.body_part == HEAD)
		if(H.head && istype(H.head,/obj/item/clothing/head/helmet/space))
			to_chat(user, span_warning("You can't apply [src] through [H.head]!"))
			return TRUE
	else
		if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/space))
			to_chat(user, span_warning("You can't apply [src] through [H.wear_suit]!"))
			return TRUE

	if(affecting.limb_status & LIMB_ROBOT)
		to_chat(user, span_warning("This isn't useful at all on a robotic limb."))
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
				to_chat(user, span_warning("The wounds on [M]'s [affecting.display_name] have already been bandaged."))
				return TRUE
			else
				for (var/datum/wound/W in affecting.wounds)
					if (W.internal)
						continue
					if (W.current_stage <= W.max_bleeding_stage)
						user.visible_message(span_notice("[user] bandages [W.desc] on [M]'s [affecting.display_name]."),
						span_notice("You bandage [W.desc] on [M]'s [affecting.display_name].") )
					else if (istype(W,/datum/wound/bruise))
						user.visible_message(span_notice("[user] places bruise patch over [W.desc] on [M]'s [affecting.display_name]."),
						span_notice("You place bruise patch over [W.desc] on [M]'s [affecting.display_name].") )
					else
						user.visible_message(span_notice("[user] places bandaid over [W.desc] on [M]'s [affecting.display_name]."),
						span_notice("You place bandaid over [W.desc] on [M]'s [affecting.display_name].") )
				use(1)
		else
			if(H.can_be_operated_on()) //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, span_notice("The [affecting.display_name] is cut open, you'll need more than a bandage!"))

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
				to_chat(user, span_warning("The wounds on [M]'s [affecting.display_name] have already been salved."))
				return TRUE
			else
				user.visible_message(span_notice("[user] salves wounds on [M]'s [affecting.display_name]."),
				span_notice("You salve wounds on [M]'s [affecting.display_name]."))
				use(1)
		else
			if (H.can_be_operated_on())        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				to_chat(user, span_notice("The [affecting.display_name] is cut open, you'll need more than a bandage!"))

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


/obj/item/stack/medical/bruise_pack/sectoid
	name = "\improper healing resin pack"
	singular_name = "healing resin pack"
	desc = "A strange tool filled with a sticky, alien resin. It seems it is meant for covering wounds."
	icon = 'icons/obj/items/surgery_tools.dmi'
	icon_state = "predator_fixovein"
	heal_brute = 20
	heal_burn = 20


/obj/item/stack/medical/advanced
	dir = NORTH
	flags_atom = DIRLOCK

/obj/item/stack/medical/advanced/update_icon_state()
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
			to_chat(user, span_warning("You start fumbling with [src]."))
			if(!do_mob(user, M, 3 SECONDS, BUSY_ICON_UNSKILLED, BUSY_ICON_MEDICAL))
				return
			heal_amt = heal_brute * 0.5 //non optimal application means less healing

		var/datum/limb/affecting = .

		if(affecting.surgery_open_stage == 0)
			var/bandaged = affecting.bandage()
			var/disinfected = affecting.disinfect()

			if(!(bandaged || disinfected))
				to_chat(user, span_warning("The wounds on [M]'s [affecting.display_name] have already been treated."))
				return TRUE
			else
				for(var/datum/wound/W in affecting.wounds)
					if(W.internal)
						continue
					if(W.current_stage <= W.max_bleeding_stage)
						user.visible_message(span_notice("[user] cleans [W.desc] on [M]'s [affecting.display_name] and seals edges with bioglue."),
						span_notice("You clean and seal [W.desc] on [M]'s [affecting.display_name]."))
					else if (istype(W,/datum/wound/bruise))
						user.visible_message(span_notice("[user] places medicine patch over [W.desc] on [M]'s [affecting.display_name]."),
						span_notice("You place medicine patch over [W.desc] on [M]'s [affecting.display_name]."))
					else
						user.visible_message(span_notice("[user] smears some bioglue over [W.desc] on [M]'s [affecting.display_name]."),
						span_notice("You smear some bioglue over [W.desc] on [M]'s [affecting.display_name]."))
				if(bandaged)
					affecting.heal_limb_damage(heal_amt, updating_health = TRUE)
				use(1)
		else
			if(H.can_be_operated_on())        //Checks if mob is lying down on table for surgery
				if(do_surgery(H, user, src))
					return
			else
				to_chat(user, span_notice("The [affecting.display_name] is cut open, you'll need more than a bandage!"))


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
			to_chat(user, span_warning("You start fumbling with [src]."))
			if(!do_mob(user, M, 3 SECONDS, BUSY_ICON_UNSKILLED, BUSY_ICON_MEDICAL))
				return
			heal_amt = heal_burn * 0.5 //non optimal application means less healing

		var/datum/limb/affecting = .

		if(affecting.surgery_open_stage == 0)
			if(!affecting.salve())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been salved.")
				return TRUE
			else
				user.visible_message(span_notice("[user] covers wounds on [M]'s [affecting.display_name] with regenerative membrane."),
				span_notice("You cover wounds on [M]'s [affecting.display_name] with regenerative membrane."))
				affecting.heal_limb_damage(burn = heal_amt, updating_health = TRUE)
				use(1)
		else
			if(H.can_be_operated_on()) //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, span_notice("The [affecting.display_name] is cut open, you'll need more than a bandage!"))

/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	icon_state = "splint"
	amount = 5
	max_amount = 5
	///How much splint health per medical skill is applied
	var/applied_splint_health = 15


/obj/item/stack/medical/splint/attack(mob/living/carbon/M, mob/user)
	. = ..()
	if(. == TRUE)
		return TRUE

	if(user.do_actions)
		return

	if(ishuman(M))
		var/datum/limb/affecting = .
		var/limb = affecting.display_name

		if(!(affecting.name in list("l_arm", "r_arm", "l_leg", "r_leg", "r_hand", "l_hand", "r_foot", "l_foot", "chest", "groin", "head")))
			to_chat(user, span_warning("You can't apply a splint there!"))
			return

		if(affecting.limb_status & LIMB_DESTROYED)
			to_chat(user, span_warning("[user == M ? "You don't" : "[M] doesn't"] have \a [limb]!"))
			return

		if(affecting.limb_status & LIMB_SPLINTED)
			to_chat(user, span_warning("[user == M ? "Your" : "[M]'s"] [limb] is already splinted!"))
			return

		if(M != user)
			user.visible_message(span_warning("[user] starts to apply [src] to [M]'s [limb]."),
			span_notice("You start to apply [src] to [M]'s [limb], hold still."))
		else
			if((!user.hand && affecting.body_part == ARM_RIGHT) || (user.hand && affecting.body_part == ARM_LEFT))
				to_chat(user, span_warning("You can't apply a splint to the arm you're using!"))
				return
			user.visible_message(span_warning("[user] starts to apply [src] to [user.p_their()] [limb]."),
			span_notice("You start to apply [src] to your [limb], hold still."))

		if(affecting.apply_splints(src, user == M ? (applied_splint_health*max(user.skills.getRating("medical") - 1, 0)) : applied_splint_health*user.skills.getRating("medical"), user, M)) // Referenced in external organ helpers.
			use(1)
