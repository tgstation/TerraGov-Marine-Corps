// CPU that allows the computer to run programs.
// Better CPUs are obtainable via research and can run more programs on background.

/obj/item/computer_hardware/processor_unit
	name = "processor board"
	desc = ""
	icon_state = "cpuboard"
	w_class = WEIGHT_CLASS_SMALL
	power_usage = 50
	critical = 1
	malfunction_probability = 1
	var/max_idle_programs = 2 // 2 idle, + 1 active = 3 as said in description.
	device_type = MC_CPU

/obj/item/computer_hardware/processor_unit/on_remove(obj/item/modular_computer/MC, mob/user)
	MC.shutdown_computer()

/obj/item/computer_hardware/processor_unit/small
	name = "microprocessor"
	desc = ""
	icon_state = "cpu"
	w_class = WEIGHT_CLASS_TINY
	power_usage = 25
	max_idle_programs = 1

/obj/item/computer_hardware/processor_unit/photonic
	name = "photonic processor board"
	desc = ""
	icon_state = "cpuboard_super"
	w_class = WEIGHT_CLASS_SMALL
	power_usage = 250
	max_idle_programs = 4

/obj/item/computer_hardware/processor_unit/photonic/small
	name = "photonic microprocessor"
	desc = ""
	icon_state = "cpu_super"
	w_class = WEIGHT_CLASS_TINY
	power_usage = 75
	max_idle_programs = 2
