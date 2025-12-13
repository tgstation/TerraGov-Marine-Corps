/obj/structure/closet/secure_closet/xeno_cage
	name = "NTC specialised containment cage"
	desc = "A secure container designed to contain dangerous lifeforms such as xenomorphs."
	icon_state = "xeno_cage_locked"
	icon_closed = "xeno_cage"
	icon_locked = "xeno_cage_locked"
	icon_broken = "xeno_cage_damage"
	icon_off = "xeno_cage"
	icon_opened = "xeno_cage_open"
	max_integrity = 500
	icon = 'ntf_modular/icons/obj/structures/xeno_cage.dmi'
	max_mob_size = MOB_SIZE_BIG
	drag_delay = 0 //wheels yay
	anchored = FALSE

/obj/structure/closet/secure_closet/xeno_cage/attack_generic(mob/user, damage_amount, damage_type, armor_type, effects, armor_penetration)
	if(user.loc == src)
		visible_message("[user] bangs uselessly on the inside of [src]!")
		return 0
	. = ..()

/obj/structure/closet/secure_closet/xeno_cage/attackby(obj/item/I, mob/user, params)
	if(user.loc == src)
		visible_message("[user] bangs uselessly on the inside of [src] with [I]!")
		return TRUE
	. = ..()
