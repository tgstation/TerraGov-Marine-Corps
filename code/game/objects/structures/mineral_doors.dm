#define CLOSED 0
#define OPEN 1

//NOT using the existing /obj/machinery/door type, since that has some complications on its own, mainly based on its
//machineryness

/obj/structure/mineral_door
	name = "mineral door"
	density = TRUE
	anchored = TRUE
	opacity = TRUE

	icon = 'icons/obj/doors/mineral_doors.dmi'
	icon_state = "metal"

	var/mineralType = "metal"
	var/state = CLOSED
	var/isSwitchingStates = FALSE
	var/hardness = 1
	var/oreAmount = 7

/obj/structure/mineral_door/New(location)
	..()
	icon_state = mineralType
	name = "[mineralType] door"


/obj/structure/mineral_door/Bumped(atom/user)
	..()
	if(!state)
		return TryToSwitchState(user)
	return

/obj/structure/mineral_door/attack_ai(mob/user as mob) //those aren't machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return
	else if(isrobot(user)) //but cyborgs can
		if(get_dist(user,src) <= 1) //not remotely though
			return TryToSwitchState(user)

/obj/structure/mineral_door/attack_paw(mob/user as mob)
	return TryToSwitchState(user)

/obj/structure/mineral_door/attack_hand(mob/user as mob)
	return TryToSwitchState(user)

/obj/structure/mineral_door/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/mineral_door/proc/TryToSwitchState(atom/user)
	if(isSwitchingStates)
		return
	if(ismob(user))
		var/mob/M = user
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					SwitchState()
			else
				SwitchState()
	else if(istype(user, /obj/mecha))
		SwitchState()

/obj/structure/mineral_door/proc/SwitchState()
	if(state)
		Close()
	else
		Open()

/obj/structure/mineral_door/proc/Open()
	isSwitchingStates = 1
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 25, 1)
	flick("[mineralType]opening",src)
	sleep(10)
	density = FALSE
	opacity = FALSE
	state = OPEN
	update_icon()
	isSwitchingStates = FALSE


/obj/structure/mineral_door/proc/Close()
	isSwitchingStates = TRUE
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 25, 1)
	flick("[mineralType]closing",src)
	sleep(10)
	density = TRUE
	opacity = TRUE
	state = CLOSED
	update_icon()
	isSwitchingStates = FALSE


/obj/structure/mineral_door/update_icon()
	if(state)
		icon_state = "[mineralType]open"
	else
		icon_state = mineralType

/obj/structure/mineral_door/attackby(obj/item/W, mob/living/user)
	if(istype(W,/obj/item/tool/pickaxe))
		var/obj/item/tool/pickaxe/digTool = W
		to_chat(user, "You start digging the [name].")
		if(do_after(user,digTool.digspeed*hardness, TRUE, 5, BUSY_ICON_GENERIC) && src)
			to_chat(user, "You finished digging.")
			Dismantle()
	else if(!(W.flags_item & NOBLUDGEON) && W.force)
		user.animation_attack_on(src)
		hardness -= W.force/100
		to_chat(user, "You hit the [name] with your [W.name]!")
		CheckHardness()
	else
		attack_hand(user)
	return

/obj/structure/mineral_door/proc/CheckHardness()
	if(hardness <= 0)
		Dismantle(1)

/obj/structure/mineral_door/proc/Dismantle(devastated = 0)
	if(!devastated)
		if (mineralType == "metal")
			var/ore = /obj/item/stack/sheet/metal
			for(var/i = 1, i <= oreAmount, i++)
				new ore(get_turf(src))
		else
			var/ore = text2path("/obj/item/stack/sheet/mineral/[mineralType]")
			for(var/i = 1, i <= oreAmount, i++)
				new ore(get_turf(src))
	else
		if (mineralType == "metal")
			var/ore = /obj/item/stack/sheet/metal
			for(var/i = 3, i <= oreAmount, i++)
				new ore(get_turf(src))
		else
			var/ore = text2path("/obj/item/stack/sheet/mineral/[mineralType]")
			for(var/i = 3, i <= oreAmount, i++)
				new ore(get_turf(src))
	cdel(src)

/obj/structure/mineral_door/ex_act(severity = 1)
	switch(severity)
		if(1)
			Dismantle(1)
		if(2)
			if(prob(20))
				Dismantle(1)
			else
				hardness--
				CheckHardness()
		if(3)
			hardness -= 0.1
			CheckHardness()
	return

/obj/structure/mineral_door/iron
	mineralType = "metal"
	hardness = 3

/obj/structure/mineral_door/silver
	mineralType = "silver"
	hardness = 3

/obj/structure/mineral_door/gold
	mineralType = "gold"

/obj/structure/mineral_door/uranium
	mineralType = "uranium"
	hardness = 3
	luminosity = 2

/obj/structure/mineral_door/uranium/Dispose()
	SetLuminosity(0)
	. = ..()

/obj/structure/mineral_door/sandstone
	mineralType = "sandstone"
	hardness = 0.5

/obj/structure/mineral_door/transparent
	opacity = FALSE

/obj/structure/mineral_door/transparent/Close()
	..()
	opacity = FALSE

/obj/structure/mineral_door/transparent/phoron
	mineralType = "phoron"

/obj/structure/mineral_door/transparent/phoron/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			TemperatureAct(100)
	..()

/obj/structure/mineral_door/transparent/phoron/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		TemperatureAct(exposed_temperature)

/obj/structure/mineral_door/transparent/phoron/proc/TemperatureAct(temperature)


/obj/structure/mineral_door/transparent/diamond
	mineralType = "diamond"
	hardness = 10

/obj/structure/mineral_door/wood
	mineralType = "wood"
	hardness = 1

/obj/structure/mineral_door/wood/Open()
	isSwitchingStates = TRUE
	playsound(loc, 'sound/effects/doorcreaky.ogg', 25, 1)
	flick("[mineralType]opening",src)
	sleep(10)
	density = FALSE
	opacity = FALSE
	state = OPEN
	update_icon()
	isSwitchingStates = FALSE

/obj/structure/mineral_door/wood/Close()
	isSwitchingStates = TRUE
	playsound(loc, 'sound/effects/doorcreaky.ogg', 25, 1)
	flick("[mineralType]closing",src)
	sleep(10)
	density = TRUE
	opacity = TRUE
	state = CLOSED
	update_icon()
	isSwitchingStates = FALSE

/obj/structure/mineral_door/wood/Dismantle(devastated = 0)
	if(!devastated)
		for(var/i = 1, i <= oreAmount, i++)
			new/obj/item/stack/sheet/wood(get_turf(src))
	cdel(src)

//Mapping instance
/obj/structure/mineral_door/wood/open
	density = FALSE
	opacity = FALSE
	state = OPEN
	icon_state = "woodopen"

#undef CLOSED
#undef OPEN