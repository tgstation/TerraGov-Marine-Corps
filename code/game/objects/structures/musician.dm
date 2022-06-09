/obj/structure/device/broken_piano
	name = "broken vintage piano"
	icon = 'icons/obj/musician.dmi'
	desc = "What a shame. This piano looks like it'll never play again. Ever. Don't even ask about it."
	icon_state = "pianobroken"
	anchored = TRUE
	density = TRUE
	coverage = 20

/obj/structure/device/broken_moog
	name = "broken vintage synthesizer"
	icon = 'icons/obj/musician.dmi'
	desc = "This spacemoog synthesizer is vintage, but trashed. Seems someone didn't like its hot fresh tunes."
	icon_state = "minimoogbroken"
	anchored = TRUE
	density = TRUE
	coverage = 15

/obj/structure/device/piano
	name = "space minimoog"
	icon = 'icons/obj/musician.dmi'
	icon_state = "minimoog"
	anchored = TRUE
	density = TRUE
	coverage = 20


/obj/structure/device/piano/Initialize()
	. = ..()
	if(prob(50))
		name = "space minimoog"
		desc = "This is a minimoog, like a space piano, but more spacey!"
		icon_state = "minimoog"
	else
		name = "space piano"
		desc = "This is a space piano, like a regular piano, but always in tune! Even if the musician isn't."
		icon_state = "piano"
