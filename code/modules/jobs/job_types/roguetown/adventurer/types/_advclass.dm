/datum/advclass
	var/name
	var/outfit
	var/tutorial = "Choose me!"
	var/list/allowed_sexes = list("male","female")
	var/list/allowed_races = list("Humen",
	"Humen",
	"Elf",
	"Elf",
	"Dark Elf",
	"Dwarf",
	"Dwarf"
	)
	var/list/allowed_patrons = ALL_PATRON_NAMES_LIST
	var/list/allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)
	var/pickprob = 100
	var/maxchosen = -1
	var/amtchosen = 0
	var/plevel_req = 0
	var/special_req = FALSE //check the json for our ckey
	var/whitelist_req = FALSE
	var/ispilgrim = FALSE
	var/isvillager = FALSE
	var/horse = FALSE
	var/vampcompat = TRUE

/datum/advclass/proc/equipme(mob/living/carbon/human/H)
	if(!H)
		return FALSE

	if(outfit)
		H.equipOutfit(outfit)

	post_equip(H)

	H.advjob = name
	H.advsetup = 0
	H.invisibility = null
	H.cure_blind("advsetup")
	H.SetStun(0)
	sleep(1)
	testing("[H] spawn troch")
	var/obj/item/flashlight/flare/torch/T = new()
	T.spark_act()
	H.put_in_hands(T)

	var/turf/TU = get_turf(H)
	if(TU)
		if(horse)
			new horse(TU)

	if(isvillager)
		for(var/mob/M in GLOB.billagerspawns)
			to_chat(M, "<span class='info'>[H.real_name] is the [name].</span>")
		GLOB.billagerspawns -= H

/datum/advclass/proc/post_equip(mob/living/carbon/human/H)
	addtimer(CALLBACK(H,/mob/living/carbon/human.proc/add_credit), 20)
	return
