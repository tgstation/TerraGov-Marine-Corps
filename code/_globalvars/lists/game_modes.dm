///List of all faction_stats datums, by faction
GLOBAL_LIST_EMPTY(faction_stats_datums)

///jobs by faction, ranked by seniority
GLOBAL_LIST_INIT(ranked_jobs_by_faction, list(
	FACTION_TERRAGOV = list(CAPTAIN, FIELD_COMMANDER, STAFF_OFFICER, SQUAD_LEADER),
	FACTION_SOM = list(SOM_COMMANDER, SOM_FIELD_COMMANDER, SOM_STAFF_OFFICER, SOM_SQUAD_LEADER, SOM_SQUAD_VETERAN),
))

///All jobs used in campaign
GLOBAL_LIST_INIT(campaign_jobs, list(
	SQUAD_MARINE,
	SQUAD_ENGINEER,
	SQUAD_CORPSMAN,
	SQUAD_SMARTGUNNER,
	SQUAD_LEADER,
	FIELD_COMMANDER,
	STAFF_OFFICER,
	CAPTAIN,
	SOM_SQUAD_MARINE,
	SOM_SQUAD_ENGINEER,
	SOM_SQUAD_CORPSMAN,
	SOM_SQUAD_VETERAN,
	SOM_SQUAD_LEADER,
	SOM_FIELD_COMMANDER,
	SOM_STAFF_OFFICER,
	SOM_COMMANDER,
))

///Loot table if Marines win a major victory in a campaign mission
GLOBAL_LIST_INIT(campaign_tgmc_major_loot, list(
	/obj/effect/supply_drop/medical_basic = 7,
	/obj/effect/supply_drop/marine_sentry = 5,
	/obj/effect/supply_drop/recoilless_rifle = 3,
	/obj/effect/supply_drop/armor_upgrades = 5,
	/obj/effect/supply_drop/mmg = 4,
	/obj/effect/supply_drop/zx_shotgun = 3,
	/obj/effect/supply_drop/minigun = 3,
	/obj/effect/supply_drop/scout = 3,
	/obj/item/implanter/sandevistan = 3,
	/obj/item/implanter/blade = 3,
	/obj/effect/supply_drop/jump_mod = 3,
))

///Loot table if Marines win a minor victory in a campaign mission
GLOBAL_LIST_INIT(campaign_tgmc_minor_loot, list(
	/obj/effect/supply_drop/medical_basic = 7,
	/obj/effect/supply_drop/marine_sentry = 5,
	/obj/effect/supply_drop/recoilless_rifle = 3,
	/obj/effect/supply_drop/armor_upgrades = 5,
	/obj/effect/supply_drop/mmg = 4,
	/obj/item/implanter/blade = 3,
	/obj/effect/supply_drop/jump_mod = 2,
))

///Loot table if SOM win a major victory in a campaign mission
GLOBAL_LIST_INIT(campaign_som_major_loot, list(
	/obj/effect/supply_drop/medical_basic = 7,
	/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope = 5,
	/obj/effect/supply_drop/som_rpg = 3,
	/obj/effect/supply_drop/som_armor_upgrades = 5,
	/obj/effect/supply_drop/charger = 4,
	/obj/effect/supply_drop/culverin = 3,
	/obj/effect/supply_drop/blink_kit = 3,
	/obj/effect/supply_drop/som_shotgun_burst = 3,
	/obj/item/implanter/sandevistan = 3,
	/obj/item/implanter/blade = 3,
	/obj/effect/supply_drop/jump_mod = 3,
))

///Loot table if SOM win a minor victory in a campaign mission
GLOBAL_LIST_INIT(campaign_som_minor_loot, list(
	/obj/effect/supply_drop/medical_basic = 7,
	/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope = 5,
	/obj/effect/supply_drop/som_rpg = 3,
	/obj/effect/supply_drop/som_armor_upgrades = 5,
	/obj/effect/supply_drop/charger = 4,
	/obj/item/implanter/blade = 3,
	/obj/effect/supply_drop/jump_mod = 2,
))

///Bike type by faction
GLOBAL_LIST_INIT(campaign_bike_by_faction, list(
	FACTION_TERRAGOV = /obj/vehicle/ridden/big_bike,
	FACTION_SOM = /obj/vehicle/ridden/hover_bike,
))

///Cas disabler by faction
GLOBAL_LIST_INIT(campaign_cas_disabler_by_faction, list(
	FACTION_TERRAGOV = /datum/campaign_asset/asset_disabler/tgmc_cas/instant,
	FACTION_SOM = /datum/campaign_asset/asset_disabler/som_cas/instant,
))
