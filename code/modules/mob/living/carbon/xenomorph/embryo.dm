/obj/item/alien_embryo
	name = "alien embryo"
	desc = "All slimy and yucky."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Larva Dead"
	var/grinder_datum = /datum/reagent/consumable/larvajelly //good ol cookin
	var/grinder_amount = 5
	var/mob/living/affected_mob

/obj/item/alien_embryo/Initialize()
	. = ..()
	if(!isliving(loc))
		return
	affected_mob = loc
	affected_mob.status_flags |= LARVA_HOST
	log_combat(affected_mob, null, "been infected with an embryo")
	START_PROCESSING(SSobj, src)
	if(iscarbon(affected_mob))
		var/mob/living/carbon/C = affected_mob
		C.med_hud_set_status()


/obj/item/alien_embryo/Destroy()
	if(affected_mob)
		log_combat(affected_mob, null, "had their embryo removed")
		affected_mob.status_flags &= ~(LARVA_HOST)
		if(iscarbon(affected_mob))
			var/mob/living/carbon/C = affected_mob
			C.med_hud_set_status()
		STOP_PROCESSING(SSobj, src)
		affected_mob = null
	return ..()


/obj/item/alien_embryo/process()
	if(!affected_mob)
		qdel(src)
		return PROCESS_KILL

	if(loc != affected_mob)
		affected_mob.status_flags &= ~(LARVA_HOST)
		if(iscarbon(affected_mob))
			var/mob/living/carbon/C = affected_mob
			C.med_hud_set_status()
		affected_mob = null
		return PROCESS_KILL

	if(affected_mob.stat == DEAD)
		return PROCESS_KILL

	if(HAS_TRAIT(affected_mob, TRAIT_STASIS))
		return //If they are in cryo, bag or cell, the embryo won't grow.

	affected_mob.reagents.add_reagent(/datum/reagent/zombium, 0.15)
