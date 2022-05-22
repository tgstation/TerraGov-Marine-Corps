/datum/job/skeleton
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/skeleton
	faction = FACTION_NEUTRAL


//Skeleton Man
/datum/job/skeleton/basic
	title = "Skeleton Man" // SKELETON MAAAAAAAAAAAN
	outfit = /datum/outfit/job/skeleton/basic


/datum/outfit/job/skeleton/basic
	name = "Skeleton Man"
	jobtype = /datum/job/skeleton/basic

	id = /obj/item/card/id
	w_uniform = /obj/item/clothing/under/gladiator
	shoes = /obj/item/clothing/shoes/sandal
	head = /obj/item/clothing/head/helmet/gladiator
	belt = /obj/item/weapon/claymore
	back = /obj/item/weapon/twohanded/spear
	ears = /obj/item/radio/headset/survivor
	r_store = /obj/item/flashlight
	l_store = /obj/item/tool/crowbar/red

/datum/outfit/job/skeleton/basic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/milk, SLOT_L_HAND)

//Skeleton Chief
/datum/job/skeleton/leader
	title = "Skeleton Commander"
	outfit = /datum/outfit/job/skeleton/leader


/datum/outfit/job/skeleton/leader
	name = "Skeleton Commander"
	jobtype = /datum/job/skeleton/leader

	id = /obj/item/card/id
	w_uniform = /obj/item/clothing/under/gladiator
	shoes = /obj/item/clothing/shoes/sandal
	head = /obj/item/clothing/head/helmet/gladiator
	belt = /obj/item/weapon/claymore
	back = /obj/item/weapon/twohanded/glaive
	ears = /obj/item/radio/headset/survivor
	r_store = /obj/item/flashlight
	l_store = /obj/item/reagent_containers/food/drinks/milk

/datum/outfit/job/skeleton/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/milk, SLOT_L_HAND)
