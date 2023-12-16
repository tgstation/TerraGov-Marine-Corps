/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	layer = BELOW_OBJ_LAYER
	idle_power_usage = 300
	active_power_usage = 300
	var/processing = 0
	///How many times the computer can be smashed by a Xeno before it is disabled.
	var/durability = 2
	resistance_flags = UNACIDABLE
	///they don't provide good cover
	coverage = 15
	light_range = 1
	light_power = 0.5
	light_color = LIGHT_COLOR_BLUE
	///The actual screen sprite for this computer
	var/screen_overlay
	///The destroyed computer sprite. Defaults based on the icon_state if not specified
	var/broken_icon

/obj/machinery/computer/Initialize(mapload)
	. = ..()
	if(!broken_icon)
		broken_icon = "[initial(icon_state)]_broken"
	start_processing()
	update_icon()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/LateInitialize()
	. = ..()
	power_change()

/obj/machinery/computer/examine(mob/user)
	. = ..()
	if(machine_stat & NOPOWER)
		. += span_warning("It is currently unpowered.")

	if(durability < initial(durability))
		. += span_warning("It is damaged, and can be fixed with a welder.")

	if(machine_stat & DISABLED)
		. += span_warning("It is currently disabled, and can be fixed with a welder.")

	if(machine_stat & BROKEN)
		. += span_warning("It is broken.")

/obj/machinery/computer/process()
	if(machine_stat & (NOPOWER|BROKEN|DISABLED))
		return 0
	return 1

/obj/machinery/computer/emp_act(severity)
	if(prob(20/severity)) set_broken()
	..()


/obj/machinery/computer/ex_act(severity)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return FALSE
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
			return
		if(EXPLODE_HEAVY)
			if (prob(25))
				qdel(src)
				return
			if (prob(50))
				for(var/x in verbs)
					verbs -= x
				set_broken()
		if(EXPLODE_LIGHT)
			if (prob(25))
				for(var/x in verbs)
					verbs -= x
				set_broken()
		if(EXPLODE_WEAK)
			if (prob(15))
				for(var/x in verbs)
					verbs -= x
				set_broken()


/obj/machinery/computer/bullet_act(obj/projectile/Proj)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		visible_message("[Proj] ricochets off [src]!")
		return 0
	else
		if(prob(round(Proj.ammo.damage /2)))
			set_broken()
		..()
		return 1

/obj/machinery/computer/update_icon()
	. = ..()
	if(machine_stat & (BROKEN|DISABLED|NOPOWER))
		set_light(0)
	else
		set_light(initial(light_range))

/obj/machinery/computer/update_icon_state()
	if(machine_stat & (BROKEN|DISABLED))
		icon_state = "[initial(icon_state)]_broken"
	else
		icon_state = initial(icon_state)

/obj/machinery/computer/update_overlays()
	. = ..()
	if(!screen_overlay)
		return
	if(machine_stat & (BROKEN|DISABLED|NOPOWER))
		return
	. += emissive_appearance(icon, screen_overlay, alpha = src.alpha)
	. += mutable_appearance(icon, screen_overlay, alpha = src.alpha)

/obj/machinery/computer/proc/set_broken()
	machine_stat |= BROKEN
	density = FALSE
	update_icon()

/obj/machinery/computer/proc/decode(text)
	// Adds line breaks
	text = replacetext(text, "\n", "<BR>")
	return text

/obj/machinery/computer/welder_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE

	var/obj/item/tool/weldingtool/welder = I

	if(!(machine_stat & DISABLED) && durability == initial(durability))
		to_chat(user, span_notice("The [src] doesn't need welding!"))
		return FALSE

	if(!welder.tool_use_check(user, 2))
		return FALSE

	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_MASTER)
		user.visible_message(span_notice("[user] fumbles around figuring out how to deconstruct [src]."),
		span_notice("You fumble around figuring out how to deconstruct [src]."))
		var/fumbling_time = 5 SECONDS * (SKILL_ENGINEER_MASTER - user.skills.getRating(SKILL_ENGINEER))
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return

	user.visible_message(span_notice("[user] begins repairing damage to [src]."),
	span_notice("You begin repairing the damage to [src]."))
	playsound(loc, 'sound/items/welder2.ogg', 25, 1)

	if(!do_after(user, 5 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return

	if(!welder.remove_fuel(2, user))
		to_chat(user, span_warning("Not enough fuel to finish the task."))
		return TRUE

	user.visible_message(span_notice("[user] repairs [src]'s damage."),
	span_notice("You repair [src]."))
	machine_stat &= ~DISABLED //Remove the disabled flag
	durability = initial(durability) //Reset its durability to its initial value
	update_icon()
	playsound(loc, 'sound/items/welder2.ogg', 25, 1)

/obj/machinery/computer/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I) && circuit)
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_MASTER)
			user.visible_message(span_notice("[user] fumbles around figuring out how to deconstruct [src]."),
			span_notice("You fumble around figuring out how to deconstruct [src]."))
			var/fumbling_time = 50 * ( SKILL_ENGINEER_MASTER - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)

		if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD))
			return

		var/obj/structure/computerframe/A = new(loc)
		var/obj/item/circuitboard/computer/M = new circuit(A)
		A.circuit = M
		A.anchored = TRUE

		for(var/obj/C in src)
			C.forceMove(loc)

		if(machine_stat & BROKEN)
			to_chat(user, span_notice("The broken glass falls out."))
			new /obj/item/shard(loc)
			A.state = 3
			A.icon_state = "3"
		else
			to_chat(user, span_notice("You disconnect the monitor."))
			A.state = 4
			A.icon_state = "4"

		M.decon(src)
		qdel(src)

	else if(isxeno(user))
		return attack_alien(user)

	else
		return attack_hand(user)


/obj/machinery/computer/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(ishuman(usr))
		pick(playsound(src, 'sound/machines/computer_typing1.ogg', 5, 1), playsound(src, 'sound/machines/computer_typing2.ogg', 5, 1), playsound(src, 'sound/machines/computer_typing3.ogg', 5, 1))

///So Xenos can smash computers out of the way without actually breaking them
/obj/machinery/computer/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if(resistance_flags & INDESTRUCTIBLE)
		to_chat(X, span_xenowarning("We're unable to damage this!"))
		return

	if(machine_stat & (BROKEN|DISABLED)) //If we're already broken or disabled, don't bother
		to_chat(X, span_xenowarning("This peculiar thing is already broken!"))
		return

	if(durability <= 0)
		set_disabled()
		to_chat(X, span_xenowarning("We smash the annoying device, disabling it!"))
	else
		durability--
		to_chat(X, span_xenowarning("We smash the annoying device!"))

	X.do_attack_animation(src, ATTACK_EFFECT_DISARM2) //SFX
	playsound(loc, pick('sound/effects/bang.ogg','sound/effects/metal_crash.ogg','sound/effects/meteorimpact.ogg'), 25, 1) //SFX
	Shake(duration = 0.5 SECONDS)
