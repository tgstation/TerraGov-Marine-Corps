/mob/living/on_death()
	dizziness = 0
	jitteriness = 0
	reset_perspective(null)

	GLOB.alive_living_list -= src

	return ..()

///Proc called when siloing a mob
/mob/living/proc/siloed(obj/structure/resin/silo/siloed_to)
	return
