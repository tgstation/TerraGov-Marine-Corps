/obj/structure/closet/secure_closet/xeno_cage
	name = "NTC specialised containment cage."
	desc = "A secure container designed to contain dangerous lifeforms such as xenomorphs."
	icon_state = "xeno_cage_locked"
	icon_closed = "xeno_cage"
	icon_locked = "xeno_cage_locked"
	icon_broken = "xeno_cage_damage"
	icon_off = "xeno_cage"
	max_integrity = 500
	icon = 'ntf_modular/icons/obj/structures/xeno_cage.dmi'
	max_mob_size = MOB_SIZE_XENO
	req_access = list(ACCESS_MARINE_PREP) //so marines basically
	drag_delay = 1 //wheels yay
