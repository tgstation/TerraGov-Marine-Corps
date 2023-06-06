/obj/effect/manifest
	name = "manifest"
	icon = 'icons/mob/screen/generic.dmi'
	icon_state = "x"
	resistance_flags = UNACIDABLE

/obj/effect/manifest/Initialize(mapload)
	. = ..()
	invisibility = INVISIBILITY_MAXIMUM

/obj/effect/manifest/proc/manifest()
	var/dat = "<B>Crew Manifest</B>:<BR>"
	for(var/mob/living/carbon/human/M in GLOB.human_mob_list)
		dat += "    [M.get_paygrade(0)] <B>[M.name]</B> -  [M.get_assignment()]<BR>"
	var/obj/item/paper/P = new(loc)
	P.info = dat
	P.name = "paper- 'Crew Manifest'"
	qdel(src)
