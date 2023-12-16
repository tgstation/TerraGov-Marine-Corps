
/*
/turf

	/open - all turfs with density = FALSE are turf/open

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

	// baseturfs can be either a list or a single turf type.
	// In class definition like here it should always be a single type.
	// A list will be created in initialization that figures out the baseturf's baseturf etc.
	// In the case of a list it is sorted from bottom layer to top.
	// This shouldn't be modified directly, use the helper procs.
	var/list/baseturfs = /turf/baseturf_bottom
	luminosity = 1

	var/changing_turf = FALSE

	/// %-reduction-based armor.
	var/datum/armor/soft_armor
	/// Flat-damage-reduction-based armor.
	var/datum/armor/hard_armor

	///Lumcount added by sources other than lighting datum objects, such as the overlay lighting component.
	var/dynamic_lumcount = 0
	///List of light sources affecting this turf.
	///Which directions does this turf block the vision of, taking into account both the turf's opacity and the movable opacity_sources.
	var/directional_opacity = NONE
	///Lazylist of movable atoms providing opacity sources.
	var/list/atom/movable/opacity_sources

	///Icon-smoothing variable to map a diagonal wall corner with a fixed underlay.
	var/list/fixed_underlay = null

/turf/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE) // anti laggies
	if(flags_atom & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	ENABLE_BITFIELD(flags_atom, INITIALIZED)

	// by default, vis_contents is inherited from the turf that was here before
	vis_contents.Cut()

	assemble_baseturfs()

	levelupdate()

	visibilityChanged()

	for(var/atom/movable/AM in src)
		Entered(AM)


	if(light_power && light_range)
		update_light()

	//Get area light
	var/area/A = loc
	if(A?.lighting_effect)
		add_overlay(A.lighting_effect)

	if(opacity)
		directional_opacity = ALL_CARDINALS

	if(islist(soft_armor))
		soft_armor = getArmor(arglist(soft_armor))
	else if (!soft_armor)
		soft_armor = getArmor()
	else if (!istype(soft_armor, /datum/armor))
		stack_trace("Invalid type [soft_armor.type] found in .soft_armor during /turf Initialize()")

	if(islist(hard_armor))
		hard_armor = getArmor(arglist(hard_armor))
	else if (!hard_armor)
		hard_armor = getArmor()
	else if (!istype(hard_armor, /datum/armor))
		stack_trace("Invalid type [hard_armor.type] found in .hard_armor during /turf Initialize()")

	if (length(smoothing_groups))
		sortTim(smoothing_groups) //In case it's not properly ordered, let's avoid duplicate entries with the same values.
		SET_BITFLAG_LIST(smoothing_groups)
	if (length(canSmoothWith))
		sortTim(canSmoothWith)
		if(canSmoothWith[length(canSmoothWith)] > MAX_S_TURF) //If the last element is higher than the maximum turf-only value, then it must scan turf contents for smoothing targets.
			smoothing_flags |= SMOOTH_OBJ
		SET_BITFLAG_LIST(canSmoothWith)
	if (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)

	return INITIALIZE_HINT_NORMAL


/turf/Destroy(force)
	if(!changing_turf)
		stack_trace("Incorrect turf deletion")
	changing_turf = FALSE
	if(force)
		..()
		//this will completely wipe turf state
		var/turf/B = new world.turf(src)
		for(var/A in B.contents)
			qdel(A)
		for(var/I in B.vars)
			B.vars[I] = null
		return QDEL_HINT_IWILLGC
	visibilityChanged()
	DISABLE_BITFIELD(flags_atom, INITIALIZED)
	soft_armor = null
	hard_armor = null
	QDEL_NULL(current_acid)
	..()
	return QDEL_HINT_IWILLGC

/// WARNING WARNING
/// Turfs DO NOT lose their signals when they get replaced, REMEMBER THIS
/// It's possible because turfs are fucked, and if you have one in a list and it's replaced with another one, the list ref points to the new turf
/// We do it because moving signals over was needlessly expensive, and bloated a very commonly used bit of code
/turf/clear_signal_refs()
	return

/turf/Enter(atom/movable/mover, direction)
	// Do not call ..()
	// Byond's default turf/Enter() doesn't have the behaviour we want with Bump()
	// By default byond will call Bump() on the first dense object in contents
	//Then, check the turf itself
	if(!CanPass(mover, src))
		switch(SEND_SIGNAL(mover, COMSIG_MOVABLE_PREBUMP_TURF, src))
			if(COMPONENT_MOVABLE_PREBUMP_STOPPED)
				return FALSE //No need for a bump, already procesed.
			if(COMPONENT_MOVABLE_PREBUMP_PLOWED)
				//Continue. We've plowed through the obstacle.
			else
				mover.Bump(src)
				return FALSE
	var/atom/firstbump
	for(var/i in contents)
		if(QDELETED(mover))
			return FALSE //We were deleted, do not attempt to proceed with movement.
		if(i == mover || i == mover.loc) // Multi tile objects and moving out of other objects
			continue
		var/atom/movable/thing = i
		if(CHECK_MULTIPLE_BITFIELDS(thing.pass_flags, HOVERING))
			continue
		if(thing.status_flags & INCORPOREAL)
			continue
		if(thing.Cross(mover))
			continue
		var/signalreturn = SEND_SIGNAL(mover, COMSIG_MOVABLE_PREBUMP_MOVABLE, thing)
		if(signalreturn & COMPONENT_MOVABLE_PREBUMP_STOPPED)
			return FALSE //Stopped, bump no longer necessary.
		if(signalreturn & COMPONENT_MOVABLE_PREBUMP_PLOWED)
			continue //We've plowed through.
		if(signalreturn & COMPONENT_MOVABLE_PREBUMP_ENTANGLED)
			return TRUE //We've entered the tile and gotten entangled inside it.
		if(QDELETED(mover)) //Mover deleted from Cross/CanPass, do not proceed.
			return FALSE
		else if(!firstbump || ((thing.layer > firstbump.layer || thing.flags_atom & ON_BORDER) && !(firstbump.flags_atom & ON_BORDER)))
			firstbump = thing
	if(QDELETED(mover)) //Mover deleted from Cross/CanPass/Bump, do not proceed.
		return FALSE
	if(firstbump)
		return mover.Bump(firstbump)
	return TRUE



/turf/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(ismob(arrived))
		var/mob/M = arrived
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

/turf/get_soft_armor(armor_type, proj_def_zone)
	return soft_armor.getRating(armor_type)

/turf/get_hard_armor(armor_type, proj_def_zone)
	return hard_armor.getRating(armor_type)

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.flags_atom & INITIALIZED)
			SEND_SIGNAL(O, COMSIG_OBJ_HIDE, intact_tile)


// Creates a new turf
// new_baseturfs can be either a single type or list of types, formated the same as baseturfs. see turf.dm
/turf/proc/ChangeTurf(path, list/new_baseturfs, flags)
	switch(path)
		if(null)
			return
		if(/turf/baseturf_bottom)
			path = SSmapping.level_trait(z, ZTRAIT_BASETURF) || /turf/open/space
			if (!ispath(path))
				path = text2path(path)
				if (!ispath(path))
					warning("Z-level [z] has invalid baseturf '[SSmapping.level_trait(z, ZTRAIT_BASETURF)]'")
					path = /turf/open/space
		if(/turf/open/space/basic)
			// basic doesn't initialize and this will cause issues
			// no warning though because this can happen naturaly as a result of it being built on top of
			path = /turf/open/space

	if(!GLOB.use_preloader && path == type && !(flags & CHANGETURF_FORCEOP) && (baseturfs == new_baseturfs)) // Don't no-op if the map loader requires it to be reconstructed
		return src
	if(flags & CHANGETURF_SKIP)
		return new path(src)

	//static lighting
	var/old_lighting_object = static_lighting_object
	var/old_lighting_corner_NE = lighting_corner_NE
	var/old_lighting_corner_SE = lighting_corner_SE
	var/old_lighting_corner_SW = lighting_corner_SW
	var/old_lighting_corner_NW = lighting_corner_NW
	//hybrid lighting
	var/list/old_hybrid_lights_affecting = hybrid_lights_affecting?.Copy()
	var/old_directional_opacity = directional_opacity

	var/list/old_baseturfs = baseturfs

	var/list/post_change_callbacks = list()
	SEND_SIGNAL(src, COMSIG_TURF_CHANGE, path, new_baseturfs, flags, post_change_callbacks)

	changing_turf = TRUE
	qdel(src)	//Just get the side effects and call Destroy
	//We do this here so anything that doesn't want to persist can clear itself
	var/list/old__listen_lookup = _listen_lookup?.Copy()
	var/list/old_signal_procs = _signal_procs?.Copy()
	var/turf/W = new path(src)

	// WARNING WARNING
	// Turfs DO NOT lose their signals when they get replaced, REMEMBER THIS
	// It's possible because turfs are fucked, and if you have one in a list and it's replaced with another one, the list ref points to the new turf
	if(old__listen_lookup)
		LAZYOR(W._listen_lookup, old__listen_lookup)
	if(old_signal_procs)
		LAZYOR(W._signal_procs, old_signal_procs)

	for(var/datum/callback/callback AS in post_change_callbacks)
		callback.InvokeAsync(W)

	if(new_baseturfs)
		W.baseturfs = new_baseturfs
	else
		W.baseturfs = old_baseturfs

	if(!(flags & CHANGETURF_DEFER_CHANGE))
		W.AfterChange(flags)

	W.hybrid_lights_affecting = old_hybrid_lights_affecting
	W.dynamic_lumcount = dynamic_lumcount

	lighting_corner_NE = old_lighting_corner_NE
	lighting_corner_SE = old_lighting_corner_SE
	lighting_corner_SW = old_lighting_corner_SW
	lighting_corner_NW = old_lighting_corner_NW

	//static Update
	if(SSlighting.initialized)
		recalculate_directional_opacity()

		W.static_lighting_object = old_lighting_object

		if(static_lighting_object && !static_lighting_object.needs_update)
			static_lighting_object.update()

	//Since the old turf was removed from hybrid_lights_affecting, readd the new turf here
	if(W.hybrid_lights_affecting)
		for(var/atom/movable/lighting_mask/mask AS in W.hybrid_lights_affecting)
			LAZYADD(mask.affecting_turfs, W)

	if(W.directional_opacity != old_directional_opacity)
		W.reconsider_lights()

	var/area/thisarea = get_area(W)
	if(thisarea.lighting_effect)
		W.add_overlay(thisarea.lighting_effect)

	if(!W.smoothing_behavior == NO_SMOOTHING)
		return W
	else
		for(var/dirn in GLOB.alldirs)
			var/turf/D = get_step(W,dirn)
			if(isnull(D))
				continue
			QUEUE_SMOOTH(D)
			QUEUE_SMOOTH_NEIGHBORS(D)
	return W

/// Take off the top layer turf and replace it with the next baseturf down
/turf/proc/ScrapeAway(amount=1, flags)
	if(!amount)
		return
	if(length(baseturfs))
		var/list/new_baseturfs = baseturfs.Copy()
		var/turf_type = new_baseturfs[max(1, length(new_baseturfs) - amount + 1)]
		while(ispath(turf_type, /turf/baseturf_skipover))
			amount++
			if(amount > length(new_baseturfs))
				CRASH("The bottomost baseturf of a turf is a skipover [src]([type])")
			turf_type = new_baseturfs[max(1, length(new_baseturfs) - amount + 1)]
		new_baseturfs.len -= min(amount, length(new_baseturfs) - 1) // No removing the very bottom
		if(length(new_baseturfs) == 1)
			new_baseturfs = new_baseturfs[1]
		return ChangeTurf(turf_type, new_baseturfs, flags)

	if(baseturfs == type)
		return src

	return ChangeTurf(baseturfs, baseturfs, flags) // The bottom baseturf will never go away

/turf/proc/empty(turf_type = /turf/open/space, baseturf_type, list/ignore_typecache, flags)
	// Remove all atoms except  landmarks, docking ports, ai nodes
	var/static/list/ignored_atoms = typecacheof(list(/mob/dead, /obj/effect/landmark, /obj/docking_port, /obj/effect/ai_node))
	var/list/allowed_contents = typecache_filter_list_reverse(GetAllContentsIgnoring(ignore_typecache), ignored_atoms)
	allowed_contents -= src
	for(var/i in 1 to length(allowed_contents))
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
	var/list/L = list()
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
/turf/proc/AddTracks(typepath,bloodDNA,comingdir,goingdir,bloodcolor="#A10808")
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


/turf/proc/ceiling_debris_check(size = 1)
	return

/turf/proc/ceiling_debris(size = 1) //debris falling in response to airstrikes, etc
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
					visible_message(span_boldnotice("Shards of glass rain down from above!"))
				for(var/i=1, i<=amount, i++)
					new /obj/item/shard(pick(turfs))
					new /obj/item/shard(pick(turfs))
		if(CEILING_METAL, CEILING_OBSTRUCTED)
			playsound(src, "sound/effects/metal_crash.ogg", 60, 1)
			spawn(8)
				if(amount >1)
					visible_message(span_boldnotice("Pieces of metal crash down from above!"))
				for(var/i=1, i<=amount, i++)
					new /obj/item/stack/sheet/metal(pick(turfs))
		if(CEILING_UNDERGROUND, CEILING_DEEP_UNDERGROUND)
			playsound(src, "sound/effects/meteorimpact.ogg", 60, 1)
			spawn(8)
				if(amount >1)
					visible_message(span_boldnotice("Chunks of rock crash down from above!"))
				for(var/i=1, i<=amount, i++)
					new /obj/item/ore(pick(turfs))
					new /obj/item/ore(pick(turfs))
		if(CEILING_UNDERGROUND_METAL, CEILING_DEEP_UNDERGROUND_METAL)
			playsound(src, "sound/effects/metal_crash.ogg", 60, 1)
			spawn(8)
				for(var/i=1, i<=amount, i++)
					new /obj/item/stack/sheet/metal(pick(turfs))
					new /obj/item/ore(pick(turfs))

/turf/proc/ceiling_desc()
	var/area/A = get_area(src)
	switch(A.ceiling)
		if(CEILING_NONE)
			return "It is in the open."
		if(CEILING_GLASS)
			return "The ceiling above is glass."
		if(CEILING_METAL)
			return "The ceiling above is metal."
		if(CEILING_OBSTRUCTED)
			return "The ceiling above is metal. Nothing could land here."
		if(CEILING_UNDERGROUND)
			return "It is underground. The cavern roof lies above."
		if(CEILING_UNDERGROUND_METAL)
			return "It is underground. The ceiling above is metal."
		if(CEILING_DEEP_UNDERGROUND)
			return "It is deep underground. The cavern roof lies above."
		if(CEILING_DEEP_UNDERGROUND_METAL)
			return "It is deep underground. The ceiling above is metal."


/turf/proc/wet_floor()
	return

//////////////////////////////////////////////////////////

//Check if you can plant weeds on that turf.
//Does NOT return a message, just a 0 or 1.
/turf/proc/is_weedable()
	return !density

/turf/closed/wall/is_weedable()
	return TRUE

/turf/closed/wall/resin/is_weedable()
	return FALSE

/turf/open/space/is_weedable()
	return FALSE

/turf/open/ground/grass/is_weedable()
	return FALSE

/turf/open/floor/plating/ground/dirtgrassborder/is_weedable()
	return FALSE

/turf/open/liquid/water/is_weedable()
	return FALSE

/turf/open/ground/coast/is_weedable()
	return FALSE


/turf/open/floor/plating/ground/dirtgrassborder/autosmooth/buildable/is_weedable()
	return TRUE

/turf/open/ground/grass/weedable/is_weedable()
	return TRUE

/**
 * Checks for whether we can build advanced xeno structures here
 * Returns TRUE if present, FALSE otherwise
 */
/turf/proc/check_disallow_alien_fortification(mob/living/builder, silent = FALSE)
	var/area/ourarea = loc
	if(ourarea.flags_area & DISALLOW_WEEDING)
		if(!silent)
			to_chat(builder, span_warning("We cannot build in this area before the talls are out!"))
		return FALSE
	return TRUE

/**
 * Check if alien abilities can construct structure on the turf
 * Return TRUE if allowed, FALSE otherwise
 */
/turf/proc/check_alien_construction(mob/living/builder, silent = FALSE, planned_building)
	var/has_obstacle
	for(var/obj/O in contents)
		if(istype(O, /obj/item/clothing/mask/facehugger))
			var/obj/item/clothing/mask/facehugger/hugger_check = O
			if(hugger_check.stat != DEAD) //We don't care about dead huggers.
				if(!silent)
					to_chat(builder, span_warning("There is a little one here already. Best move it."))
				return FALSE
		if(istype(O, /obj/alien/egg))
			if(!silent)
				to_chat(builder, span_warning("There's already an egg here."))
			return FALSE
		if(istype(O, /obj/structure/xeno))
			if(!silent)
				to_chat(builder, span_warning("There's already a resin structure here!"))
			return FALSE
		if(istype(O, /obj/structure/xeno/plant))
			if(!silent)
				to_chat(builder, span_warning("There is a plant growing here, destroying it would be a waste to the hive."))
			return FALSE
		if(istype(O, /obj/structure/mineral_door) || istype(O, /obj/structure/ladder) || istype(O, /obj/alien/resin))
			has_obstacle = TRUE
			break
		if(istype(O, /obj/structure/bed))
			if(istype(O, /obj/structure/bed/chair/dropship/passenger))
				var/obj/structure/bed/chair/dropship/passenger/P = O
				if(P.chair_state != DROPSHIP_CHAIR_BROKEN)
					has_obstacle = TRUE
					break
			else if(istype(O, /obj/structure/bed/nest)) //We don't care about other beds/chairs/whatever the fuck.
				has_obstacle = TRUE
				break
		if(istype(O, /obj/structure/xeno/hivemindcore))
			has_obstacle = TRUE
			break

		if(istype(O, /obj/structure/cocoon))
			has_obstacle = TRUE
			break

		if(O.density && !(O.flags_atom & ON_BORDER))
			has_obstacle = TRUE
			break

	if(density || has_obstacle)
		if(!silent)
			to_chat(builder, span_warning("There's something built here already."))
		return FALSE
	return TRUE

/turf/closed/check_alien_construction(mob/living/builder, silent = FALSE, planned_building)
	if(!silent)
		to_chat(builder, span_warning("There's something built here already."))
	return FALSE

/turf/proc/can_dig_xeno_tunnel()
	return FALSE

/turf/open/ground/can_dig_xeno_tunnel()
	return TRUE

/turf/open/liquid/water/can_dig_xeno_tunnel()
	return FALSE

/turf/open/floor/plating/ground/snow/can_dig_xeno_tunnel()
	return TRUE

/turf/open/floor/plating/ground/ice/can_dig_xeno_tunnel()
	return TRUE

/turf/open/floor/can_dig_xeno_tunnel()
	return TRUE

/turf/open/floor/plating/catwalk/can_dig_xeno_tunnel()
	return FALSE

/turf/open/floor/mainship/research/containment/can_dig_xeno_tunnel()
	return FALSE

/turf/open/ground/jungle/can_dig_xeno_tunnel()
	return TRUE

/turf/open/ground/jungle/impenetrable/can_dig_xeno_tunnel()
	return FALSE

/turf/open/ground/jungle/water/can_dig_xeno_tunnel()
	return FALSE

/turf/open/floor/prison/can_dig_xeno_tunnel()
	return TRUE

/turf/open/lavaland/basalt/can_dig_xeno_tunnel()
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

/turf/open/lavaland/basalt/get_dirt_type()
	return DIRT_TYPE_LAVALAND

/turf/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!target)
		return FALSE

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
		change_type = new_baseturfs[length(new_baseturfs)]
		new_baseturfs.len--
		if(length(new_baseturfs))
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
			// with default inputs this would be Copy(clamp(2, -INFINITY, length(baseturfs)))
			// Don't forget a lower index is lower in the baseturfs stack, the bottom is baseturfs[1]
			target_baseturfs = copytarget.baseturfs.Copy(clamp(1 + ignore_bottom, 1 + length(copytarget.baseturfs) - depth, length(copytarget.baseturfs)))
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
		T.ChangeTurf(type)
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(color)
		T.atom_colours = atom_colours.Copy()
		T.update_atom_colour()
	if(T.dir != dir)
		T.setDir(dir)
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
	created_baseturf_lists[new_baseturfs[length(new_baseturfs)]] = new_baseturfs.Copy()
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


/turf/proc/add_vomit_floor(mob/living/carbon/M, toxvomit = 0)
	var/obj/effect/decal/cleanable/vomit/this = new /obj/effect/decal/cleanable/vomit(src)

	// Make toxins vomit look different
	if(toxvomit)
		this.icon_state = "vomittox_[pick(1,4)]"


/turf/proc/visibilityChanged()
	for(var/datum/cameranet/net AS in list(GLOB.cameranet, GLOB.som_cameranet))

		net.updateVisibility(src)
		// The cameranet usually handles this for us, but if we've just been
		// recreated we should make sure we have the cameranet vis_contents.
		var/datum/camerachunk/C = net.chunkGenerated(x, y, z)
		if(C)
			if(C.obscuredTurfs[src])
				vis_contents += net.vis_contents_opaque
			else
				vis_contents -= net.vis_contents_opaque


/turf/AllowDrop()
	return TRUE


/turf/contents_explosion(severity)
	for(var/thing in contents)
		var/atom/movable/thing_in_turf = thing
		if(thing_in_turf.resistance_flags & INDESTRUCTIBLE)
			continue
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highMovAtom[thing_in_turf] += list(src)
				if(thing_in_turf.flags_atom & PREVENT_CONTENTS_EXPLOSION)
					continue
				for(var/a in thing_in_turf.contents)
					SSexplosions.highMovAtom[a] += list(src)
			if(EXPLODE_HEAVY)
				SSexplosions.medMovAtom[thing_in_turf] += list(src)
				if(thing_in_turf.flags_atom & PREVENT_CONTENTS_EXPLOSION)
					continue
				for(var/a in thing_in_turf.contents)
					SSexplosions.medMovAtom[a] += list(src)
			if(EXPLODE_LIGHT)
				SSexplosions.lowMovAtom[thing_in_turf] += list(src)
				if(thing_in_turf.flags_atom & PREVENT_CONTENTS_EXPLOSION)
					continue
				for(var/a in thing_in_turf.contents)
					SSexplosions.lowMovAtom[a] += list(src)
			if(EXPLODE_WEAK)
				SSexplosions.weakMovAtom[thing_in_turf] += list(src)
				if(thing_in_turf.flags_atom & PREVENT_CONTENTS_EXPLOSION)
					continue
				for(var/a in thing_in_turf.contents)
					SSexplosions.weakMovAtom[a] += list(src)


/turf/vv_edit_var(var_name, new_value)
	var/static/list/banned_edits = list("x", "y", "z")
	if(var_name in banned_edits)
		return FALSE
	return ..()

/turf/balloon_alert_perform(mob/viewer, text)
	// Balloon alerts occuring on turf objects result in mass spam of alerts.
	// Thus, no more balloon alerts for turfs.
	return

///cleans any cleanable decals from the turf
/turf/proc/clean_turf()
	for(var/obj/effect/decal/cleanable/filth in src)
		qdel(filth) //dirty, filthy floor

/turf/proc/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = icon
	underlay_appearance.icon_state = icon_state
	underlay_appearance.dir = adjacency_dir
	return TRUE

///Are we able to teleport to this turf using in game teleport mechanics
/turf/proc/can_teleport_here()
	if(density)
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_TURF_TELEPORT_CHECK))
		return FALSE
	return TRUE
