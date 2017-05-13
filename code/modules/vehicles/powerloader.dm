


/obj/vehicle/powerloader
	name = "\improper Power Loader"
	icon = 'icons/obj/vehicles.dmi'
	desc = "Autonomous Power Loader Unit. The workhorse of the exosuit world."
	icon_state = "powerloader"
	layer = OBJ_LAYER
	anchored = 1
	density = 1
	move_delay = 6
	buckling_y = 6
	health = 200
	maxhealth = 200


/obj/vehicle/powerloader/New()
	..()
	cell = new /obj/item/weapon/cell/apc

/obj/vehicle/powerloader/relaymove(mob/user, direction)
	. = ..()
	if(.)
		pick(playsound(loc, 'sound/mecha/powerloader_step.ogg', 40, 1), playsound(loc, 'sound/mecha/powerloader_step2.ogg', 40, 1))



/obj/vehicle/powerloader/afterbuckle(mob/M)
	. = ..()
	overlays.Cut()
	if(.)
		overlays += image(icon_state= "powerloader_overlay", layer = MOB_LAYER + 0.1)

/obj/vehicle/powerloader/handle_rotation()
	if(dir == NORTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER


/obj/vehicle/powerloader/explode()
	new /obj/structure/powerloader_wreckage(loc)
	..()


/obj/item/weapon/powerloader_clamp
	name = "\improper Power Loader Clamp"


/obj/structure/powerloader_wreckage
	name = "\improper Power Loader wreckage"
	desc = "Remains of some unfortunate Power Loader. Completely unrepairable."
	icon = 'icons/mecha/mecha.dmi'
	icon_state = "ripley-broken-old"
	density = 1
	anchored = 0
	opacity = 0