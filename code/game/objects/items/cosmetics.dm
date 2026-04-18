/obj/item/facepaint
	gender = PLURAL
	name = "customization kit"
	desc = "A kit designed for customizing various pieces of armor and clothing. Comes with facepaint!"
	icon = 'icons/obj/items/cosmetics.dmi'
	icon_state = "camo"
	var/paint_color = "green"
	w_class = WEIGHT_CLASS_TINY
	var/uses = 100

/obj/item/facepaint/green
	name = "Green customization kit"
	paint_color = "green"
	icon_state = "green_camo"


/obj/item/facepaint/brown
	name = "Brown customization kit"
	paint_color = "brown"
	icon_state = "brown_camo"

/obj/item/facepaint/black
	name = "Black customization kit"
	desc = "A kit designed for customizing various pieces of armor and clothing. Comes with eye black!"
	paint_color = "black"
	icon_state = "black_camo"

/obj/item/facepaint/sniper
	name = "Fullbody customization kit"
	paint_color = "full"
	icon_state = "full_camo"


/obj/item/facepaint/attack(mob/M, mob/user)
	. = ..()
	if(!ishuman(M))
		to_chat(user, span_warning("This doesn't have a human face..."))
		return

	var/mob/living/carbon/human/attacked_human = M
	if(attacked_human.makeup_style)	//if they already have lipstick on
		to_chat(user, span_warning("You need to wipe the old paint off with paper first!"))
		return

	if(attacked_human != user && attacked_human.client)
		user.visible_message(span_notice("[user] is trying to apply [src] on [attacked_human]'s face..."), span_notice("You attempt to apply [src] on [attacked_human]..."))
		if(tgui_alert(attacked_human, "Apply makeup", "Will you allow [user] to paint your face?", list("Yes","No")) != "Yes")
			return
		if(!user || loc != user || !user.Adjacent(attacked_human))
			return

	paint_face(attacked_human, user)

///Handles applying the makeup
/obj/item/facepaint/proc/paint_face(mob/living/carbon/human/H, mob/user)
	if(!H || !user)
		return //In case they're passed as null.
	user.visible_message(span_notice("[user] carefully applies [src] on [H]'s face."), \
						span_notice("You apply [src]."))
	H.makeup_style = paint_color
	H.alpha = max(0, initial(H.alpha) - 1) // decreases your alpha by 1
	H.update_body()
	uses--
	if(!uses)
		user.temporarilyRemoveItemFromInventory(src)
		user.update_inv_l_hand(0)
		user.update_inv_r_hand()
		qdel(src)
