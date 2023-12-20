


/*****************************Pickaxe********************************/

/obj/item/tool/pickaxe
	name = "pickaxe"
	icon = 'icons/obj/mining.dmi'
	icon_state = "pickaxe"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	force = 15
	throwforce = 4
	item_state = "pickaxe"
	w_class = WEIGHT_CLASS_BULKY
	var/digspeed = 40 //moving the delay to an item var so R&D can make improved picks. --NEO
	attack_verb = list("hit", "pierced", "sliced", "attacked")
	var/drill_sound = 'sound/weapons/genhit.ogg'
	var/drill_verb = "picking"
	sharp = IS_SHARP_ITEM_SIMPLE
	var/excavation_amount = 100

/obj/item/tool/pickaxe/hammer
	name = "sledgehammer"
	//icon_state = "sledgehammer" Waiting on sprite
	desc = "A mining hammer made of reinforced metal. You feel like smashing your boss in the face with this."

/obj/item/tool/pickaxe/silver
	name = "silver pickaxe"
	icon_state = "spickaxe"
	item_state = "spickaxe"
	digspeed = 30
	desc = "This makes no metallurgic sense."

/obj/item/tool/pickaxe/drill
	name = "mining drill" // Can dig sand as well!
	icon_state = "handdrill"
	item_state = "drill"
	digspeed = 30
	desc = "Yours is the drill that will pierce through the rock walls."
	drill_verb = "drilling"

/obj/item/tool/pickaxe/jackhammer
	name = "sonic jackhammer"
	icon_state = "jackhammer"
	item_state = "jackhammer"
	digspeed = 20 //faster than drill, but cannot dig
	desc = "Cracks rocks with sonic blasts, perfect for killing cave lizards."
	drill_verb = "hammering"

/obj/item/tool/pickaxe/gold
	name = "golden pickaxe"
	icon_state = "gpickaxe"
	item_state = "gpickaxe"
	digspeed = 20
	desc = "This makes no metallurgic sense."

/obj/item/tool/pickaxe/diamond
	name = "diamond pickaxe"
	icon_state = "dpickaxe"
	item_state = "dpickaxe"
	digspeed = 10
	desc = "A pickaxe with a diamond pick head, this is just like minecraft."

/obj/item/tool/pickaxe/diamonddrill //When people ask about the badass leader of the mining tools, they are talking about ME!
	name = "diamond mining drill"
	icon_state = "diamonddrill"
	item_state = "jackhammer"
	digspeed = 5 //Digs through walls, girders, and can dig up sand
	desc = "Yours is the drill that will pierce the heavens!"
	drill_verb = "drilling"

/obj/item/tool/pickaxe/borgdrill
	name = "cyborg mining drill"
	icon_state = "diamonddrill"
	item_state = "jackhammer"
	digspeed = 15
	desc = ""
	drill_verb = "drilling"


/obj/item/tool/pickaxe/plasmacutter
	name = "plasma cutter"
	desc = "A tool that cuts with deadly hot plasma. You could use it to cut limbs off of xenos! Or, you know, cut apart walls or mine through stone. Eye protection strongly recommended."
	icon = 'icons/obj/items/tools.dmi'
	icon_state = "plasma_cutter_off"
	item_state = "plasmacutter"
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	force = 70
	damtype = BURN
	digspeed = 20 //Can slice though normal walls, all girders, or be used in reinforced wall deconstruction
	drill_verb = "cutting"
	attack_verb = list("dissolves", "disintegrates", "liquefies", "subliminates", "vaporizes")
	heat = 3800
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_PURPLE
	var/cutting_sound = 'sound/items/welder2.ogg'
	var/powered = FALSE
	var/dirt_amt_per_dig = 5
	var/obj/item/cell/rtg/large/cell //The plasma cutter cell is unremovable and recharges over time
	tool_behaviour = TOOL_WELD_CUTTER

/obj/item/tool/pickaxe/plasmacutter/Initialize(mapload)
	. = ..()
	cell = new /obj/item/cell/rtg/plasma_cutter()


/obj/item/tool/pickaxe/plasmacutter/examine(mob/user)
	. = ..()
	if(cell)
		. += "The internal battery readout counter is active. <b>Charge Remaining: [cell.charge]/[cell.maxcharge]</b>"
	else
		. += span_warning("It does not have a power source installed!")

/obj/item/tool/pickaxe/plasmacutter/attack_self(mob/user)
	toggle(user)
	user.changeNext_move(CLICK_CD_LONG)


//Toggles the cutter off and on
/obj/item/tool/pickaxe/plasmacutter/proc/toggle(mob/user, silent)
	if(powered)
		playsound(loc, 'sound/weapons/saberoff.ogg', 15)
		powered = FALSE
		if(!silent && user)
			user.visible_message(span_notice("[user] turns [src] off."),
		span_notice("You switch [src] off. <b>Charge Remaining: [cell.charge]/[cell.maxcharge]</b>"))
		update_plasmacutter()
		return

	if(!cell || cell.charge <= 0)
		fizzle_message(user)
		return
	playsound(loc, 'sound/weapons/saberon.ogg', 15)
	powered = TRUE
	if(!silent && user)
		user.visible_message(span_notice("[user] turns [src] on."),
		span_notice("You switch [src] on. <b>Charge Remaining: [cell.charge]/[cell.maxcharge]</b>"))

	update_plasmacutter()


/obj/item/tool/pickaxe/plasmacutter/proc/fizzle_message(mob/user)
	playsound(src, 'sound/machines/buzz-two.ogg', 25, 1)
	if(!cell)
		balloon_alert(user, "No battery installed")
	else if(!powered)
		balloon_alert(user, "Turned off")
	else
		balloon_alert(user, "Insufficient charge")
		to_chat(user, span_warning("The plasma cutter has inadequate charge remaining! Give the internal battery time to recharge, or attack a living creature! <b>Charge Remaining: [cell.charge]/[cell.maxcharge]</b>"))

/obj/item/tool/pickaxe/plasmacutter/proc/start_cut(mob/user, name = "", atom/source, charge_amount = PLASMACUTTER_BASE_COST, custom_string, no_string, SFX = TRUE)
	if(!(cell.charge >= charge_amount) || !powered) //Check power
		fizzle_message(user)
		return FALSE
	eyecheck(user)
	if(SFX)
		playsound(source, cutting_sound, 25, 1)
		var/datum/effect_system/spark_spread/spark_system
		spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, source)
		spark_system.attach(source)
		spark_system.start(source)
	if(!no_string)
		balloon_alert(user, "Cutting...")
		if(custom_string)
			to_chat(user, span_notice(custom_string))
		else
			balloon_alert(user, "Starts cutting apart")
	return TRUE

/obj/item/tool/pickaxe/plasmacutter/proc/cut_apart(mob/user, name = "", atom/source, charge_amount = PLASMACUTTER_BASE_COST, custom_string)
	eyecheck(user)
	playsound(source, cutting_sound, 25, 1)
	var/datum/effect_system/spark_spread/spark_system
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, source)
	spark_system.attach(source)
	spark_system.start(source)
	use_charge(user, charge_amount, FALSE)
	balloon_alert(user, "Charge Remaining: [cell.charge]/[cell.maxcharge]")
	if(custom_string)
		to_chat(user, span_notice(custom_string))
	else
		balloon_alert(user, "Cuts apart")

/obj/item/tool/pickaxe/plasmacutter/proc/debris(location, metal = 0, rods = 0, wood = 0, wires = 0, shards = 0, plasteel = 0)
	if(metal)
		new /obj/item/stack/sheet/metal (location, metal)
	if(rods)
		new /obj/item/stack/rods (location, rods)
	if(wood)
		new /obj/item/stack/sheet/wood (location, wood)
	if(wires)
		new /obj/item/stack/cable_coil (location, wires)
	if(shards)
		while(shards > 0)
			new /obj/item/shard (location)
			shards--
	if(plasteel)
		new /obj/item/stack/sheet/plasteel (location, plasteel)

/obj/item/tool/pickaxe/plasmacutter/proc/use_charge(mob/user, amount = PLASMACUTTER_BASE_COST, mention_charge = TRUE)
	cell.charge -= min(cell.charge, amount)
	if(mention_charge)
		balloon_alert(user, "Charge Remaining: [cell.charge]/[cell.maxcharge]")
	update_plasmacutter()

/obj/item/tool/pickaxe/plasmacutter/proc/calc_delay(mob/user)
	. = PLASMACUTTER_CUT_DELAY
	var/skill = user.skills.getRating(SKILL_ENGINEER)
	if(skill < SKILL_ENGINEER_ENGI) //We don't have proper skills; time to fumble and bumble.
		user.visible_message(span_notice("[user] fumbles around figuring out how to use [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
		return . *= max(1, 4 - skill) //Takes twice to four times as long depending on your skill.
	. -= min(PLASMACUTTER_CUT_DELAY, (skill - 3) * 5) //We have proper skills; delay lowered by 0.5 per skill point in excess of a field engineer's.

/obj/item/tool/pickaxe/plasmacutter/proc/update_plasmacutter(mob/user, silent=FALSE) //Updates the icon and power on/off status of the plasma cutter
	if(!user && ismob(loc) )
		user = loc
	if(!cell || cell.charge <= 0 || powered == FALSE)
		icon_state = "plasma_cutter_off"
		if(powered)
			powered = FALSE
			if(!silent)
				playsound(loc, 'sound/weapons/saberoff.ogg', 25)
				balloon_alert(user, "Insufficient charge")
				to_chat(user, span_warning("The plasma cutter abruptly shuts down due to a lack of power!"))
		force = 5
		damtype = BRUTE
		heat = 0
		set_light_on(FALSE)
	else
		icon_state = "plasma_cutter_on"
		powered = TRUE
		force = 70
		damtype = BURN
		heat = 3800
		set_light_on(TRUE)


/obj/item/tool/pickaxe/plasmacutter/attack(mob/living/M, mob/living/user)
	if(!powered)
		fizzle_message(user)
	else
		playsound(M, cutting_sound, 25, 1)
		eyecheck(user)
		update_plasmacutter()
		var/datum/effect_system/spark_spread/spark_system
		spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, M)
		spark_system.attach(M)
		spark_system.start(M)
		if(isxeno(M) && M.stat != DEAD)
			cell.charge += 200
			var/mob/living/carbon/xenomorph/xeno = M
			if(!CHECK_BITFIELD(xeno.xeno_caste.caste_flags, CASTE_PLASMADRAIN_IMMUNE))
				xeno.use_plasma(round(xeno.xeno_caste.plasma_regen_limit * xeno.xeno_caste.plasma_max * 0.2)) //One fifth of the xeno's regeneratable plasma per hit.
	return ..()


/obj/item/tool/pickaxe/plasmacutter/afterattack(atom/target, mob/user, proximity)
	if(!proximity || user.do_actions)
		return

	if(isturf(target))//Melting snow with the plasma cutter.
		var/turf/T = target
		var/turfdirt = T.get_dirt_type()
		if(!turfdirt == DIRT_TYPE_SNOW)
			return
		if(!istype(T, /turf/open/floor/plating/ground/snow))
			return
		var/turf/open/floor/plating/ground/snow/ST = T
		if(!ST.slayer)
			return
		if(!start_cut(user, target.name, target, 0, span_notice("You start melting the [target.name] with [src].")))
			return
		playsound(user.loc, 'sound/items/welder.ogg', 25, 1)
		if(!do_after(user, calc_delay(user) * PLASMACUTTER_VLOW_MOD, NONE, T, BUSY_ICON_BUILD))
			return
		if(!powered)
			fizzle_message(user)
			return
		if(!turfdirt == DIRT_TYPE_SNOW)
			return
		if(!ST.slayer)
			return
		ST.slayer = max(0 , ST.slayer - dirt_amt_per_dig)
		ST.update_icon(1,0)
		cut_apart(user, target.name, target, 0, "You melt the snow with [src]. ") //costs nothing



/obj/item/tool/pickaxe/plasmacutter/attack_obj(obj/O, mob/living/user)
	if(!powered || user.do_actions || CHECK_BITFIELD(O.resistance_flags, INDESTRUCTIBLE) || CHECK_BITFIELD(O.resistance_flags, PLASMACUTTER_IMMUNE))
		..()
		return TRUE

	if(!start_cut(user, O.name, O))
		return TRUE

	if(!do_after(user, calc_delay(user), NONE, O, BUSY_ICON_HOSTILE))
		return TRUE

	cut_apart(user, O.name, O)
	O.deconstruct(TRUE)
	return TRUE
