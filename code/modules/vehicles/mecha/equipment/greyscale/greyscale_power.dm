/obj/item/mecha_equipment/generator/greyscale
	name = "phoron engine"
	desc = "An advanced Nanotrasen phoron engine core prototype designed for TGMC advanced mech exosuits. Uses solid phoron as fuel, click engine to refuel. The lightest engine mechs can use at a cost of recharge rate and max fuel capacity."
	icon_state = "phoron_engine"
	rechargerate = 5
	slowdown = 0.3
	max_fuel = 30000

/obj/item/mecha_equipment/generator/greyscale/upgraded
	name = "fusion engine"
	desc = "A highly experimental phoron fusion core. Generates more power at the same consumption rate, but slows you down even more than the standard phoron engine. Uses solid phoron as fuel, click engine to refuel. The heaviest engine mechs can use at a cost of speed due to weight."
	icon_state = "phoron_engine_adv"
	rechargerate = 10
	slowdown = 0.6
	max_fuel = 60000

/obj/item/mecha_equipment/energy_optimizer
	name = "energy optimizer"
	desc = "A Nanotrasen-brand computer that uses predictive algorithms to reduce the power consumption of all steps by 50%."
	icon_state = "optimizer"
	equipment_slot = MECHA_POWER
	slowdown = 0.3

/obj/item/mecha_equipment/energy_optimizer/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	M.normal_step_energy_drain *= 0.50
	M.step_energy_drain *= 0.50
	M.overload_step_energy_drain_min *= 0.50

/obj/item/mecha_equipment/energy_optimizer/detach(atom/moveto)
	chassis.normal_step_energy_drain /= 0.50
	chassis.step_energy_drain /= 0.50
	chassis.overload_step_energy_drain_min /= 0.50
	return ..()
