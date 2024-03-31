
/obj/item/rope
	name = "rope"
	desc = ""
	gender = PLURAL
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "rope"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_WRISTS
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 1
	throw_range = 3
	breakouttime = 5 SECONDS
	slipouttime = 1 MINUTES
	var/cuffsound = 'sound/blank.ogg'
	possible_item_intents = list(/datum/intent/tie)
	firefuel = 5 MINUTES
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'

/datum/intent/tie
	name = "tie"
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	canparry = FALSE
	misscost = 0

/obj/item/rope/Destroy()
	if(iscarbon(loc))
		var/mob/living/carbon/M = loc
		if(M.handcuffed == src)
			M.handcuffed = null
			M.update_handcuffed()
			if(M.buckled && M.buckled.buckle_requires_restraints)
				M.buckled.unbuckle_mob(M)
		if(M.legcuffed == src)
			M.legcuffed = null
			M.update_inv_legcuffed()
	return ..()

/obj/item/rope/attack(mob/living/carbon/C, mob/living/user)
	if(user.used_intent.type != /datum/intent/tie)
		..()
		return

	if(!istype(C))
		return

	if(user.aimheight > 4)
		if(!C.handcuffed)
			if(C.get_num_arms(TRUE))
				C.visible_message("<span class='warning'>[user] is trying to tie [C]'s arms with [src.name]!</span>", \
									"<span class='userdanger'>[user] is trying to tie my arms with [src.name]!</span>")

				playsound(loc, cuffsound, 100, TRUE, -2)
				if(do_mob(user, C, 60) && C.get_num_arms(FALSE))
					apply_cuffs(C, user)
					C.visible_message("<span class='warning'>[user] ties [C] with [src.name].</span>", \
										"<span class='danger'>[user] ties me up with [src.name].</span>")
					SSblackbox.record_feedback("tally", "handcuffs", 1, type)

					log_combat(user, C, "handcuffed")
				else
					to_chat(user, "<span class='warning'>I fail to tie up [C]!</span>")
			else
				to_chat(user, "<span class='warning'>[C] has no arms to tie up.</span>")

	if(user.aimheight <= 4)
		if(!C.legcuffed)
			if(C.get_num_legs(TRUE) == 2)
				C.visible_message("<span class='warning'>[user] is trying to tie [C]'s legs with [src.name]!</span>", \
									"<span class='userdanger'>[user] is trying to tie my legs with [src.name]!</span>")

				playsound(loc, cuffsound, 30, TRUE, -2)
				if(do_mob(user, C, 60) && (C.get_num_legs(FALSE) < 2))
					apply_cuffs(C, user)
					C.visible_message("<span class='warning'>[user] ties [C]'s legs with [src.name].</span>", \
										"<span class='danger'>[user] ties my legs with [src.name].</span>")
					SSblackbox.record_feedback("tally", "legcuffs", 1, type)

					log_combat(user, C, "legcuffed", TRUE)
				else
					to_chat(user, "<span class='warning'>I fail to tie up [C]!</span>")
			else
				to_chat(user, "<span class='warning'>[C] is missing two or one legs.</span>")

/obj/item/rope/proc/apply_cuffs(mob/living/carbon/target, mob/user, leg = FALSE)
	if(!leg)
		if(target.handcuffed)
			return

		if(!user.temporarilyRemoveItemFromInventory(src) )
			return

		var/obj/item/cuffs = src

		cuffs.forceMove(target)
		target.handcuffed = cuffs

		target.update_handcuffed()
		return
	else
		if(target.legcuffed)
			return

		if(!user.temporarilyRemoveItemFromInventory(src) )
			return

		var/obj/item/cuffs = src

		cuffs.forceMove(target)
		target.legcuffed = cuffs

		target.update_inv_legcuffed()
		return


/datum/intent/whip
	name = "strike"
	blade_class = BCLASS_BLUNT
	attack_verb = list("whips", "strikes", "smacks")
	penfactor = 40
	chargetime = 5

/obj/item/rope/chain
	name = "chain"
	desc = ""
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "chain"
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_WRISTS
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 1
	throw_range = 3
	breakouttime = 1 MINUTES
	slipouttime = 5 MINUTES
	cuffsound = 'sound/blank.ogg'
	possible_item_intents = list(/datum/intent/tie, /datum/intent/whip)
	firefuel = null
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'