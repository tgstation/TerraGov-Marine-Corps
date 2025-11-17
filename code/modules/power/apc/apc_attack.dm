/obj/machinery/power/apc/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return FALSE

	if(effects)
		xeno_attacker.do_attack_animation(src, ATTACK_EFFECT_CLAW)
		xeno_attacker.visible_message(span_danger("[xeno_attacker] slashes \the [src]!"), \
		span_danger("We slash \the [src]!"), null, 5)
		playsound(loc, SFX_ALIEN_CLAW_METAL, 25, 1)

	var/allcut = wires.is_all_cut()

	if(beenhit >= pick(3, 4) && !CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		ENABLE_BITFIELD(machine_stat, PANEL_OPEN)
		update_appearance()
		visible_message(span_danger("\The [src]'s cover swings open, exposing the wires!"), null, null, 5)

	else if(CHECK_BITFIELD(machine_stat, PANEL_OPEN) && !allcut)
		wires.cut_all()
		update_appearance()
		visible_message(span_danger("\The [src]'s wires snap apart in a rain of sparks!"), null, null, 5)
		if(xeno_attacker.client)
			var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[xeno_attacker.ckey]
			personal_statistics.apcs_slashed++
	else
		beenhit += 1

//Attack with an item - open/close cover, insert cell, or (un)lock interface //todo please clean this up
/obj/machinery/power/apc/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/cell) && opened) //Trying to put a cell inside
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			user.visible_message(span_notice("[user] fumbles around figuring out how to fit [I] into [src]."),
			span_notice("You fumble around figuring out how to fit [I] into [src]."))
			var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		if(cell)
			balloon_alert(user, "Already installed")
			return

		if(machine_stat & MAINT)
			balloon_alert(user, "No connector")
			return

		if(!user.transferItemToLoc(I, src))
			return

		set_cell(I)
		user.visible_message("<span class='notice'>[user] inserts [I] into [src]!",
		"<span class='notice'>You insert [I] into [src]!")
		chargecount = 0
		update_appearance()

	else if(istype(I, /obj/item/card/id)) //Trying to unlock the interface with an ID card
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			user.visible_message(span_notice("[user] fumbles around figuring out where to swipe [I] on [src]."),
			span_notice("You fumble around figuring out where to swipe [I] on [src]."))
			var/fumbling_time = 3 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		if(opened)
			balloon_alert(user, "Close the cover first")
			return

		if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
			balloon_alert(user, "Close the panel first")
			return

		if(machine_stat & (BROKEN|MAINT))
			balloon_alert(user, "Nothing happens")
			return

		if(!allowed(user))
			balloon_alert(user, "Access denied")
			return

		locked = !locked
		balloon_alert_to_viewers("[locked ? "locked" : "unlocked"]")
		update_appearance()

	else if(iscablecoil(I) && !terminal && opened && has_electronics != APC_ELECTRONICS_SECURED)
		var/obj/item/stack/cable_coil/C = I

		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			balloon_alert_to_viewers("fumbles")
			var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		var/turf/T = get_turf(src)
		if(T.intact_tile)
			balloon_alert(user, "Remove the floor plating")
			return

		if(C.get_amount() < 10)
			balloon_alert(user, "Not enough wires")
			return

		balloon_alert_to_viewers("starts wiring [src]")
		playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)

		if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD) || terminal || !opened || has_electronics == APC_ELECTRONICS_SECURED)
			return

		var/obj/structure/cable/N = T.get_cable_node()
		if(prob(50) && electrocute_mob(user, N, N))
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(5, 1, src)
			s.start()
			return

		if(!C.use(10))
			return

		balloon_alert_to_viewers("Wired]")
		make_terminal()
		terminal.connect_to_network()

	else if(istype(I, /obj/item/circuitboard/apc) && opened && has_electronics == APC_ELECTRONICS_MISSING && !(machine_stat & BROKEN))
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			balloon_alert_to_viewers("fumbles")
			var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		balloon_alert_to_viewers("Tries to insert APC board into [src]")
		playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)

		if(!do_after(user, 15, NONE, src, BUSY_ICON_BUILD))
			return

		has_electronics = APC_ELECTRONICS_INSTALLED
		balloon_alert_to_viewers("Inserts APC board into [src]")
		qdel(I)

	else if(istype(I, /obj/item/circuitboard/apc) && opened && has_electronics == APC_ELECTRONICS_MISSING && (machine_stat & BROKEN))
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			balloon_alert_to_viewers("fumbles")
			var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		balloon_alert(user, "Cannot, frame damaged")

	else if(istype(I, /obj/item/frame/apc) && opened && (machine_stat & BROKEN))
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			balloon_alert_to_viewers("fumbles")
			var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		if(has_electronics)
			balloon_alert(user, "Cannot, electronics still inside")
			return

		balloon_alert_to_viewers("Begins replacing front panel")

		if(!do_after(user, 50, NONE, src, BUSY_ICON_BUILD))
			return

		balloon_alert_to_viewers("Replaces front panel")
		qdel(I)
		DISABLE_BITFIELD(machine_stat, BROKEN)
		if(opened == APC_COVER_REMOVED)
			opened = APC_COVER_OPENED
		update_appearance()

	else if(istype(I, /obj/item/frame/apc) && opened)
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			balloon_alert_to_viewers("fumbles")
			var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		if(opened == APC_COVER_REMOVED)
			opened = APC_COVER_OPENED
		balloon_alert_to_viewers("Replaces [src]'s front panel")
		qdel(I)
		update_appearance()

	else
		if(((machine_stat & BROKEN)) && !opened && I.force >= 5)
			opened = APC_COVER_REMOVED
			balloon_alert_to_viewers("Knocks down [src]'s panel")
			update_appearance()
		else
			if(issilicon(user))
				return attack_hand(user)

			if(!opened && CHECK_BITFIELD(machine_stat, PANEL_OPEN) && (ismultitool(I) || iswirecutter(I)))
				return attack_hand(user)
			balloon_alert_to_viewers("Hits [src] with [I]")

//Attack with hand - remove cell (if cover open) or interact with the APC
/obj/machinery/power/apc/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(opened && cell && !issilicon(user))
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			balloon_alert_to_viewers("fumbles")
			var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return
		balloon_alert_to_viewers("Removes [src] from [src]")
		user.put_in_hands(cell)
		cell.update_appearance()
		set_cell(null)
		charging = APC_NOT_CHARGING
		update_appearance()
		return

	if(machine_stat & (BROKEN|MAINT))
		return

	interact(user)

//Alternate attack with hand - lock/unlock the interface
/obj/machinery/power/apc/attack_hand_alternate(mob/living/user)
	. = ..()
	if(!can_use(user))
		return

	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
		return

	if(opened)
		balloon_alert(user, "Close the cover first")
		return

	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		balloon_alert(user, "Close the panel first")
		return

	if(machine_stat & (BROKEN|MAINT))
		balloon_alert(user, "Nothing happens")
		return

	if(!allowed(user))
		balloon_alert(user, "Access denied")
		return

	locked = !locked
	balloon_alert_to_viewers("[locked ? "locked" : "unlocked"]")
	update_appearance()
