
/*
/turf

	/open - all turfs with density = 0 are turf/open

		/floor - floors are constructed floor as opposed to natural grounds

		/space

		/shuttle - shuttle floors are separated from real floors because they're magic

		/snow - snow is one type of non-floor open turf

	/closed - all turfs with density = 1 are turf/closed

		/wall - walls are constructed walls as opposed to natural solid turfs

			/r_wall

		/shuttle - shuttle walls are separated from real walls because they're magic, and don't smoothes with walls.

		/ice_rock - ice_rock is one type of non-wall closed turf

*/



/turf
	icon = 'icons/turf/floors.dmi'
	var/intact_tile = 1 //used by floors to distinguish floor with/without a floortile(e.g. plating).
	var/can_bloody = TRUE //Can blood spawn on this turf?
	var/oldTurf = "" //The previous turf's path as text. Used when deconning on LV --MadSnailDisease



/turf/New()
	..()
	turfs += src
	for(var/atom/movable/AM as mob|obj in src)
		spawn(0)
			Entered(AM)

	levelupdate()


/turf/Dispose()
	if(oldTurf != "")
		ChangeTurf(text2path(oldTurf), TRUE)
	else
		ChangeTurf(/turf/open/floor/plating, TRUE)
	..()
	return TA_PURGE_ME_NOW

/turf/ex_act(severity)
	return 0

/turf/proc/update_icon() //Base parent. - Abby
	return




/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if(movement_disabled && usr.ckey != movement_disabled_exception)
		usr << "\red Movement is admin-disabled." //This is to identify lag problems
		return
	if (!mover || !isturf(mover.loc))
		return 1


	//First, check objects to block exit that are not on the border
	for(var/obj/obstacle in mover.loc)
		if(!(obstacle.flags_atom & ON_BORDER) && (mover != obstacle) && (forget != obstacle))
			if(!obstacle.CheckExit(mover, src))
				mover.Bump(obstacle, 1)
				return 0

	//Now, check objects to block exit that are on the border
	for(var/obj/border_obstacle in mover.loc)
		if((border_obstacle.flags_atom & ON_BORDER) && (mover != border_obstacle) && (forget != border_obstacle))
			if(!border_obstacle.CheckExit(mover, src))
				mover.Bump(border_obstacle, 1)
				return 0

	//Next, check objects to block entry that are on the border
	for(var/obj/border_obstacle in src)
		if(border_obstacle.flags_atom & ON_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc) && (forget != border_obstacle))
				mover.Bump(border_obstacle, 1)
				return 0

	//Then, check the turf itself
	if (!CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in src)
		if(!(obstacle.flags_atom & ON_BORDER))
			if(!obstacle.CanPass(mover, mover.loc) && (forget != obstacle))
				mover.Bump(obstacle, 1)
				return 0
	return 1 //Nothing found to block so return success!


/turf/Entered(atom/movable/A)

	if(!istype(A))
		return

	if(ismob(A))
		var/mob/M = A
		if(!M.lastarea)
			M.lastarea = get_area(M.loc)
		if(M.lastarea.has_gravity == 0)
			inertial_drift(M)

		else if(!istype(src, /turf/open/space))
			M.inertia_dir = 0
			M.make_floating(0)
	..()



/turf/proc/is_plating()
	return 0

/turf/proc/is_asteroid_floor()
	return 0
/turf/proc/is_plasteel_floor()
	return 0
/turf/proc/is_light_floor()
	return 0
/turf/proc/is_grass_floor()
	return 0
/turf/proc/is_wood_floor()
	return 0
/turf/proc/is_carpet_floor()
	return 0
/turf/proc/return_siding_icon_state()		//used for grass floors, which have siding.
	return 0

/turf/proc/inertial_drift(atom/movable/A as mob|obj)
	if(!(A.last_move_dir))	return
	if((istype(A, /mob/) && src.x > 2 && src.x < (world.maxx - 1) && src.y > 2 && src.y < (world.maxy-1)))
		var/mob/M = A
		if(M.Process_Spacemove(1))
			M.inertia_dir  = 0
			return
		spawn(5)
			if((M && !(M.anchored) && !(M.pulledby) && (M.loc == src)))
				if(M.inertia_dir)
					step(M, M.inertia_dir)
					return
				M.inertia_dir = M.last_move_dir
				step(M, M.inertia_dir)
	return



/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(intact_tile)


//Creates a new turf. this is called by every code that changes a turf ("spawn atom" verb, cdel, build mode stuff, etc)
/turf/proc/ChangeTurf(new_turf_path, forget_old_turf)
	if (!new_turf_path)
		return

	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)

	//world << "Replacing [src.type] with [new_turf_path]"

	var/path = "[src.type]"
	var/turf/W = new new_turf_path( locate(src.x, src.y, src.z) )
	if(!forget_old_turf)	//e.g. if an admin spawn a new wall on a wall tile, we don't
		W.oldTurf = path	//want the new wall to change into the old wall when destroyed
	W.lighting_lumcount += old_lumcount
	if(old_lumcount != W.lighting_lumcount)
		W.lighting_changed = 1
		lighting_controller.changed_turfs += W

	W.levelupdate()
	return W


/turf/proc/ReplaceWithLattice()
	src.ChangeTurf(/turf/open/space)
	new /obj/structure/lattice( locate(src.x, src.y, src.z) )




/turf/proc/AdjacentTurfs()
	var/L[] = new()
	for(var/turf/t in oview(src,1))
		if(!t.density)
			if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)
	return L

/turf/proc/AdjacentTurfsSpace()
	var/L[] = new()
	for(var/turf/t in oview(src,1))
		if(!t.density)
			if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)
	return L



/turf/proc/Distance(turf/t)
	if(get_dist(src,t) == 1)
		var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y)
		return cost
	else
		return get_dist(src,t)


//Blood stuff------------
/turf/proc/AddTracks(var/typepath,var/bloodDNA,var/comingdir,var/goingdir,var/bloodcolor="#A10808")
	if(!can_bloody)
		return
	var/obj/effect/decal/cleanable/blood/tracks/tracks = locate(typepath) in src
	if(!tracks)
		tracks = new typepath(src)
	tracks.AddTracks(bloodDNA,comingdir,goingdir,bloodcolor)







//for xeno corrosive acid, 0 for unmeltable, 1 for regular, 2 for strong walls that require strong acid and more time.
/turf/proc/can_be_dissolved()
	return 0

/turf/proc/ceiling_debris_check(var/size = 1)
	return

/turf/proc/ceiling_debris(var/size = 1) //debris falling in response to airstrikes, etc
	var/area/A = get_area(src)
	if(!A.ceiling) return

	var/amount = size
	var/spread = round(sqrt(size)*1.5)

	var/list/turfs = list()
	for(var/turf/open/floor/F in range(src,spread))
		turfs += F

	switch(A.ceiling)
		if(CEILING_GLASS)
			playsound(src, "sound/effects/Glassbr1.ogg", 60, 1)
			spawn(8)
				if(amount >1)
					visible_message("<span class='boldnotice'>Shards of glass rain down from above!</span>")
				for(var/i=1, i<=amount, i++)
					new /obj/item/shard(pick(turfs))
					new /obj/item/shard(pick(turfs))
		if(CEILING_METAL)
			playsound(src, "sound/effects/metal_crash.ogg", 60, 1)
			spawn(8)
				if(amount >1)
					visible_message("<span class='boldnotice'>Pieces of metal crash down from above!</span>")
				for(var/i=1, i<=amount, i++)
					new /obj/item/stack/sheet/metal(pick(turfs))
		if(CEILING_UNDERGROUND, CEILING_DEEP_UNDERGROUND)
			playsound(src, "sound/effects/meteorimpact.ogg", 60, 1)
			spawn(8)
				if(amount >1)
					visible_message("<span class='boldnotice'>Chunks of rock crash down from above!</span>")
				for(var/i=1, i<=amount, i++)
					new /obj/item/ore(pick(turfs))
					new /obj/item/ore(pick(turfs))
		if(CEILING_UNDERGROUND_METAL, CEILING_DEEP_UNDERGROUND_METAL)
			playsound(src, "sound/effects/metal_crash.ogg", 60, 1)
			spawn(8)
				for(var/i=1, i<=amount, i++)
					new /obj/item/stack/sheet/metal(pick(turfs))
					new /obj/item/ore(pick(turfs))

/turf/proc/ceiling_desc(mob/user)
	var/area/A = get_area(src)
	switch(A.ceiling)
		if(CEILING_NONE)
			user << "It is in the open."
		if(CEILING_GLASS)
			user << "The ceiling above is glass."
		if(CEILING_METAL)
			user << "The ceiling above is metal."
		if(CEILING_UNDERGROUND)
			user << "It is underground. The cavern roof lies above."
		if(CEILING_UNDERGROUND_METAL)
			user << "It is underground. The ceiling above is metal."
		if(CEILING_DEEP_UNDERGROUND)
			user << "It is deep underground. The cavern roof lies above."
		if(CEILING_DEEP_UNDERGROUND_METAL)
			user << "It is deep underground. The ceiling above is metal."



/turf/proc/wet_floor()
	return





//////////////////////////////////////////////////////////





//Check if you can plant weeds on that turf.
//Does NOT return a message, just a 0 or 1.
/turf/proc/is_weedable()
	return !density

/turf/open/space/is_weedable()
	return FALSE

/turf/open/gm/grass/is_weedable()
	return FALSE

/turf/open/gm/dirtgrassborder/is_weedable()
	return FALSE

/turf/open/gm/river/is_weedable()
	return FALSE

/turf/open/gm/coast/is_weedable()
	return FALSE

/turf/open/snow/is_weedable()
	return !slayer

/turf/open/mars/is_weedable()
	return FALSE


/turf/open/floor/plating/plating_catwalk/is_weedable() //covered catwalks are unweedable
	if(covered)
		return FALSE
	else
		return TRUE


/turf/closed/wall/is_weedable()
	return TRUE //so we can spawn weeds on the walls






/turf/proc/can_dig_xeno_tunnel()
	return FALSE

/turf/open/gm/can_dig_xeno_tunnel()
	return TRUE

/turf/open/gm/river/can_dig_xeno_tunnel()
	return FALSE

/turf/open/snow/can_dig_xeno_tunnel()
	return TRUE

/turf/open/mars/can_dig_xeno_tunnel()
	return TRUE

/turf/open/mars_cave/can_dig_xeno_tunnel()
	return TRUE

/turf/open/floor/prison/can_dig_xeno_tunnel()
	return TRUE







//what dirt type you can dig from this turf if any.
/turf/proc/get_dirt_type()
	return NO_DIRT

/turf/open/gm/get_dirt_type()
	return DIRT_TYPE_GROUND

/turf/open/mars/get_dirt_type()
	return DIRT_TYPE_MARS

/turf/open/snow/get_dirt_type()
	return DIRT_TYPE_SNOW







/turf/CanPass(atom/movable/mover, turf/target)
	if(!target) return 0

	if(istype(mover)) // turf/Enter(...) will perform more advanced checks
		return !density
