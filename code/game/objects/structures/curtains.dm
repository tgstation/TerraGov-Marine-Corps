/obj/structure/curtain
	icon = 'icons/obj/structures/curtain.dmi'
	name = "curtain"
	icon_state = "closed"
	layer = ABOVE_MOB_LAYER
	opacity = TRUE
	density = FALSE

/obj/structure/curtain/open
	icon_state = "open"
	layer = OBJ_LAYER
	opacity = FALSE


/obj/structure/curtain/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	playsound(get_turf(loc), "rustle", 15, 1, 6)
	toggle()

/obj/structure/curtain/proc/toggle()
	opacity = !opacity
	if(opacity)
		icon_state = "closed"
		layer = ABOVE_MOB_LAYER
	else
		icon_state = "open"
		layer = OBJ_LAYER

/obj/structure/curtain/shower
	name = "shower curtain"
	color = "#ACD1E9"
	alpha = 200

/obj/structure/curtain/black
	name = "black curtain"
	color = "#222222"

/obj/structure/curtain/medical
	name = "plastic curtain"
	color = "#B8F5E3"
	alpha = 200

/obj/structure/curtain/open/shower
	name = "shower curtain"
	color = "#ACD1E9"
	alpha = 200

/obj/structure/curtain/open/black
	name = "black curtain"
	color = "#222222"

/obj/structure/curtain/open/medical
	name = "plastic curtain"
	color = "#B8F5E3"
	alpha = 200
