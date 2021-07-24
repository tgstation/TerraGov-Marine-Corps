



//Floorbot
/obj/machinery/bot/floorbot
	name = "Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "floorbot0"
	density = FALSE
	anchored = FALSE
	max_integrity = 25
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


/obj/machinery/bot/floorbot/Initialize()
	. = ..()
	updateicon()
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

/obj/machinery/bot/floorbot/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat
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

	var/datum/browser/popup = new(user, "floorbot", "<div align='center'>[src]</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/bot/floorbot/attackby(obj/item/W , mob/user as mob)
	. = ..()

	if(istype(W, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/T = W
		if(amount >= 50)
			return
		var/loaded = min(50 - amount, T.get_amount())
		T.use(loaded)
		amount += loaded
		to_chat(user, span_notice("You load [loaded] tiles into the floorbot. He now contains [amount] tiles."))
		updateicon()

	else if(istype(W, /obj/item/card/id))
		if(allowed(user) && !open)
			locked = !locked
			to_chat(user, span_notice("You [locked ? "lock" : "unlock"] \the [src] behaviour controls."))
		else if(open)
			to_chat(user, span_warning("Please close the access panel before locking it."))
		else
			to_chat(user, span_warning("Access denied."))
		updateUsrDialog()


/obj/machinery/bot/floorbot/Topic(href, href_list)
	. = ..()
	if(.)
		return

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

	updateUsrDialog()


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
						if(!(M in floorbottargets) && M != src.oldtarget && M.amount == 1 && !isclosedturf(M.loc))
							src.oldtarget = M
							src.target = M
							break
		else
			return
	if(prob(5))
		visible_message("[src] makes an excited booping beeping sound!")

	if((!src.target || src.target == null))
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
			if(isspaceturf(T))
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
				if(!(F in floorbottargets) && F != src.oldtarget && F.icon_state == "Floor1" && !F.is_plating())
					src.oldtarget = F
					src.target = F
					break
		if((!src.target || src.target == null) && src.eattiles)
			for(var/obj/item/stack/tile/plasteel/T in view(7, src))
				if(!(T in floorbottargets) && T != src.oldtarget)
					src.oldtarget = T
					src.target = T
					break

	if((!src.target || src.target == null))
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
		else if(istype(src.target, /turf/))
			repair(src.target)
		src.path = new()
		return

	src.oldloc = src.loc


/obj/machinery/bot/floorbot/proc/repair(turf/target)
	if(isspaceturf(target))
		if(target.loc.name == "Space")
			return
	else if(!isfloorturf(target))
		return
	if(src.amount <= 0)
		return
	src.anchored = TRUE
	src.icon_state = "floorbot-c"
	if(isspaceturf(target))
		visible_message(span_warning(" [src] begins to repair the hole"))
		var/obj/item/stack/tile/plasteel/T = new /obj/item/stack/tile/plasteel
		src.repairing = 1
		spawn(50)
			T.build(src.loc)
			src.repairing = 0
			src.amount -= 1
			src.updateicon()
			src.anchored = FALSE
			src.target = null
	else
		visible_message(span_warning(" [src] begins to improve the floor."))
		src.repairing = 1
		spawn(50)
			src.loc.icon_state = "floor"
			src.repairing = 0
			src.amount -= 1
			src.updateicon()
			src.anchored = FALSE
			src.target = null

/obj/machinery/bot/floorbot/proc/eattile(obj/item/stack/tile/plasteel/T)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		return
	visible_message(span_warning(" [src] begins to collect tiles."))
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
			qdel(T)
		src.updateicon()
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/proc/maketile(obj/item/stack/sheet/metal/M)
	if(!istype(M, /obj/item/stack/sheet/metal))
		return
	if(M.get_amount() > 1)
		return
	visible_message(span_warning(" [src] begins to create tiles."))
	src.repairing = 1
	spawn(20)
		if(isnull(M))
			src.target = null
			src.repairing = 0
			return
		var/obj/item/stack/tile/plasteel/T = new /obj/item/stack/tile/plasteel
		T.amount = 4
		T.loc = M.loc
		qdel(M)
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/proc/updateicon()
	if(src.amount > 0)
		src.icon_state = "floorbot[src.on]"
	else
		src.icon_state = "floorbot[src.on]e"

/obj/machinery/bot/floorbot/deconstruct(disassembled = TRUE)
	new /obj/item/storage/toolbox/mechanical(loc)
	new /obj/item/assembly/prox_sensor(loc)
	if(prob(50))
		new /obj/item/robot_parts/l_arm(loc)
	var/obj/item/stack/tile/plasteel/T = new(loc)
	T.amount = amount
	T.update_icon()

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	return ..()


/obj/item/storage/toolbox/mechanical/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/stack/tile/plasteel))
		return ..()

	var/obj/item/stack/tile/plasteel/PS = I

	if(length(contents) >= 1)
		to_chat(user, span_notice("They wont fit in as there is already stuff inside."))
		return

	if(user.s_active)
		user.s_active.close(user)

	if(!PS.use(10))
		to_chat(user, span_warning("You need 10 floortiles for a floorbot."))
		return

	var/obj/item/frame/toolbox_tiles/B = new
	user.put_in_hands(B)
	to_chat(user, span_notice("You add the tiles into the empty toolbox. They protrude from the top."))
	user.temporarilyRemoveItemFromInventory(src)
	qdel(src)
