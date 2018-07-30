/obj/item/facepaint
	gender = PLURAL
	name = "facepaint"
	desc = "Paint, for your face. Who woulda thought?."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "camo"
	var/colour = "green"
	w_class = 1.0
	var/uses = 10

/obj/item/facepaint/green
	name = "green facepaint"
	colour = "green"
	icon_state = "green_cammo"


/obj/item/facepaint/brown
	name = "brown facepaint"
	colour = "brown"
	icon_state = "brown_cammo"

/obj/item/facepaint/black
	name = "black facepaint"
	colour = "black"
	icon_state = "black_cammo"

/obj/item/facepaint/sniper
	name = "Fullbody paint"
	colour = "full"
	icon_state = "full_cammo"


/obj/item/facepaint/attack(mob/M as mob, mob/user as mob)
	if(!ismob(M)) return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.lip_style)	//if they already have lipstick on
			user << "<span class='warning'>You need to wipe the old paint off with paper first!</span>"
			return
		if(H == user)
			paint_face(H, user)
			return 1
		else
			user << "<span class='notice'>You attempt to apply [src] on [H]...</span>"
			H << "<span class='notice'>[user] is trying to apply [src] on your face...</span>"
			if(alert(H,"Will you allow [user] to paint your face?",,"Sure","No") == "Sure")
				if( user && loc == user && (user in range(1,H)) ) //Have to be close and hold the thing.
					paint_face(H, user)
					return 1

	user << "<span class='warning'>Foiled!</span>"


/obj/item/facepaint/proc/paint_face(var/mob/living/carbon/human/H, var/mob/user)
	if(!H || !user) return //In case they're passed as null.
	user.visible_message("<span class='notice'>[user] carefully applies [src] on [H]'s face.</span>", \
						 "<span class='notice'>You apply [src].</span>")
	H.lip_style = colour
	H.update_body()
	uses--
	if(!uses)
		user.temp_drop_inv_item(src)
		user.update_inv_l_hand(0)
		user.update_inv_r_hand()
		cdel(src)

//you can wipe off lipstick with paper! see code/modules/paperwork/paper.dm, paper/attack()