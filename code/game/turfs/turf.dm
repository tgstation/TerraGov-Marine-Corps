
/*
/turf

	/open - all turfs with density = 0 are turf/open

		/floor - floors are constructed floor as opposed to natural grounds

		/space

		/shuttle - shuttle floors are separated from real floors because they're magic

		/snow - snow is one type of non-floor open turf

	/closed - all turfs with density = TRUE are turf/closed

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

	// baseturfs can be either a list or a single turf type.
	// In class definition like here it should always be a single type.
	// A list will be created in initialization that figures out the baseturf's baseturf etc.
	// In the case of a list it is sorted from bottom layer to top.
	// This shouldn't be modified directly, use the helper procs.
	var/list/baseturfs = /turf/baseturf_bottom
	var/obj/effect/xenomorph/acid/current_acid = null //If it has acid spewed on it

/turf/Initialize(mapload, ...)
	. = ..()
	GLOB.turfs += src
	for(var/atom/movable/AM in src)
		Entered(AM)

	levelupdate()

	if(luminosity)
		if(light)	
			WARNING("[type] - Don't set lights up manually during New(), We do it automatically.")
		trueLuminosity = luminosity * luminosity
		light = new(src)
	visibilityChanged()

/turf/Destroy()
	if(oldTurf != "")
		ChangeTurf(text2path(oldTurf), TRUE)
	else
		ChangeTurf(/turf/open/floor/plating, TRUE)
	visibilityChanged()
	return ..()

/turf/ex_act(severity)
	return 0

/turf/proc/update_icon() //Base parent. - Abby
	return




/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
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

		if(!isspaceturf(src))
			M.inertia_dir = 0
	..()

/turf/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_CHEM))
		S.reagents?.reaction(src, VAPOR, S.fraction)

/turf/proc/is_plating()
	return FALSE
/turf/proc/is_asteroid_floor()
	return FALSE
/turf/proc/is_plasteel_floor()
	return FALSE
/turf/proc/is_light_floor()
	return FALSE
/turf/proc/is_grass_floor()
	return FALSE
/turf/proc/is_wood_floor()
	return FALSE
/turf/proc/is_carpet_floor()
	return FALSE
/turf/proc/return_siding_icon_state()		//used for grass floors, which have siding.
	return 0


/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(intact_tile)


//Creates a new turf. this is called by every code that changes a turf ("spawn atom" verb, cdel, build mode stuff, etc)
/turf/proc/ChangeTurf(new_turf_path, forget_old_turf, flags)
	if (!new_turf_path)
		return

	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)

	//to_chat(world, "Replacing [src.type] with [new_turf_path]")

	var/path = "[src.type]"
	var/turf/W = new new_turf_path( locate(src.x, src.y, src.z) )
	if(!forget_old_turf)	//e.g. if an admin spawn a new wall on a wall tile, we don't
		W.oldTurf = path	//want the new wall to change into the old wall when destroyed

	var/list/transferring_comps = list()
	SEND_SIGNAL(src, COMSIG_TURF_CHANGE, path, flags, transferring_comps)
	for(var/i in transferring_comps)
		var/datum/component/comp = i
		comp.RemoveComponent()


	if(!(flags & CHANGETURF_DEFER_CHANGE))
		W.AfterChange(flags)

	W.lighting_lumcount += old_lumcount
	if(old_lumcount != W.lighting_lumcount)
		W.lighting_changed = 1
		lighting_controller.changed_turfs += W

	W.levelupdate()
	return W

// Take off the top layer turf and replace it with the next baseturf down
/turf/proc/ScrapeAway(amount=1, flags)
	if(!amount)
		return
	if(length(baseturfs))
		var/list/new_baseturfs = baseturfs.Copy()
		var/turf_type = new_baseturfs[max(1, new_baseturfs.len - amount + 1)]
		while(ispath(turf_type, /turf/baseturf_skipover))
			amount++
			if(amount > new_baseturfs.len)
				CRASH("The bottomost baseturf of a turf is a skipover [src]([type])")
			turf_type = new_baseturfs[max(1, new_baseturfs.len - amount + 1)]
		new_baseturfs.len -= min(amount, new_baseturfs.len - 1) // No removing the very bottom
		if(new_baseturfs.len == 1)
			new_baseturfs = new_baseturfs[1]
		return ChangeTurf(turf_type, new_baseturfs, flags)

	if(baseturfs == type)
		return src

	return ChangeTurf(baseturfs, baseturfs, flags) // The bottom baseturf will never go away

/turf/proc/empty(turf_type=/turf/open/space, baseturf_type, list/ignore_typecache, flags)
	// Remove all atoms except observers, landmarks, docking ports
	var/static/list/ignored_atoms = typecacheof(list(/mob/dead, /obj/effect/landmark, /obj/docking_port))
	var/list/allowed_contents = typecache_filter_list_reverse(GetAllContentsIgnoring(ignore_typecache), ignored_atoms)
	allowed_contents -= src
	for(var/i in 1 to allowed_contents.len)
		var/thing = allowed_contents[i]
		qdel(thing, force=TRUE)

	if(turf_type)
		ChangeTurf(turf_type, baseturf_type, flags)
		//var/turf/newT = ChangeTurf(turf_type, baseturf_type, flags)

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


//  This Distance proc assumes that only cardinal movement is
//  possible. It results in more efficient (CPU-wise) pathing
//  for bots and anything else that only moves in cardinal dirs.
/turf/proc/Distance_cardinal(turf/T)
	if(!src || !T)
		return FALSE
	return abs(x - T.x) + abs(y - T.y)


//Blood stuff------------
/turf/proc/AddTracks(var/typepath,var/bloodDNA,var/comingdir,var/goingdir,var/bloodcolor="#A10808")
	if(!can_bloody)
		return
	var/obj/effect/decal/cleanable/blood/tracks/tracks = locate(typepath) in src
	if(!tracks)
		tracks = new typepath(src)
	tracks.AddTracks(bloodDNA,comingdir,goingdir,bloodcolor)

//Cables laying helpers
/turf/proc/can_have_cabling()
	return TRUE

/turf/proc/can_lay_cable()
	return can_have_cabling() & !intact_tile

//Enable cable laying on turf click instead of pixel hunting the cable
/turf/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(.)
		return TRUE

	user.changeNext_move(I.attack_speed)

	if(can_lay_cable() && istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = I
		for(var/obj/structure/cable/C in src)
			if(C.d1 == CABLE_NODE || C.d2 == CABLE_NODE)
				C.attackby(I, user, params)
				return
		coil.place_turf(src, user)
		return TRUE

//for xeno corrosive acid, 0 for unmeltable, 1 for regular, 2 for strong walls that require strong acid and more time.
/turf/proc/can_be_dissolved()
	return FALSE

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
			playsound(src, "sound/effects/glassbr1.ogg", 60, 1)
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
			to_chat(user, "It is in the open.")
		if(CEILING_GLASS)
			to_chat(user, "The ceiling above is glass.")
		if(CEILING_METAL)
			to_chat(user, "The ceiling above is metal.")
		if(CEILING_UNDERGROUND)
			to_chat(user, "It is underground. The cavern roof lies above.")
		if(CEILING_UNDERGROUND_METAL)
			to_chat(user, "It is underground. The ceiling above is metal.")
		if(CEILING_DEEP_UNDERGROUND)
			to_chat(user, "It is deep underground. The cavern roof lies above.")
		if(CEILING_DEEP_UNDERGROUND_METAL)
			to_chat(user, "It is deep underground. The ceiling above is metal.")



/turf/proc/wet_floor()
	return

//////////////////////////////////////////////////////////



GLOBAL_LIST_INIT(unweedable_areas, typecacheof(list(
	/area/shuttle/drop1/lz1,
	/area/shuttle/drop2/lz2,
	/area/sulaco/hangar)))

//Check if you can plant weeds on that turf.
//Does NOT return a message, just a 0 or 1.
/turf/proc/is_weedable()
	return !density && !is_type_in_typecache((get_area(src)), GLOB.unweedable_areas)

/turf/open/space/is_weedable()
	return FALSE

/turf/open/ground/grass/is_weedable()
	return FALSE

/turf/open/floor/plating/ground/dirtgrassborder/is_weedable()
	return FALSE

/turf/open/ground/river/is_weedable()
	return FALSE

/turf/open/ground/coast/is_weedable()
	return FALSE

/turf/open/floor/plating/ground/snow/is_weedable()
	return !slayer && ..()


/turf/open/floor/plating/plating_catwalk/is_weedable() //covered catwalks are unweedable
	. = ..()
	if(covered)
		return FALSE


/turf/closed/wall/is_weedable()
	return !is_type_in_typecache((get_area(src)), GLOB.unweedable_areas) //so we can spawn weeds on the walls


/turf/proc/check_alien_construction(mob/living/L, silent = FALSE)
	var/has_obstacle
	for(var/obj/O in contents)
		if(istype(O, /obj/item/clothing/mask/facehugger))
			if(!silent)
				to_chat(L, "<span class='warning'>There is a little one here already. Best move it.</span>")
			return FALSE
		if(istype(O, /obj/effect/alien/egg))
			if(!silent)
				to_chat(L, "<span class='warning'>There's already an egg.</span>")
			return FALSE
		if(istype(O, /obj/structure/mineral_door) || istype(O, /obj/effect/alien/resin))
			has_obstacle = TRUE
			break
		if(istype(O, /obj/structure/ladder))
			has_obstacle = TRUE
			break
		if(istype(O, /obj/structure/bed))
			if(istype(O, /obj/structure/bed/chair/dropship/passenger))
				var/obj/structure/bed/chair/dropship/passenger/P = O
				if(P.chair_state != DROPSHIP_CHAIR_BROKEN)
					has_obstacle = TRUE
					break
			else
				has_obstacle = TRUE
				break

		if(O.density && !(O.flags_atom & ON_BORDER))
			has_obstacle = TRUE
			break

	if(density || has_obstacle)
		if(!silent)
			to_chat(L, "<span class='warning'>There's something built here already.</span>")
		return FALSE
	return TRUE

/turf/closed/check_alien_construction(mob/living/L, silent = FALSE)
	if(!silent)
		to_chat(L, "<span class='warning'>There's something built here already.</span>")
	return FALSE

/turf/proc/can_dig_xeno_tunnel()
	return FALSE

/turf/open/ground/can_dig_xeno_tunnel()
	return TRUE

/turf/open/ground/river/can_dig_xeno_tunnel()
	return FALSE

/turf/open/floor/plating/ground/snow/can_dig_xeno_tunnel()
	return TRUE

/turf/open/floor/plating/ground/ice/can_dig_xeno_tunnel()
	return TRUE

/turf/open/floor/can_dig_xeno_tunnel()
	return TRUE

/turf/open/floor/plating/catwalk/can_dig_xeno_tunnel()
	return FALSE

/turf/open/floor/almayer/research/containment/can_dig_xeno_tunnel()
	return FALSE

/turf/open/ground/jungle/can_dig_xeno_tunnel()
	return TRUE

/turf/open/ground/jungle/impenetrable/can_dig_xeno_tunnel()
	return FALSE

/turf/open/ground/jungle/water/can_dig_xeno_tunnel()
	return FALSE

/turf/open/floor/prison/can_dig_xeno_tunnel()
	return TRUE







//what dirt type you can dig from this turf if any.
/turf/proc/get_dirt_type()
	return NO_DIRT

/turf/open/ground/get_dirt_type()
	return DIRT_TYPE_GROUND

/turf/open/floor/plating/ground/get_dirt_type()
	return DIRT_TYPE_GROUND

/turf/open/floor/plating/ground/mars/get_dirt_type()
	return DIRT_TYPE_MARS

/turf/open/floor/plating/ground/snow/get_dirt_type()
	return DIRT_TYPE_SNOW







/turf/CanPass(atom/movable/mover, turf/target)
	if(!target) return 0

	if(istype(mover)) // turf/Enter(...) will perform more advanced checks
		return !density

GLOBAL_LIST_INIT(blacklisted_automated_baseturfs, typecacheof(list(
	/turf/open/space,
	/turf/baseturf_bottom,
	)))

// Make a new turf and put it on top
// The args behave identical to PlaceOnBottom except they go on top
// Things placed on top of closed turfs will ignore the topmost closed turf
// Returns the new turf
/turf/proc/PlaceOnTop(list/new_baseturfs, turf/fake_turf_type, flags)
	var/area/turf_area = loc
	if(new_baseturfs && !length(new_baseturfs))
		new_baseturfs = list(new_baseturfs)
	flags = turf_area.PlaceOnTopReact(new_baseturfs, fake_turf_type, flags) // A hook so areas can modify the incoming args

	var/turf/newT
	if(flags & CHANGETURF_SKIP) // We haven't been initialized
		if(flags_atom & INITIALIZED)
			stack_trace("CHANGETURF_SKIP was used in a PlaceOnTop call for a turf that's initialized. This is a mistake. [src]([type])")
		assemble_baseturfs()
	if(fake_turf_type)
		if(!new_baseturfs) // If no baseturfs list then we want to create one from the turf type
			if(!length(baseturfs))
				baseturfs = list(baseturfs)
			var/list/old_baseturfs = baseturfs.Copy()
			if(!istype(src, /turf/closed))
				old_baseturfs += type
			newT = ChangeTurf(fake_turf_type, null, flags)
			newT.assemble_baseturfs(initial(fake_turf_type.baseturfs)) // The baseturfs list is created like roundstart
			if(!length(newT.baseturfs))
				newT.baseturfs = list(baseturfs)
			newT.baseturfs -= GLOB.blacklisted_automated_baseturfs
			newT.baseturfs.Insert(1, old_baseturfs) // The old baseturfs are put underneath
			return newT
		if(!length(baseturfs))
			baseturfs = list(baseturfs)
		if(!istype(src, /turf/closed))
			baseturfs += type
		baseturfs += new_baseturfs
		return ChangeTurf(fake_turf_type, null, flags)
	if(!length(baseturfs))
		baseturfs = list(baseturfs)
	if(!istype(src, /turf/closed))
		baseturfs += type
	var/turf/change_type
	if(length(new_baseturfs))
		change_type = new_baseturfs[new_baseturfs.len]
		new_baseturfs.len--
		if(new_baseturfs.len)
			baseturfs += new_baseturfs
	else
		change_type = new_baseturfs
	return ChangeTurf(change_type, null, flags)

// Copy an existing turf and put it on top
// Returns the new turf
/turf/proc/CopyOnTop(turf/copytarget, ignore_bottom=1, depth=INFINITY, copy_air = FALSE)
	var/list/new_baseturfs = list()
	new_baseturfs += baseturfs
	new_baseturfs += type

	if(depth)
		var/list/target_baseturfs
		if(length(copytarget.baseturfs))
			// with default inputs this would be Copy(CLAMP(2, -INFINITY, baseturfs.len))
			// Don't forget a lower index is lower in the baseturfs stack, the bottom is baseturfs[1]
			target_baseturfs = copytarget.baseturfs.Copy(CLAMP(1 + ignore_bottom, 1 + copytarget.baseturfs.len - depth, copytarget.baseturfs.len))
		else if(!ignore_bottom)
			target_baseturfs = list(copytarget.baseturfs)
		if(target_baseturfs)
			target_baseturfs -= new_baseturfs & GLOB.blacklisted_automated_baseturfs
			new_baseturfs += target_baseturfs

	var/turf/newT = copytarget.copyTurf(src, copy_air)
	newT.baseturfs = new_baseturfs
	return newT

/turf/proc/copyTurf(turf/T)
	if(T.type != type)
		var/obj/O
		if(underlays.len)	//we have underlays, which implies some sort of transparency, so we want to a snapshot of the previous turf as an underlay
			O = new()
			O.underlays.Add(T)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = O.underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	//if(T.dir != dir)//components
	//	T.setDir(dir)
	return T

//If you modify this function, ensure it works correctly with lateloaded map templates.
/turf/proc/AfterChange(flags) //called after a turf has been replaced in ChangeTurf()
	levelupdate()
	//CalculateAdjacentTurfs() // linda

	//update firedoor adjacency
//	var/list/turfs_to_check = get_adjacent_open_turfs(src) | src
//	for(var/I in turfs_to_check)
//		var/turf/T = I
//		for(var/obj/machinery/door/firedoor/FD in T)
//			FD.CalculateAffectingAreas()

//	queue_smooth_neighbors(src)

	HandleTurfChange(src)

/turf/open/AfterChange(flags)
	..()
	RemoveLattice()

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L && (L.flags_atom & INITIALIZED))
		qdel(L)

// A proc in case it needs to be recreated or badmins want to change the baseturfs
/turf/proc/assemble_baseturfs(turf/fake_baseturf_type)
	var/static/list/created_baseturf_lists = list()
	var/turf/current_target
	if(fake_baseturf_type)
		if(length(fake_baseturf_type)) // We were given a list, just apply it and move on
			baseturfs = fake_baseturf_type
			return
		current_target = fake_baseturf_type
	else
		if(length(baseturfs))
			return // No replacement baseturf has been given and the current baseturfs value is already a list/assembled
		if(!baseturfs)
			current_target = initial(baseturfs) || type // This should never happen but just in case...
			stack_trace("baseturfs var was null for [type]. Failsafe activated and it has been given a new baseturfs value of [current_target].")
		else
			current_target = baseturfs

	// If we've made the output before we don't need to regenerate it
	if(created_baseturf_lists[current_target])
		var/list/premade_baseturfs = created_baseturf_lists[current_target]
		if(length(premade_baseturfs))
			baseturfs = premade_baseturfs.Copy()
		else
			baseturfs = premade_baseturfs
		return baseturfs

	var/turf/next_target = initial(current_target.baseturfs)
	//Most things only have 1 baseturf so this loop won't run in most cases
	if(current_target == next_target)
		baseturfs = current_target
		created_baseturf_lists[current_target] = current_target
		return current_target
	var/list/new_baseturfs = list(current_target)
	for(var/i=0;current_target != next_target;i++)
		if(i > 100)
			// A baseturfs list over 100 members long is silly
			// Because of how this is all structured it will only runtime/message once per type
			stack_trace("A turf <[type]> created a baseturfs list over 100 members long. This is most likely an infinite loop.")
			message_admins("A turf <[type]> created a baseturfs list over 100 members long. This is most likely an infinite loop.")
			break
		new_baseturfs.Insert(1, next_target)
		current_target = next_target
		next_target = initial(current_target.baseturfs)

	baseturfs = new_baseturfs
	created_baseturf_lists[new_baseturfs[new_baseturfs.len]] = new_baseturfs.Copy()
	return new_baseturfs

// Take the input as baseturfs and put it underneath the current baseturfs
// If fake_turf_type is provided and new_baseturfs is not the baseturfs list will be created identical to the turf type's
// If both or just new_baseturfs is provided they will be inserted below the existing baseturfs
/turf/proc/PlaceOnBottom(list/new_baseturfs, turf/fake_turf_type)
	if(fake_turf_type)
		if(!new_baseturfs)
			if(!length(baseturfs))
				baseturfs = list(baseturfs)
			var/list/old_baseturfs = baseturfs.Copy()
			assemble_baseturfs(fake_turf_type)
			if(!length(baseturfs))
				baseturfs = list(baseturfs)
			baseturfs -= baseturfs & GLOB.blacklisted_automated_baseturfs
			baseturfs += old_baseturfs
			return
		else if(!length(new_baseturfs))
			new_baseturfs = list(new_baseturfs, fake_turf_type)
		else
			new_baseturfs += fake_turf_type
	if(!length(baseturfs))
		baseturfs = list(baseturfs)
	baseturfs.Insert(1, new_baseturfs)

/turf/baseturf_bottom
	name = "Z-level baseturf placeholder"
	desc = "Marker for z-level baseturf, usually resolves to space."
	baseturfs = /turf/baseturf_bottom


/turf/proc/add_vomit_floor(mob/living/carbon/M, var/toxvomit = 0)
	var/obj/effect/decal/cleanable/vomit/this = new /obj/effect/decal/cleanable/vomit(src)

	// Make toxins vomit look different
	if(toxvomit)
		this.icon_state = "vomittox_[pick(1,4)]"


/turf/proc/visibilityChanged()
	GLOB.cameranet.updateVisibility(src)
	// The cameranet usually handles this for us, but if we've just been
	// recreated we should make sure we have the cameranet vis_contents.
	var/datum/camerachunk/C = GLOB.cameranet.chunkGenerated(x, y, z)
	if(C)
		if(C.obscuredTurfs[src])
			vis_contents += GLOB.cameranet.vis_contents_objects
		else
			vis_contents -= GLOB.cameranet.vis_contents_objects


/turf/AllowDrop()
	return TRUE


/turf/contents_explosion(severity, target)
	for(var/i in contents)
		var/atom/A = i
		if(!QDELETED(A) && A.level >= severity)
			A.ex_act(severity, target)