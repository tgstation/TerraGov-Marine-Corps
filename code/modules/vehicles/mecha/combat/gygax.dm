/obj/vehicle/sealed/mecha/combat/gygax
	desc = "A lightweight, security exosuit. Popular among private and corporate security."
	name = "\improper Gygax"
	icon_state = "gygax"
	base_icon_state = "gygax"
	allow_diagonal_movement = TRUE
	move_delay = 3
	dir_in = 1 //Facing North.
	max_integrity = 250
	soft_armor = list(MELEE = 25, BULLET = 20, LASER = 30, ENERGY = 15, BOMB = 0, BIO = 0, FIRE = 100, ACID = 100)
	max_temperature = 25000
	leg_overload_coeff = 80
	force = 25
	wreckage = /obj/structure/mecha_wreckage/gygax
	mech_type = EXOSUIT_MODULE_GYGAX
	max_equip_by_category = list(
		MECHA_UTILITY = 1,
		MECHA_POWER = 1,
		MECHA_ARMOR = 2,
	)
	step_energy_drain = 3

/obj/vehicle/sealed/mecha/combat/gygax/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_overload_mode)

/datum/action/vehicle/sealed/mecha/mech_overload_mode
	name = "Toggle leg actuators overload"
	action_icon_state = "mech_overload_off"

/datum/action/vehicle/sealed/mecha/mech_overload_mode/action_activate(trigger_flags, forced_state = null)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(!isnull(forced_state))
		chassis.leg_overload_mode = forced_state
	else
		chassis.leg_overload_mode = !chassis.leg_overload_mode
	action_icon_state = "mech_overload_[chassis.leg_overload_mode ? "on" : "off"]"
	chassis.log_message("Toggled leg actuators overload.", LOG_MECHA)
	//tgmc add
	var/obj/item/mecha_parts/mecha_equipment/ability/dash/ability = locate() in chassis.equip_by_category[MECHA_UTILITY]
	if(ability)
		chassis.cut_overlay(ability.overlay)
		var/state = chassis.leg_overload_mode ? (initial(ability.icon_state) + "_active") : initial(ability.icon_state)
		ability.overlay = image('icons/mecha/mecha_ability_overlays.dmi', icon_state = state, layer=chassis.layer+0.001)
		chassis.add_overlay(ability.overlay)
		if(chassis.leg_overload_mode)
			ability.sound_loop.start(chassis)
		else
			ability.sound_loop.stop(chassis)
	//tgmc end
	if(chassis.leg_overload_mode)
		chassis.speed_mod = min(chassis.move_delay-1, round(chassis.move_delay * 0.5))
		chassis.move_delay -= chassis.speed_mod
		chassis.step_energy_drain = max(chassis.overload_step_energy_drain_min,chassis.step_energy_drain*chassis.leg_overload_coeff)
		chassis.balloon_alert(owner,"leg actuators overloaded")
	else
		chassis.move_delay += chassis.speed_mod
		chassis.step_energy_drain = chassis.normal_step_energy_drain
		chassis.balloon_alert(owner, "you disable the overload")
	update_button_icon()

/obj/vehicle/sealed/mecha/combat/gygax/dark
	desc = "A lightweight exosuit, painted in a dark scheme. This model appears to have some modifications."
	name = "\improper Dark Gygax"
	icon_state = "darkgygax"
	base_icon_state = "darkgygax"
	max_integrity = 300
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 50, ENERGY = 35, BOMB = 20, BIO = 0, FIRE = 100, ACID = 100)
	max_temperature = 35000
	leg_overload_coeff = 70
	force = 30
	operation_req_access = list()
	internals_req_access = list()
	wreckage = /obj/structure/mecha_wreckage/gygax/dark
	max_equip_by_category = list(
		MECHA_UTILITY = 2,
		MECHA_POWER = 1,
		MECHA_ARMOR = 3,
	)
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(/obj/item/mecha_parts/mecha_equipment/armor/anticcw_armor_booster, /obj/item/mecha_parts/mecha_equipment/armor/antiproj_armor_booster),
	)
	destruction_sleep_duration = 20

/obj/vehicle/sealed/mecha/combat/gygax/dark/loaded/Initialize(mapload)
	. = ..()
	max_ammo()

