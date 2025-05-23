/datum/outfit/job/erp
	name = "ERP Prankster"
	jobtype = /datum/job/erp

	id = /obj/item/card/id/captains_spare
	ears = /obj/item/radio/headset/distress/erp
	mask = /obj/item/clothing/mask/gas/clown_hat
	gloves = /obj/item/clothing/gloves/marine/black
	back = /obj/item/storage/backpack/clown
	shoes = /obj/item/clothing/shoes/clown_shoes/erp
	w_uniform = /obj/item/clothing/under/rank/clown/erp
	wear_suit = /obj/item/clothing/suit/modular/rownin/erp
	head = /obj/item/clothing/head/tgmcberet/red2/erp
	l_pocket = /obj/item/storage/pouch/medkit/firstaid
	r_pocket = /obj/item/storage/holster/flarepouch/full
	belt = /obj/item/storage/belt/marine
	suit_store = /obj/item/weapon/gun/rifle/standard_carbine/beginner

	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/mre_pack/xmas1 = 1,
		/obj/item/reagent_containers/food/snacks/mre_pack/xmas2 = 1,
		/obj/item/explosive/grenade/creampie = 6,
		/obj/item/ammo_magazine/rifle/standard_carbine/ap = 2,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/standard_carbine = 6,
	)

	webbing_contents = list(
		/obj/item/tool/crowbar = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/toy/plush/gnome = 1,
		/obj/item/toy/plush/rouny = 1,
		/obj/item/toy/bikehorn = 1,
	)

/datum/outfit/job/erp/masterprankster
	name = "ERP Master Prankster"
	jobtype = /datum/job/erp/masterprankster

	head = /obj/item/clothing/head/tgmcberet/red2/erp/masterprankster
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/rifle

	backpack_contents = list(
		/obj/item/cell/lasgun/plasma = 2,
		/obj/item/reagent_containers/food/snacks/mre_pack/xmas1 = 1,
		/obj/item/reagent_containers/food/snacks/mre_pack/xmas2 = 1,
		/obj/item/explosive/grenade/creampie = 6,
	)

	belt_contents = list(
		/obj/item/cell/lasgun/plasma = 6,
	)

	webbing_contents = list(
		/obj/item/tool/crowbar = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/toy/plush/gnome = 1,
		/obj/item/toy/plush/rouny = 1,
		/obj/item/toy/bikehorn = 1,
	)


/datum/outfit/job/erp/boobookisser
	name = "ERP Boo-boo kisser"
	jobtype = /datum/job/erp/boobookisser

	l_pocket = /obj/item/storage/pouch/medkit/medic
	r_pocket = /obj/item/storage/pouch/medical_injectors/medic
	belt = /obj/item/storage/belt/lifesaver/full

	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/mre_pack/xmas1 = 1,
		/obj/item/reagent_containers/food/snacks/mre_pack/xmas2 = 1,
		/obj/item/ammo_magazine/rifle/standard_carbine/ap = 6,
	)

	webbing_contents = list(
		/obj/item/tool/crowbar = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/toy/plush/gnome = 1,
		/obj/item/toy/plush/rouny = 1,
		/obj/item/toy/bikehorn = 1,
	)

	belt_contents = null


/datum/outfit/job/erp/piethrower
	name = "ERP Pie thrower"
	jobtype = /datum/job/erp/piethrower

	belt = /obj/item/storage/belt/grenade
	suit_store = /obj/item/weapon/gun/grenade_launcher/multinade_launcher/erp
	r_pocket = /obj/item/storage/pouch/grenade

	backpack_contents = list(
		/obj/item/explosive/grenade/creampie = 10,
		/obj/item/reagent_containers/food/snacks/mre_pack/xmas1 = 1,
		/obj/item/reagent_containers/food/snacks/mre_pack/xmas2 = 1,
	)

	belt_contents = list(
		/obj/item/explosive/grenade/creampie = 9,
	)

	webbing_contents = list(
		/obj/item/tool/crowbar = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/toy/plush/gnome = 1,
		/obj/item/toy/plush/rouny = 1,
		/obj/item/toy/bikehorn = 1,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade/creampie = 6,
	)
