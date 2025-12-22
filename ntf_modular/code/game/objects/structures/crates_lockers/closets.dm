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

/obj/item/explosive/grenade/cagenade
	name = "CG1 widerange species capture grenade"
	icon_state = "grenade_sticky_pmc"
	desc = "Unfolds into a xeno containment device when thrown, Gotta catch em all."
	hit_sound = null

/obj/item/explosive/grenade/cagenade/throw_impact(atom/hit_atom, speed, bounce)
	. = ..()
	if(isliving(hit_atom))
		var/mob/living/mafaka = hit_atom
		Move(mafaka.loc) //go beneath people

/obj/item/explosive/grenade/cagenade/prime()
	explosion(loc, weak_impact_range = 1, explosion_cause=src)
	var/obj/structure/closet/secure_closet/xeno_cage/cockcage = new /obj/structure/closet/secure_closet/xeno_cage(loc)
	cockcage.locked = FALSE
	cockcage.opened = TRUE
	update_icon()
	//manual close and move grenade to nullspace
	var/atom/oldloc = loc
	loc = null
	if(oldloc)
		var/area/old_area = get_area(oldloc)
		oldloc.Exited(src, NONE)
		if(old_area)
			old_area.Exited(src, NONE)
	sleep(2)
	cockcage.take_contents()
	playsound(cockcage.loc, cockcage.close_sound, 15, 1)
	cockcage.opened = FALSE
	cockcage.density = TRUE
	cockcage.locked = TRUE
	cockcage.update_icon()
	sleep(2)
	if(length(cockcage.contents))
		playsound(cockcage.loc, 'sound/machines/ping.ogg', 25, 1)
	else
		playsound(cockcage.loc, 'sound/machines/buzz-two.ogg', 25, 1)
	qdel(src)
