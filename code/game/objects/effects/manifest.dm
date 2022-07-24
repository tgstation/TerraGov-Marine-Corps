/atom/movable/effect/manifest
	name = "manifest"
	icon = 'icons/mob/screen/generic.dmi'
	icon_state = "x"
	resistance_flags = UNACIDABLE

/atom/movable/effect/manifest/Initialize()
	. = ..()
	invisibility = INVISIBILITY_MAXIMUM

/atom/movable/effect/manifest/proc/manifest()
	var/dat = "<B>Crew Manifest</B>:<BR>"
	for(var/mob/living/carbon/human/M in GLOB.human_mob_list)
		dat += text("    [] <B>[]</B> -  []<BR>", M.get_paygrade(0), M.name, M.get_assignment())
	var/obj/item/paper/P = new(loc)
	P.info = dat
	P.name = "paper- 'Crew Manifest'"
	qdel(src)
