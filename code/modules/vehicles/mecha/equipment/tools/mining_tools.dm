
// Drill, Diamond drill, Mining scanner

#define DRILL_BASIC 1
#define DRILL_HARDENED 2


/obj/item/mecha_parts/mecha_equipment/drill
	name = "exosuit drill"
	desc = "Equipment for engineering and combat exosuits. This is the drill that'll pierce the heavens!"
	icon_state = "mecha_drill"
	equip_cooldown = 15
	energy_drain = 10
	force = 15
	harmful = TRUE
	range = MECHA_MELEE
	toolspeed = 0.9
	mech_flags = EXOSUIT_MODULE_WORKING | EXOSUIT_MODULE_COMBAT
	var/drill_delay = 7
	var/drill_level = DRILL_BASIC

/obj/item/mecha_parts/mecha_equipment/drill/action(mob/source, atom/target, list/modifiers)
	// Check if we can even use the equipment to begin with.
	if(!action_checks(target))
		return

	// We can only drill non-space turfs, living mobs and objects.
	if(isspaceturf(target) || !(isliving(target) || isobj(target) || isturf(target)))
		return

	// For whatever reason we can't drill things that acid won't even stick too, and probably
	// shouldn't waste our time drilling indestructible things.
	if(isobj(target))
		var/obj/target_obj = target
		if(target_obj.resistance_flags & (UNACIDABLE | INDESTRUCTIBLE))
			return

	// You can't drill harder by clicking more.
	if(!LAZYACCESS(source.do_actions, target) && do_after_cooldown(target, source, DOAFTER_SOURCE_MECHADRILL))

		target.visible_message(span_warning("[chassis] starts to drill [target]."), \
					span_userdanger("[chassis] starts to drill [target]..."), \
					span_hear("You hear drilling."))

		log_message("Started drilling [target]", LOG_MECHA)
		// Drilling a turf is a one-and-done procedure.
		if(isturf(target))
			var/turf/T = target
			T.drill_act(src, source)
			return ..()
		// Drilling objects and mobs is a repeating procedure.
		while(do_after_mecha(target, source, drill_delay))
			if(isliving(target))
				drill_mob(target, source)
				playsound(src,'sound/effects/drill.ogg',40,TRUE)
			else if(isobj(target))
				var/obj/O = target
				O.take_damage(15, BRUTE, 0, FALSE, get_dir(chassis, target))
				playsound(src,'sound/effects/drill.ogg',40,TRUE)

			// If we caused a qdel drilling the target, we can stop drilling them.
			// Prevents starting a do_after on a qdeleted target.
			if(QDELETED(target))
				break

	return ..()

/turf/proc/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill, mob/user)
	return

/turf/closed/wall/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill, mob/user)
	if(drill.do_after_mecha(src, user, 60 / drill.drill_level))
		drill.log_message("Drilled through [src]", LOG_MECHA)
		dismantle_wall(TRUE, FALSE)

/turf/closed/wall/r_wall/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill, mob/user)
	if(drill.drill_level >= DRILL_HARDENED)
		if(drill.do_after_mecha(src, user, 120 / drill.drill_level))
			drill.log_message("Drilled through [src]", LOG_MECHA)
			dismantle_wall(TRUE, FALSE)
	else
		to_chat(user, "[icon2html(src, user)][span_danger("[src] is too durable to drill through.")]")

/obj/item/mecha_parts/mecha_equipment/drill/can_attach(obj/vehicle/sealed/mecha/M, attach_right = FALSE)
	if(..())
		if(istype(M, /obj/vehicle/sealed/mecha/working) || istype(M, /obj/vehicle/sealed/mecha/combat))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/drill/proc/drill_mob(mob/living/target, mob/living/user)
	target.visible_message(span_danger("[chassis] is drilling [target] with [src]!"), \
						span_userdanger("[chassis] is drilling you with [src]!"))
	log_combat(user, target, "drilled", "[name]", "INTENT: [user.a_intent ? "On" : "Off"])(DAMTYPE: [uppertext(damtype)])")
	//drill makes a hole
	target.apply_damage(10, BRUTE, BODY_ZONE_CHEST, updating_health = TRUE)

	//blood splatters
	new /obj/effect/temp_visual/dir_setting/bloodsplatter(target.drop_location(), get_dir(chassis, target))

/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill
	name = "diamond-tipped exosuit drill"
	desc = "Equipment for engineering and combat exosuits. This is an upgraded version of the drill that'll pierce the heavens!"
	icon_state = "mecha_diamond_drill"
	equip_cooldown = 10
	drill_delay = 4
	drill_level = DRILL_HARDENED
	force = 15
	toolspeed = 0.7

#undef DRILL_BASIC
#undef DRILL_HARDENED
