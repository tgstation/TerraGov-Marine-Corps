/obj/vehicle/sealed/mecha/working/ripley
	desc = "Autonomous Power Loader Unit MK-I. Designed primarily around heavy lifting, the Ripley can be outfitted with utility equipment to fill a number of roles."
	name = "\improper APLU MK-I \"Ripley\""
	icon_state = "ripley"
	base_icon_state = "ripley"
	silicon_icon_state = "ripley-empty"
	move_delay = 1.5 //Move speed, lower is faster.
	max_temperature = 20000
	max_integrity = 200
	ui_x = 1200
	lights_power = 7
	soft_armor = list(MELEE = 40, BULLET = 20, LASER = 10, ENERGY = 20, BOMB = 40, BIO = 0, FIRE = 100, ACID = 100)
	max_equip_by_category = list(
		MECHA_UTILITY = 2,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	wreckage = /obj/structure/mecha_wreckage/ripley
	mech_type = EXOSUIT_MODULE_RIPLEY
	possible_int_damage = MECHA_INT_FIRE|MECHA_INT_CONTROL_LOST|MECHA_INT_SHORT_CIRCUIT
	enclosed = FALSE //Normal ripley has an open cockpit design
	enter_delay = 10 //can enter in a quarter of the time of other mechs
	exit_delay = 10
	/// Custom Ripley step and turning sounds (from TGMC)
	stepsound = 'sound/mecha/powerloader_step.ogg'
	turnsound = 'sound/mecha/powerloader_turn2.ogg'
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	/// Amount of Goliath hides attached to the mech
	var/hides = 0
	/// List of all things in Ripley's Cargo Compartment
	var/list/cargo
	/// How much things Ripley can carry in their Cargo Compartment
	var/cargo_capacity = 15
	/// How fast the mech is in low pressure
	var/fast_pressure_step_in = 1.5
	/// How fast the mech is in normal pressure
	var/slow_pressure_step_in = 2

/obj/vehicle/sealed/mecha/working/ripley/generate_actions() //isnt allowed to have internal air
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_eject)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_lights)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_view_stats)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/strafe)


/obj/vehicle/sealed/mecha/working/ripley/Destroy()
	for(var/atom/movable/A in cargo)
		A.forceMove(drop_location())
		step_rand(A)
	QDEL_LIST(cargo)
	return ..()

/obj/vehicle/sealed/mecha/working/ripley/mk2
	desc = "Autonomous Power Loader Unit MK-II. This prototype Ripley is refitted with a pressurized cabin, trading its prior speed for atmospheric protection and armor."
	name = "\improper APLU MK-II \"Ripley\""
	icon_state = "ripleymkii"
	base_icon_state = "ripleymkii"
	fast_pressure_step_in = 2 //step_in while in low pressure conditions
	slow_pressure_step_in = 4 //step_in while in normal pressure conditions
	move_delay = 4
	max_temperature = 30000
	max_integrity = 250
	possible_int_damage = MECHA_INT_FIRE|MECHA_INT_TEMP_CONTROL|MECHA_INT_TANK_BREACH|MECHA_INT_CONTROL_LOST|MECHA_INT_SHORT_CIRCUIT
	soft_armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 60, BIO = 0, FIRE = 100, ACID = 100)
	wreckage = /obj/structure/mecha_wreckage/ripley/mk2
	enclosed = TRUE
	enter_delay = 40
	silicon_icon_state = null

/obj/vehicle/sealed/mecha/working/ripley/mk2/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_eject)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_internals)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_lights)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_view_stats)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/strafe)

/obj/vehicle/sealed/mecha/working/ripley/deathripley
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE"
	name = "\improper DEATH-RIPLEY"
	icon_state = "deathripley"
	base_icon_state = "deathripley"
	fast_pressure_step_in = 2 //step_in while in low pressure conditions
	slow_pressure_step_in = 3 //step_in while in normal pressure conditions
	move_delay = 4
	lights_power = 7
	wreckage = /obj/structure/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0
	enclosed = TRUE
	enter_delay = 40
	silicon_icon_state = null
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/fake,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/obj/vehicle/sealed/mecha/working/ripley/deathripley/real
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE. FOR REAL"
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/obj/vehicle/sealed/mecha/working/ripley/mining
	desc = "An old, dusty mining Ripley."
	name = "\improper APLU \"Miner\""

/obj/vehicle/sealed/mecha/working/ripley/mining/Initialize(mapload)
	. = ..()
	take_damage(125) // Low starting health

/obj/vehicle/sealed/mecha/working/ripley/mining/Initialize(mapload)
	. = ..()
	if(cell)
		cell.charge = FLOOR(cell.charge * 0.25, 1) //Starts at very low charge
	if(prob(70)) //Maybe add a drill
		if(prob(15)) //Possible diamond drill... Feeling lucky?
			var/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill/D = new
			D.attach(src)
		else
			var/obj/item/mecha_parts/mecha_equipment/drill/D = new
			D.attach(src)

	//Attach hydraulic clamp
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src, TRUE)

/obj/vehicle/sealed/mecha/working/ripley/cargo
	desc = "An ailing, old, repurposed cargo hauler. Most of its equipment wires are frayed or missing and its frame is rusted."
	name = "\improper APLU \"Big Bess\""
	icon_state = "hauler"
	base_icon_state = "hauler"
	max_integrity = 100 //Has half the health of a normal RIPLEY mech, so it's harder to use as a weapon.

/obj/vehicle/sealed/mecha/working/ripley/cargo/Initialize(mapload)
	. = ..()
	if(cell)
		cell.charge = FLOOR(cell.charge * 0.25, 1) //Starts at very low charge

	//Attach hydraulic clamp ONLY
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src)

	take_damage(max_integrity * 0.5, sound_effect=FALSE) //Low starting health

/obj/vehicle/sealed/mecha/working/ripley/Exit(atom/movable/leaving, direction)
	if(leaving in cargo)
		return FALSE
	return ..()

/obj/vehicle/sealed/mecha/working/ripley/contents_explosion(severity, target)
	for(var/i in cargo)
		var/obj/cargoobj = i
		if(prob(10 * severity))
			LAZYREMOVE(cargo, cargoobj)
			cargoobj.forceMove(drop_location())
	return ..()

/obj/item/mecha_parts/mecha_equipment/ejector
	name = "Cargo compartment"
	equipment_slot = MECHA_UTILITY
	detachable = FALSE

/obj/item/mecha_parts/mecha_equipment/ejector/get_snowflake_data()
	var/list/data = list("snowflake_id" = MECHA_SNOWFLAKE_ID_EJECTOR, "cargo" = list())
	var/obj/vehicle/sealed/mecha/working/ripley/miner = chassis
	for(var/obj/crate in miner.cargo)
		data["cargo"] += list(list(
			"name" = crate.name,
			"ref" = REF(crate),
		))
	return data

/obj/item/mecha_parts/mecha_equipment/ejector/ui_act(action, list/params)
	. = ..()
	if(.)
		return TRUE
	if(action == "eject")
		var/obj/vehicle/sealed/mecha/working/ripley/miner = chassis
		var/obj/crate = locate(params["cargoref"]) in miner.cargo
		if(!crate)
			return FALSE
		to_chat(miner.occupants, "[icon2html(src,  miner.occupants)][span_notice("You unload [crate].")]")
		crate.forceMove(drop_location())
		LAZYREMOVE(miner.cargo, crate)
		if(crate == miner.box)
			miner.box = null
		log_message("Unloaded [crate]. Cargo compartment capacity: [miner.cargo_capacity - LAZYLEN(miner.cargo)]", LOG_MECHA)
		return TRUE


/obj/vehicle/sealed/mecha/working/ripley/resisted_against(mob/living/user, obj/O)
	to_chat(user, span_notice("You lean on the back of [O] and start pushing so it falls out of [src]."))
	if(do_after(user, 300, target = O))
		if(!user || user.stat != CONSCIOUS || user.loc != src || O.loc != src )
			return
		to_chat(user, span_notice("You successfully pushed [O] out of [src]!"))
		O.forceMove(drop_location())
		LAZYREMOVE(cargo, O)
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, span_warning("You fail to push [O] out of [src]!"))
