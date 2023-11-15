/obj/item/facepaint
	gender = PLURAL
	name = "customization kit"
	desc = "A kit designed for customizing various pieces of armor and clothing. Comes with facepaint!"
	icon = 'icons/obj/items/cosmetics.dmi'
	icon_state = "camo"
	var/colour = "green"
	w_class = WEIGHT_CLASS_TINY
	var/uses = 100

/obj/item/facepaint/green
	name = "green customization kit"
	colour = "green"
	icon_state = "green_camo"


/obj/item/facepaint/brown
	name = "brown customization kit"
	colour = "brown"
	icon_state = "brown_camo"

/obj/item/facepaint/black
	name = "black customization kit"
	colour = "black"
	icon_state = "black_camo"

/obj/item/facepaint/sniper
	name = "Fullbody customization kit"
	desc = "A kit designed for customizing various pieces of armor and clothing. Comes with fullbody paint!"
	colour = "full"
	icon_state = "full_camo"


/obj/item/facepaint/attack(mob/M as mob, mob/user as mob)
	if(!ismob(M)) return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.lip_style)	//if they already have lipstick on
			to_chat(user, span_warning("You need to wipe the old paint off with paper first!"))
			return
		if(H == user)
			paint_face(H, user)
			return 1
		else
			to_chat(user, span_notice("You attempt to apply [src] on [H]..."))
			to_chat(H, span_notice("[user] is trying to apply [src] on your face..."))
			if(tgui_alert(H, "Will you allow [user] to paint your face?", null, list("Sure","No")) == "Sure")
				if( user && loc == user && (user in range(1,H)) ) //Have to be close and hold the thing.
					paint_face(H, user)
					return 1

	to_chat(user, span_warning("Foiled!"))


/obj/item/facepaint/proc/paint_face(mob/living/carbon/human/H, mob/user)
	if(!H || !user) return //In case they're passed as null.
	user.visible_message(span_notice("[user] carefully applies [src] on [H]'s face."), \
						span_notice("You apply [src]."))
	H.lip_style = colour
	H.alpha = max(0, initial(H.alpha) - 1) // decreases your alpha by 1
	H.update_body()
	uses--
	if(!uses)
		user.temporarilyRemoveItemFromInventory(src)
		user.update_inv_l_hand(0)
		user.update_inv_r_hand()
		qdel(src)

//you can wipe off lipstick with paper! see code/modules/paperwork/paper.dm, paper/attack()
