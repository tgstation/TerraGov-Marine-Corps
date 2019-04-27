/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/wallframes.dmi'
	icon_state = "extinguisher"
	pixel_x = -16
	pixel_y = -16
	anchored = TRUE
	density = FALSE
	var/obj/item/tool/extinguisher/has_extinguisher
	var/starter_extinguisher = /obj/item/tool/extinguisher
	var/opened = FALSE

/obj/structure/extinguisher_cabinet/Initialize(mapload, ndir)
	. = ..()
	if(ndir)
		dir = ndir
	switch(dir)
		if(NORTH)
			pixel_y -= 32
		if(SOUTH)
			pixel_y += 32
		if(EAST)
			pixel_x -= 32
		if(WEST)
			pixel_x += 32
	if(starter_extinguisher)
		has_extinguisher = new starter_extinguisher(src)
	update_icon()

/obj/structure/extinguisher_cabinet/attackby(obj/item/O, mob/user)
	if(iscyborg(user))
		return
	if(istype(O, /obj/item/tool/extinguisher))
		if(!has_extinguisher && opened)
			user.drop_held_item()
			contents += O
			has_extinguisher = O
			to_chat(user, "<span class='notice'>You place [O] in [src].</span>")
		else
			opened = !opened
	else
		opened = !opened
	update_icon()


/obj/structure/extinguisher_cabinet/attack_hand(mob/user)
	if(iscyborg(user))
		return

	if(has_extinguisher)
		user.put_in_hands(has_extinguisher)
		to_chat(user, "<span class='notice'>You take [has_extinguisher] from [src].</span>")
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	if(has_extinguisher)
		has_extinguisher.loc = loc
		to_chat(user, "<span class='notice'>You telekinetically remove [has_extinguisher] from [src].</span>")
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_paw(mob/user)
	attack_hand(user)
	return


/obj/structure/extinguisher_cabinet/update_icon()
	overlays.Cut()
	icon_state = "[initial(icon_state)][opened]"

	if(opened && has_extinguisher)
		overlays += "extinguishero_[has_extinguisher.sprite_name]"

/obj/structure/extinguisher_cabinet/mini
	starter_extinguisher = /obj/item/tool/extinguisher/mini

/obj/structure/extinguisher_cabinet/empty
	starter_extinguisher = null