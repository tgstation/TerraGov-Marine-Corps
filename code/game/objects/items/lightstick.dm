

//Lightsticks----------
//Blue
/obj/item/lightstick
	name = "blue lightstick"
	desc = "You can stick them in the ground"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lightstick_blue0"
	l_color = "#47A3FF" //Blue
	var/s_color = "blue"

	Crossed(var/mob/living/O)
		if(anchored && prob(20))
			if(!istype(O,/mob/living/carbon/Xenomorph/Larva))
				visible_message("<span class='danger'>[O] tramples the [src]!</span>")
				playsound(src, 'sound/weapons/Genhit.ogg', 25, 1)
				if(istype(O,/mob/living/carbon/Xenomorph))
					if(prob(40))
						cdel(src)
					else
						anchored = 0
						icon_state = "lightstick_[s_color][anchored]"
						SetLuminosity(0)
						pixel_x = 0
						pixel_y = 0
				else
					anchored = 0
					icon_state = "lightstick_[s_color][anchored]"
					SetLuminosity(0)
					pixel_x = 0
					pixel_y = 0

	//Removing from turf
	attack_hand(mob/user)
		..()
		if(!anchored)//If planted
			return

		user << "You start pulling out \the [src]."
		if(!do_after(user,20, TRUE, 5, BUSY_ICON_BUILD))
			return

		anchored = 0
		user.visible_message("[user.name] removes \the [src] from the ground.","You remove the [src] from the ground.")
		icon_state = "lightstick_[s_color][anchored]"
		SetLuminosity(0)
		pixel_x = 0
		pixel_y = 0
		playsound(user, 'sound/weapons/Genhit.ogg', 25, 1)

	//Remove lightsource
	Dispose()
		SetLuminosity(0)
		. = ..()

//Red
/obj/item/lightstick/red
	name = "red lightstick"
	l_color = "#CC3300"
	icon_state = "lightstick_red0"
	s_color = "red"
