/mob/living/silicon/controlled
	name = "meme man"
	icon = 'icons/mob/human.dmi'
	icon_state = "body_m_s"
	var/move_delay = 1

/mob/living/silicon/controlled/Initialize()
	. = ..()
	for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
		to_chat(ai, "AI shell [name] created.")
	GLOB.aiShells += src
	

/mob/living/silicon/controlled/Destroy()
	for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
		to_chat(ai, "AI shell [name] destroyed.")
	GLOB.aiShells -= src
	..()

/mob/living/silicon/controlled/proc/startControl(mob/living/silicon/ai/AI)
	return

/mob/living/silicon/controlled/proc/stopControl(mob/living/silicon/ai/AI)
	return

/mob/living/silicon/controlled/relaymove(mob/luser, direct)
	if(world.time > last_move_time + move_delay)
		. = step(src, direct)