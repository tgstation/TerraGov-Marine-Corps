
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
		return

	if(isobj(target))
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
		return

	if(isliving(target))
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
		return
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
	mech_flags = EXOSUIT_MODULE_WORKING|EXOSUIT_MODULE_GREYSCALE
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
