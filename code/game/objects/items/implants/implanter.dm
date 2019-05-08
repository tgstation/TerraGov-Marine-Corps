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

					src.imp = null
					update()
				else
					to_chat(user, "<span class='notice'> You failed to implant [M].</span>")

	return

/obj/item/implanter/loyalty
	name = "implanter-loyalty"
	imp = /obj/item/implant/loyalty
