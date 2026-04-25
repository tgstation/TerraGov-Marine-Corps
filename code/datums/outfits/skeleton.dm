/datum/outfit/job/skeleton/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.set_species("Skeleton")

	H.name = GLOB.namepool[/datum/namepool/skeleton].random_name(H)
	H.real_name = H.name

/datum/outfit/job/skeleton/basic
	name = "Skeleton Man"
	jobtype = /datum/job/skeleton/basic

	id = /obj/item/card/id
	w_uniform = /obj/item/clothing/under/gladiator
	shoes = /obj/item/clothing/shoes/sandal
	head = /obj/item/clothing/head/helmet/gladiator
	belt = /obj/item/weapon/sword
	back = /obj/item/weapon/twohanded/spear
	ears = /obj/item/radio/headset/survivor
	r_pocket = /obj/item/flashlight
	l_pocket = /obj/item/tool/crowbar/red
	l_hand = /obj/item/reagent_containers/food/drinks/milk

/datum/outfit/job/skeleton/leader
	name = "Skeleton Commander"
	jobtype = /datum/job/skeleton/leader

	id = /obj/item/card/id
	w_uniform = /obj/item/clothing/under/gladiator
	shoes = /obj/item/clothing/shoes/sandal
	head = /obj/item/clothing/head/helmet/gladiator
	belt = /obj/item/weapon/sword
	back = /obj/item/weapon/twohanded/glaive
	ears = /obj/item/radio/headset/survivor
	r_pocket = /obj/item/flashlight
	l_pocket = /obj/item/reagent_containers/food/drinks/milk
	l_hand = /obj/item/reagent_containers/food/drinks/milk
