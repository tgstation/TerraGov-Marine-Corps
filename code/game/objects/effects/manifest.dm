/obj/effect/manifest
	name = "manifest"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	resistance_flags = UNACIDABLE

/obj/effect/manifest/New()

	src.invisibility = INVISIBILITY_MAXIMUM
	return

/obj/effect/manifest/proc/manifest()
	var/dat = "<B>Crew Manifest</B>:<BR>"
	for(var/mob/living/carbon/human/M in GLOB.human_mob_list)
		dat += text("    [] <B>[]</B> -  []<BR>", M.get_paygrade(0), M.name, M.get_assignment())
	var/obj/item/paper/P = new /obj/item/paper( src.loc )
	P.info = dat
	P.name = "paper- 'Crew Manifest'"
	//SN src = null
	qdel(src)
	return
