//Carrier trap
/obj/structure/xeno/trap
	desc = "It looks like a hiding hole."
	name = "resin hole"
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "trap"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 5
	layer = RESIN_STRUCTURE_LAYER
	destroy_sound = SFX_ALIEN_RESIN_BREAK
	///defines for trap type to trigger on activation
	var/trap_type
	///The hugger inside our trap
	var/obj/item/clothing/mask/facehugger/hugger = null
	///smoke effect to create when the trap is triggered
	var/datum/effect_system/smoke_spread/smoke
	///connection list for huggers
	var/static/list/listen_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(trigger_trap),
	)

/obj/structure/xeno/trap/Initialize(mapload, _hivenumber)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_SHUTTLE_CRUSH, PROC_REF(shuttle_crush))
	AddElement(/datum/element/connect_loc, listen_connections)

/obj/structure/xeno/trap/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(400, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(200, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(100, BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(50, BRUTE, BOMB)

/obj/structure/xeno/trap/update_icon_state()
	. = ..()
	switch(trap_type)
		if(TRAP_HUGGER)
			icon_state = "traphugger"
		if(TRAP_SMOKE_NEURO)
			icon_state = "trapneurogas"
		if(TRAP_SMOKE_ACID)
			icon_state = "trapacidgas"
		if(TRAP_ACID_WEAK)
			icon_state = "trapacidweak"
		if(TRAP_ACID_NORMAL)
			icon_state = "trapacid"
		if(TRAP_ACID_STRONG)
			icon_state = "trapacidstrong"
		else
			icon_state = "trap"

/obj/structure/xeno/trap/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	if((damage_amount || damage_flag) && hugger && loc)
		trigger_trap()
	return ..()

/obj/structure/xeno/trap/proc/set_trap_type(new_trap_type)
	if(new_trap_type == trap_type)
		return
	trap_type = new_trap_type
	update_icon()

///Ensures that no huggies will be released when the trap is crushed by a shuttle; no more trapping shuttles with huggies
/obj/structure/xeno/trap/proc/shuttle_crush()
	SIGNAL_HANDLER
	qdel(src)

/obj/structure/xeno/trap/examine(mob/user)
	. = ..()
	if(!isxeno(user))
		return
	. += "A hole for a little one to hide in ambush for or for spewing acid."
	switch(trap_type)
		if(TRAP_HUGGER)
			. += "There's a little one inside."
		if(TRAP_SMOKE_NEURO)
			. += "There's pressurized neurotoxin inside."
		if(TRAP_SMOKE_ACID)
			. += "There's pressurized acid gas inside."
		if(TRAP_ACID_WEAK)
			. += "There's pressurized weak acid inside."
		if(TRAP_ACID_NORMAL)
			. += "There's pressurized normal acid inside."
		if(TRAP_ACID_STRONG)
			. += "There's strong pressurized acid inside."
		else
			. += "It's empty."

/obj/structure/xeno/trap/fire_act(burn_level)
	hugger?.kill_hugger()
	trigger_trap()
	set_trap_type(null)

///Triggers the hugger trap
/obj/structure/xeno/trap/proc/trigger_trap(datum/source, atom/movable/AM, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!trap_type)
		return
	if(AM && (hivenumber == AM.get_xeno_hivenumber()))
		return
	playsound(src, SFX_ALIEN_RESIN_BREAK, 25)
	if(iscarbon(AM))
		var/mob/living/carbon/crosser = AM
		crosser.visible_message(span_warning("[crosser] trips on [src]!"), span_danger("You trip on [src]!"))
		crosser.ParalyzeNoChain(4 SECONDS)
	switch(trap_type)
		if(TRAP_HUGGER)
			if(!AM)
				drop_hugger()
				return
			if(!iscarbon(AM))
				return
			var/mob/living/carbon/crosser = AM
			if(!crosser.can_be_facehugged(hugger))
				return
			drop_hugger()
		if(TRAP_SMOKE_NEURO, TRAP_SMOKE_ACID)
			smoke.start()
		if(TRAP_ACID_WEAK)
			for(var/turf/acided AS in RANGE_TURFS(1, src))
				new /obj/effect/xenomorph/spray(acided, 7 SECONDS, XENO_DEFAULT_ACID_PUDDLE_DAMAGE)
		if(TRAP_ACID_NORMAL)
			for(var/turf/acided AS in RANGE_TURFS(1, src))
				new /obj/effect/xenomorph/spray(acided, 10 SECONDS, XENO_DEFAULT_ACID_PUDDLE_DAMAGE)
		if(TRAP_ACID_STRONG)
			for(var/turf/acided AS in RANGE_TURFS(1, src))
				new /obj/effect/xenomorph/spray(acided, 12 SECONDS, XENO_DEFAULT_ACID_PUDDLE_DAMAGE)
	xeno_message("A [trap_type] trap at [AREACOORD_NO_Z(src)] has been triggered!", "xenoannounce", 5, hivenumber,  FALSE, get_turf(src), 'sound/voice/alien_talk2.ogg', FALSE, null, /atom/movable/screen/arrow/attack_order_arrow, COLOR_ORANGE, TRUE)
	set_trap_type(null)

/// Move the hugger out of the trap
/obj/structure/xeno/trap/proc/drop_hugger()
	hugger.forceMove(loc)
	hugger.go_active(TRUE, TRUE) //Removes stasis
	visible_message(span_warning("[hugger] gets out of [src]!") )
	hugger = null
	set_trap_type(null)

/obj/structure/xeno/trap/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return FALSE

	if(xeno_attacker.a_intent == INTENT_HARM)
		return ..()
	if(trap_type == TRAP_HUGGER)
		if(!(xeno_attacker.xeno_caste.can_flags & CASTE_CAN_HOLD_FACEHUGGERS))
			return
		if(!hugger)
			balloon_alert(xeno_attacker, "It is empty")
			return
		xeno_attacker.put_in_active_hand(hugger)
		hugger.go_active(TRUE)
		hugger = null
		set_trap_type(null)
		balloon_alert(xeno_attacker, "Removed facehugger")
		return
	var/datum/action/ability/activable/xeno/corrosive_acid/acid_action = locate(/datum/action/ability/activable/xeno/corrosive_acid) in xeno_attacker.actions
	if(istype(xeno_attacker.ammo, /datum/ammo/xeno/boiler_gas))
		var/datum/ammo/xeno/boiler_gas/boiler_glob = xeno_attacker.ammo
		if(!boiler_glob.enhance_trap(src, xeno_attacker))
			return
	else if(acid_action)
		if(!do_after(xeno_attacker, 2 SECONDS, NONE, src))
			return
		switch(acid_action.acid_type)
			if(/obj/effect/xenomorph/acid/weak)
				set_trap_type(TRAP_ACID_WEAK)
			if(/obj/effect/xenomorph/acid)
				set_trap_type(TRAP_ACID_NORMAL)
			if(/obj/effect/xenomorph/acid/strong)
				set_trap_type(TRAP_ACID_STRONG)
	else
		return // nothing happened!
	playsound(xeno_attacker.loc, 'sound/effects/refill.ogg', 25, 1)
	balloon_alert(xeno_attacker, "Filled with [trap_type]")

/obj/structure/xeno/trap/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!istype(I, /obj/item/clothing/mask/facehugger) || !isxeno(user))
		return
	var/obj/item/clothing/mask/facehugger/FH = I
	if(trap_type)
		balloon_alert(user, "Already occupied")
		return

	if(FH.stat == DEAD)
		balloon_alert(user, "Cannot insert facehugger")
		return

	user.transferItemToLoc(FH, src)
	FH.go_idle(TRUE)
	hugger = FH
	set_trap_type(TRAP_HUGGER)
	balloon_alert(user, "Inserted facehugger")
