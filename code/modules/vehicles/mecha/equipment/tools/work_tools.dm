
//Hydraulic clamp, Kill clamp, Extinguisher, RCD, Cable layer.


/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	name = "hydraulic clamp"
	desc = "Equipment for engineering exosuits. Lifts objects and loads them into cargo."
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 10
	range = MECHA_MELEE
	toolspeed = 0.8
	harmful = TRUE
	mech_flags = EXOSUIT_MODULE_RIPLEY
	///Bool for whether we beat the hell out of things we punch (and tear off their arms)
	var/killer_clamp = FALSE
	///How much base damage this clamp does
	var/clamp_damage = 20
	///Var for the chassis we are attached to, needed to access ripley contents and such
	var/obj/vehicle/sealed/mecha/working/ripley/cargo_holder
	///Audio for using the hydraulic clamp
	var/clampsound = 'sound/mecha/hydraulic.ogg'

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/attach(obj/vehicle/sealed/mecha/M)
	. = ..()
	cargo_holder = M

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/detach(atom/moveto = null)
	. = ..()
	cargo_holder = null

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/action(mob/living/source, atom/target, list/modifiers)
	if(!action_checks(target))
		return
	if(!cargo_holder)
		return
	if(ismecha(target))
		var/obj/vehicle/sealed/mecha/M = target
		var/have_ammo
		for(var/obj/item/mecha_ammo/box in cargo_holder.cargo)
			if(istype(box, /obj/item/mecha_ammo) && box.rounds)
				have_ammo = TRUE
				if(M.ammo_resupply(box, source, TRUE))
					return
		if(have_ammo)
			to_chat(source, "No further supplies can be provided to [M].")
		else
			to_chat(source, "No providable supplies found in cargo hold")

	else if(isobj(target))
		var/obj/clamptarget = target
		if(clamptarget.anchored)
			to_chat(source, "[icon2html(src, source)][span_warning("[target] is firmly secured!")]")
			return
		if(LAZYLEN(cargo_holder.cargo) >= cargo_holder.cargo_capacity)
			to_chat(source, "[icon2html(src, source)][span_warning("Not enough room in cargo compartment!")]")
			return
		playsound(chassis, clampsound, 50, FALSE, -6)
		chassis.visible_message(span_notice("[chassis] lifts [target] and starts to load it into cargo compartment."))
		clamptarget.anchored = TRUE
		if(!do_after_cooldown(target, source))
			clamptarget.anchored = initial(clamptarget.anchored)
			return
		LAZYADD(cargo_holder.cargo, clamptarget)
		clamptarget.forceMove(chassis)
		clamptarget.anchored = initial(clamptarget.anchored)
		if(!cargo_holder.box && istype(clamptarget, /obj/structure/ore_box))
			cargo_holder.box = clamptarget
		to_chat(source, "[icon2html(src, source)][span_notice("[target] successfully loaded.")]")
		log_message("Loaded [clamptarget]. Cargo compartment capacity: [cargo_holder.cargo_capacity - LAZYLEN(cargo_holder.cargo)]", LOG_MECHA)

	else if(isliving(target))
		var/mob/living/M = target
		if(M.stat == DEAD)
			return

		if(source.a_intent == INTENT_HELP)
			step_away(M,chassis)
			if(killer_clamp)
				target.visible_message(span_danger("[chassis] tosses [target] like a piece of paper!"), \
					span_userdanger("[chassis] tosses you like a piece of paper!"))
			else
				to_chat(source, "[icon2html(src, source)][span_notice("You push [target] out of the way.")]")
				chassis.visible_message(span_notice("[chassis] pushes [target] out of the way."), \
				span_notice("[chassis] pushes you aside."))
			return ..()
		else if(LAZYACCESS(modifiers, RIGHT_CLICK) && ishuman(M))//meme clamp here
			if(!killer_clamp)
				to_chat(source, span_notice("You longingly wish to tear [M]'s arms off."))
				return
			var/mob/living/carbon/human/marine_wit_no_arms = target
			for(var/datum/limb/appendage AS in marine_wit_no_arms.limbs) //Ma arms fell off :(
				if(istype(appendage, /datum/limb/chest) || istype(appendage, /datum/limb/groin) || istype(appendage, /datum/limb/head))
					continue
				appendage.droplimb()
			target.visible_message(span_danger("[chassis] rips [target]'s arms and legs off!"), \
						span_userdanger("[chassis] rips your arms and legs off!"))
			log_combat(source, M, "removed both arms and legs with a real clamp,", "[name]", "(INTENT: [source.a_intent]) (DAMTYPE: [uppertext(damtype)])")
			return ..()

		M.take_overall_damage(clamp_damage)
		if(!M) //get gibbed stoopid
			return
		M.adjustOxyLoss(round(clamp_damage/2))
		M.updatehealth()
		target.visible_message(span_danger("[chassis] squeezes [target]!"), \
							span_userdanger("[chassis] squeezes you!"),\
							span_hear("You hear something crack."))
		log_combat(source, M, "attacked", "[name]", "(INTENT: [source.a_intent]) (DAMTYPE: [uppertext(damtype)])")
	return ..()



//This is pretty much just for the death-ripley
/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	name = "\improper KILL CLAMP"
	desc = "They won't know what clamped them! This time for real!"
	killer_clamp = TRUE

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/fake//harmless fake for pranks
	desc = "They won't know what clamped them!"
	energy_drain = 0
	clamp_damage = 0
	killer_clamp = FALSE

/obj/item/mecha_parts/mecha_equipment/extinguisher
	name = "exosuit extinguisher"
	desc = "Equipment for engineering exosuits. A rapid-firing high capacity fire extinguisher."
	icon_state = "mecha_exting"
	equip_cooldown = 5
	energy_drain = 0
	equipment_slot = MECHA_UTILITY
	range = MECHA_MELEE|MECHA_RANGED
	mech_flags = EXOSUIT_MODULE_WORKING
	///Minimum amount of reagent needed to activate.
	var/required_amount = 80

/obj/item/mecha_parts/mecha_equipment/extinguisher/Initialize(mapload)
	. = ..()
	create_reagents(400)
	reagents.add_reagent(/datum/reagent/water, 400)

/obj/item/mecha_parts/mecha_equipment/extinguisher/proc/spray_extinguisher(mob/user)
	if(reagents.total_volume < required_amount)
		return

	// todo copy paste tg extinguisher code here

	playsound(chassis, 'sound/effects/extinguish.ogg', 75, TRUE, -3)


/**
 * Handles attemted refills of the extinguisher.
 *
 * The mech can only refill an extinguisher that is in front of it.
 * Only water tank objects can be used.
 */
/obj/item/mecha_parts/mecha_equipment/extinguisher/proc/attempt_refill(mob/user)
	if(reagents.maximum_volume == reagents.total_volume)
		return
	var/turf/in_front = get_step(chassis, chassis.dir)
	var/obj/structure/reagent_dispensers/watertank/refill_source = locate(/obj/structure/reagent_dispensers/watertank) in in_front
	if(!refill_source)
		to_chat(user, span_notice("Refill failed. No compatible tank found."))
		return
	if(!refill_source.reagents?.total_volume)
		to_chat(user, span_notice("Refill failed. Source tank empty."))
		return

	refill_source.reagents.trans_to(src, reagents.maximum_volume)
	playsound(chassis, 'sound/effects/refill.ogg', 50, TRUE, -6)

/obj/item/mecha_parts/mecha_equipment/extinguisher/get_snowflake_data()
	return list(
		"snowflake_id" = MECHA_SNOWFLAKE_ID_EXTINGUISHER,
		"reagents" = reagents.total_volume,
		"total_reagents" = reagents.maximum_volume,
		"minimum_requ" = required_amount,
	)

/obj/item/mecha_parts/mecha_equipment/extinguisher/ui_act(action, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(action)
		if("activate")
			spray_extinguisher(usr)
			return TRUE
		if("refill")
			attempt_refill(usr)
			return TRUE

#define MODE_DECONSTRUCT 0
#define MODE_WALL 1
#define MODE_AIRLOCK 2

/obj/item/mecha_parts/mecha_equipment/rcd
	name = "mounted RCD"
	desc = "An exosuit-mounted Rapid Construction Device."
	icon_state = "mecha_rcd"
	equip_cooldown = 10
	energy_drain = 250
	range = MECHA_MELEE|MECHA_RANGED
	///determines what we'll so when clicking on a turf
	var/mode = MODE_DECONSTRUCT

/obj/item/mecha_parts/mecha_equipment/rcd/get_snowflake_data()
	return list(
		"snowflake_id" = MECHA_SNOWFLAKE_ID_MODE,
		"name" = "RCD control",
		"mode" = get_mode_name(),
	)

/// fetches the mode name to display in the UI
/obj/item/mecha_parts/mecha_equipment/rcd/proc/get_mode_name()
	switch(mode)
		if(MODE_DECONSTRUCT)
			return "Deconstruct"
		if(MODE_WALL)
			return "Build wall"
		if(MODE_AIRLOCK)
			return "Build Airlock"
		else
			return "Someone didnt set this"

/obj/item/mecha_parts/mecha_equipment/rcd/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action == "change_mode")
		mode++
		if(mode > MODE_AIRLOCK)
			mode = MODE_DECONSTRUCT
		switch(mode)
			if(MODE_DECONSTRUCT)
				to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("Switched RCD to Deconstruct.")]")
				energy_drain = initial(energy_drain)
			if(MODE_WALL)
				to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("Switched RCD to Construct Walls and Flooring.")]")
				energy_drain = 2*initial(energy_drain)
			if(MODE_AIRLOCK)
				to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("Switched RCD to Construct Airlock.")]")
				energy_drain = 2*initial(energy_drain)
		return TRUE

/obj/item/mecha_parts/mecha_equipment/rcd/action(mob/source, atom/target, list/modifiers)
	if(!isturf(target) && !istype(target, /obj/machinery/door/airlock))
		target = get_turf(target)
	if(!action_checks(target) || get_dist(chassis, target)>3 || istype(target, /turf/open/space/transit))
		return
	playsound(chassis, 'sound/machines/click.ogg', 50, TRUE)

	switch(mode)
		if(MODE_DECONSTRUCT)
			to_chat(source, "[icon2html(src, source)][span_notice("Deconstructing [target]...")]")
			if(iswallturf(target))
				var/turf/closed/wall/W = target
				if(!do_after_cooldown(W, source))
					return
				W.ScrapeAway()
			else if(isfloorturf(target))
				var/turf/open/floor/F = target
				if(!do_after_cooldown(target, source))
					return
				F.ScrapeAway()
			else if (istype(target, /obj/machinery/door/airlock))
				if(!do_after_cooldown(target, source))
					return
				qdel(target)
		if(MODE_WALL)
			if(isspaceturf(target))
				var/turf/open/space/S = target
				to_chat(source, "[icon2html(src, source)][span_notice("Building Floor...")]")
				if(!do_after_cooldown(S, source))
					return
				S.PlaceOnTop(/turf/open/floor/plating)
			else if(isfloorturf(target))
				var/turf/open/floor/F = target
				to_chat(source, "[icon2html(src, source)][span_notice("Building Wall...")]")
				if(!do_after_cooldown(F, source))
					return
				F.PlaceOnTop(/turf/closed/wall)
		if(MODE_AIRLOCK)
			if(isfloorturf(target))
				to_chat(source, "[icon2html(src, source)][span_notice("Building Airlock...")]")
				if(!do_after_cooldown(target, source))
					return
				var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock(target)
				T.autoclose = TRUE
				playsound(target, 'sound/effects/sparks2.ogg', 50, TRUE)
	chassis.spark_system.start()
	playsound(target, 'sound/items/deconstruct.ogg', 50, TRUE)
	return ..()

#undef MODE_DECONSTRUCT
#undef MODE_WALL
#undef MODE_AIRLOCK

//Dunno where else to put this so shrug
/obj/item/mecha_parts/mecha_equipment/ripleyupgrade
	name = "Ripley MK-II Conversion Kit"
	desc = "A pressurized canopy attachment kit for an Autonomous Power Loader Unit \"Ripley\" MK-I mecha, to convert it to the slower, but space-worthy MK-II design. This kit cannot be removed, once applied."
	icon_state = "ripleyupgrade"
	mech_flags = EXOSUIT_MODULE_RIPLEY

/obj/item/mecha_parts/mecha_equipment/ripleyupgrade/can_attach(obj/vehicle/sealed/mecha/working/ripley/M, attach_right = FALSE)
	if(M.type != /obj/vehicle/sealed/mecha/working/ripley)
		to_chat(loc, span_warning("This conversion kit can only be applied to APLU MK-I models."))
		return FALSE
	if(LAZYLEN(M.cargo))
		to_chat(loc, span_warning("[M]'s cargo hold must be empty before this conversion kit can be applied."))
		return FALSE
	if(!(M.mecha_flags & ADDING_MAINT_ACCESS_POSSIBLE)) //non-removable upgrade, so lets make sure the pilot or owner has their say.
		to_chat(loc, span_warning("[M] must have maintenance protocols active in order to allow this conversion kit."))
		return FALSE
	if(LAZYLEN(M.occupants)) //We're actualy making a new mech and swapping things over, it might get weird if players are involved
		to_chat(loc, span_warning("[M] must be unoccupied before this conversion kit can be applied."))
		return FALSE
	if(!M.cell) //Turns out things break if the cell is missing
		to_chat(loc, span_warning("The conversion process requires a cell installed."))
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/ripleyupgrade/attach(obj/vehicle/sealed/mecha/markone, attach_right = FALSE)
	var/obj/vehicle/sealed/mecha/working/ripley/mk2/marktwo = new (get_turf(markone),1)
	if(!marktwo)
		return
	QDEL_NULL(marktwo.cell)
	if (markone.cell)
		marktwo.cell = markone.cell
		markone.cell.forceMove(marktwo)
		markone.cell = null
	QDEL_NULL(marktwo.scanmod)
	if (markone.scanmod)
		marktwo.scanmod = markone.scanmod
		markone.scanmod.forceMove(marktwo)
		markone.scanmod = null
	QDEL_NULL(marktwo.capacitor)
	if (markone.capacitor)
		marktwo.capacitor = markone.capacitor
		markone.capacitor.forceMove(marktwo)
		markone.capacitor = null
	marktwo.update_part_values()
	for(var/obj/item/mecha_parts/mecha_equipment/equipment in markone.flat_equipment) //Move the equipment over...
		if(istype(equipment, /obj/item/mecha_parts/mecha_equipment/ejector))
			continue //the MK2 already has one.
		var/righthandgun = markone.equip_by_category[MECHA_R_ARM] == equipment
		equipment.detach(marktwo)
		equipment.attach(marktwo, righthandgun)
	marktwo.dna_lock = markone.dna_lock
	marktwo.mecha_flags = markone.mecha_flags
	marktwo.strafe = markone.strafe
	//Integ set to the same percentage integ as the old mecha, rounded to be whole number
	marktwo.obj_integrity = round((markone.obj_integrity / markone.max_integrity) * marktwo.obj_integrity)
	if(markone.name != initial(markone.name))
		marktwo.name = markone.name
	markone.wreckage = FALSE
	qdel(markone)
	playsound(get_turf(marktwo),'sound/items/ratchet.ogg',50,TRUE)
