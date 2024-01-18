/datum/loadout_item/suit_store/main_gun/som_marine
	jobs_supported = list(SOM_SQUAD_MARINE)

/datum/loadout_item/suit_store/main_gun/som_marine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!ammo_type)
		return
	if(!istype(wearer.back, /obj/item/storage))
		return
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
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/som_marine/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
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
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
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
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
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
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
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
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
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
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
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
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/weldingtool/largetank, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
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
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
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
	purchase_cost = 75
	quantity = 4

/datum/loadout_item/suit_store/main_gun/som_marine/volkite_charger/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
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
	jobs_supported = list(SOM_SQUAD_MARINE)

/datum/loadout_item/suit_store/boarding_axe/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return
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
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)

//Engineer
/datum/loadout_item/suit_store/main_gun/som_engineer
	jobs_supported = list(SOM_SQUAD_ENGINEER)

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
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

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
	item_typepath = /obj/item/weapon/gun/shotgun/som/support

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

//Medic
/datum/loadout_item/suit_store/main_gun/som_medic
	jobs_supported = list(SOM_SQUAD_CORPSMAN)

/datum/loadout_item/suit_store/main_gun/som_medic/standard_rifle
	name = "V-31"
	desc = "The V-31 was the primary rifle of the Sons of Mars until the introduction of more advanced energy weapons. \
	Nevertheless, the V-31 continues to see common use due to its comparative ease of production and maintenance, and due to the inbuilt low velocity railgun designed for so called 'micro' grenades. \
	Has good handling due to its compact bullpup design, and is generally effective at all ranges. Uses 10x25mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som/standard
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/som_medic/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_medic/mpi
	name = "MPi-KM"
	desc = "A cheap and robust rifle manufactured by the SOM, famed for its reliability and stopping power. \
	Sometimes better known as an 'AK', it chambers 7.62x39mm."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/mpi_km/black/magharness

/datum/loadout_item/suit_store/main_gun/som_medic/mpi/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_medic/carbine
	name = "V-34"
	desc = "A modern redesign by the SOM of an ancient weapon that saw extensive use in the Martian uprising. \
	A comparatively light and compact weapon, it still packs a considerable punch thanks to a good rate of fire and high calibre, although at range its effective drops off considerably. \
	It is chambered in 7.62x39mm."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som_carbine/black/standard

/datum/loadout_item/suit_store/main_gun/som_medic/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/carbine/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/carbine/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/carbine/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/carbine/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_medic/smg
	name = "V-21"
	desc = "The V-21 is the principal submachinegun used by the Sons of Mars, designed to be used effectively one or two handed with  a variable rate of fire. \
	When fired at full speed it's performance is severely degraded unless used properly wielded, while the lower rate of fire can still be effectively used one handed when necessary. \
	It uses 10x20mm caseless rounds."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/smg/som/support

/datum/loadout_item/suit_store/main_gun/som_medic/smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_medic/flechette_shotgun
	name = "V-51"
	desc = "The V-51 is the main shotgun utilised by the Sons of Mars. Slower firing than some other semi automatic shotguns, but packs more of a kick. Loaded with flechette rounds."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/shotgun/som/support

/datum/loadout_item/suit_store/main_gun/som_medic/flechette_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)

//Veteran
/datum/loadout_item/suit_store/main_gun/som_veteran
	jobs_supported = list(SOM_SQUAD_VETERAN)

/datum/loadout_item/suit_store/main_gun/som_veteran/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
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

/datum/loadout_item/suit_store/main_gun/som_veteran/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/standard_rifle
	name = "V-31"
	desc = "The V-31 was the primary rifle of the Sons of Mars until the introduction of more advanced energy weapons. \
	Nevertheless, the V-31 continues to see common use due to its comparative ease of production and maintenance, and due to the inbuilt low velocity railgun designed for so called 'micro' grenades. \
	Has good handling due to its compact bullpup design, and is generally effective at all ranges. Loaded with armor piercing 10x25mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som/veteran
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/som_veteran/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/standard_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/smg
	name = "V-21"
	desc = "The V-21 is the principal submachinegun used by the Sons of Mars, designed to be used effectively one or two handed with  a variable rate of fire. \
	When fired at full speed it's performance is severely degraded unless used properly wielded, while the lower rate of fire can still be effectively used one handed when necessary. \
	Loaded with armor piercing 10x20mm caseless rounds."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/smg/som/veteran

/datum/loadout_item/suit_store/main_gun/som_veteran/smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/smg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/breacher
	name = "VX-32B charger"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. \
	Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. \
	The charger is a light weight weapon with a high rate of fire, designed for high mobility and easy handling. Ineffective at longer ranges. \
	This one comes with a S-144 boarding shield, intended for use with M-31 Lorica combat armor for boarding actions."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet
	purchase_cost = 50

/datum/loadout_item/suit_store/main_gun/som_veteran/breacher/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/som, SLOT_L_HAND)
	if(istype(wearer.back, /obj/item/storage))
		return ..()

	wearer.equip_to_slot_or_del(new /obj/item/tool/weldingtool/largetank, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	return ..()

/datum/loadout_item/suit_store/main_gun/som_veteran/breacher/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_charger
	name = "VX-32 charger"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. \
	Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. \
	The charger is a light weight weapon with a high rate of fire, designed for high mobility and easy handling. Ineffective at longer ranges. \
	This one is configured for more effective one handed use, and has a motion sensor attached."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/scout

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_charger/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_charger/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_caliver
	name = "VX-33 caliver"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. \
	Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. \
	The caliver is the primary rifle of the volkite family, and effective at most ranges and situations. Drag click the powerpack to the gun to use that instead of magazines."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/standard

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_caliver/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_caliver/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/mpi
	name = "MPi-KM"
	desc = "A cheap and robust rifle, sometimes better known as an 'AK'. Chambers 7.62x39mm. This one has a built in underbarrel grenade launcher and looks very old, but well looked after."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/mpi_km/grenadier

/datum/loadout_item/suit_store/main_gun/som_veteran/mpi/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/carbine
	name = "V-34"
	desc = "An old but robust weapon that saw extensive use in the Martian uprising. \
	A comparatively light and compact weapon, it still packs a considerable punch thanks to a good rate of fire and high calibre, \
	although at range its effective drops off considerably. It is chambered in 7.62x39mm."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som_carbine/mag_harness

/datum/loadout_item/suit_store/main_gun/som_veteran/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_caliver_pack
	name = "VX-33P Caliver"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. \
	Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. \
	The caliver is the primary rifle of the volkite family, and effective at most ranges and situations. Drag click the powerpack to the gun to use that instead of magazines. \
	This one has a motion sensor and is paired with a volkite powerpack."
	req_desc = "Requires a volkite powerback."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor
	quantity = 2
	purchase_cost = 100
	item_whitelist = list(/obj/item/cell/lasgun/volkite/powerpack = ITEM_SLOT_BACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_caliver_pack/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	if(istype(wearer.belt, /obj/item/weapon/gun/shotgun/double/sawn))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
	else
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_culverin
	name = "VX-42 culverin"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. \
	Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. \
	The culverin is the largest man portable example of volkite weaponry, and can lay down a staggering torrent of fire due to its linked back-mounted powerpack. Drag click the powerpack to the gun to load."
	req_desc = "Requires a volkite powerback to operate."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/magharness
	quantity = 2
	purchase_cost = 150
	item_whitelist = list(/obj/item/cell/lasgun/volkite/powerpack = ITEM_SLOT_BACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_culverin/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	if(istype(wearer.belt, /obj/item/weapon/gun/shotgun/double/sawn))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
	else
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/radioactive_smg
	name = "V-21R"
	desc = "The V-21 is the principal submachinegun used by the Sons of Mars, designed to be used effectively one or two handed with  a variable rate of fire. \
	When fired at full speed it's performance is severely degraded unless used properly wielded, while the lower rate of fire can still be effectively used one handed when necessary. \
	This particular weapon comes with a variety of irradiated and incendiary magazines."
	req_desc = "Requires a suit with a Mithridatius environmental protection module."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/smg/som/support
	item_whitelist = list(/obj/item/clothing/suit/modular/som/heavy/mithridatius = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/suit_store/main_gun/som_veteran/radioactive_smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x20mm, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

	if(istype(wearer.belt, /obj/item/storage/belt))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	if(istype(wearer.l_store, /obj/item/storage/pouch/magazine))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_L_POUCH)
	if(istype(wearer.r_store, /obj/item/storage/pouch/magazine))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)

	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/energy_sword
	name = "Energy sword"
	desc = "A SOM energy sword. Designed to cut through armored plate. An uncommon primary weapon, typically seen wielded by so called 'blink assault' troops."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/energy/sword/som
	jobs_supported = list(SOM_SQUAD_VETERAN)

/datum/loadout_item/suit_store/energy_sword/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return

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
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)

//Squad leader
/datum/loadout_item/suit_store/main_gun/som_squad_leader
	jobs_supported = list(SOM_SQUAD_LEADER)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!ammo_type)
		return
	if(istype(wearer.back, /obj/item/storage))
		if(istype(wearer.belt, /obj/item/storage/holster/belt/pistol/m4a3/som)) //if we have a backpack and pistol belt, we just load more ammo in the back
			wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		else //else we put the sidearm in the bag
			wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta(wearer), SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/standard_rifle
	name = "V-31"
	desc = "The V-31 was the primary rifle of the Sons of Mars until the introduction of more advanced energy weapons. \
	Nevertheless, the V-31 continues to see common use due to its comparative ease of production and maintenance, and due to the inbuilt low velocity railgun designed for so called 'micro' grenades. \
	Has good handling due to its compact bullpup design, and is generally effective at all ranges. Loaded with armor piercing 10x25mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som/veteran
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/som_squad_leader/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/smg
	name = "V-21"
	desc = "The V-21 is the principal submachinegun used by the Sons of Mars, designed to be used effectively one or two handed with  a variable rate of fire. \
	When fired at full speed it's performance is severely degraded unless used properly wielded, while the lower rate of fire can still be effectively used one handed when necessary. \
	Loaded with armor piercing 10x20mm caseless rounds."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/smg/som/veteran

/datum/loadout_item/suit_store/main_gun/som_squad_leader/smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/volkite_charger
	name = "VX-32 charger"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. \
	Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. \
	The charger is a light weight weapon with a high rate of fire, designed for high mobility and easy handling. Ineffective at longer ranges. \
	This one is configured for more effective one handed use, and has a motion sensor attached."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/scout

/datum/loadout_item/suit_store/main_gun/som_squad_leader/volkite_charger/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/volkite_caliver
	name = "VX-33 caliver"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. \
	Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. \
	The caliver is the primary rifle of the volkite family, and effective at most ranges and situations. Drag click the powerpack to the gun to use that instead of magazines."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor

/datum/loadout_item/suit_store/main_gun/som_squad_leader/volkite_caliver/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/mpi
	name = "MPi-KM"
	desc = "A cheap and robust rifle, sometimes better known as an 'AK'. Chambers 7.62x39mm. This one has a built in underbarrel grenade launcher and looks very old, but well looked after."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/mpi_km/grenadier

/datum/loadout_item/suit_store/main_gun/som_squad_leader/mpi/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/carbine
	name = "V-34"
	desc = "An old but robust weapon that saw extensive use in the Martian uprising. \
	A comparatively light and compact weapon, it still packs a considerable punch thanks to a good rate of fire and high calibre, \
	although at range its effective drops off considerably. It is chambered in 7.62x39mm."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som_carbine/mag_harness

/datum/loadout_item/suit_store/main_gun/som_squad_leader/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)

//Field commander
/datum/loadout_item/suit_store/main_gun/som_field_commander
	jobs_supported = list(SOM_FIELD_COMMANDER)

/datum/loadout_item/suit_store/main_gun/som_field_commander/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!ammo_type)
		return
	if(istype(wearer.back, /obj/item/storage))
		if(istype(wearer.belt, /obj/item/storage/holster/belt/pistol/m4a3/som)) //if we have a backpack and pistol belt, we just load more ammo in the back
			wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		else //else we put the sidearm in the bag
			wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta/custom(wearer), SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_field_commander/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_field_commander/standard_rifle
	name = "V-31"
	desc = "The V-31 was the primary rifle of the Sons of Mars until the introduction of more advanced energy weapons. \
	Nevertheless, the V-31 continues to see common use due to its comparative ease of production and maintenance, and due to the inbuilt low velocity railgun designed for so called 'micro' grenades. \
	Has good handling due to its compact bullpup design, and is generally effective at all ranges. Loaded with armor piercing 10x25mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som/veteran
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/som_field_commander/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_field_commander/smg
	name = "V-21"
	desc = "The V-21 is the principal submachinegun used by the Sons of Mars, designed to be used effectively one or two handed with  a variable rate of fire. \
	When fired at full speed it's performance is severely degraded unless used properly wielded, while the lower rate of fire can still be effectively used one handed when necessary. \
	Loaded with armor piercing 10x20mm caseless rounds."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/smg/som/veteran

/datum/loadout_item/suit_store/main_gun/som_field_commander/smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_field_commander/volkite_charger
	name = "VX-32 charger"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. \
	Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. \
	The charger is a light weight weapon with a high rate of fire, designed for high mobility and easy handling. Ineffective at longer ranges. \
	This one is configured for more effective one handed use, and has a motion sensor attached."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/scout

/datum/loadout_item/suit_store/main_gun/som_field_commander/volkite_charger/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_field_commander/volkite_caliver
	name = "VX-33 caliver"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. \
	Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. \
	The caliver is the primary rifle of the volkite family, and effective at most ranges and situations. Drag click the powerpack to the gun to use that instead of magazines."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor

/datum/loadout_item/suit_store/main_gun/som_field_commander/volkite_caliver/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_field_commander/mpi
	name = "MPi-KM"
	desc = "A cheap and robust rifle, sometimes better known as an 'AK'. Chambers 7.62x39mm. This one has a built in underbarrel grenade launcher and looks very old, but well looked after."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/mpi_km/grenadier

/datum/loadout_item/suit_store/main_gun/som_field_commander/mpi/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_field_commander/carbine
	name = "V-34"
	desc = "An old but robust weapon that saw extensive use in the Martian uprising. \
	A comparatively light and compact weapon, it still packs a considerable punch thanks to a good rate of fire and high calibre, \
	although at range its effective drops off considerably. It is chambered in 7.62x39mm."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som_carbine/mag_harness

/datum/loadout_item/suit_store/main_gun/som_field_commander/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/fc_boarding_axe
	name = "Boarding axe"
	desc = "A SOM boarding axe, effective at breaching doors as well as skulls. When wielded it can be used to block as well as attack."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/twohanded/fireaxe/som
	item_blacklist = list(/obj/item/weapon/twohanded/fireaxe/som = ITEM_SLOT_BACK)
	jobs_supported = list(SOM_FIELD_COMMANDER)

/datum/loadout_item/suit_store/fc_boarding_axe/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign/som, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return
	if(istype(wearer.belt, /obj/item/storage/holster/belt/pistol/m4a3/som))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	else
		wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta/custom(wearer), SLOT_IN_BACKPACK)

	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
