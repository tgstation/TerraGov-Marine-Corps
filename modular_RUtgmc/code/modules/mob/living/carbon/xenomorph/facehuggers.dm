///Time it takes to impregnate someone
#define IMPREGNATION_TIME 10 SECONDS

/obj/item/clothing/mask/facehugger/Attach(mob/living/carbon/M, can_catch = TRUE)

	set_throwing(FALSE)
	leaping = FALSE
	update_icon()

	if(!istype(M))
		return FALSE

	if(attached)
		return TRUE

	if(M.status_flags & XENO_HOST || M.status_flags & GODMODE || isxeno(M))
		return FALSE

	if(isxeno(loc)) //Being carried? Drop it
		var/mob/living/carbon/xenomorph/X = loc
		X.dropItemToGround(src)
		X.update_icons()

	if(M.in_throw_mode && M.dir != dir && !M.incapacitated() && !M.get_active_held_item() && can_catch)
		var/catch_chance = 50
		if(M.dir == REVERSE_DIR(dir))
			catch_chance += 20
		catch_chance -= M.shock_stage * 0.3
		if(M.get_inactive_held_item())
			catch_chance  -= 25

		if(prob(catch_chance))
			M.visible_message("<span class='notice'>[M] snatches [src] out of the air and [pickweight(list("clobbers" = 30, "kills" = 30, "squashes" = 25, "dunks" = 10, "dribbles" = 5))] it!")
			kill_hugger()
			return TRUE

	var/blocked = null //To determine if the hugger just rips off the protection or can infect.
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(!H.has_limb(HEAD))
			visible_message(span_warning("[src] looks for a face to hug on [H], but finds none!"))
			return FALSE

		if(H.head)
			var/obj/item/clothing/head/D = H.head
			if(istype(D))
				if(D.anti_hug > 0 || D.flags_item & NODROP)
					blocked = D
					D.anti_hug = max(0, --D.anti_hug)
					H.visible_message("<span class='danger'>[src] smashes against [H]'s [D.name], damaging it!")
					return FALSE
				else
					H.update_inv_head()

	if(M.wear_mask)
		var/obj/item/clothing/mask/W = M.wear_mask
		if(istype(W))
			if(istype(W, /obj/item/clothing/mask/facehugger))
				var/obj/item/clothing/mask/facehugger/hugger = W
				if(hugger.stat != DEAD)
					return FALSE

			if(W.anti_hug > 0 || W.flags_item & NODROP)
				if(!blocked)
					blocked = W
				W.anti_hug = max(0, --W.anti_hug)
				M.visible_message(span_danger("[src] smashes against [M]'s [blocked]!"))
				return FALSE

			if(!blocked)
				M.visible_message(span_danger("[src] smashes against [M]'s [W.name] and rips it off!"))
				M.dropItemToGround(W)

	if(blocked)
		M.visible_message(span_danger("[src] smashes against [M]'s [blocked]!"))
		return FALSE

	M.equip_to_slot(src, SLOT_WEAR_MASK)
	return TRUE

/obj/item/clothing/mask/facehugger/equipped(mob/living/user, slot)
	. = ..()
	if(isxenofacehugger(source))
		source.status_flags |= GODMODE
		ADD_TRAIT(source, TRAIT_HANDS_BLOCKED, REF(src))

/obj/item/clothing/mask/facehugger/dropped(mob/user)
	. = ..()
	//If hugger sentient, then we drop player's hugger
	if(isxenofacehugger(source))
		var/mob/living/M = user
		source.status_flags &= ~GODMODE
		REMOVE_TRAIT(source, TRAIT_HANDS_BLOCKED, REF(src))
		source.forceMove(get_turf(M))
		if(source in M.client_mobs_in_contents)
			M.client_mobs_in_contents -= source
		if(sterile || M.status_flags & XENO_HOST)
			source.death()
		kill_hugger()

/obj/item/clothing/mask/facehugger/kill_hugger(melt_timer)
	. = ..()
	if(isxenofacehugger(source))
		qdel(src)

#undef IMPREGNATION_TIME
