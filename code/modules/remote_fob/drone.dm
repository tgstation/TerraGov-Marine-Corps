/////////For remote construction of FOB using a computer on the ship during setup phase
GLOBAL_LIST_INIT(dropship_lzs, typecacheof(list(/area/shuttle/drop1/lz1, /area/shuttle/drop2/lz2)))
GLOBAL_LIST_INIT(blocked_remotebuild_turfs, typecacheof(list(/turf/closed)))
GLOBAL_LIST_INIT(blocked_remotebuild_objs, typecacheof(list(/obj/machinery/computer/camera_advanced/remote_fob, /obj/structure/window, /obj/machinery/door/poddoor)))
/////////////////////////////// Drone Mob

/mob/camera/aiEye/remote/fobdrone
	name = "Remote Construction Drone"
	icon = 'icons/obj/machines/fob.dmi'
	icon_state = "drone"
	use_static = FALSE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	light_system = MOVABLE_LIGHT
	light_range = 6
	light_power = 4
	light_on = TRUE
	move_delay = 0.2 SECONDS
	acceleration = FALSE

	var/area/starting_area
	var/turf/spawnloc

/mob/camera/aiEye/remote/fobdrone/Initialize(mapload)
	. = ..()
	starting_area = get_area(loc)

/mob/camera/aiEye/remote/fobdrone/Destroy()
	starting_area = null
	spawnloc = null
	return ..()

/mob/camera/aiEye/remote/fobdrone/setLoc(atom/target) //unrestricted movement inside the landing zone
	if(is_type_in_typecache(target, GLOB.blocked_remotebuild_turfs))
		return
	for(var/atom/movable/thing in target)
		if(is_type_in_typecache(thing, GLOB.blocked_remotebuild_objs))
			return
	return ..()

/mob/camera/aiEye/remote/fobdrone/relaymove(mob/user, direct)
	setDir(closest_cardinal_dir(direct)) //This camera eye is visible as a drone, and needs to keep the dir updated
	return ..()

/mob/camera/aiEye/remote/fobdrone/update_remote_sight(mob/living/user)
	user.set_invis_see(0)
	user.set_sight(SEE_SELF|SEE_TURFS)
	user.lighting_cutoff = LIGHTING_CUTOFF_HIGH
	user.sync_lighting_plane_cutoff()
	return TRUE
