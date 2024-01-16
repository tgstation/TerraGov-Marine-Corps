// Camera mob, used by AI camera.
/mob/camera
	name = "camera mob"
	density = FALSE
	move_force = INFINITY
	move_resist = INFINITY
	resistance_flags = RESIST_ALL
	status_flags = GODMODE | INCORPOREAL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	see_in_dark = 7
	invisibility = INVISIBILITY_ABSTRACT // No one can see us
	sight = SEE_SELF
	move_on_shuttle = FALSE
	var/call_life = FALSE //TRUE if Life() should be called on this camera every tick of the mobs subystem, as if it were a living mob
	var/datum/cameranet/parent_cameranet


/mob/camera/Initialize(mapload, cameranet, new_faction)
	. = ..()
	if(call_life)
		GLOB.living_cameras += src
	parent_cameranet = cameranet ? cameranet : GLOB.cameranet


/mob/camera/Destroy()
	if(call_life)
		GLOB.living_cameras -= src
	return ..()


/mob/camera/forceMove(atom/destination)
	var/oldloc = loc
	loc = destination
	Moved(oldloc, NONE, TRUE)


/mob/camera/drop_held_item()
	return


/mob/camera/drop_all_held_items()
	return


/mob/camera/emote(act, m_type, message, intentional = FALSE)
	return
