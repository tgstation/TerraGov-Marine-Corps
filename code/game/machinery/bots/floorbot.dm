



//Floorbot
/obj/machinery/bot/floorbot
	name = "Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "floorbot0"
	density = 0
	anchored = 0
	health = 25
	maxhealth = 25
	//weight = 1.0E7
	var/amount = 10
	var/repairing = 0
	var/improvefloors = 0
	var/eattiles = 0
	var/maketiles = 0
	var/turf/target
	var/turf/oldtarget
	var/oldloc = null
	req_access = list(ACCESS_CIVILIAN_ENGINEERING)
	var/path[] = new()
	var/targetdirection


/obj/machinery/bot/floorbot/New()
	..()
	src.updateicon()
	start_processing()

/obj/machinery/bot/floorbot/turn_on()
	. = ..()
	src.updateicon()
	src.updateUsrDialog()

/obj/machinery/bot/floorbot/turn_off()
	..()
	src.target = null
	src.oldtarget = null
	src.oldloc = null
	src.updateicon()
	src.path = new()
	src.updateUsrDialog()

/obj/machinery/bot/floorbot/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	usr.set_interaction(src)
	interact(user)

/obj/machinery/bot/floorbot/interact(mob/user as mob)
	var/dat
	dat += "<TT><B>Automatic Station Floor Repairer v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];operation=start'>[src.on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel is [src.open ? "opened" : "closed"]<BR>"
	dat += "Tiles left: [src.amount]<BR>"
	dat += "Behvaiour controls are [src.locked ? "locked" : "unlocked"]<BR>"
	if(!src.locked || issilicon(user))
		dat += "Improves floors: <A href='?src=\ref[src];operation=improve'>[src.improvefloors ? "Yes" : "No"]</A><BR>"
		dat += "Finds tiles: <A href='?src=\ref[src];operation=tiles'>[src.eattiles ? "Yes" : "No"]</A><BR>"
		dat += "Make singles pieces of metal into tiles when empty: <A href='?src=\ref[src];operation=make'>[src.maketiles ? "Yes" : "No"]</A><BR>"
		var/bmode
		if (src.targetdirection)
			bmode = dir2text(src.targetdirection)
		else
			bmode = "Disabled"
		dat += "<BR><BR>Bridge Mode : <A href='?src=\ref[src];operation=bridgemode'>[bmode]</A><BR>"

	user << browse("<HEAD><TITLE>Repairbot v1.0 controls</TITLE></HEAD>[dat]", "window=autorepair")
	onclose(user, "autorepair")
	return


/obj/machinery/bot/floorbot/attackby(var/obj/item/W , mob/user as mob)
	if(istype(W, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/T = W
		if(src.amount >= 50)
			return
		var/loaded = min(50-src.amount, T.get_amount())
		T.use(loaded)
		src.amount += loaded
		user << "<span class='notice'>You load [loaded] tiles into the floorbot. He now contains [src.amount] tiles.</span>"
		src.updateicon()
	else if(istype(W, /obj/item/card/id)||istype(W, /obj/item/device/pda))
		if(src.allowed(usr) && !open && !emagged)
			src.locked = !src.locked
			user << "<span class='notice'>You [src.locked ? "lock" : "unlock"] the [src] behaviour controls.</span>"
		else
			if(emagged)
				user << "<span class='warning'>ERROR</span>"
			if(open)
				user << "<span class='warning'>Please close the access panel before locking it.</span>"
			else
				user << "<span class='warning'>Access denied.</span>"
		src.updateUsrDialog()
	else
		..()

/obj/machinery/bot/floorbot/Emag(mob/user as mob)
	..()
	if(open && !locked)
		if(user) user << "<span class='notice'>The [src] buzzes and beeps.</span>"

/obj/machinery/bot/floorbot/Topic(href, href_list)
	if(..())
		return
	usr.set_interaction(src)
	src.add_fingerprint(usr)
	switch(href_list["operation"])
		if("start")
			if (src.on)
				turn_off()
			else
				turn_on()
		if("improve")
			src.improvefloors = !src.improvefloors
			src.updateUsrDialog()
		if("tiles")
			src.eattiles = !src.eattiles
			src.updateUsrDialog()
		if("make")
			src.maketiles = !src.maketiles
			src.updateUsrDialog()
		if("bridgemode")
			switch(src.targetdirection)
				if(null)
					targetdirection = 1
				if(1)
					targetdirection = 2
				if(2)
					targetdirection = 4
				if(4)
					targetdirection = 8
				if(8)
					targetdirection = null
				else
					targetdirection = null
			src.updateUsrDialog()

/obj/machinery/bot/floorbot/process()
	set background = 1

	if(!src.on)
		return
	if(src.repairing)
		return
	var/list/floorbottargets = list()
	if(src.amount <= 0 && ((src.target == null) || !src.target))
		if(src.eattiles)
			for(var/obj/item/stack/tile/plasteel/T in view(7, src))
				if(T != src.oldtarget && !(target in floorbottargets))
					src.oldtarget = T
					src.target = T
					break
		if(src.target == null || !src.target)
			if(src.maketiles)
				if(src.target == null || !src.target)
					for(var/obj/item/stack/sheet/metal/M in view(7, src))
						if(!(M in floorbottargets) && M != src.oldtarget && M.amount == 1 && !(istype(M.loc, /turf/closed)))
							src.oldtarget = M
							src.target = M
							break
		else
			return
	if(prob(5))
		visible_message("[src] makes an excited booping beeping sound!")

	if((!src.target || src.target == null) && emagged < 2)
		if(targetdirection != null)
			/*
			for (var/turf/open/space/D in view(7,src))
				if(!(D in floorbottargets) && D != src.oldtarget)			// Added for bridging mode -- TLE
					if(get_dir(src, D) == targetdirection)
						src.oldtarget = D
						src.target = D
						break
			*/
			var/turf/T = get_step(src, targetdirection)
			if(istype(T, /turf/open/space))
				src.oldtarget = T
				src.target = T
		if(!src.target || src.target == null)
			for (var/turf/open/space/D in view(7,src))
				if(!(D in floorbottargets) && D != src.oldtarget && (D.loc.name != "Space"))
					src.oldtarget = D
					src.target = D
					break
		if((!src.target || src.target == null ) && src.improvefloors)
			for (var/turf/open/floor/F in view(7,src))
				if(!(F in floorbottargets) && F != src.oldtarget && F.icon_state == "Floor1" && !(istype(F, /turf/open/floor/plating)))
					src.oldtarget = F
					src.target = F
					break
		if((!src.target || src.target == null) && src.eattiles)
			for(var/obj/item/stack/tile/plasteel/T in view(7, src))
				if(!(T in floorbottargets) && T != src.oldtarget)
					src.oldtarget = T
					src.target = T
					break

	if((!src.target || src.target == null) && emagged == 2)
		if(!src.target || src.target == null)
			for (var/turf/open/floor/D in view(7,src))
				if(!(D in floorbottargets) && D != src.oldtarget && D.floor_tile)
					src.oldtarget = D
					src.target = D
					break

	if(!src.target || src.target == null)
		if(src.loc != src.oldloc)
			src.oldtarget = null
		return

	if(src.target && (src.target != null) && src.path.len == 0)
		spawn(0)
			if(!istype(src.target, /turf/))
				src.path = AStar(src.loc, src.target.loc, /turf/proc/AdjacentTurfsSpace, /turf/proc/Distance, 0, 30, id=botcard)
			else
				src.path = AStar(src.loc, src.target, /turf/proc/AdjacentTurfsSpace, /turf/proc/Distance, 0, 30, id=botcard)
			if (!src.path) src.path = list()
			if(src.path.len == 0)
				src.oldtarget = src.target
				src.target = null
		return
	if(src.path.len > 0 && src.target && (src.target != null))
		step_to(src, src.path[1])
		src.path -= src.path[1]
	else if(src.path.len == 1)
		step_to(src, target)
		src.path = new()

	if(src.loc == src.target || src.loc == src.target.loc)
		if(istype(src.target, /obj/item/stack/tile/plasteel))
			src.eattile(src.target)
		else if(istype(src.target, /obj/item/stack/sheet/metal))
			src.maketile(src.target)
		else if(istype(src.target, /turf/) && emagged < 2)
			repair(src.target)
		else if(emagged == 2 && istype(src.target,/turf/open/floor))
			var/turf/open/floor/F = src.target
			src.anchored = 1
			src.repairing = 1
			if(prob(90))
				F.break_tile_to_plating()
			else
				F.ReplaceWithLattice()
			visible_message("\red [src] makes an excited booping sound.")
			spawn(50)
				src.amount ++
				src.anchored = 0
				src.repairing = 0
				src.target = null
		src.path = new()
		return

	src.oldloc = src.loc


/obj/machinery/bot/floorbot/proc/repair(var/turf/target)
	if(istype(target, /turf/open/space/))
		if(target.loc.name == "Space")
			return
	else if(!istype(target, /turf/open/floor))
		return
	if(src.amount <= 0)
		return
	src.anchored = 1
	src.icon_state = "floorbot-c"
	if(istype(target, /turf/open/space/))
		visible_message("\red [src] begins to repair the hole")
		var/obj/item/stack/tile/plasteel/T = new /obj/item/stack/tile/plasteel
		src.repairing = 1
		spawn(50)
			T.build(src.loc)
			src.repairing = 0
			src.amount -= 1
			src.updateicon()
			src.anchored = 0
			src.target = null
	else
		visible_message("\red [src] begins to improve the floor.")
		src.repairing = 1
		spawn(50)
			src.loc.icon_state = "floor"
			src.repairing = 0
			src.amount -= 1
			src.updateicon()
			src.anchored = 0
			src.target = null

/obj/machinery/bot/floorbot/proc/eattile(var/obj/item/stack/tile/plasteel/T)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		return
	visible_message("\red [src] begins to collect tiles.")
	src.repairing = 1
	spawn(20)
		if(isnull(T))
			src.target = null
			src.repairing = 0
			return
		if(src.amount + T.get_amount() > 50)
			var/i = 50 - src.amount
			src.amount += i
			T.use(i)
		else
			src.amount += T.get_amount()
			cdel(T)
		src.updateicon()
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/proc/maketile(var/obj/item/stack/sheet/metal/M)
	if(!istype(M, /obj/item/stack/sheet/metal))
		return
	if(M.get_amount() > 1)
		return
	visible_message("\red [src] begins to create tiles.")
	src.repairing = 1
	spawn(20)
		if(isnull(M))
			src.target = null
			src.repairing = 0
			return
		var/obj/item/stack/tile/plasteel/T = new /obj/item/stack/tile/plasteel
		T.amount = 4
		T.loc = M.loc
		cdel(M)
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/proc/updateicon()
	if(src.amount > 0)
		src.icon_state = "floorbot[src.on]"
	else
		src.icon_state = "floorbot[src.on]e"

/obj/machinery/bot/floorbot/explode()
	src.on = 0
	src.visible_message("\red <B>[src] blows apart!</B>", 1)
	var/turf/Tsec = get_turf(src)

	var/obj/item/storage/toolbox/mechanical/N = new /obj/item/storage/toolbox/mechanical(Tsec)
	N.contents = list()

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	while (amount)//Dumps the tiles into the appropriate sized stacks
		if(amount >= 16)
			var/obj/item/stack/tile/plasteel/T = new (Tsec)
			T.amount = 16
			amount -= 16
		else
			var/obj/item/stack/tile/plasteel/T = new (Tsec)
			T.amount = src.amount
			amount = 0

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	cdel(src)
	return


/obj/item/storage/toolbox/mechanical/attackby(var/obj/item/stack/tile/plasteel/T, mob/user as mob)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		..()
		return
	if(src.contents.len >= 1)
		user << "<span class='notice'>They wont fit in as there is already stuff inside.</span>"
		return
	if(user.s_active)
		user.s_active.close(user)
	if (T.use(10))
		var/obj/item/frame/toolbox_tiles/B = new /obj/item/frame/toolbox_tiles
		user.put_in_hands(B)
		user << "<span class='notice'>You add the tiles into the empty toolbox. They protrude from the top.</span>"
		user.temp_drop_inv_item(src)
		cdel(src)
	else
		user << "<span class='warning'>You need 10 floortiles for a floorbot.</span>"
	return
