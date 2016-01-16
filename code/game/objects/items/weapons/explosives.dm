/obj/item/weapon/plastique/attack_self(mob/user as mob)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(newtime < 10)
		newtime = 10
	if(newtime > 60)
		newtime = 60
	timer = newtime
	user << "Timer set for [timer] seconds."

/obj/item/weapon/plastique/afterattack(atom/target as obj|turf, mob/user as mob, flag)
	if (!flag)
		return
	if (istype(target, /turf/unsimulated) || istype(target, /turf/simulated/shuttle) || istype(target, /obj/item/weapon/storage/) || istype(target, /obj/item/clothing/under) || istype(target,/obj/item))
		return
	if (istype(target, /obj/structure/ladder) || istype(target, /turf/simulated/floor) || istype(target, /obj/machinery/telecomms) || istype(target, /obj/machinery/computer/shuttle_control) || istype(target, /obj/effect/forcefield) || istype(target, /obj/machinery/door/poddoor/four_tile_hor/secure) || istype(target, /obj/machinery/door/poddoor/four_tile_ver/secure)  || istype(target, /obj/machinery/door/poddoor/two_tile_hor/secure) || istype(target, /obj/machinery/door/poddoor/two_tile_ver/secure))
		return

	user << "Planting explosives..."
	user.visible_message("\red [user.name] is trying to plant some kind of explosive on [target.name]!")

	if(do_after(user, 50) && in_range(user, target))
		user.drop_item()
		target = target
		loc = null
		var/location
		if (isturf(target)) location = target
		if (isobj(target)) location = target.loc

		if (ismob(target))
			user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] successfully planted [name] on [target:real_name] ([target:ckey])</font>"
			message_admins("[key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) planted [src.name] on [key_name(target)](<A HREF='?_src_=holder;adminmoreinfo=\ref[target]'>?</A>) with [timer] second fuse",0,1)
			log_game("[key_name(user)] planted [src.name] on [key_name(target)] with [timer] second fuse")
		else
			message_admins("[key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) planted [src.name] on [target.name] at ([target.x],[target.y],[target.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>JMP</a>) with [timer] second fuse",0,1)
			log_game("[key_name(user)] planted [src.name] on [target.name] at ([target.x],[target.y],[target.z]) with [timer] second fuse")

		target.overlays += image('icons/obj/assemblies.dmi', "plastic-explosive2")
		user << "Bomb has been planted. Timer counting down from [timer]."
		spawn(timer*10)
			if(target)
				explosion(location, -1, -1, 2, 3)
				if (istype(target, /turf/simulated/wall)) target:dismantle_wall(1)
				else target.ex_act(1)
				if (isobj(target))
					if (target)
						del(target)
				if (src)
					del(src)

/obj/item/weapon/plastique/attack(mob/M as mob, mob/user as mob, def_zone)
	return