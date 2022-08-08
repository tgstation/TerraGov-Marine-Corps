/////////For remote construction of FOB using a computer on the ship during setup phase
GLOBAL_LIST_INIT(dropship_lzs, typecacheof(list(/area/shuttle/drop1/lz1, /area/shuttle/drop2/lz2)))
GLOBAL_LIST_INIT(blocked_remotebuild_turfs, typecacheof(list(/turf/closed, /turf/open/beach/sea)))
GLOBAL_LIST_INIT(blocked_remotebuild_objs, typecacheof(list(/obj/machinery/computer/camera_advanced/remote_fob, /obj/structure/window, /obj/machinery/door/poddoor)))
/////////////////////////////// Drone Mob

/mob/camera/aiEye/remote/fobdrone
	name = "Remote Construction Drone"
	icon = 'icons/Marine/remotefob.dmi'
	icon_state = "drone"
	use_static = FALSE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	light_system = MOVABLE_LIGHT
	light_range = 6
	light_power = 4
	light_on = TRUE

	var/area/starting_area
	var/turf/spawnloc

/mob/camera/aiEye/remote/fobdrone/Initialize()
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
	user.see_invisible = FALSE
	user.sight = SEE_SELF|SEE_TURFS
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_NV_TRAIT
	user.see_in_dark = 7
	return TRUE
