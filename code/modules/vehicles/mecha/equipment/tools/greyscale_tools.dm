/obj/item/mecha_parts/mecha_equipment/armor/melee
	name = "melee armor booster"
	desc = "Increases armor against melee attacks by 15%."
	icon_state = "mecha_abooster_ccw"
	iconstate_name = "melee"
	protect_name = "Melee Armor"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	slowdown = 0.5
	armor_mod = list(MELEE = 15)

/obj/item/mecha_parts/mecha_equipment/armor/acid
	name = "caustic armor booster"
	desc = "Increases armor against acid attacks by 15%."
	icon_state = "mecha_abooster_ccw"
	iconstate_name = "melee"
	protect_name = "Caustic Armor"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	slowdown = 0.4
	armor_mod = list(ACID = 15)

/obj/item/mecha_parts/mecha_equipment/armor/explosive
	name = "explosive armor booster"
	desc = "Increases armor against melee attacks by 50%."
	icon_state = "mecha_abooster_ccw"
	iconstate_name = "melee"
	protect_name = "Explosive Armor"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	slowdown = 0.3
	armor_mod = list(BOMB = 50)


/obj/item/mecha_parts/mecha_equipment/generator/greyscale
	name = "phoron engine"
	desc = "An advanced nanotrasen phoron engine core prototype designed for TGMC advanced mech exosuits. Uses solid phoron as fuel, click engine to refuel. The increased power generation comes at a cost to speed due to the weight."
	icon_state = "phoron_engine"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	rechargerate = 100
	slowdown = 0.2

/obj/item/mecha_parts/mecha_equipment/generator/greyscale/upgraded
	name = "fusion engine"
	desc = "A highly experimental phoron fusion core. Generates more power at the same consumption rate, but slows you down even more than the standard phoron engine. Uses solid phoron as fuel, click engine to refuel. Nanotrasen does not take any responsibility in case of detonation."
	icon_state = "phoron_engine_adv"
	slowdown = 0.4

/obj/item/mecha_parts/mecha_equipment/energy_optimizer
	name = "energy optimizer"
	desc = "A nanotrasen brand computer that uses predictive algorithms to reduce the power consumption of all steps by 75%."
	icon_state = "optimizer"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	equipment_slot = MECHA_POWER
	slowdown = 0.3

/obj/item/mecha_parts/mecha_equipment/energy_optimizer/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	M.normal_step_energy_drain *= 0.75
	M.step_energy_drain *= 0.75
	M.overload_step_energy_drain_min *= 0.75

/obj/item/mecha_parts/mecha_equipment/energy_control/detach(atom/moveto)
	chassis.normal_step_energy_drain /= 0.75
	chassis.step_energy_drain /= 0.75
	chassis.overload_step_energy_drain_min /= 0.75
	return ..()
