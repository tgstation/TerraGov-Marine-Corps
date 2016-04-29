/obj/item/weapon/facepaint
	gender = PLURAL
	name = "facepaint"
	desc = "Paint, for your face. Who woulda thought?."
	icon = 'icons/obj/items.dmi'
	icon_state = "camo"
	flags = FPRINT | TABLEPASS
	w_class = 1.0
	var/colour = "green"



/obj/item/weapon/facepaint/green
	name = "green facepaint"
	colour = "green"
	icon_state = "green_cammo"


/obj/item/weapon/facepaint/brown
	name = "brown facepaint"
	colour = "brown"
	icon_state = "brown_cammo"

/obj/item/weapon/facepaint/black
	name = "black facepaint"
	colour = "black"
	icon_state = "black_cammo"

/obj/item/weapon/facepaint/sniper
	name = "Fullbody paint"
	colour = "full"
	icon_state = "full_cammo"


/obj/item/weapon/facepaint/attack(mob/M as mob, mob/user as mob)

	if(!istype(M, /mob))	return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.lip_style)	//if they already have lipstick on
			user << "<span class='notice'>You need to wipe the old paint off with paper first!</span>"
			return
		if(H == user)
			user.visible_message("<span class='notice'>[user] paints their face with\the [src].</span>", \
								 "<span class='notice'>You begin professionally slapping the \the [src] on your face. Perfect!</span>")
			H.lip_style = colour
			H.update_body()
		else
			user.visible_message("<span class='warning'>[user] begins to do [H]'s face with \the [src].</span>", \
								 "<span class='notice'>You begin to apply \the [src].</span>")
			if(do_after(user, 20) && do_after(H, 20, 5, 0))	//user needs to keep their active hand, H does not.
				user.visible_message("<span class='notice'>[user] does [H]'s face with \the [src].</span>", \
									 "<span class='notice'>You apply \the [src].</span>")
				H.lip_style = colour
				H.update_body()
	else
		user << "<span class='notice'>Where are the lips on that?</span>"

//you can wipe off lipstick with paper! see code/modules/paperwork/paper.dm, paper/attack()