#define D_CLOSED 0
#define D_OPEN 1

//NOT using the existing /obj/machinery/door type, since that has some complications on its own, mainly based on its
//machineryness

/obj/structure/mineral_door
	name = "mineral door"
	density = TRUE
	anchored = TRUE
	opacity = TRUE
	throwpass = FALSE

	icon = 'icons/obj/doors/mineral_doors.dmi'
	icon_state = "metal"
	resistance_flags = DROPSHIP_IMMUNE

	var/mineralType = "metal"
	var/state = D_CLOSED
	var/isSwitchingStates = FALSE
	var/hardness = 1
	var/oreAmount = 7

/obj/structure/mineral_door/Initialize()
	. = ..()
	icon_state = mineralType
	name = "[mineralType] door"


/obj/structure/mineral_door/Bumped(atom/user)
	. = ..()
	if(!state)
		return TryToSwitchState(user)

/obj/structure/mineral_door/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	return TryToSwitchState(user)

/obj/structure/mineral_door/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover, /atom/movable/effect/beam))
		return !opacity

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
	state = D_OPEN
	update_icon()
	isSwitchingStates = FALSE


/obj/structure/mineral_door/proc/Close()
	isSwitchingStates = TRUE
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 25, 1)
	flick("[mineralType]closing",src)
	sleep(10)
	density = TRUE
	opacity = TRUE
	state = D_CLOSED
	update_icon()
	isSwitchingStates = FALSE


/obj/structure/mineral_door/update_icon()
	if(state)
		icon_state = "[mineralType]open"
	else
		icon_state = mineralType

/obj/structure/mineral_door/attackby(obj/item/W, mob/living/user)
	var/is_resin = istype(src, /obj/structure/mineral_door/resin)
	if(!(W.flags_item & NOBLUDGEON) && W.force)
		user.changeNext_move(W.attack_speed)
		var/multiplier = 1
		var/obj/item/tool/pickaxe/plasmacutter/P
		if(istype(W, /obj/item/tool/pickaxe/plasmacutter) && !user.do_actions)
			P = W
			if(P.start_cut(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD))
				if(is_resin)
					multiplier += PLASMACUTTER_RESIN_MULTIPLIER //Plasma cutters are particularly good at destroying resin structures.
				else
					multiplier += PLASMACUTTER_RESIN_MULTIPLIER * 0.5 //Plasma cutters are particularly good at destroying resin structures.
				P.cut_apart(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD) //Minimal energy cost.
		if(W.damtype == BURN && is_resin) //Burn damage deals extra vs resin structures (mostly welders).
			multiplier += 1
		user.do_attack_animation(src, used_item = W)
		hardness -= W.force * multiplier * 0.01
		if(!P)
			to_chat(user, "You hit the [name] with your [W.name]!")
		CheckHardness()
		return
	attack_hand(user)

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
	qdel(src)

/obj/structure/mineral_door/ex_act(severity = 1)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			Dismantle(1)
		if(EXPLODE_HEAVY)
			if(prob(20))
				Dismantle(1)
			else
				hardness--
				CheckHardness()
		if(EXPLODE_LIGHT)
			hardness -= 0.1
			CheckHardness()


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
	state = D_OPEN
	update_icon()
	isSwitchingStates = FALSE

/obj/structure/mineral_door/wood/Close()
	isSwitchingStates = TRUE
	playsound(loc, 'sound/effects/doorcreaky.ogg', 25, 1)
	flick("[mineralType]closing",src)
	sleep(10)
	density = TRUE
	opacity = TRUE
	state = D_CLOSED
	update_icon()
	isSwitchingStates = FALSE

/obj/structure/mineral_door/wood/Dismantle(devastated = 0)
	if(!devastated)
		for(var/i = 1, i <= oreAmount, i++)
			new/obj/item/stack/sheet/wood(get_turf(src))
	qdel(src)

//Mapping instance
/obj/structure/mineral_door/wood/open
	density = FALSE
	opacity = FALSE
	state = D_OPEN
	icon_state = "woodopen"

#undef D_CLOSED
#undef D_OPEN
