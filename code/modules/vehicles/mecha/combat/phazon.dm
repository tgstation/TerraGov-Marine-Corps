/obj/vehicle/sealed/mecha/combat/phazon
	desc = "This is a Phazon exosuit. The pinnacle of scientific research and pride of Nanotrasen, it uses cutting edge bluespace technology and expensive materials."
	name = "\improper Phazon"
	icon_state = "phazon"
	base_icon_state = "phazon"
	move_delay = 2
	dir_in = 2 //Facing South.
	step_energy_drain = 3
	max_integrity = 200
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 30, BIO = 0, FIRE = 100, ACID = 100)
	max_temperature = 25000
	wreckage = /obj/structure/mecha_wreckage/phazon
	mech_type = EXOSUIT_MODULE_PHAZON
	force = 15
	max_equip_by_category = list(
		MECHA_UTILITY = 1,
		MECHA_POWER = 1,
		MECHA_ARMOR = 2,
	)
	phase_state = "phazon-phase"

/obj/vehicle/sealed/mecha/combat/phazon/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_phasing)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_switch_damtype)
