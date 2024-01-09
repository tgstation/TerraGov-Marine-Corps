/datum/loadout_item/suit_store/main_gun/som_marine
	jobs_supported = list(SOM_SQUAD_MARINE)

/datum/loadout_item/suit_store/main_gun/som_marine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!ammo_type)
		return
	if(istype(wearer.back, /obj/item/storage))
		if(istype(wearer.belt, /obj/item/storage/holster/belt/pistol/m4a3/som)) //if we have a backpack and pistol belt, we just load more ammo in the back
			wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		else //else we put the sidearm in the bag
			wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/som/standard(wearer), SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/standard_rifle
	name = "V-31"
	desc = "The V-31 was the primary rifle of the Sons of Mars until the introduction of more advanced energy weapons. \
	Nevertheless, the V-31 continues to see common use due to its comparative ease of production and maintenance, and due to the inbuilt low velocity railgun designed for so called 'micro' grenades. \
	Has good handling due to its compact bullpup design, and is generally effective at all ranges. Uses 10x25mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som/standard

/datum/loadout_item/suit_store/main_gun/som_marine/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/standard_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/mpi_grenadier
	name = "MPi-KM"
	desc = "A cheap and robust rifle manufactured by the SOM, famed for its reliability and stopping power. \
	Sometimes better known as an 'AK', it chambers 7.62x39mm. This one has a built in underbarrel grenade launcher."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/mpi_km/black/grenadier

/datum/loadout_item/suit_store/main_gun/som_marine/mpi_grenadier/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/carbine
	name = "V-34"
	desc = "A modern redesign by the SOM of an ancient weapon that saw extensive use in the Martian uprising. \
	A comparatively light and compact weapon, it still packs a considerable punch thanks to a good rate of fire and high calibre, although at range its effective drops off considerably. \
	It is chambered in 7.62x39mm."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som_carbine/black/standard

/datum/loadout_item/suit_store/main_gun/som_marine/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/smg
	name = "V-21"
	desc = "The V-21 is the principal submachinegun used by the Sons of Mars, designed to be used effectively one or two handed with  a variable rate of fire. \
	When fired at full speed it's performance is severely degraded unless used properly wielded, while the lower rate of fire can still be effectively used one handed when necessary. \
	It uses 10x20mm caseless rounds."
	req_desc = "Requires M-11 scout armor."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/smg/som/scout
	item_whitelist = list(/obj/item/clothing/suit/modular/som/light/shield = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/suit_store/main_gun/som_marine/smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/smg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/standard_shotgun
	name = "V-51"
	desc = "The V-51 is the main shotgun utilised by the Sons of Mars. Slower firing than some other semi automatic shotguns, but packs more of a kick."
	req_desc = "Requires M-11 scout armor."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/shotgun/som/standard
	item_whitelist = list(/obj/item/clothing/suit/modular/som/light/shield = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/suit_store/main_gun/som_marine/standard_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/smg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/flamer
	name = "V-62 incinerator"
	desc = "The V-62 is a deadly weapon employed in close quarter combat, favoured as much for the terror it inspires as the actual damage it inflicts. \
	It has good range for a flamer, but lacks the integrated extinguisher of its TGMC equivalent."
	req_desc = "Requires M-31 combat armor with a Hades fireproof module."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/flamer/som/mag_harness
	item_whitelist = list(/obj/item/clothing/suit/modular/som/heavy/pyro = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/suit_store/main_gun/som_marine/flamer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/flamer/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/smg_and_shield
	name = "V-21 & riot shield"
	desc = "The V-21 is the principal submachinegun used by the Sons of Mars, designed to be used effectively one or two handed with  a variable rate of fire. \
	When fired at full speed it's performance is severely degraded unless used properly wielded, while the lower rate of fire can still be effectively used one handed when necessary. \
	It uses 10x20mm caseless rounds. \
	This one comes with a S-144 boarding shield, intended for use with M-31 combat armor for boarding actions."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/smg/som/one_handed

/datum/loadout_item/suit_store/main_gun/som_marine/smg_and_shield/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/som, SLOT_L_HAND)
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/tool/weldingtool/largetank, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	return ..() //we explicitly don't want a sidearm for this weapon choice

/datum/loadout_item/suit_store/main_gun/som_marine/smg_and_shield/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/machinegunner
	name = "V-41"
	desc = "The V-41 is a large man portable machine used by the SOM, allowing for sustained, accurate suppressive firepower at the cost of mobility and handling. \
	Commonly seen where their preferred tactics of fast, mobile aggression is ill suited. Takes 10x26mm Caseless."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som_mg/standard

/datum/loadout_item/suit_store/main_gun/som_marine/machinegunner/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/machinegunner/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/volkite_charger
	name = "VX-32 charger"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. \
	Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. \
	The charger is a light weight weapon with a high rate of fire, designed for high mobility and easy handling. Ineffective at longer ranges."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/magharness
	purchase_cost = 2
	quantity = 4

/datum/loadout_item/suit_store/main_gun/som_marine/volkite_charger/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/volkite_charger/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/boarding_axe
	name = "Boarding axe"
	desc = "A SOM boarding axe, effective at breaching doors as well as skulls. When wielded it can be used to block as well as attack."
	req_desc = "Requires M-31 combat armor with a Lorica extra armor module."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/twohanded/fireaxe/som
	item_whitelist = list(/obj/item/clothing/suit/modular/som/heavy/lorica = ITEM_SLOT_OCLOTHING)
	item_blacklist = list(/obj/item/weapon/twohanded/fireaxe/som = ITEM_SLOT_BACK)

/datum/loadout_item/suit_store/boarding_axe/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(istype(wearer.back, /obj/item/storage))
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)

	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)

//Engineer
/datum/loadout_item/suit_store/main_gun/som_engineer
	jobs_supported = list(SOM_SQUAD_MARINE)

/datum/loadout_item/suit_store/main_gun/som_engineer/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_engineer/standard_rifle
	name = "V-31"
	desc = "The V-31 was the primary rifle of the Sons of Mars until the introduction of more advanced energy weapons. \
	Nevertheless, the V-31 continues to see common use due to its comparative ease of production and maintenance, and due to the inbuilt low velocity railgun designed for so called 'micro' grenades. \
	Has good handling due to its compact bullpup design, and is generally effective at all ranges. Uses 10x25mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som/standard

/datum/loadout_item/suit_store/main_gun/som_engineer/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_engineer/standard_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_engineer/mpi
	name = "MPi-KM"
	desc = "A cheap and robust rifle manufactured by the SOM, famed for its reliability and stopping power. \
	Sometimes better known as an 'AK', it chambers 7.62x39mm."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/mpi_km/black/magharness

/datum/loadout_item/suit_store/main_gun/som_engineer/mpi/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_engineer/carbine
	name = "V-34"
	desc = "A modern redesign by the SOM of an ancient weapon that saw extensive use in the Martian uprising. \
	A comparatively light and compact weapon, it still packs a considerable punch thanks to a good rate of fire and high calibre, although at range its effective drops off considerably. \
	It is chambered in 7.62x39mm."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som_carbine/black/standard

/datum/loadout_item/suit_store/main_gun/som_engineer/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_engineer/smg
	name = "V-21"
	desc = "The V-21 is the principal submachinegun used by the Sons of Mars, designed to be used effectively one or two handed with  a variable rate of fire. \
	When fired at full speed it's performance is severely degraded unless used properly wielded, while the lower rate of fire can still be effectively used one handed when necessary. \
	It uses 10x20mm caseless rounds."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/smg/som/support

/datum/loadout_item/suit_store/main_gun/som_engineer/smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_engineer/smg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_engineer/flechette_shotgun
	name = "V-51"
	desc = "The V-51 is the main shotgun utilised by the Sons of Mars. Slower firing than some other semi automatic shotguns, but packs more of a kick. Loaded with flechette rounds."
	ui_icon = "ballistic"
	item_typepath = /obj/item/storage/belt/shotgun/som/flechette

/datum/loadout_item/suit_store/main_gun/som_engineer/flechette_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_engineer/flechette_shotgun/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_ACCESSORY)
