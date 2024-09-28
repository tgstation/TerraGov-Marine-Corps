//Assistant
/datum/job/survivor/assistant
	title = "Assistant Survivor"
	outfit = /datum/outfit/job/survivor/assistant


/datum/outfit/job/survivor/assistant
	name = "Assistant Survivor"
	jobtype = /datum/job/survivor/assistant

	w_uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm
	wear_suit = /obj/item/clothing/suit/armor/vest
	ears = /obj/item/radio/survivor
	mask = /obj/item/clothing/mask/gas/tactical/coif
	head = /obj/item/clothing/head/welding/flipped
	belt = /obj/item/storage/belt/utility/full
	l_pocket = /obj/item/flashlight/combat
	r_hand = /obj/item/weapon/combat_knife

/datum/outfit/job/survivor/scientist
	name = "Scientist Survivor"
	jobtype = /datum/job/survivor/scientist

	w_uniform = /obj/item/clothing/under/rank/scientist
	wear_suit = /obj/item/clothing/suit/storage/labcoat/researcher
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/toxins
	ears = /obj/item/radio/survivor
	l_hand = /obj/item/storage/firstaid/adv
	l_pocket = /obj/item/storage/pouch/surgery
	r_pocket = /obj/item/flashlight/combat

/datum/outfit/job/survivor/scientist/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/polyhexanide, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/sleeptoxin, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)

/datum/outfit/job/survivor/doctor
	name = "Doctor's Assistant Survivor"
	jobtype = /datum/job/survivor/doctor

	w_uniform = /obj/item/clothing/under/rank/medical/blue
	wear_suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/med
	gloves = /obj/item/clothing/gloves/latex
	glasses = /obj/item/clothing/glasses/hud/health
	r_pocket = /obj/item/storage/pouch/surgery
	belt = /obj/item/storage/belt/rig
	mask = /obj/item/clothing/mask/surgical
	ears = /obj/item/radio/survivor

/datum/outfit/job/survivor/doctor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/healthanalyzer, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/bicaridine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/kelotane, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/dylovene, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/isotonic, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/inaprovaline, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/flashlight, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/tweezers, SLOT_IN_R_POUCH)

/datum/outfit/job/survivor/liaison
	name = "Liaison Survivor"
	jobtype = /datum/job/survivor/liaison

	w_uniform = /obj/item/clothing/under/liaison_suit
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm
	ears = /obj/item/radio/survivor
	belt = /obj/item/storage/holster/belt/pistol/m4a3/vp78
	l_hand = /obj/item/flashlight/combat
	l_pocket = /obj/item/tool/crowbar

/datum/outfit/job/survivor/security
	name = "Security Guard Survivor"
	jobtype = /datum/job/survivor/security

	w_uniform = /obj/item/clothing/under/rank/security
	wear_suit = /obj/item/clothing/suit/armor/patrol
	head = /obj/item/clothing/head/securitycap
	shoes = /obj/item/clothing/shoes/marine
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security
	gloves = /obj/item/clothing/gloves/black
	suit_store = /obj/item/weapon/gun/pistol/g22
	ears = /obj/item/radio/survivor

/datum/outfit/job/survivor/security/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/flashlight/combat, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/weapon/telebaton, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)


/datum/outfit/job/survivor/civilian
	name = "Civilian Survivor"
	jobtype = /datum/job/survivor/civilian

	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm
	ears = /obj/item/radio/survivor

/datum/outfit/job/survivor/civilian/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/flashlight, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_BACKPACK)


/datum/outfit/job/survivor/chef
	name = "Chef Survivor"
	jobtype = /datum/job/survivor/chef

	w_uniform = /obj/item/clothing/under/rank/chef
	wear_suit = /obj/item/clothing/suit/storage/chef
	head = /obj/item/clothing/head/chefhat
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack
	ears = /obj/item/radio/survivor

/datum/outfit/job/survivor/chef/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/flashlight, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/kitchen/knife/butcher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/burger/crazy, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/soup/mysterysoup, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/packaged_hdogs, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/organ, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/chocolateegg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/meat/xeno, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/pastries/xemeatpie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/pastries/birthdaycakeslice, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/donut/meat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)


/datum/outfit/job/survivor/botanist
	name = "Botanist Survivor"
	jobtype = /datum/job/survivor/botanist

	w_uniform = /obj/item/clothing/under/rank/hydroponics
	wear_suit = /obj/item/clothing/suit/storage/apron/overalls
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/hydroponics
	ears = /obj/item/radio/survivor
	suit_store = /obj/item/weapon/combat_knife
	l_pocket = /obj/item/flashlight
	r_pocket = /obj/item/tool/crowbar

/datum/outfit/job/survivor/botanist/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/grown/ambrosiadeus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/grown/ambrosiadeus, SLOT_IN_BACKPACK)


/datum/outfit/job/survivor/atmos
	name = "Atmospherics Technician Survivor"
	jobtype = /datum/job/survivor/atmos

	w_uniform = /obj/item/clothing/under/rank/atmospheric_technician
	wear_suit = /obj/item/clothing/suit/storage/hazardvest
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/som
	gloves = /obj/item/clothing/gloves/insulated
	belt = /obj/item/storage/belt
	head = /obj/item/clothing/head/hardhat/white
	glasses = /obj/item/clothing/glasses/welding
	r_pocket = /obj/item/storage/pouch/electronics/full
	l_pocket = /obj/item/storage/pouch/construction
	ears = /obj/item/radio/survivor

/datum/outfit/job/survivor/atmos/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/tool/screwdriver, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/tool/wrench, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/tool/wirecutters, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/tool/multitool, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/lightreplacer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/deployable_floodlight, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/small_stack, SLOT_IN_L_POUCH)


/datum/outfit/job/survivor/chaplain
	name = "Chaplain Survivor"
	jobtype = /datum/job/survivor/chaplain

	w_uniform = /obj/item/clothing/under/rank/chaplain
	wear_suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm
	ears = /obj/item/radio/survivor

/datum/outfit/job/survivor/chaplain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/tool/candle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/candle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/candle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/lighter, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/bible, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)

/datum/outfit/job/survivor/miner
	name = "Miner Survivor"
	jobtype = /datum/job/survivor/miner

	w_uniform = /obj/item/clothing/under/rank/miner
	head = /obj/item/clothing/head/helmet/space/rig/mining
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/som
	l_hand = /obj/item/weapon/twohanded/sledgehammer
	r_pocket = /obj/item/reagent_containers/cup/glass/flask
	r_hand = /obj/item/clothing/suit/space/rig/mining
	ears = /obj/item/radio/survivor

/datum/outfit/job/survivor/miner/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/storage/fancy/cigarettes, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/lighter, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/bottle/whiskey, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)


/datum/outfit/job/survivor/salesman
	name = "Salesman Survivor"
	jobtype = /datum/job/survivor/salesman

	w_uniform = /obj/item/clothing/under/lawyer/purpsuit
	wear_suit = /obj/item/clothing/suit/storage/lawyer/purpjacket
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel
	mask = /obj/item/clothing/mask/cigarette/pipe/bonepipe
	glasses = /obj/item/clothing/glasses/sunglasses/aviator
	ears = /obj/item/radio/survivor

/datum/outfit/job/survivor/salesman/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/holdout, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/holdout, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/holdout, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/holdout, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/lighter/zippo, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)


/datum/outfit/job/survivor/marshal
	name = "Colonial Marshal Survivor"
	jobtype = /datum/job/survivor/marshal

	w_uniform = /obj/item/clothing/under/CM_uniform
	wear_suit = /obj/item/clothing/suit/storage/CMB
	shoes = /obj/item/clothing/shoes/jackboots
	back = /obj/item/storage/backpack/satchel/sec
	suit_store = /obj/item/storage/holster/belt/m44/full
	belt = /obj/item/storage/belt/sparepouch
	gloves = /obj/item/clothing/gloves/ruggedgloves
	l_pocket = /obj/item/flashlight/combat
	ears = /obj/item/radio/survivor
	head = /obj/item/clothing/head/slouch

/datum/outfit/job/survivor/marshal/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/restraints/handcuffs, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BELT)


/datum/outfit/job/survivor/rambo
	name = "Overpowered Survivor"
	jobtype = /datum/job/survivor/rambo
	w_uniform = /obj/item/clothing/under/marine/striped
	wear_suit = /obj/item/clothing/suit/armor/patrol
	shoes = /obj/item/clothing/shoes/marine/clf/full
	back = /obj/item/storage/holster/blade/machete/full
	gloves = /obj/item/clothing/gloves/ruggedgloves
	suit_store = /obj/item/weapon/gun/rifle/alf_machinecarbine/freelancer
	belt = /obj/item/storage/belt/marine/alf_machinecarbine
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	r_pocket = /obj/item/flashlight/combat
	glasses = /obj/item/clothing/glasses/m42_goggles
	head = /obj/item/clothing/head/headband
	ears = /obj/item/radio/survivor
