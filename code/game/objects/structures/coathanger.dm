/obj/structure/coatrack
	name = "coat rack"
	desc = "Rack that holds coats."
	icon = 'icons/obj/structures/misc.dmi'
	icon_state = "coatrack0"
	var/obj/item/clothing/suit/coat
	var/list/allowed = list(/obj/item/clothing/suit/storage/labcoat, /obj/item/clothing/suit/storage/det_suit, /obj/item/clothing/suit/bomber)

/obj/structure/coatrack/attack_hand(mob/user as mob)
	if(coat)
		user.visible_message("[user] takes [coat] off \the [src].", "You take [coat] off the \the [src]")
		if(!user.put_in_active_hand(coat))
			coat.loc = get_turf(user)
		coat = null
		update_icon()

/obj/structure/coatrack/attackby(obj/item/W as obj, mob/user as mob)
	var/can_hang = 0
	for (var/T in allowed)
		if(istype(W,T))
			can_hang = 1
	if (can_hang && !coat)
		user.visible_message("[user] hangs [W] on \the [src].", "You hang [W] on the \the [src]")
		coat = W
		user.drop_held_item(src)
		coat.forceMove(src)
		update_icon()
	else
		to_chat(user, "<span class='notice'>You cannot hang [W] on [src]</span>")
		return ..()

/obj/structure/coatrack/Crossed(atom/movable/AM)
	..()
	if(!coat)
		for(var/T in allowed)
			if(istype(AM,T))
				src.visible_message("[AM] lands on \the [src].")
				coat = AM
				coat.forceMove(src)
				update_icon()
				break


/obj/structure/coatrack/update_icon()
	overlays.Cut()
	if(istype(coat, /obj/item/clothing/suit/storage/labcoat))
		overlays += image(icon, icon_state = "coat_lab")
	if(istype(coat, /obj/item/clothing/suit/storage/labcoat/cmo))
		overlays += image(icon, icon_state = "coat_cmo")
	if(istype(coat, /obj/item/clothing/suit/storage/det_suit))
		overlays += image(icon, icon_state = "coat_det")