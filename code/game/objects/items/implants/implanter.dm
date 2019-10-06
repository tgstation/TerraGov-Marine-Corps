/obj/item/implanter
	name = "implanter"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
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

		if ((M == user || do_after(user, 50, TRUE, M, BUSY_ICON_GENERIC)) && imp)
			if(imp.implanted(M, user))
				M.visible_message("<span class='warning'>[M] has been implanted by [user].</span>")

				log_combat(user, M, "implanted", src)
				message_admins("[ADMIN_TPMONTY(usr)] implanted [ADMIN_TPMONTY(M)] with [src.name].")

				imp.loc = M
				imp.imp_in = M
				imp.implanted = 1
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					var/datum/limb/affected = H.get_limb(user.zone_selected)
					affected.implants += imp
					imp.part = affected

				imp = null
				update()
			else
				to_chat(user, "<span class='notice'> You failed to implant [M].</span>")

	return


/obj/item/implanter/codex
	name = "implanter (codex)"
	imp = /obj/item/implant/codex


/obj/item/implanter/neurostim
	name = "implanter"
	imp = /obj/item/implant/neurostim
