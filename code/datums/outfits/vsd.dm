
//outfits
/datum/outfit/job/vsd/standard
	name = "VSD Standard"
	jobtype = /datum/job/vsd/standard

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/vsd
	glasses = /obj/item/clothing/glasses/night/vsd
	w_uniform = /obj/item/clothing/under/vsd/webbing
	shoes = /obj/item/clothing/shoes/marine/vsd/full
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/vsd
	r_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	l_pocket = /obj/item/storage/pouch/magazine
	back = /obj/item/storage/backpack/lightpack/vsd
	belt = /obj/item/storage/holster/belt/pistol/standard_pistol

	backpack_contents = list(
		/obj/item/storage/box/m94 = 1,
		/obj/item/storage/box/MRE = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat = 4,
	)

	suit_contents = list(
		/obj/item/explosive/grenade/vsd = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/pistol/vsd_pistol = 6,
		/obj/item/weapon/gun/pistol/vsd_pistol/standard = 1,
	)

	webbing_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/explosive/grenade/vsd = 2,
	)

/datum/outfit/job/vsd/standard/grunt_one
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/desert
	head = /obj/item/clothing/head/helmet/marine/vsd/secondary
	suit_store = /obj/item/weapon/gun/rifle/vsd_rifle/standard
	mask = /obj/item/clothing/mask/gas/vsd

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_rifle = 4,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_rifle = 1,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_rifle = 2,
	)

/datum/outfit/job/vsd/standard/ksg
	w_uniform = /obj/item/clothing/under/vsd/shirt/webbing
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/desert
	suit_store = /obj/item/weapon/gun/shotgun/pump/ksg/standard
	l_pocket = /obj/item/storage/pouch/shotgun

	backpack_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 4,
		/obj/item/explosive/grenade/vsd = 3,
	)

	suit_contents = list(
		/obj/item/explosive/grenade/vsd = 1,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 4,
	)


/datum/outfit/job/vsd/standard/grunt_second
	suit_store = /obj/item/weapon/gun/rifle/vsd_rifle/standard
	head = /obj/item/clothing/head/vsd

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_rifle = 4,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_rifle = 2,
	)

	head_contents = null

/datum/outfit/job/vsd/standard/grunt_third
	suit_store = /obj/item/weapon/gun/rifle/vsd_rifle/standard
	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_rifle = 4,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_rifle = 2,
	)


//outfits
/datum/outfit/job/vsd/engineer
	name = "VSD Engineer"
	jobtype = /datum/job/vsd/engineer

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/vsd
	glasses = /obj/item/clothing/glasses/meson
	w_uniform = /obj/item/clothing/under/vsd/webbing
	shoes = /obj/item/clothing/shoes/marine/vsd/full
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/marmor/desert
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/vsd/secondary
	r_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	l_pocket = /obj/item/storage/pouch/magazine
	back = /obj/item/storage/backpack/lightpack/vsd
	belt = /obj/item/storage/belt/utility/full

	backpack_contents = list(
		/obj/item/storage/box/MRE = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/combat = 2,
		/obj/item/stack/sheet/metal/large_stack = 2,
		/obj/item/explosive/plastique = 4,
	)

	suit_contents = list(
		/obj/item/explosive/grenade/vsd = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/plastique = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/explosive/grenade/vsd = 2,
	)


/datum/outfit/job/vsd/engineer/l26
	suit_store = /obj/item/weapon/gun/rifle/vsd_lmg/engineer

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_mg = 2,
		/obj/item/attachable/buildasentry = 1,
		/obj/item/stack/sheet/metal/large_stack = 1,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_mg = 2,
	)

/datum/outfit/job/vsd/engineer/vsd_rifle
	suit_store = /obj/item/weapon/gun/rifle/vsd_rifle/standard
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/marmor
	head = /obj/item/clothing/head/vsd

	backpack_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/ammo_magazine/rifle/vsd_rifle = 2,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_rifle = 2,
	)

	head_contents = null


//outfits
/datum/outfit/job/vsd/medic
	name = "VSD Medic"
	jobtype = /datum/job/vsd/medic

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/vsd
	belt = /obj/item/storage/belt/lifesaver/full/upp
	glasses = /obj/item/clothing/glasses/hud/health
	w_uniform = /obj/item/clothing/under/vsd/medic
	shoes = /obj/item/clothing/shoes/marine/vsd/full
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/vsd/medic
	r_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	l_pocket = /obj/item/storage/pouch/magazine
	back = /obj/item/storage/backpack/lightpack/vsd

	backpack_contents = list(
		/obj/item/defibrillator = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 2,
	)

	webbing_contents = list(
		/obj/item/roller = 1,
		/obj/item/tweezers_advanced = 1,
		/obj/item/storage/pill_bottle/spaceacillin = 1,
		/obj/item/reagent_containers/hypospray/advanced/nanoblood = 1,
		/obj/item/bodybag/cryobag = 1,
		/obj/item/reagent_containers/hypospray/advanced/combat_advanced = 1,
	)


/datum/outfit/job/vsd/medic/ksg
	suit_store = /obj/item/weapon/gun/shotgun/pump/ksg/support
	l_pocket = /obj/item/storage/pouch/shotgun

	backpack_contents = list(
		/obj/item/ammo_magazine/pistol/vsd_pistol = 3,
		/obj/item/weapon/gun/pistol/vsd_pistol/standard = 1,
		/obj/item/ammo_magazine/handful/buckshot = 3,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 2,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 4,
	)


/datum/outfit/job/vsd/medic/vsd_rifle
	suit_store = /obj/item/weapon/gun/rifle/vsd_rifle

	backpack_contents = list(
		/obj/item/ammo_magazine/pistol/vsd_pistol = 3,
		/obj/item/ammo_magazine/rifle/vsd_rifle = 2,
		/obj/item/weapon/gun/pistol/vsd_pistol/standard = 1,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_rifle = 2,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_rifle = 2,
	)

/datum/outfit/job/vsd/medic/vsd_pdw
	suit_store = /obj/item/weapon/gun/smg/vsd_pdw/medic

	backpack_contents = list(
		/obj/item/ammo_magazine/pistol/vsd_pistol = 3,
		/obj/item/ammo_magazine/smg/vsd_pdw = 2,
		/obj/item/weapon/gun/pistol/vsd_pistol/standard = 1,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/smg/vsd_pdw = 2,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/smg/vsd_pdw = 2,
	)


//outfits
/datum/outfit/job/vsd/spec
	name = "VSD Specialist"
	jobtype = /datum/job/vsd/spec

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/vsd
	glasses = /obj/item/clothing/glasses/night/vsd
	w_uniform = /obj/item/clothing/under/vsd/webbing
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd
	head = /obj/item/clothing/head/helmet/marine/vsd
	shoes = /obj/item/clothing/shoes/marine/vsd/full
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	r_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack/vsd
	belt = /obj/item/storage/holster/belt/pistol/standard_pistol

	suit_contents = list(
		/obj/item/explosive/grenade/vsd = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 2,
	)

	webbing_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/explosive/plastique = 1,
	)

/datum/outfit/job/vsd/spec/flamer
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/marmor
	head = /obj/item/clothing/head/helmet/marine/vsd/pyro
	belt = /obj/item/belt_harness/marine
	suit_store = /obj/item/weapon/gun/flamer/big_flamer/vsd
	back = /obj/item/ammo_magazine/flamer_tank/backtank/X
	w_uniform = /obj/item/clothing/under/vsd/shirt/webbing
	l_pocket = /obj/item/storage/pouch/grenade

	suit_contents = list(
		/obj/item/ammo_magazine/flamer_tank/large = 2,
	)

	webbing_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/tool/extinguisher/mini = 1,
	)

	l_pocket_contents = list(
		/obj/item/explosive/grenade/phosphorus/upp = 6,
	)

/datum/outfit/job/vsd/spec/demolitionist
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/harmor
	head = /obj/item/clothing/head/helmet/marine/vsd
	belt = /obj/item/belt_harness/marine
	glasses = /obj/item/clothing/glasses/meson
	suit_store = /obj/item/weapon/gun/launcher/rocket/vsd
	l_pocket = /obj/item/storage/pouch/explosive

	backpack_contents = list(
		/obj/item/explosive/plastique = 4,
		/obj/item/storage/box/MRE = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/ammo_magazine/rocket/vsd/he = 4,
		/obj/item/explosive/grenade/vsd = 2,
	)

	webbing_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 2,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rocket/vsd/he = 4,
	)

/datum/outfit/job/vsd/spec/gunslinger
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd
	head = /obj/item/clothing/head/helmet/marine/vsd/secondary
	belt = /obj/item/storage/holster/belt/korovin
	w_uniform = /obj/item/clothing/under/vsd/shirt/webbing

	backpack_contents = list(
		/obj/item/storage/box/m94 = 1,
		/obj/item/storage/box/MRE = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat = 4,
		/obj/item/ammo_magazine/pistol/xmdivider = 4,
		/obj/item/explosive/grenade/vsd = 3,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/pistol/xmdivider = 6,
		/obj/item/weapon/gun/pistol/xmdivider/gunslinger = 1,
	)

	webbing_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 2,
	)

/datum/outfit/job/vsd/spec/uslspec_one
	w_uniform = /obj/item/clothing/under/vsd/upp/white_webbing
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/marmor/upp
	head = /obj/item/clothing/head/helmet/marine/vsd/upp
	mask = /obj/item/clothing/mask/gas/vsd
	suit_store = /obj/item/weapon/gun/rifle/type71/flamer
	l_pocket = /obj/item/storage/pouch/general/large

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/ammo_magazine/rifle/type71 = 4,
		/obj/item/reagent_containers/hypospray/autoinjector/combat = 2,
		/obj/item/storage/box/MRE = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/grenade/vsd = 1,
		/obj/item/explosive/plastique = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/pistol/vsd_pistol = 6,
		/obj/item/weapon/gun/pistol/vsd_pistol/standard = 1,
	)

	webbing_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/flamer_tank/mini = 3,
	)

/datum/outfit/job/vsd/spec/uslspec_two
	w_uniform = /obj/item/clothing/under/vsd/upp/white_webbing
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/marmor/upp
	head = /obj/item/clothing/head/uppcap/beret
	glasses = /obj/item/clothing/glasses/sunglasses/fake
	mask = /obj/item/clothing/mask/gas/vsd
	suit_store = /obj/item/weapon/gun/clf_heavyrifle
	back = /obj/item/shotgunbox/clf_heavyrifle
	l_pocket = /obj/item/storage/pouch/grenade

	belt_contents = list(
		/obj/item/ammo_magazine/pistol/vsd_pistol = 6,
		/obj/item/weapon/gun/pistol/vsd_pistol/standard = 1,
	)

	webbing_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)

	l_pocket_contents = list(
		/obj/item/explosive/grenade/vsd = 3,
		/obj/item/explosive/grenade/upp = 3,
	)

	head_contents = null

//juggernaut outfits
/datum/outfit/job/vsd/juggernaut
	name = "VSD Juggernaut"
	jobtype = /datum/job/vsd/juggernaut

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/vsd
	glasses = /obj/item/clothing/glasses/meson
	w_uniform = /obj/item/clothing/under/vsd/webbing
	shoes = /obj/item/clothing/shoes/marine/vsd/full
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/juggernaut
	suit_store = /obj/item/weapon/gun/rifle/vsd_lmg/juggernaut
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/vsd/juggernaut
	mask = /obj/item/clothing/mask/gas/vsd
	r_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	l_pocket = /obj/item/storage/pouch/magazine
	back = /obj/item/storage/backpack/lightpack/vsd

	backpack_contents = list(
		/obj/item/storage/box/m94 = 1,
		/obj/item/storage/box/MRE = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 2,
		/obj/item/ammo_magazine/rifle/vsd_mg = 5,
	)

	suit_contents = list(
		/obj/item/explosive/grenade/vsd = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 2,
	)

	webbing_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 2,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/explosive/plastique = 1,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_mg = 2,
	)

/datum/outfit/job/vsd/eod
	name = "VSD Juggernaut"
	jobtype = /datum/job/vsd/juggernaut

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/vsd
	glasses = /obj/item/clothing/glasses/meson
	w_uniform = /obj/item/clothing/under/vsd/webbing
	shoes = /obj/item/clothing/shoes/marine/vsd/full
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/eod
	suit_store = /obj/item/weapon/gun/launcher/rocket/vsd
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/vsd/eod
	belt = /obj/item/belt_harness/marine
	mask = /obj/item/clothing/mask/gas/vsd
	r_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	l_pocket = /obj/item/storage/pouch/explosive
	back = /obj/item/storage/backpack/lightpack/vsd

	backpack_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/explosive/grenade/vsd = 4,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 2,
		/obj/item/ammo_magazine/rocket/vsd/he = 2,
		/obj/item/ammo_magazine/rocket/vsd/incendiary = 2,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/rocket/vsd/chemical = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 2,
	)

	webbing_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 2,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/explosive/plastique = 1,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rocket/vsd/he = 2,
		/obj/item/ammo_magazine/rocket/vsd/incendiary = 2,
	)


//SL outfits
/datum/outfit/job/vsd/leader
	name = "VSD Squad Leader"
	jobtype = /datum/job/vsd/leader

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/vsd
	w_uniform = /obj/item/clothing/under/vsd/webbing
	shoes = /obj/item/clothing/shoes/marine/vsd/full
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	r_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	l_pocket = /obj/item/storage/pouch/magazine
	back = /obj/item/storage/backpack/lightpack/vsd
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/harmor
	head = /obj/item/clothing/head/helmet/marine/vsd

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/storage/box/MRE = 1,
	)

	suit_contents = list(
		/obj/item/explosive/grenade/vsd = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
	)

	webbing_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 2,
		/obj/item/explosive/plastique = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
	)

/datum/outfit/job/vsd/leader/one
	head = /obj/item/clothing/head/vsd/beret
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/desert
	mask = /obj/item/clothing/mask/gas/vsd
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/rifle/vsd_rifle/standard
	belt = /obj/item/storage/holster/belt/pistol/standard_pistol

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_rifle = 4,
		/obj/item/ammo_magazine/pistol/vsd_pistol = 2,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/pistol/vsd_pistol = 6,
		/obj/item/weapon/gun/pistol/vsd_pistol/standard = 1,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_rifle = 2,
	)

	head_contents = null

/datum/outfit/job/vsd/leader/two
	head = /obj/item/clothing/head/helmet/marine/vsd
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/harmor
	mask = /obj/item/clothing/mask/gas/vsd
	glasses = /obj/item/clothing/glasses/night/vsd
	suit_store = /obj/item/weapon/gun/rifle/vsd_lmg/juggernaut
	belt = /obj/item/storage/holster/belt/korovin

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_mg = 3,
		/obj/item/ammo_magazine/pistol/xmdivider = 4,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/pistol/xmdivider = 6,
		/obj/item/weapon/gun/pistol/xmdivider/gunslinger = 1,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_mg = 2,
	)

/datum/outfit/job/vsd/leader/upp_three
	head = /obj/item/clothing/head/uppcap/beret
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/harmor/upp
	mask = /obj/item/clothing/mask/gas/vsd
	glasses = /obj/item/clothing/glasses/night/vsd
	suit_store = /obj/item/weapon/gun/rifle/vsd_lmg/juggernaut
	belt = /obj/item/storage/holster/belt/pistol/standard_pistol

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_mg = 3,
		/obj/item/ammo_magazine/pistol/vsd_pistol = 2,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/pistol/vsd_pistol = 6,
		/obj/item/weapon/gun/pistol/vsd_pistol/standard = 1,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/vsd_mg = 2,
	)

	head_contents = null
