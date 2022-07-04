///Lavaproof, fireproof, fast mech with low armor and higher energy consumption, cannot strafe and has an internal ore box.
/obj/vehicle/sealed/mecha/working/clarke
	desc = "Combining man and machine for a better, stronger engineer. Can even resist lava!"
	name = "\improper Clarke"
	icon_state = "clarke"
	base_icon_state = "clarke"
	max_temperature = 65000
	max_integrity = 200
	move_delay = 1.25
	lights_power = 7
	step_energy_drain = 15 //slightly higher energy drain since you movin those wheels FAST
	soft_armor = list(MELEE = 20, BULLET = 10, LASER = 20, ENERGY = 10, BOMB = 60, BIO = 0, FIRE = 100, ACID = 100) //low armor to compensate for fire protection and speed
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/orebox_manager),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	wreckage = /obj/structure/mecha_wreckage/clarke
	mech_type = EXOSUIT_MODULE_CLARKE
	enter_delay = 40
	mecha_flags = ADDING_ACCESS_POSSIBLE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE | OMNIDIRECTIONAL_ATTACKS

/obj/vehicle/sealed/mecha/working/clarke/Initialize(mapload)
	. = ..()
	box = new(src)

//Ore Box Controls

///Special equipment for the Clarke mech, handles moving ore without giving the mech a hydraulic clamp and cargo compartment.
/obj/item/mecha_parts/mecha_equipment/orebox_manager
	name = "ore storage module"
	desc = "An automated ore box management device."
	icon = 'icons/obj/mining.dmi'
	icon_state = "bin"
	equipment_slot = MECHA_UTILITY
	detachable = FALSE
	/// Var to avoid istype checking every time the topic button is pressed. This will only work inside Clarke mechs.
	var/obj/vehicle/sealed/mecha/working/clarke/hostmech

/obj/item/mecha_parts/mecha_equipment/orebox_manager/attach(obj/vehicle/sealed/mecha/M, attach_right = FALSE)
	. = ..()
	if(istype(M, /obj/vehicle/sealed/mecha/working/clarke))
		hostmech = M

/obj/item/mecha_parts/mecha_equipment/orebox_manager/detach()
	hostmech = null //just in case
	return ..()

/obj/item/mecha_parts/mecha_equipment/orebox_manager/ui_act(action, list/params)
	. = ..()
	if(action == "toggle")
		//hostmech.box?.dump_box_contents()
		activated = TRUE
