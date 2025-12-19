/obj/machinery/deployable/dispenser/medic
	name = "NM Automedical dispenser"
	desc = "The Novamed Automedical dispenser is a machine capable of holding a large amount of items on it, while also healing nearby non-synthetics. Your allies will often ask you to lay down one of these."
	color = COLOR_DARK_CYAN

/obj/machinery/deployable/dispenser/medic/deploy()
	affecting_list = list()
	for(var/mob/living/carbon/human/human in view(2, src))
		if((human.species.species_flags & ROBOTIC_LIMBS)) // can only affect nonrobots
			continue
		RegisterSignal(human, COMSIG_QDELETING, PROC_REF(on_affecting_qdel))
		affecting_list[human] = beam(human, "medbeam", maxdistance = 3)
		RegisterSignal(affecting_list[human], COMSIG_QDELETING, PROC_REF(on_beam_qdel))
		human.playsound_local(get_turf(src), 'sound/machines/dispenser/dispenser_heal.ogg', 50)
	for(var/turf/turfs AS in RANGE_TURFS(2, src))
		RegisterSignal(turfs, COMSIG_ATOM_ENTERED, PROC_REF(entered_tiles))
	active = TRUE
	START_PROCESSING(SSobj, src)

/obj/machinery/deployable/dispenser/medic/process()
	for(var/mob/living/carbon/human/affecting AS in affecting_list)
		if(!line_of_sight(src, affecting, 2))
			qdel(affecting_list[affecting])
			affecting_list -= affecting
			UnregisterSignal(affecting, COMSIG_QDELETING)
			continue
		affecting.heal_overall_damage(2, 2, FALSE, TRUE)
		affecting.adjustOxyLoss(-0.5)
		affecting.adjustToxLoss(-0.5)

/obj/machinery/deployable/dispenser/medic/entered_tiles(datum/source, mob/living/carbon/human/entering)
	//SIGNAL_HANDLER (issues with parenting if it dont work we'll have to find something else)
	if(!ishuman(entering) || (entering.species.species_flags & ROBOTIC_LIMBS)) // can only affect nonrobots
		return
	if(entering in affecting_list)
		return
	if(!line_of_sight(src, entering))
		return

	RegisterSignal(entering, COMSIG_QDELETING, PROC_REF(on_affecting_qdel))
	entering.playsound_local(get_turf(src), 'sound/machines/dispenser/dispenser_heal.ogg', 50)
	affecting_list[entering] = beam(entering, "medbeam", maxdistance = 3)
	RegisterSignal(affecting_list[entering], COMSIG_QDELETING, PROC_REF(on_beam_qdel))

/obj/item/storage/backpack/dispenser/medic
	name = "NM automedical dispenser"
	desc = "The Novamed Automedical dispenser is a machine capable of holding a large amount of items on it, while also healing nearby non-synthetics. Your allies will often ask you to lay down one of these."
	color = COLOR_DARK_CYAN

/obj/item/storage/backpack/dispenser/medic/Initialize(mapload, ...)
	. = ..()
	remove_component(/datum/component/deployable_item) //get rid of old
	AddComponent(/datum/component/deployable_item, /obj/machinery/deployable/dispenser/medic, 0, 0)
