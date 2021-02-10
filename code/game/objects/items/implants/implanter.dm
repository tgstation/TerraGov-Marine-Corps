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
		imp = new imp(src)
		update_icon()

/obj/item/implanter/update_icon_state()
	. = ..()
	icon_state = "implanter[imp?"1":"0"]"

/obj/item/implanter/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, "it contains [imp ? "a [imp.name]" : "no implant"]!")

/obj/item/implanter/attack(mob/target, mob/user)
	. = ..()
	if(!ishuman(target))
		return FALSE
	if(!imp)
		to_chat(user, "<span class='warning'> There is no implant in the [src]!</span>")
		return FALSE
	user.visible_message("<span class='warning'>[user] is attemping to implant [target].</span>", "<span class='notice'>You're attemping to implant [target].</span>")

	if(!do_after(user, 5 SECONDS, TRUE, target, BUSY_ICON_GENERIC) || !imp)
		to_chat(user, "<span class='notice'> You failed to implant [target].</span>")
		return

	if(imp.try_implant(target, user))
		target.visible_message("<span class='warning'>[target] has been implanted by [user].</span>")
		log_game(user, target, "implanted", src)
		imp = null
		update_icon()
		return
	to_chat(user, "<span class='notice'> You fail to implant [target].</span>")

/obj/item/implanter/neurostim
	name = "neurostim implanter"
	imp = /obj/item/implant/neurostim

/obj/item/implanter/chem
	name = "chem implant implanter"
	imp = /obj/item/implant/chem
