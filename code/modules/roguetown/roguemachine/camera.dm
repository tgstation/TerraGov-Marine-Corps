/obj/structure/roguemachine/camera
	name = "face"
	desc = ""
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "camera-mid"
	density = FALSE
	blade_dulling = DULLING_BASH
	layer = ABOVE_MOB_LAYER
	max_integrity = 0
	var/number = 1
	pixel_y = 10

/obj/structure/roguemachine/camera/right
	icon_state = "camera-r"
	pixel_x = 5
	pixel_y = 5

/obj/structure/roguemachine/camera/left
	icon_state = "camera-l"
	pixel_x = -5
	pixel_y = 5

/obj/structure/roguemachine/camera/obj_break(damage_flag)
	..()
	set_light(0)
	icon_state = "camera-br"
	SSroguemachine.cameras -= src

/obj/structure/roguemachine/camera/Initialize()
	. = ..()
	set_light(1, 1, "#ff0d0d")
	SSroguemachine.cameras += src
	number = SSroguemachine.cameras.len
	name = "face #[number]"

/obj/structure/roguemachine/camera/Destroy()
	set_light(0)
	SSroguemachine.cameras -= src
	. = ..()