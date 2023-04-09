#define SHORT 5/7
#define TALL 7/5

/**
 * squish.dm - (Mostly) ported from /tg/. All credit to the original author.
*/

/datum/element/squish
	element_flags = ELEMENT_DETACH

/datum/element/squish/Attach(datum/target, duration=20 SECONDS)
	. = ..()
	if(!iscarbon(target))
		return ELEMENT_INCOMPATIBLE

	var/mob/living/carbon/C = target
	addtimer(CALLBACK(src, PROC_REF(Detach), C), duration)
	C.transform = C.transform.Scale(TALL, SHORT)

/datum/element/squish/Detach(mob/living/carbon/C)
	. = ..()
	C.transform = C.transform.Scale(SHORT, TALL)

#undef SHORT
#undef TALL
