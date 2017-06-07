/*
 * False Walls
 */
/obj/structure/falsewall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	anchored = 1
	icon_state = "0"
	icon = 'icons/turf/walls.dmi'
	var/mineral = "metal"
	var/opening = 0

	tiles_with = list(
		/turf/simulated/wall,
		/obj/structure/falsewall)

/obj/structure/falsewall/New()
	relativewall_neighbours()
	update_icon()
	..()

/obj/structure/falsewall/Dispose()
	relativewall_neighbours()
	. = ..()


/obj/structure/falsewall/relativewall()

	if(!density)
		icon_state = "[mineral]fwall_open"
		return

	..()

/obj/structure/falsewall/attack_hand(mob/user as mob)
	if(opening)
		return
	if(density) open_wall()
	else close_wall()


/obj/structure/falsewall/proc/open_wall()
	opening = 1
	icon_state = "[mineral]fwall_open"
	flick("[mineral]fwall_opening", src)
	sleep(15)
	density = 0
	SetOpacity(0)
	opening = 0

/obj/structure/falsewall/proc/close_wall()
	for(var/atom/movable/AM in loc)
		if(AM == src) continue
		if(AM.density) return //something blocks the way.
	opening = 1
	flick("[mineral]fwall_closing", src)
	icon_state = "[mineral]0"
	density = 1
	sleep(15)
	SetOpacity(1)
	relativewall()
	opening = 0
	for(var/atom/movable/AM in loc)
		if(AM == src) continue
		if(AM.density)
			open_wall()//something sneaks on the tile and blocks the way, open the false wall.
			break

/obj/structure/falsewall/update_icon()//Calling icon_update will refresh the smoothwalls if it's closed, otherwise it will make sure the icon is correct if it's open
	..()
	if(density)
		icon_state = "[mineral]0"
		relativewall()
	else
		icon_state = "[mineral]fwall_open"

/obj/structure/falsewall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(opening)
		user << "\red You must wait until the door has stopped moving."
		return

	if(density)
		var/turf/T = get_turf(src)
		if(T.density)
			user << "\red The wall is blocked!"
			return
		if(istype(W, /obj/item/weapon/screwdriver))
			user.visible_message("[user] tightens some bolts on the wall.", "You tighten the bolts on the wall.")
			if(!mineral || mineral == "metal" || mineral == "rwall")
				T.ChangeTurf(/turf/simulated/wall)
			else
				T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
			cdel(src)

		if( istype(W, /obj/item/weapon/weldingtool) )
			var/obj/item/weapon/weldingtool/WT = W
			if( WT:welding )
				if(!mineral || mineral == "metal" || mineral == "rwall") //Mineral metal walls don't exist
					T.ChangeTurf(/turf/simulated/wall)
				else
					T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
				if(mineral != "phoron")//Stupid shit keeps me from pushing the attackby() to phoron walls -Sieve
					T = get_turf(src)
					T.attackby(W,user)
				cdel(src)
	else
		user << "\blue You can't reach, close it first!"

	if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )
		var/turf/T = get_turf(src)
		if(!mineral || mineral == "metal" || mineral == "rwall")
			T.ChangeTurf(/turf/simulated/wall)
		else
			T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
		if(mineral != "phoron")
			T = get_turf(src)
			T.attackby(W,user)
		cdel(src)

	//DRILLING
	else if (istype(W, /obj/item/weapon/pickaxe/diamonddrill))
		var/turf/T = get_turf(src)
		if(!mineral || mineral == "metal" || mineral == "rwall")
			T.ChangeTurf(/turf/simulated/wall)
		else
			T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
		T = get_turf(src)
		T.attackby(W,user)
		cdel(src)

	else if( istype(W, /obj/item/weapon/melee/energy/blade) )
		var/turf/T = get_turf(src)
		if(!mineral || mineral == "metal" || mineral == "rwall")
			T.ChangeTurf(/turf/simulated/wall)
		else
			T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
		if(mineral != "phoron")
			T = get_turf(src)
			T.attackby(W,user)
		cdel(src)

/obj/structure/falsewall/update_icon()//Calling icon_update will refresh the smoothwalls if it's closed, otherwise it will make sure the icon is correct if it's open
	..()
	if(density)
		icon_state = "[mineral]0"
		src.relativewall()
	else
		icon_state = "[mineral]fwall_open"

/*
 * False R-Walls
 */

/obj/structure/falsewall/reinforced
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	mineral = "rwall"

/*
 * Uranium Falsewalls
 */

/obj/structure/falsewall/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	mineral = "uranium"
	var/active = null
	var/last_event = 0

/obj/structure/falsewall/uranium/attackby(obj/item/weapon/W as obj, mob/user as mob)
	radiate()
	..()

/obj/structure/falsewall/uranium/attack_hand(mob/user as mob)
	radiate()
	..()

/obj/structure/falsewall/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(12,IRRADIATE,0)
			for(var/turf/simulated/wall/mineral/uranium/T in range(3,src))
				T.radiate()
			last_event = world.time
			active = null
			return
	return
/*
 * Other misc falsewall types
 */

/obj/structure/falsewall/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	mineral = "gold"

/obj/structure/falsewall/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny."
	mineral = "silver"

/obj/structure/falsewall/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	mineral = "diamond"

/obj/structure/falsewall/phoron
	name = "phoron wall"
	desc = "A wall with phoron plating. This is definately a bad idea."
	mineral = "phoron"

/obj/structure/falsewall/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	mineral = "sandstone"
//------------wtf?------------end