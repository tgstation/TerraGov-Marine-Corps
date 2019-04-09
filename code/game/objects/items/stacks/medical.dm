/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items/items.dmi'
	amount = 10
	max_amount = 10
	w_class = 2
	throw_speed = 4
	throw_range = 20
	var/heal_brute = 0
	var/heal_burn = 0

/obj/item/stack/medical/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!istype(M))
		to_chat(user, "<span class='warning'>\The [src] cannot be applied to [M]!</span>")
		return TRUE

	if(!ishuman(user) && !iscyborg(user))
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return TRUE

	var/mob/living/carbon/human/H = M
	var/datum/limb/affecting = H.get_limb(user.zone_selected)

	if(!affecting)
		to_chat(user, "<span class='warning'>[H] has no [parse_zone(user.zone_selected)]!</span>")
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

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "medical gauze"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon_state = "brutepack"
	heal_brute = 1
	origin_tech = "biotech=1"
	stack_id = "bruise pack"

/obj/item/stack/medical/bruise_pack/attack(mob/living/carbon/M as mob, mob/user as mob)
	. = ..()
	if(.)
		return TRUE

	if (ishuman(M))
		var/mob/living/carbon/human/H = M

		if(user.mind && user.mind.cm_skills)
			if(user.mind.cm_skills.medical < SKILL_MEDICAL_PRACTICED)
				if(!do_mob(user, M, 10, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
					return TRUE

		var/datum/limb/affecting = H.get_limb(user.zone_selected)

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
	origin_tech = "biotech=1"
	stack_id = "ointment"

/obj/item/stack/medical/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	. = ..()
	if(.)
		return TRUE

	if (ishuman(M))
		var/mob/living/carbon/human/H = M

		if(user.mind && user.mind.cm_skills)
			if(user.mind.cm_skills.medical < SKILL_MEDICAL_PRACTICED)
				if(!do_mob(user, M, 10, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
					return TRUE

		var/datum/limb/affecting = H.get_limb(user.zone_selected)

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
	stack_id = "Hand leaf"

/obj/item/stack/medical/ointment/tajaran
	name = "\improper Messa's Tear petals"
	singular_name = "Messa's Tear petal"
	desc = "A poultice made of cold, blue petals that is rubbed on burns."
	icon = 'icons/obj/items/harvest.dmi'
	icon_state = "mtearp"
	heal_burn = 7
	stack_id = "Tear petals"


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
	origin_tech = "biotech=1"
	stack_id = "advanced bruise pack"

/obj/item/stack/medical/advanced/bruise_pack/attack(mob/living/carbon/M, mob/user)
	. = ..()
	if(.)
		return TRUE

	if (ishuman(M))
		var/mob/living/carbon/human/H = M

		var/heal_amt = heal_brute
		if(user.mind && user.mind.cm_skills)
			if(user.mind.cm_skills.medical < SKILL_MEDICAL_PRACTICED) //untrained marines have a hard time using it
				to_chat(user, "<span class='warning'>You start fumbling with [src].</span>")
				if(!do_mob(user, M, 30, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
					return
				heal_amt = heal_brute * 0.5 //non optimal application means less healing

		var/datum/limb/affecting = H.get_limb(user.zone_selected)

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
					affecting.heal_damage(heal_amt, 0)
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
	origin_tech = "biotech=1"
	stack_id = "advanced burn kit"

/obj/item/stack/medical/advanced/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	. = ..()
	if(.)
		return TRUE

	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		var/heal_amt = heal_burn
		if(user.mind && user.mind.cm_skills)
			if(user.mind.cm_skills.medical < SKILL_MEDICAL_PRACTICED) //untrained marines have a hard time using it
				to_chat(user, "<span class='warning'>You start fumbling with [src].</span>")
				if(!do_mob(user, M, 30, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
					return
				heal_amt = heal_burn * 0.5 //non optimal application means less healing

		var/datum/limb/affecting = H.get_limb(user.zone_selected)

		if(affecting.surgery_open_stage == 0)
			if(!affecting.salve())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been salved.")
				return TRUE
			else
				user.visible_message("<span class='notice'>[user] covers wounds on [M]'s [affecting.display_name] with regenerative membrane.</span>",
				"<span class='notice'>You cover wounds on [M]'s [affecting.display_name] with regenerative membrane.</span>")
				affecting.heal_damage(0, heal_amt)
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
	stack_id = "splint"

/obj/item/stack/medical/splint/attack(mob/living/carbon/M, mob/user)
	. = ..()
	if(.)
		return TRUE

	if(user.action_busy)
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/limb/affecting = H.get_limb(user.zone_selected)
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
