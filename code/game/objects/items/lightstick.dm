

//Lightsticks----------
//Blue
/obj/item/lightstick
	name = "blue lightstick"
	desc = "You can stick them in the ground"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lightstick_blue0"
	var/s_color = "blue"

/obj/item/lightstick/Crossed(mob/living/L)
	. = ..()
	if(!anchored || !istype(L) || isxenolarva(L))
		return
	if(L.mob_size != MOB_SIZE_BIG && prob(80))
		return
	visible_message("<span class='danger'>[L] tramples the [src]!</span>")
	playsound(src, 'sound/weapons/genhit.ogg', 25, 1)
	if(isxeno(L) && prob(40))
		qdel(src)
		return
	anchored = FALSE
	icon_state = "lightstick_[s_color][anchored]"
	set_light(0)

	//Removing from turf
/obj/item/lightstick/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!anchored)//If planted
		return

	to_chat(user, "You start pulling out \the [src].")
	if(!do_after(user,20, TRUE, src, BUSY_ICON_GENERIC))
		return

	anchored = FALSE
	user.visible_message("[user.name] removes \the [src] from the ground.","You remove the [src] from the ground.")
	icon_state = "lightstick_[s_color][anchored]"
	set_light(0)
	playsound(user, 'sound/weapons/genhit.ogg', 25, 1)

/obj/item/lightstick/anchored
	icon_state = "lightstick_blue1"
	anchored = TRUE


/obj/item/lightstick/anchored/Initialize(mapload, ...)
	. = ..()
	set_light(2, l_color = LIGHT_COLOR_CYAN)


//Red
/obj/item/lightstick/red
	name = "red lightstick"
	icon_state = "lightstick_red0"
	s_color = "red"

/obj/item/lightstick/red/anchored
	icon_state = "lightstick_red1"
	anchored = TRUE


/obj/item/lightstick/red/anchored/Initialize(mapload, ...)
	. = ..()
	set_light(2, l_color = COLOR_RED)
