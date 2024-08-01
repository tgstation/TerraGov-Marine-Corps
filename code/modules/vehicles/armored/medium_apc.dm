/obj/vehicle/sealed/armored/multitile/medium/apc
	name = "TAV - Nike"
	desc = "A heavily armoured vehicle with light armaments designed to ferry troops around the battlefield, or assist with search and rescue (SAR) operations."
	icon = 'icons/obj/armored/2x2/medium_vehicles.dmi'
	turret_icon = 'icons/obj/armored/2x2/medium_vehicles.dmi'
	turret_icon_state = "apc_turret"
	damage_icon_path = null
//	interior = /datum/interior/armored/transport
	required_entry_skill = SKILL_LARGE_VEHICLE_DEFAULT
	minimap_icon_state = null
	armored_flags = ARMORED_HAS_HEADLIGHTS|ARMORED_PURCHASABLE_TRANSPORT|ARMORED_HAS_UNDERLAY
	permitted_weapons = list(/obj/item/armored_weapon/secondary_weapon)
	permitted_mods = list(/obj/item/tank_module/overdrive, /obj/item/tank_module/ability/zoom/*, /obj/item/tank_module/interior/medical, /obj/item/tank_module/interior/clone_bay*/)
	icon_state = "apc"
	minimap_icon_state = "apc"
	move_delay = 0.6 SECONDS
	max_occupants = 8
