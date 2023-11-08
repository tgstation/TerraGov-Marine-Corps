/datum/hive_upgrade/defence/oblivion
    name = "Oblivion"
    desc = "Destroy the bodies beneath you "
    icon = "smartminions"
    psypoint_cost = 1000
    flags_gamemode = ABILITY_NUCLEARWAR

/datum/hive_upgrade/defence/oblivion/can_buy(mob/living/carbon/xenomorph/buyer, silent = TRUE)
	. = ..()
	if(!.)
		return
	var/turf/T = get_turf(buyer)
	var/mob/living/carbon/human/H = locate() in T
	var/mob/living/carbon/human/species/synthetic = locate() in T
	if(!H || H.stat != DEAD || synthetic)
		if(!silent)
			to_chat(buyer, span_xenowarning("You cannot destroy nothing or alive"))
		return FALSE

	return TRUE

/datum/hive_upgrade/defence/oblivion/on_buy(mob/living/carbon/xenomorph/buyer)

	if(!can_buy(buyer, FALSE))
		return FALSE

	var/turf/T = get_turf(buyer)
	var/mob/living/carbon/human/H = locate() in T
	xeno_message("[buyer] sent [H] into oblivion!", "xenoannounce", 5, buyer.hivenumber)
	to_chat(buyer, span_xenowarning("WE HAVE SENT THE [H] INTO OBLIVION"))
	H.gib()

	log_game("[buyer] sent [H] into oblivion, spending [psypoint_cost] psy points in the process")


	return ..()

/datum/hive_upgrade/building/silo
	psypoint_cost = 600

/datum/hive_upgrade/building/pherotower
	psypoint_cost = 100

/datum/hive_upgrade/defence/turret
	psypoint_cost = 50

/datum/hive_upgrade/defence/turret/sticky
	psypoint_cost = 25
