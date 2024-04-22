/obj/structure/fluff/grindwheel
	name = "grind wheel"
	desc = ""
	icon = 'icons/roguetown/misc/forge.dmi'
	icon_state = "grindwheel"
	density = TRUE
	anchored = FALSE
	blade_dulling = DULLING_BASH
	max_integrity = 400

/obj/structure/fluff/grindwheel/attackby(obj/item/W, mob/living/user, params)
	if(W.max_blade_int)
		playsound(loc,'sound/foley/grindblade.ogg', 100, FALSE)
		if(do_after(user, 41, target = src))
			W.add_bintegrity(999)
//				W.degrade_bintegrity(1)
		return
	..()
