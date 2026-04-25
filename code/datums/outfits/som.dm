/datum/outfit/job/som/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.underwear = 10
	H.undershirt = H.undershirt ? 10 : 0
	H.regenerate_icons()

/datum/outfit/job/som/squad/standard
	name = "SOM Standard"
	jobtype = /datum/job/som/squad/standard

	id = /obj/item/card/id/dogtag/som

/datum/outfit/job/som/squad/engineer
	name = "SOM Engineer"
	jobtype = /datum/job/som/squad/engineer

	id = /obj/item/card/id/dogtag/som

/datum/outfit/job/som/squad/medic
	name = "SOM Medic"
	jobtype = /datum/job/som/squad/medic

	id = /obj/item/card/id/dogtag/som

/datum/outfit/job/som/squad/veteran
	name = "SOM Veteran"
	jobtype = /datum/job/som/squad/veteran
	id = /obj/item/card/id/dogtag/som

/datum/outfit/job/som/squad/leader
	name = "SOM Leader"
	jobtype = /datum/job/som/squad/leader

	id = /obj/item/card/id/dogtag/som
