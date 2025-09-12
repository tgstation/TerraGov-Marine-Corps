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

	backpack_contents = list(
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

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

	backpack_contents = list(
		/obj/item/roller = 1,
		/obj/item/defibrillator = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/polyhexanide = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/sleeptoxin = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)


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

	backpack_contents = list(
		/obj/item/flashlight = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

	belt_contents = list(
		/obj/item/roller = 1,
		/obj/item/defibrillator = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack = 2,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack = 2,
		/obj/item/stack/medical/splint = 2,
		/obj/item/storage/pill_bottle/packet/bicaridine = 1,
		/obj/item/storage/pill_bottle/packet/kelotane = 1,
		/obj/item/storage/pill_bottle/packet/tramadol = 1,
		/obj/item/storage/pill_bottle/packet/tricordrazine = 1,
		/obj/item/storage/pill_bottle/packet/dylovene = 1,
		/obj/item/storage/pill_bottle/packet/isotonic = 1,
		/obj/item/storage/pill_bottle/inaprovaline = 1,
	)

	r_pocket_contents = list(
		/obj/item/tweezers = 1,
	)

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
	shoes = /obj/item/clothing/shoes/marine/full
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security
	gloves = /obj/item/clothing/gloves/black
	suit_store = /obj/item/weapon/gun/pistol/g22
	ears = /obj/item/radio/survivor

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/pistol/g22 = 2,
		/obj/item/flashlight/combat = 1,
		/obj/item/weapon/telebaton = 1,
	)

/datum/outfit/job/survivor/civilian
	name = "Civilian Survivor"
	jobtype = /datum/job/survivor/civilian

	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm
	ears = /obj/item/radio/survivor

	backpack_contents = list(
		/obj/item/tool/crowbar = 1,
		/obj/item/flashlight = 1,
		/obj/item/weapon/combat_knife/upp = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)


/datum/outfit/job/survivor/chef
	name = "Chef Survivor"
	jobtype = /datum/job/survivor/chef

	w_uniform = /obj/item/clothing/under/rank/chef
	wear_suit = /obj/item/clothing/suit/storage/chef
	head = /obj/item/clothing/head/chefhat
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack
	ears = /obj/item/radio/survivor

	backpack_contents = list(
		/obj/item/flashlight = 1,
		/obj/item/tool/kitchen/knife/butcher = 1,
		/obj/item/reagent_containers/food/snacks/burger/crazy = 1,
		/obj/item/reagent_containers/food/snacks/soup/mysterysoup = 1,
		/obj/item/reagent_containers/food/snacks/packaged_hdogs = 1,
		/obj/item/reagent_containers/food/snacks/organ = 1,
		/obj/item/reagent_containers/food/snacks/chocolateegg = 1,
		/obj/item/reagent_containers/food/snacks/meat/xeno = 1,
		/obj/item/reagent_containers/food/snacks/pastries/xemeatpie = 1,
		/obj/item/reagent_containers/food/snacks/donut/meat = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)


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
	l_hand = /obj/item/weapon/gun/shotgun/double

	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris = 2,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiadeus = 2,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

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

	backpack_contents = list(
		/obj/item/lightreplacer = 1,
		/obj/item/deployable_floodlight = 1,
		/obj/item/explosive/grenade/chem_grenade/metalfoam = 2,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

	belt_contents = list(
		/obj/item/tool/screwdriver = 1,
		/obj/item/tool/wrench = 1,
		/obj/item/tool/wirecutters = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/tool/weldingtool = 1,
		/obj/item/tool/multitool = 1,
		/obj/item/stack/cable_coil = 1,
	)

	l_pocket_contents = list(
		/obj/item/stack/sheet/metal/medium_stack = 1,
		/obj/item/stack/sheet/plasteel/small_stack = 1,
	)


/datum/outfit/job/survivor/chaplain
	name = "Chaplain Survivor"
	jobtype = /datum/job/survivor/chaplain

	w_uniform = /obj/item/clothing/under/rank/chaplain
	wear_suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/norm
	ears = /obj/item/radio/survivor

	l_hand = /obj/item/weapon/gun/shotgun/double
	r_hand = /obj/item/ammo_magazine/handful/buckshot

	backpack_contents = list(
		/obj/item/storage/fancy/candle_box = 1,
		/obj/item/tool/candle = 3,
		/obj/item/tool/lighter = 1,
		/obj/item/storage/bible = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/reagent_containers/cup/glass/bottle/holywater = 1,
	)

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

	backpack_contents = list(
		/obj/item/storage/fancy/cigarettes = 1,
		/obj/item/tool/lighter = 1,
		/obj/item/reagent_containers/food/drinks/bottle/whiskey = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)


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

	backpack_contents = list(
		/obj/item/weapon/gun/pistol/holdout = 1,
		/obj/item/ammo_magazine/pistol/holdout = 3,
		/obj/item/tool/lighter/zippo = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)


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

	belt_contents = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

/datum/outfit/job/survivor/bartender
	name = "Bartender Survivor"
	jobtype = /datum/job/survivor/bartender

	w_uniform = /obj/item/clothing/under/rank/bartender
	wear_suit = /obj/item/clothing/suit/armor/vest
	back = /obj/item/storage/backpack/satchel
	belt = /obj/item/ammo_magazine/shotgun/buckshot
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/collectable/tophat
	ears = /obj/item/radio/survivor
	glasses = /obj/item/clothing/glasses/sunglasses
	l_pocket = /obj/item/flashlight
	r_pocket = /obj/item/tool/crowbar
	suit_store = /obj/item/weapon/gun/shotgun/double/sawn

	backpack_contents = list(
		/obj/item/reagent_containers/food/drinks/bottle/whiskey = 1,
		/obj/item/reagent_containers/food/drinks/bottle/vodka = 1,
		/obj/item/reagent_containers/food/drinks/cans/beer = 2,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)





/datum/outfit/job/survivor/chemist
	name = "Pharmacy Technician Survivor"
	jobtype = /datum/job/survivor/chemist

	w_uniform = /obj/item/clothing/under/rank/chemist
	wear_suit = /obj/item/clothing/suit/storage/labcoat/chemist
	back = /obj/item/storage/backpack/satchel/chem
	belt = /obj/item/storage/belt/hypospraybelt
	gloves = /obj/item/clothing/gloves/latex
	shoes = /obj/item/clothing/shoes/white
	ears = /obj/item/radio/survivor
	glasses = /obj/item/clothing/glasses/science
	l_pocket = /obj/item/flashlight
	r_pocket = /obj/item/tool/crowbar
	suit_store = /obj/item/healthanalyzer

	backpack_contents = list(
		/obj/item/reagent_containers/dropper = 1,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack = 1,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack = 1,
		/obj/item/stack/medical/splint = 2,
		/obj/item/defibrillator = 1,
		/obj/item/clothing/glasses/hud/health = 1,
	)

	belt_contents = list(
		/obj/item/reagent_containers/glass/bottle/bicaridine = 1,
		/obj/item/reagent_containers/glass/bottle/kelotane = 1,
		/obj/item/reagent_containers/glass/bottle/tramadol = 1,
		/obj/item/reagent_containers/glass/bottle/tricordrazine = 1,
		/obj/item/reagent_containers/glass/bottle/lemoline/doctor = 1,
		/obj/item/reagent_containers/glass/beaker/large = 2,
		/obj/item/reagent_containers/hypospray/advanced/bicaridine = 1,
		/obj/item/reagent_containers/hypospray/advanced/kelotane = 1,
		/obj/item/reagent_containers/hypospray/advanced/tramadol = 1,
		/obj/item/reagent_containers/hypospray/advanced/tricordrazine = 1,
		/obj/item/reagent_containers/hypospray/advanced/dylovene = 1,
		/obj/item/reagent_containers/hypospray/advanced/inaprovaline = 1,
		/obj/item/reagent_containers/hypospray/advanced/hypervene = 1,
		/obj/item/reagent_containers/hypospray/advanced/imialky = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 1,
		/obj/item/reagent_containers/hypospray/advanced/big = 2,
		/obj/item/storage/syringe_case/empty = 2,
	)


/datum/outfit/job/survivor/roboticist
	name = "Roboticist Survivor"
	jobtype = /datum/job/survivor/roboticist

	w_uniform = /obj/item/clothing/under/rank/roboticist
	wear_suit = /obj/item/clothing/suit/storage/labcoat/science
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel/tox
	ears = /obj/item/radio/survivor
	glasses = /obj/item/clothing/glasses/welding/flipped
	l_pocket = /obj/item/storage/pouch/electronics/full
	r_pocket = /obj/item/flashlight/combat

	backpack_contents = list(
		/obj/item/stack/sheet/metal/medium_stack = 1,
		/obj/item/stack/sheet/plasteel/small_stack = 1,
		/obj/item/attachable/buildasentry = 1,
		/obj/item/cell/high = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

/datum/outfit/job/survivor/rambo
	name = "Overpowered Survivor"
	jobtype = /datum/job/survivor/rambo
	w_uniform = /obj/item/clothing/under/marine/striped
	wear_suit = /obj/item/clothing/suit/armor/patrol
	shoes = /obj/item/clothing/shoes/marine/clf/full
	back = /obj/item/storage/holster/blade/machete/full
	gloves = /obj/item/clothing/gloves/ruggedgloves
	suit_store = /obj/item/weapon/gun/rifle/alf_machinecarbine/assault
	belt = /obj/item/storage/belt/marine/alf_machinecarbine
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	r_pocket = /obj/item/flashlight/combat
	glasses = /obj/item/clothing/glasses/m42_goggles
	head = /obj/item/clothing/head/headband
	ears = /obj/item/radio/survivor
