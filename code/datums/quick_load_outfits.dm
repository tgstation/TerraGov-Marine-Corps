/datum/outfit/quick
	var/desc






/datum/outfit/quick/som/standard
	name = "SOM Standard"
	desc = "hello world"

	id = /obj/item/card/id/dogtag/som
	belt = /obj/item/storage/belt/marine/som
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som
	gloves = /obj/item/clothing/gloves/marine/som
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som/standard
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/som
	r_store = /obj/item/storage/pouch/firstaid/som/full
	l_store = /obj/item/storage/pouch/pistol
	back = /obj/item/storage/backpack/lightpack/som

//AK
/datum/outfit/quick/som/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/upp, SLOT_IN_L_POUCH)

//Charger
/datum/outfit/quick/som/standard/one
	desc = "boop world"
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/magharness

/datum/outfit/quick/som/standard/one/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/upp, SLOT_IN_L_POUCH)

//charger
/datum/outfit/quick/som/veteran
	name = "SOM Veteran"

	id = /obj/item/card/id/dogtag/som
	belt = /obj/item/storage/belt/marine/som
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/veteran/highpower
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som/heavy
	gloves = /obj/item/clothing/gloves/marine/som/veteran
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som/veteran/vet
	glasses = /obj/item/clothing/glasses/meson
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet
	r_store = /obj/item/storage/pouch/grenade
	l_store = /obj/item/storage/pouch/firstaid/som/full
	back = /obj/item/storage/backpack/lightpack/som

/datum/outfit/quick/som/veteran/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

//Culverin - bringing the big guns
/datum/outfit/quick/som/veteran/three
	w_uniform = /obj/item/clothing/under/som/veteran/webbing_vet
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/magharness
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	back = /obj/item/cell/lasgun/volkite/powerpack

/datum/outfit/quick/som/veteran/three/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
