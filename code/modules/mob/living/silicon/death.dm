/mob/living/silicon/spawn_gibs()
	robogibs(get_turf(src))


/mob/living/silicon/gib_animation()
	new /obj/effect/overlay/temp/gib_animation(loc, 0, src, "gibbed-r")


/mob/living/silicon/spawn_dust_remains()
	new /obj/effect/decal/remains/robot(loc)


/mob/living/silicon/dust_animation()
	new /obj/effect/overlay/temp/dust_animation(loc, 0, src, "dust-r")
