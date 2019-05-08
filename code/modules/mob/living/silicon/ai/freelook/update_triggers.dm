#define BORG_CAMERA_BUFFER 30

//UPDATE TRIGGERS, when the chunk (and the surrounding chunks) should update.

// TURFS

/turf
	var/image/obscured

/turf/proc/visibilityChanged()
	if(SSticker)
		cameranet.updateVisibility(src)

/turf/Destroy()
	visibilityChanged()
	. = ..()

/turf/New()
	..()
	visibilityChanged()



// STRUCTURES

/obj/structure/Destroy()
	if(SSticker?.current_state != GAME_STATE_STARTUP)
		cameranet.updateVisibility(src)
	return ..()

/obj/structure/New()
	. = ..()
	if(SSticker?.current_state != GAME_STATE_STARTUP)
		cameranet.updateVisibility(src)

// EFFECTS

/obj/effect/Destroy()
	if(SSticker?.current_state != GAME_STATE_STARTUP)
		cameranet.updateVisibility(src)
	return ..()

/obj/effect/New()
	. = ..()
	if(SSticker?.current_state != GAME_STATE_STARTUP)
		cameranet.updateVisibility(src)


// CAMERA

// An addition to deactivate which removes/adds the camera from the chunk list based on if it works or not.

/obj/machinery/camera/toggle_cam_status(mob/user, silent)
	..()
	if(can_use())
		cameranet.addCamera(src)
	else
		SetLuminosity(0)
		cameranet.removeCamera(src)

/obj/machinery/camera/New()
	..()
	cameranet.cameras += src //Camera must be added to global list of all cameras no matter what...
	var/list/open_networks = difflist(network,RESTRICTED_CAMERA_NETWORKS) //...but if all of camera's networks are restricted, it only works for specific camera consoles.
	if(open_networks.len) //If there is at least one open network, chunk is available for AI usage.
		cameranet.addCamera(src)

/obj/machinery/camera/Destroy()
	cameranet.cameras -= src
	var/list/open_networks = difflist(network,RESTRICTED_CAMERA_NETWORKS)
	if(open_networks.len)
		cameranet.removeCamera(src)
	. = ..()

#undef BORG_CAMERA_BUFFER