/*******************************************************************************
SMARTGUNS
*******************************************************************************/
/datum/supply_packs/smartguns
	group = "Smartguns"
	containertype = /obj/structure/closet/crate/smart

/datum/supply_packs/smartguns/smartgun
	name = "SG-29 smart machine gun"
	contains = list(/obj/item/weapon/gun/rifle/standard_smartmachinegun)
	cost = 400

/datum/supply_packs/smartguns/smartgun_ammo
	name = "SG-29 ammo drum"
	contains = list(/obj/item/ammo_magazine/standard_smartmachinegun)
	cost = 50

/datum/supply_packs/smartguns/smart_minigun
	name = "SG-85 smart gatling gun"
	contains = list(/obj/item/weapon/gun/minigun/smart_minigun)
	cost = 400

/datum/supply_packs/smartguns/smart_minigun_ammo
	name = "SG-85 ammo bin"
	contains = list(/obj/item/ammo_magazine/packet/smart_minigun)
	cost = 50

/datum/supply_packs/smartguns/smart_minigun_powerpack
	name = "SG-85 powerpack"
	contains = list(/obj/item/ammo_magazine/minigun_powerpack/smartgun)
	cost = 150

/datum/supply_packs/smartguns/smarttarget_rifle
	name = "SG-62 smart target rifle"
	contains = list(/obj/item/weapon/gun/rifle/standard_smarttargetrifle)
	cost = 400

/datum/supply_packs/smartguns/smarttarget_rifle_ammo
	name = "SG-62 smart target rifle ammo"
	contains = list(/obj/item/ammo_magazine/rifle/standard_smarttargetrifle)
	cost = 35

/datum/supply_packs/smartguns/smarttarget_rifle_ammo_bin
	name = "SG-62 smart target rifle ammo bin"
	contains = list(/obj/item/ammo_magazine/packet/smart_targetrifle)
	cost = 50

/datum/supply_packs/smartguns/smartspotting_rifle_ammo_bin
	name = "SG-153 spotting rifle ammo bin"
	contains = list(/obj/item/ammo_magazine/packet/smart_spottingrifle)
	cost = 50

/datum/supply_packs/smartguns/spotting_rifle_ammo
	name = "SG-153 spotting rifle ammo"
	contains = list(/obj/item/ammo_magazine/rifle/standard_spottingrifle)
	cost = 15

/datum/supply_packs/smartguns/spotting_rifle_ammo/highimpact
	name = "SG-153 high impact spotting rifle ammo"
	contains = list(/obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact)

/datum/supply_packs/smartguns/spotting_rifle_ammo/heavyrubber
	name = "SG-153 heavy rubber spotting rifle ammo"
	contains = list(/obj/item/ammo_magazine/rifle/standard_spottingrifle/heavyrubber)

/datum/supply_packs/smartguns/spotting_rifle_ammo/plasmaloss
	name = "SG-153 tanglefoot spotting rifle ammo"
	contains = list(/obj/item/ammo_magazine/rifle/standard_spottingrifle/plasmaloss)

/datum/supply_packs/smartguns/spotting_rifle_ammo/tungsten
	name = "SG-153 tungsten spotting rifle ammo"
	contains = list(/obj/item/ammo_magazine/rifle/standard_spottingrifle/tungsten)

/datum/supply_packs/smartguns/spotting_rifle_ammo/flak
	name = "SG-153 flak spotting rifle ammo"
	contains = list(/obj/item/ammo_magazine/rifle/standard_spottingrifle/flak)

/datum/supply_packs/smartguns/spotting_rifle_ammo/incendiary
	name = "SG-153 incendiary spotting rifle ammo"
	contains = list(/obj/item/ammo_magazine/rifle/standard_spottingrifle/incendiary)
