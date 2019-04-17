/datum/job/other
	department_flag = J_FLAG_MISC


//Colonist
/datum/job/other/colonist
	title = "Colonist"
	paygrade = "C"
	access = list(ACCESS_IFF_MARINE)
	minimal_access = list(ACCESS_IFF_MARINE)
	flag = MISC_COLONIST
	outfit = /datum/outfit/job/other/colonist


/datum/outfit/job/other/colonist
	name = "Colonist"
	jobtype = /datum/job/other/colonist

	id = /obj/item/card/id
	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/marine
	l_store = /obj/item/storage/pouch/survival/full
	r_store = /obj/item/radio


//Passenger
/datum/job/other/passenger
	title = "Passenger"
	paygrade = "C"
	access = list(ACCESS_IFF_MARINE)
	minimal_access = list(ACCESS_IFF_MARINE)
	flag = MISC_PASSENGER


//Pizza Deliverer
/datum/job/other/pizza
	title = "Pizza Deliverer"
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	flag = MISC_PIZZA
	outfit = /datum/outfit/job/other/pizza
	skills_type = /datum/skills/pfc


/datum/outfit/job/other/pizza
	name = "Pizza Deliverer"
	jobtype = /datum/job/other/pizza

	id = /obj/item/card/id/silver
	w_uniform = /obj/item/clothing/under/pizza
	belt = /obj/item/weapon/gun/pistol/holdout
	shoes = /obj/item/clothing/shoes/red
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/soft/red
	r_store = /obj/item/radio
	l_store = /obj/item/reagent_container/food/drinks/cans/dr_gibb
	back = /obj/item/storage/backpack/satchel


//Spatial Agent
/datum/job/other/spatial_agent
	title = "Spatial Agent"
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	flag = MISC_SPATIAL_AGENT
	skills_type = /datum/skills/spatial_agent
	outfit = /datum/outfit/job/other/spatial_agent


/datum/outfit/job/other/spatial_agent
	name = "Spatial Agent"
	jobtype = /datum/job/other/spatial_agent

	id = /obj/item/card/id/silver
	w_uniform = /obj/item/clothing/under/rank/centcom_commander/sa
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/marinechief/sa
	gloves = /obj/item/clothing/gloves/marine/officer/chief/sa
	glasses = /obj/item/clothing/glasses/sunglasses/sa
	back = /obj/item/storage/backpack/marine/satchel