//Any loadout that is intended for the new player loadout vendor
///When making new loadouts, remember to also add the typepath to the list under init_beginner_loadouts() or else it won't show up in the vendor


/datum/outfit/quick/beginner
	name = "Beginner loadout base"
	desc = "The base loadout for beginners. You shouldn't be able to see this"
	jobtype = "Squad Marine"

	w_uniform = /obj/item/clothing/under/marine
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten
	gloves = /obj/item/clothing/gloves/marine/black
	mask = /obj/item/clothing/mask/bandanna
	head = /obj/item/clothing/head/modular/m10x
	r_store = /obj/item/storage/pouch/medkit/firstaid
	l_store = /obj/item/storage/holster/flarepouch/full
	back = /obj/item/storage/backpack/marine/satchel
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/mainship/marine

/datum/outfit/quick/beginner/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/protein_pack, SLOT_IN_HEAD)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/protein_pack, SLOT_IN_HEAD)

/datum/outfit/quick/beginner/marine/rifleman
	name = "Rifleman"
	desc = "A typical rifleman for the marines. \
	Wields the AR-12, a versatile all-rounder assault rifle with a powerful underbarrel grenade launcher attached. \
	Also carries the strong P-23 sidearm and a variety of flares, medical equipment, and more for every situation."

	wear_suit = /obj/item/clothing/suit/modular/xenonauten/hodgrenades
	head = /obj/item/clothing/head/modular/m10x/hod
	w_uniform = /obj/item/clothing/under/marine/holster
	suit_store = /obj/item/weapon/gun/rifle/standard_assaultrifle/medic
	l_hand = /obj/item/paper/tutorial/beginner_rifleman

/datum/outfit/quick/beginner/marine/rifleman/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BACKPACK)

	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)

	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/beginner(human), SLOT_IN_ACCESSORY)

	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)

/datum/outfit/quick/beginner/marine/machinegunner
	name = "Machinegunner"
	desc = "The king of suppressive fire. Uses the MG-60, a fully automatic 200 round machine gun with a bipod attached. \
	Excels at denying large areas to the enemy and eliminating those who refuse to leave."

	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/tyr_onegeneral
	head = /obj/item/clothing/head/modular/m10x/tyr
	w_uniform = /obj/item/clothing/under/marine/black_vest
	back = /obj/item/storage/backpack/marine/standard
	belt = /obj/item/storage/belt/sparepouch
	suit_store = /obj/item/weapon/gun/rifle/standard_gpmg/beginner
	mask = /obj/item/clothing/mask/rebreather
	l_hand = /obj/item/paper/tutorial/beginner_machinegunner

/datum/outfit/quick/beginner/marine/machinegunner/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BACKPACK)

	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BELT)

	human.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)

	human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/plasma_pistol, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/plasma_pistol, SLOT_IN_SUIT)


/datum/outfit/quick/beginner/marine/marksman
	name = "Marksman"
	desc = "Quality over quantity. Equipped with the DMR-37, an accurate long-range designated marksman rifle with a scope attached. \
	While subpar in close quarters, the precision of the DMR is unmatched, exceeding at taking out threats from afar."

	wear_suit = /obj/item/clothing/suit/modular/xenonauten/lightmedical
	head = /obj/item/clothing/head/modular/style/boonie
	w_uniform = /obj/item/clothing/under/marine/holster
	belt = /obj/item/belt_harness/marine
	l_store = /obj/item/storage/pouch/magazine/large
	r_store = /obj/item/storage/pouch/magazine/large
	suit_store = /obj/item/weapon/gun/rifle/standard_dmr/beginner
	mask = /obj/item/clothing/mask/breath
	l_hand = /obj/item/paper/tutorial/beginner_marksman

/datum/outfit/quick/beginner/marine/marksman/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_dmr, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_dmr, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_dmr, SLOT_IN_BACKPACK)

	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_dmr, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_dmr, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_dmr, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_dmr, SLOT_IN_R_POUCH)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_dmr, SLOT_IN_R_POUCH)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_dmr, SLOT_IN_R_POUCH)

	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/beginner(human), SLOT_IN_ACCESSORY)

	human.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/bicaridine, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/kelotane, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tricordrazine, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tramadol, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_SUIT)

/datum/outfit/quick/beginner/marine/shotgunner
	name = "Shotgunner"
	desc = "Up close and personal. Wields the SH-39, a semi-automatic shotgun loaded with slugs. \
	An absolute monster at short to mid range, the shotgun will do heavy damage to any target hit, as well as stunning them briefly, staggering them, and knocking them back."

	w_uniform = /obj/item/clothing/under/marine/holster
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/lightgeneral
	suit_store = /obj/item/weapon/gun/shotgun/combat/standardmarine/beginner
	belt = /obj/item/storage/belt/shotgun
	head = /obj/item/clothing/head/modular/m10x/freyr
	gloves = /obj/item/clothing/gloves/marine/fingerless
	mask = /obj/item/clothing/mask/gas/tactical/coif
	l_hand = /obj/item/paper/tutorial/beginner_shotgunner

/datum/outfit/quick/beginner/marine/shotgunner/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_BACKPACK)

	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)

	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/plasma_pistol/beginner(human), SLOT_IN_ACCESSORY)

	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_SUIT)

/datum/outfit/quick/beginner/marine/shocktrooper
	name = "Shocktrooper"
	desc = "The bleeding edge of the corps. \
	Equipped with the experimental battery-fed laser rifle, featuring four different modes that can be freely swapped between, with an underbarrel flamethrower for area denial and clearing mazes."

	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/medic
	glasses = /obj/item/clothing/glasses/sunglasses/fake/big
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/lightgeneral
	head = /obj/item/clothing/head/modular/style/cap
	mask = /obj/item/clothing/mask/gas/modular/skimask
	r_store = /obj/item/cell/lasgun/volkite/powerpack/marine
	w_uniform = /obj/item/clothing/under/marine/corpman_vest
	shoes = /obj/item/clothing/shoes/marine
	l_hand = /obj/item/paper/tutorial/beginner_shocktrooper

/datum/outfit/quick/beginner/marine/shocktrooper/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)

	human.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BOOT)

	human.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/dylovene, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_BACKPACK)

	human.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/powerpack/marine, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_SUIT)

	human.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/bicaridine, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/kelotane, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tricordrazine, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tramadol, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_ACCESSORY)

/datum/outfit/quick/beginner/marine/hazmat
	name = "Hazmat"
	desc = "Designed for danger. \
	Wields the AR-11, a powerful yet innacurate assault rifle with high magazine size and an equipped tactical sensor that detects enemies through smoke and walls. \
	Wears Mimir combat armor, rendering the user immune to the dangerous toxic gas possessed by many xenomorphs."

	head = /obj/item/clothing/head/modular/m10x/mimir
	suit_store = /obj/item/weapon/gun/rifle/tx11/freelancertwo
	back = /obj/item/storage/backpack/marine/standard
	w_uniform = /obj/item/clothing/under/marine/black_vest
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/mimir
	mask = /obj/item/clothing/mask/rebreather/scarf
	belt = /obj/item/belt_harness/marine
	l_hand = /obj/item/paper/tutorial/beginner_hazmat

/datum/outfit/quick/beginner/marine/hazmat/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)

	human.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)

	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_SUIT)

/datum/outfit/quick/beginner/marine/cqc
	name = "CQC"
	desc = "Swift and lethal. \
	Equipped with the AR-18, a lightweight carbine with a rapid-fire burst mode. Designed for maximum mobility, soldiers are able to rush in, assault the enemy, and retreat before they can respond."

	suit_store = /obj/item/weapon/gun/rifle/standard_carbine/beginner
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/lightgeneral
	w_uniform = /obj/item/clothing/under/marine/black_vest
	head = /obj/item/clothing/head/modular/style/beret
	glasses = /obj/item/clothing/glasses/mgoggles
	l_hand = /obj/item/paper/tutorial/beginner_cqc

/datum/outfit/quick/beginner/marine/cqc/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)

	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BACKPACK)

	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_SUIT)

	human.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)

/datum/outfit/quick/beginner/marine/chad //Ya gotta be if you pick this loadout
	name = "Grenadier"
	desc = "Explosive area denial. \
	Uses the GL-70, a six shot semi-automatic grenade launcher, loaded with HEDP high explosive grenades. \
	Boasts unmatched power, though heavy caution is advised to avoid harming friendlies."

	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/grenadier
	suit_store = /obj/item/weapon/gun/grenade_launcher/multinade_launcher/beginner
	l_store = /obj/item/storage/pouch/grenade
	r_store = /obj/item/storage/pouch/grenade
	belt = /obj/item/storage/belt/grenade
	mask = /obj/item/clothing/mask/gas
	w_uniform = /obj/item/clothing/under/marine/corpman_vest
	head = /obj/item/clothing/head/modular/m10x/antenna
	shoes = /obj/item/clothing/shoes/marine
	l_hand = /obj/item/paper/tutorial/beginner_chad

/datum/outfit/quick/beginner/marine/chad/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BELT)

	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)

	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)

	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)

	human.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/bicaridine, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/kelotane, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tricordrazine, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tramadol, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_ACCESSORY)

	human.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/double/derringer, SLOT_IN_BOOT) //So you can kill yourself when you run out of grenades

/datum/outfit/quick/beginner/engineer
	jobtype = "Squad Engineer"

	w_uniform = /obj/item/clothing/under/marine/brown_vest
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/marine/insulated
	l_store = /obj/item/storage/pouch/tools

/datum/outfit/quick/beginner/engineer/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BOOT)

	human.equip_to_slot_or_del(new /obj/item/tool/screwdriver, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/tool/wirecutters, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/tool/wrench, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/tool/weldingtool/hugetank, SLOT_IN_L_POUCH)

	human.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_smol, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/tool/handheld_charger/hicapcell, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_ACCESSORY)

	human.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/medium_stack, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)

/datum/outfit/quick/beginner/engineer/builder
	name = "Engineer Standard"
	desc = "Born to build. Equipped with a metric ton of metal, you can be certain that a lack of barricades is not a possibility with you around."

	suit_store = /obj/item/weapon/gun/rifle/standard_lmg/beginner
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/mimirengi
	mask = /obj/item/clothing/mask/gas/tactical
	head = /obj/item/clothing/head/modular/m10x/mimir
	back = /obj/item/storage/backpack/marine/radiopack
	belt = /obj/item/belt_harness/marine
	glasses = /obj/item/clothing/glasses/welding/superior
	l_hand = /obj/item/paper/tutorial/builder

/datum/outfit/quick/beginner/engineer/builder/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)

	human.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/stack/sandbags_empty/full, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_lmg, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_lmg, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_lmg, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_lmg, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_lmg, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

/datum/outfit/quick/beginner/engineer/burnitall
	name = "Flamethrower"
	desc = "For those who truly love to watch the world burn. Equipped with a laser and a flamethrower, you can be certain that none of your enemies will be left un-burnt."

	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/beginner
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/engineer
	mask = /obj/item/clothing/mask/gas/tactical/coif
	head = /obj/item/clothing/head/modular/m10x/superiorwelding
	back = /obj/item/storage/holster/backholster/flamer
	glasses = /obj/item/clothing/glasses/meson
	l_hand = /obj/item/paper/tutorial/flamer

/datum/outfit/quick/beginner/engineer/burnitall/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/tool/multitool, SLOT_IN_SUIT)

	human.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	human.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)

	human.equip_to_slot_or_del(new /obj/item/weapon/gun/flamer/big_flamer/marinestandard/engineer/beginner(human), SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines/large, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool, SLOT_IN_BACKPACK)

/datum/outfit/quick/beginner/engineer/pcenjoyer
	name = "Plasma Cutter"
	desc = "For the open-air enjoyers. Equipped with a plasma cutter, you will be able to cut down all types of walls and obstacles that dare exist within your vicinity."

	suit_store = /obj/item/tool/pickaxe/plasmacutter
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/engineer
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/m10x/superiorwelding
	back = /obj/item/storage/backpack/marine/engineerpack
	belt = /obj/item/belt_harness/marine
	glasses = /obj/item/clothing/glasses/meson
	l_hand = /obj/item/paper/tutorial/plasmacutter

/datum/outfit/quick/beginner/engineer/pcenjoyer/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_HEAD)

	human.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_SUIT)

	human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/standard_machinepistol/compact(human), SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)

/datum/outfit/quick/beginner/corpsman
	jobtype = "Squad Corpsman"

	shoes = /obj/item/clothing/shoes/marine
	w_uniform = /obj/item/clothing/under/marine/corpsman/corpman_vest
	glasses = /obj/item/clothing/glasses/hud/health
	r_hand = /obj/item/medevac_beacon

/datum/outfit/quick/beginner/corpsman/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BOOT)

/datum/outfit/quick/beginner/corpsman/lifesaver
	name = "Standard Lifesaver"
	desc = "Miracle in progress. \
	Wields the bolt action Leicaster Repeater, and is equipped with a large variety of medicine for keeping the entire corps topped up and in the fight."

	suit_store = /obj/item/weapon/gun/shotgun/pump/lever/repeater/beginner
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/mimirinjector
	gloves = /obj/item/defibrillator/gloves
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/m10x/mimir
	r_store = /obj/item/storage/pouch/medkit/medic
	l_store = /obj/item/storage/pouch/shotgun
	back = /obj/item/storage/backpack/marine/corpsman
	belt = /obj/item/storage/belt/lifesaver/beginner
	l_hand = /obj/item/paper/tutorial/lifesaver

/datum/outfit/quick/beginner/corpsman/lifesaver/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/bodybag/cryobag, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/nanoblood, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/roller/medevac, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/tweezers, SLOT_IN_ACCESSORY)

	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dexalinplus, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_SUIT)

	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p4570, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p4570, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p4570, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p4570, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p4570, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p4570, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p4570, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)

	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/repeater, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/repeater, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/repeater, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/repeater, SLOT_IN_L_POUCH)

/datum/outfit/quick/beginner/corpsman/hypobelt
	name = "Standard Hypobelt"
	desc = "Putting the combat in combat medic. \
	Wields the pump action SH-35 shotgun, and is equipped with a belt full of hyposprays for rapidly treating patients in bad condition."

	suit_store = /obj/item/weapon/gun/shotgun/pump/t35/beginner
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/light/lightmedical
	gloves = /obj/item/healthanalyzer/gloves
	mask = /obj/item/clothing/mask/gas/modular/coofmask
	head = /obj/item/clothing/head/modular/m10x/antenna
	r_store = /obj/item/storage/pouch/medkit/medic
	l_store = /obj/item/storage/pouch/shotgun
	back = /obj/item/storage/backpack/marine/corpsman
	belt = /obj/item/storage/belt/hypospraybelt/beginner
	l_hand = /obj/item/paper/tutorial/hypobelt

/datum/outfit/quick/beginner/corpsman/hypobelt/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_ACCESSORY)

	human.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/bodybag/cryobag, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/roller/medevac, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/tweezers, SLOT_IN_SUIT)

	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_L_POUCH)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_L_POUCH)

	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/protein_pack, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BACKPACK)

/datum/outfit/quick/beginner/smartgunner
	jobtype = "Squad Smartgunner"

	w_uniform = /obj/item/clothing/under/marine/black_vest
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/lightgeneral
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/m10x/antenna
	belt = /obj/item/belt_harness/marine
	glasses = /obj/item/clothing/glasses/night/m56_goggles

/datum/outfit/quick/beginner/smartgunner/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BOOT)

/datum/outfit/quick/beginner/smartgunner/sg29
	name = "Standard Smartmachinegun"
	desc = "Tactical support fire. \
	Uses the SG-29, a specialist light machine gun that will shoot through your allies, \
	equipped with a tactical sensor to detect enemies through smoke, walls, and darkness."

	suit_store = /obj/item/weapon/gun/rifle/standard_smartmachinegun/pmc
	l_hand = /obj/item/paper/tutorial/smartmachinegunner

/datum/outfit/quick/beginner/smartgunner/sg29/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_SUIT)

	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_ACCESSORY)

	human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/plasma_pistol, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)

/datum/outfit/quick/beginner/smartgunner/sg85
	name = "Standard Smartminigun"
	desc = "Lead wall! Wields the SG-85, a specialist minigun that holds one thousand rounds and can shoot through your allies, \
	equipped with a tactical sensor to detect enemies through smoke, walls, and darkness."

	suit_store = /obj/item/weapon/gun/minigun/smart_minigun/motion_detector
	back = /obj/item/ammo_magazine/minigun_powerpack/smartgun
	l_hand = /obj/item/paper/tutorial/smartminigunner

/datum/outfit/quick/beginner/smartgunner/sg85/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/smart_minigun, SLOT_IN_SUIT)
	human.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/smart_minigun, SLOT_IN_SUIT)

	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_ACCESSORY)
	human.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_ACCESSORY)

