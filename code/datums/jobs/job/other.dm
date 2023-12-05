//Colonist
/datum/job/colonist
	title = "Colonist"
	paygrade = "C"
	outfit = /datum/outfit/job/other/colonist


/datum/outfit/job/other/colonist
	name = "Colonist"
	jobtype = /datum/job/colonist

	id = /obj/item/card/id
	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/marine
	l_store = /obj/item/storage/pouch/survival/full
	r_store = /obj/item/radio


//Passenger
/datum/job/passenger
	title = "Passenger"
	paygrade = "C"


//Pizza Deliverer
/datum/job/pizza
	title = "Pizza Deliverer"
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	outfit = /datum/outfit/job/other/pizza


/datum/outfit/job/other/pizza
	name = "Pizza Deliverer"
	jobtype = /datum/job/pizza

	id = /obj/item/card/id/silver
	w_uniform = /obj/item/clothing/under/pizza
	belt = /obj/item/weapon/gun/pistol/holdout
	shoes = /obj/item/clothing/shoes/red
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/soft/red
	r_store = /obj/item/radio
	l_store = /obj/item/reagent_containers/food/drinks/cans/dr_gibb
	back = /obj/item/storage/backpack/satchel
	r_hand = /obj/item/pizzabox/random


//Spatial Agent
/datum/job/spatial_agent
	title = "Spatial Agent"
	access = ALL_ACCESS
	minimal_access = ALL_ACCESS
	skills_type = /datum/skills/spatial_agent
	outfit = /datum/outfit/job/other/spatial_agent


/datum/outfit/job/other/spatial_agent
	name = "Spatial Agent"
	jobtype = /datum/job/spatial_agent

	id = /obj/item/card/id/silver
	w_uniform = /obj/item/clothing/under/rank/centcom_commander/sa
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/marinechief/sa
	gloves = /obj/item/clothing/gloves/marine/officer/chief/sa
	glasses = /obj/item/clothing/glasses/sunglasses/sa/nodrop
	back = /obj/item/storage/backpack/marine/satchel

/datum/job/spatial_agent/galaxy_red
	outfit = /datum/outfit/job/other/spatial_agent/galaxy_red

/datum/outfit/job/other/spatial_agent/galaxy_red
	w_uniform = /obj/item/clothing/under/liaison_suit/galaxy_red
	belt = null
	back = null

/datum/job/spatial_agent/galaxy_blue
	outfit = /datum/outfit/job/other/spatial_agent/galaxy_blue

/datum/outfit/job/other/spatial_agent/galaxy_blue
	w_uniform = /obj/item/clothing/under/liaison_suit/galaxy_blue
	belt = null
	back = null

/datum/job/spatial_agent/xeno_suit
	outfit = /datum/outfit/job/other/spatial_agent/xeno_suit

/datum/outfit/job/other/spatial_agent/xeno_suit
	head = /obj/item/clothing/head/xenos
	wear_suit = /obj/item/clothing/suit/xenos

/datum/job/spatial_agent/marine_officer
	outfit = /datum/outfit/job/other/spatial_agent/marine_officer

/datum/outfit/job/other/spatial_agent/marine_officer
	w_uniform = /obj/item/clothing/under/marine/officer/bridge
	head = /obj/item/clothing/head/beret/marine
	belt = /obj/item/storage/holster/belt/pistol/m4a3/officer
	back = null
	shoes = /obj/item/clothing/shoes/marine/full

/datum/job/zombie
	title = "Oh god run"

/datum/job/santa
	title = "Elf" //no custom names here, Santa can't tell them apart
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/elf
	faction = FACTION_SANTA
	outfit = /datum/outfit/job/santa/elf

/datum/job/santa/elf/eventspawn
	outfit = /datum/outfit/job/santa/elf/eventspawn

/datum/job/santa/leader
	title = "Santa Claus"
	access = ALL_ACCESS
	minimal_access = ALL_ACCESS
	skills_type = /datum/skills/santaclause
	outfit = /datum/outfit/job/santa/leader

/datum/job/santa/contractspawn
	outfit = /datum/outfit/job/santa/elf/contractspawn

/datum/job/santa/eventspawn
	title = "Event Santa Claus"
	access = ALL_ACCESS
	minimal_access = ALL_ACCESS
	skills_type = /datum/skills/santaclause
	outfit = /datum/outfit/job/santa/eventspawn

/datum/outfit/job/santa/elf
	name = "Elf"
	jobtype = /datum/outfit/job/santa/elf/eventspawn

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/holster/belt/pistol/m4a3/vp70_pmc
	ears = /obj/item/radio/headset/distress/commando
	w_uniform = /obj/item/clothing/under/spec_operative
	shoes = /obj/item/clothing/shoes/ruggedboot
	wear_suit = /obj/item/clothing/suit/space/elf/nodrop
	gloves = /obj/item/clothing/gloves/ruggedgloves
	head = /obj/item/clothing/head/helmet/space/elf/special
	glasses = /obj/item/clothing/glasses/welding
	l_store = /obj/item/storage/pouch/construction/equippedengineer
	r_store = /obj/item/storage/pouch/tools/full
	back = /obj/item/storage/backpack/industrial
	suit_store = /obj/item/weapon/gun/pistol/vp70
	r_hand = /obj/item/weapon/twohanded/spear/candycane/elf

/datum/outfit/job/santa/elf/eventspawn
	name = "Event Elf"
	jobtype = /datum/job/santa

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/distress/commando
	w_uniform = /obj/item/clothing/under/spec_operative
	shoes = /obj/item/clothing/shoes/ruggedboot
	wear_suit = /obj/item/clothing/suit/space/elf/nodrop
	gloves = /obj/item/clothing/gloves/ruggedgloves
	head = /obj/item/clothing/head/helmet/space/elf/special
	glasses = /obj/item/clothing/glasses/welding
	l_store = /obj/item/storage/pouch/medkit/medic
	r_store = /obj/item/storage/pouch/pistol/vp70
	back = /obj/item/storage/backpack/industrial
	suit_store = /obj/item/weapon/gun/pistol/vp70
	r_hand = /obj/item/weapon/twohanded/spear/candycane/elf

/datum/outfit/job/santa/elf/contractspawn
	name = "Contract Elf"
	jobtype = /datum/job/santa/contractspawn

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/distress/commando
	w_uniform = /obj/item/clothing/under/spec_operative
	shoes = /obj/item/clothing/shoes/ruggedboot
	wear_suit = /obj/item/clothing/suit/space/elf
	gloves = /obj/item/clothing/gloves/ruggedgloves
	head = /obj/item/clothing/head/helmet/space/elf/special
	glasses = /obj/item/clothing/glasses/welding/elf
	l_store = /obj/item/storage/pouch/medkit/medic
	r_store = /obj/item/storage/pouch/pistol/vp70
	back = /obj/item/storage/backpack/industrial
	suit_store = /obj/item/weapon/gun/pistol/vp70
	r_hand = /obj/item/weapon/twohanded/spear/candycane/elf

/datum/outfit/job/santa/elf/eventspawn/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()


	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookieone/special, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookietwo/special, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/bottle/eggnog/special, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new 	/obj/item/weapon/gun/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new 	/obj/item/weapon/gun/pistol/vp70, SLOT_IN_BACKPACK)

/datum/outfit/job/santa/leader //he's done ho ho ho ing around
	name = "ERT Santa Claus"
	jobtype = /datum/job/santa/leader

	id = /obj/item/card/id/gold
	belt = /obj/item/storage/belt/coalbelt/full
	ears = /obj/item/radio/headset/distress/commando
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/commando
	shoes = /obj/item/clothing/shoes/galoshes/santa
	wear_suit = /obj/item/clothing/suit/space/santa/special
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc/commando/santa
	mask = /obj/item/clothing/mask/gas/swat/santa
	head = /obj/item/clothing/head/helmet/space/santahat/special
	glasses = /obj/item/clothing/glasses/thermal/eyepatch //santa lost one of his eyes in a vicious reindeer accident circa '32
	r_store = /obj/item/storage/pouch/magazine/pistol/large
	l_store = /obj/item/storage/pouch/medkit/firstaid
	back = /obj/item/storage/backpack/santabag
	suit_store = /obj/item/weapon/gun/launcher/rocket/m57a4

/datum/outfit/job/santa/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()


	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookieone, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookietwo, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/auto9, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/auto9, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/auto9, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/auto9, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/auto9, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/auto9, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/auto9, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/auto9, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/auto9, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/auto9, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/auto9, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/auto9, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/auto9, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookieone/special, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookietwo/special, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookiethree/special, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookiefour/special, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookiefive/special, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookiesix/special, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookieseven/special, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/bottle/eggnog/special, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/whistle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/sliceable/pastries/fruitcake, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/energy/sword/green, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)

/datum/outfit/job/santa/eventspawn //like ERT santa, but less OP
	name = "Event Santa Claus"
	jobtype = /datum/job/santa/eventspawn

	id = /obj/item/card/id/gold
	belt = /obj/item/storage/belt/coalbelt/full
	ears = /obj/item/radio/headset/distress/commando
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/commando
	shoes = /obj/item/clothing/shoes/galoshes/santa
	wear_suit = /obj/item/clothing/suit/space/santa/special/eventspawn
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc/commando/santa
	mask = /obj/item/clothing/mask/gas/swat/santa/eventspawn
	head = /obj/item/clothing/head/helmet/space/santahat/special
	r_store = /obj/item/storage/pouch/magazine/large/pmc_m25
	l_store = /obj/item/storage/pouch/santaspouch
	back = /obj/item/storage/backpack/santabag
	suit_store = /obj/item/weapon/gun/smg/m25/elite

/datum/outfit/job/santa/eventspawn/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()


	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookieone, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookietwo, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/shield/energy, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/mateba, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookieone/special, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookietwo/special, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookiethree/special, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookiefour/special, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookiefive/special, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookiesix/special, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookieseven/special, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/bottle/eggnog/special, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/whistle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/sliceable/pastries/fruitcake, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/energy/sword/green, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)


/datum/outfit/job/santa/elf/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()


	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookieone/special, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/christmas_cookietwo/special, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/bottle/eggnog/special, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
