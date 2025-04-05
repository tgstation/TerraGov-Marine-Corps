/mob/living/brain/death(gibbing, deathmessage = "", silent)
	if(stat == DEAD)
		return ..()
	if(!gibbing && istype(container, /obj/item/mmi)) //If not gibbing but in a container.
		container.icon_state = "mmi_dead"
		deathmessage = "beeps shrilly as the MMI flatlines!"
	return ..()


/mob/living/brain/gib()
	if(istype(container, /obj/item/mmi))
		qdel(container)//Gets rid of the MMI if there is one
	if(loc)
		if(istype(loc,/obj/item/organ/brain))
			qdel(loc)//Gets rid of the brain item
	..()
