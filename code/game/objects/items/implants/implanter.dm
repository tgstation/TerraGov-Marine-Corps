/obj/item/implanter
	name = "implanter"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = 1
	var/obj/item/implant/imp = null

/obj/item/implanter/Initialize(mapload, ...)
	. = ..()
	if(imp)
		imp = new imp()
		update()

/obj/item/implanter/proc/update()
	if (src.imp)
		src.icon_state = "implanter1"
	else
		src.icon_state = "implanter0"
	return


/obj/item/implanter/attack(mob/M as mob, mob/user as mob)
	if (!ishuman(M) && !ismonkey(M))
		return
	if (user && src.imp)
		user.visible_message("<span class='warning'>[user] is attemping to implant [M].</span>", "<span class='notice'>You're attemping to implant [M].</span>")

		var/turf/T1 = get_turf(M)
		if (T1 && ((M == user) || do_after(user, 50, TRUE, 5, BUSY_ICON_GENERIC)))
			if(user && M && (get_turf(M) == T1) && src && src.imp)
				if(src.imp.implanted(M, user))
					M.visible_message("<span class='warning'>[M] has been implanted by [user].</span>")

					log_combat(user, M, "implanted", src)
					message_admins("[ADMIN_TPMONTY(usr)] implanted [ADMIN_TPMONTY(M)] with [src.name].")

					src.imp.loc = M
					src.imp.imp_in = M
					src.imp.implanted = 1
					if (ishuman(M))
						var/mob/living/carbon/human/H = M
						var/datum/limb/affected = H.get_limb(user.zone_selected)
						affected.implants += src.imp
						imp.part = affected

						M.sec_hud_set_implants()

					src.imp = null
					update()
				else
					to_chat(user, "<span class='notice'> You failed to implant [M].</span>")

	return

/obj/item/implanter/freedom
	name = "implanter-freedom"
	imp = /obj/item/implant/freedom

/obj/item/implanter/loyalty
	name = "implanter-loyalty"
	imp = /obj/item/implant/loyalty

/obj/item/implanter/explosive
	name = "implanter (E)"
	imp = /obj/item/implant/explosive

/obj/item/implanter/adrenalin
	name = "implanter-adrenalin"
	imp = /obj/item/implant/adrenalin

/obj/item/implanter/codex
	name = "implanter (codex)"
	imp = /obj/item/implant/codex

/obj/item/implanter/compressed
	name = "implanter (C)"
	icon_state = "cimplanter1"
	imp = /obj/item/implant/compressed

/obj/item/implanter/compressed/update()
	if (imp)
		var/obj/item/implant/compressed/c = imp
		if(!c.scanned)
			icon_state = "cimplanter1"
		else
			icon_state = "cimplanter2"
	else
		icon_state = "cimplanter0"
	return

/obj/item/implanter/compressed/attack(mob/M as mob, mob/user as mob)
	var/obj/item/implant/compressed/c = imp
	if (!c)	return
	if (c.scanned == null)
		to_chat(user, "Please scan an object with the implanter first.")
		return
	..()

/obj/item/implanter/compressed/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity)
		return
	if(istype(A,/obj/item) && imp)
		var/obj/item/implant/compressed/c = imp
		if (c.scanned)
			to_chat(user, "<span class='warning'>Something is already scanned inside the implant!</span>")
			return
		c.scanned = A
		if(istype(A.loc,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = A.loc
			H.dropItemToGround(A)
		else if(istype(A.loc,/obj/item/storage))
			var/obj/item/storage/S = A.loc
			S.remove_from_storage(A)
		update()
