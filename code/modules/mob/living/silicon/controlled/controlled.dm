/mob/living/silicon/controlled
	name = "meme man"
	icon = 'icons/mob/human.dmi'
	icon_state = "body_m_s"

	var/move_delay = 1
	var/mob/living/silicon/ai/controllingAI
	var/obj/machinery/camera/camera

/mob/living/silicon/controlled/Initialize()
	. = ..()
	for(var/elem in GLOB.ai_list)
		var/mob/living/silicon/ai/ai = elem
		to_chat(ai, "AI shell [name] created.")
	GLOB.aiShells += src
	camera = new /obj/machinery/camera/borg(src)

/mob/living/silicon/controlled/Destroy()
	for(var/elem in GLOB.ai_list)
		var/mob/living/silicon/ai/ai = elem
		to_chat(ai, "AI shell [name] destroyed.")
	GLOB.aiShells -= src
	return ..()

/mob/living/silicon/controlled/proc/startControl(mob/living/silicon/ai/AI)
	controllingAI = AI
	return

/mob/living/silicon/controlled/proc/stopControl(mob/living/silicon/ai/AI)
	controllingAI = null
	return

/mob/living/silicon/controlled/update_camera_location(oldloc)
	if(QDELETED(camera))
		return

	addtimer(CALLBACK(src, .proc/do_camera_update, oldloc), 0.5 SECONDS)

/mob/living/silicon/controlled/do_camera_update(oldloc)
	if(QDELETED(camera) || get_turf(oldloc) == get_turf(src))
		return
	
	GLOB.cameranet.updatePortableCamera(camera)

/mob/living/silicon/controlled/relaymove(mob/luser, direct)
	if(world.time > last_move_time + move_delay)
		. = step(src, direct)
