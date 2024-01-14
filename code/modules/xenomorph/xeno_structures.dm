/obj/structure/xeno
	hit_sound = "alien_resin_break"
	layer = RESIN_STRUCTURE_LAYER
	resistance_flags = UNACIDABLE
	///Bitflags specific to xeno structures
	var/xeno_structure_flags
	///Which hive(number) do we belong to?
	var/hivenumber = XENO_HIVE_NORMAL

/obj/structure/xeno/Initialize(mapload, _hivenumber)
	. = ..()
	if(!(xeno_structure_flags & IGNORE_WEED_REMOVAL))
		RegisterSignal(loc, COMSIG_TURF_WEED_REMOVED, PROC_REF(weed_removed))
	if(_hivenumber) ///because admins can spawn them
		hivenumber = _hivenumber
	LAZYADDASSOC(GLOB.xeno_structures_by_hive, hivenumber, src)
	if(xeno_structure_flags & CRITICAL_STRUCTURE)
		LAZYADDASSOC(GLOB.xeno_critical_structures_by_hive, hivenumber, src)

/obj/structure/xeno/Destroy()
	if(!locate(src) in GLOB.xeno_structures_by_hive[hivenumber]+GLOB.xeno_critical_structures_by_hive[hivenumber]) //The rest of the proc is pointless to look through if its not in the lists
		stack_trace("[src] not found in the list of (potentially critical) xeno structures!") //We dont want to CRASH because that'd block deletion completely. Just trace it and continue.
		return ..()
	GLOB.xeno_structures_by_hive[hivenumber] -= src
	if(xeno_structure_flags & CRITICAL_STRUCTURE)
		GLOB.xeno_critical_structures_by_hive[hivenumber] -= src
	return ..()

/obj/structure/xeno/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(210, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(140, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(70, BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(35, BRUTE, BOMB)

/obj/structure/xeno/attack_hand(mob/living/user)
	balloon_alert(user, "You only scrape at it")
	return TRUE

/obj/structure/xeno/flamer_fire_act(burnlevel)
	take_damage(burnlevel / 3, BURN, FIRE)

/obj/structure/xeno/fire_act()
	take_damage(10, BURN, FIRE)

/// Destroy the xeno structure when the weed it was on is destroyed
/obj/structure/xeno/proc/weed_removed()
	SIGNAL_HANDLER
	obj_destruction(damage_flag = MELEE)

/obj/structure/xeno/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(!(HAS_TRAIT(X, TRAIT_VALHALLA_XENO) && X.a_intent == INTENT_HARM && (tgui_alert(X, "Are you sure you want to tear down [src]?", "Tear down [src]?", list("Yes","No"))) == "Yes"))
		return ..()
	if(!do_after(X, 3 SECONDS, NONE, src))
		return
	X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	balloon_alert_to_viewers("\The [X] tears down \the [src]!", "We tear down \the [src].")
	playsound(src, "alien_resin_break", 25)
	take_damage(max_integrity) // Ensure its destroyed


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
	destroy_sound = "alien_resin_break"
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

/obj/structure/xeno/trap/obj_destruction(damage_amount, damage_type, damage_flag)
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

/obj/structure/xeno/trap/flamer_fire_act(burnlevel)
	hugger?.kill_hugger()
	trigger_trap()
	set_trap_type(null)

/obj/structure/xeno/trap/fire_act()
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
	playsound(src, "alien_resin_break", 25)
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

/obj/structure/xeno/trap/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if(X.a_intent == INTENT_HARM)
		return ..()
	if(trap_type == TRAP_HUGGER)
		if(!(X.xeno_caste.can_flags & CASTE_CAN_HOLD_FACEHUGGERS))
			return
		if(!hugger)
			balloon_alert(X, "It is empty")
			return
		X.put_in_active_hand(hugger)
		hugger.go_active(TRUE)
		hugger = null
		set_trap_type(null)
		balloon_alert(X, "Removed facehugger")
		return
	var/datum/action/ability/activable/xeno/corrosive_acid/acid_action = locate(/datum/action/ability/activable/xeno/corrosive_acid) in X.actions
	if(istype(X.ammo, /datum/ammo/xeno/boiler_gas))
		var/datum/ammo/xeno/boiler_gas/boiler_glob = X.ammo
		if(!boiler_glob.enhance_trap(src, X))
			return
	else if(acid_action)
		if(!do_after(X, 2 SECONDS, NONE, src))
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
	playsound(X.loc, 'sound/effects/refill.ogg', 25, 1)
	balloon_alert(X, "Filled with [trap_type]")

/obj/structure/xeno/trap/attackby(obj/item/I, mob/user, params)
	. = ..()

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

/*
TUNNEL
*/
/obj/structure/xeno/tunnel
	name = "tunnel"
	desc = "A tunnel entrance. Looks like it was dug by some kind of clawed beast."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "hole"

	density = FALSE
	opacity = FALSE
	anchored = TRUE
	resistance_flags = UNACIDABLE|BANISH_IMMUNE
	layer = RESIN_STRUCTURE_LAYER

	max_integrity = 140

	hud_possible = list(XENO_TACTICAL_HUD)
	xeno_structure_flags = IGNORE_WEED_REMOVAL
	///Description added by the hivelord.
	var/tunnel_desc = ""
	///What hivelord created that tunnel. Can be null
	var/mob/living/carbon/xenomorph/hivelord/creator = null

/obj/structure/xeno/tunnel/Initialize(mapload, _hivenumber)
	. = ..()
	LAZYADDASSOC(GLOB.xeno_tunnels_by_hive, hivenumber, src)
	prepare_huds()
	for(var/datum/atom_hud/xeno_tactical/xeno_tac_hud in GLOB.huds) //Add to the xeno tachud
		xeno_tac_hud.add_to_hud(src)
	hud_set_xeno_tunnel()
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, "xenotunnel"))

/obj/structure/xeno/tunnel/Destroy()
	var/turf/drop_loc = get_turf(src)
	for(var/atom/movable/thing AS in contents) //Empty the tunnel of contents
		thing.forceMove(drop_loc)

	if(!QDELETED(creator))
		to_chat(creator, span_xenoannounce("You sense your [name] at [tunnel_desc] has been destroyed!") ) //Alert creator

	xeno_message("Hive tunnel [name] at [tunnel_desc] has been destroyed!", "xenoannounce", 5, hivenumber) //Also alert hive because tunnels matter.

	LAZYREMOVE(GLOB.xeno_tunnels_by_hive[hivenumber], src)
	if(creator)
		creator.tunnels -= src
	creator = null

	for(var/datum/atom_hud/xeno_tactical/xeno_tac_hud in GLOB.huds) //HUD clean up
		xeno_tac_hud.remove_from_hud(src)
	SSminimaps.remove_marker(src)

	return ..()

///Signal handler for creator destruction to clear reference
/obj/structure/xeno/tunnel/proc/clear_creator()
	SIGNAL_HANDLER
	creator = null

/obj/structure/xeno/tunnel/examine(mob/user)
	. = ..()
	if(!isxeno(user) && !isobserver(user))
		return
	if(tunnel_desc)
		. += span_info("The Hivelord scent reads: \'[tunnel_desc]\'")

/obj/structure/xeno/tunnel/deconstruct(disassembled = TRUE)
	visible_message(span_danger("[src] suddenly collapses!") )
	return ..()

/obj/structure/xeno/tunnel/attackby(obj/item/I, mob/user, params)
	if(!isxeno(user))
		return ..()
	attack_alien(user)

/obj/structure/xeno/tunnel/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(!istype(X) || X.stat || X.lying_angle || X.status_flags & INCORPOREAL)
		return

	if(X.a_intent == INTENT_HARM && X == creator)
		balloon_alert(X, "Filling in tunnel...")
		if(do_after(X, HIVELORD_TUNNEL_DISMANTLE_TIME, IGNORE_HELD_ITEM, src, BUSY_ICON_BUILD))
			deconstruct(FALSE)
		return

	if(X.anchored)
		balloon_alert(X, "Cannot enter while immobile")
		return FALSE

	if(length(GLOB.xeno_tunnels_by_hive[hivenumber]) < 2)
		balloon_alert(X, "No exit tunnel")
		return FALSE

	pick_a_tunnel(X)

/obj/structure/xeno/tunnel/attack_larva(mob/living/carbon/xenomorph/larva/L) //So larvas can actually use tunnels
	attack_alien(L)

/obj/structure/xeno/tunnel/attack_ghost(mob/dead/observer/user)
	. = ..()

	var/list/obj/destinations = GLOB.xeno_tunnels_by_hive[hivenumber]
	var/obj/structure/xeno/tunnel/targettunnel
	if(LAZYLEN(destinations) > 2)
		var/list/tunnel_assoc = list()
		for(var/obj/D in destinations)
			tunnel_assoc["X:[D.x], Y:[D.y] - \[[get_area(D)]\]"] = D
		destinations = list()
		for(var/d in tunnel_assoc)
			destinations += d
		var/input = tgui_input_list(user ,"Choose a tunnel to teleport to:" ,"Ghost Tunnel teleport" ,destinations ,null, 0)
		if(!input)
			return
		targettunnel = tunnel_assoc[input]
		if(!input)
			return
	else
		//There are only 2 tunnels. Pick the other one.
		for(var/P in destinations)
			if(P != src)
				targettunnel = P
	if(!targettunnel || QDELETED(targettunnel) || !targettunnel.loc)
		return
	user.forceMove(get_turf(targettunnel))

///Here we pick a tunnel to go to, then travel to that tunnel and peep out, confirming whether or not we want to emerge or go to another tunnel.
/obj/structure/xeno/tunnel/proc/pick_a_tunnel(mob/living/carbon/xenomorph/M)
	var/obj/structure/xeno/tunnel/targettunnel = tgui_input_list(M, "Choose a tunnel to crawl to", "Tunnel", GLOB.xeno_tunnels_by_hive[hivenumber])
	if(QDELETED(src)) //Make sure we still exist in the event the player keeps the interface open
		return
	if(!M.Adjacent(src) && M.loc != src) //Make sure we're close enough to our tunnel; either adjacent to or in one
		return
	if(QDELETED(targettunnel)) //Make sure our target destination still exists in the event the player keeps the interface open
		balloon_alert(M, "Tunnel no longer exists")
		if(M.loc == src) //If we're in the tunnel and cancelling out, spit us out.
			M.forceMove(loc)
		return
	if(targettunnel == src)
		balloon_alert(M, "We're already here")
		if(M.loc == src) //If we're in the tunnel and cancelling out, spit us out.
			M.forceMove(loc)
		return
	if(targettunnel.z != z)
		balloon_alert(M, "Tunnel not connected")
		if(M.loc == src) //If we're in the tunnel and cancelling out, spit us out.
			M.forceMove(loc)
		return
	var/distance = get_dist(get_turf(src), get_turf(targettunnel))
	var/tunnel_time = clamp(distance, HIVELORD_TUNNEL_MIN_TRAVEL_TIME, HIVELORD_TUNNEL_SMALL_MAX_TRAVEL_TIME)

	if(M.mob_size == MOB_SIZE_BIG) //Big xenos take longer
		tunnel_time = clamp(distance * 1.5, HIVELORD_TUNNEL_MIN_TRAVEL_TIME, HIVELORD_TUNNEL_LARGE_MAX_TRAVEL_TIME)
		M.visible_message(span_xenonotice("[M] begins heaving their huge bulk down into \the [src].") , \
		span_xenonotice("We begin heaving our monstrous bulk into \the [src] to <b>[targettunnel.tunnel_desc]</b>.") )
	else
		M.visible_message(span_xenonotice("\The [M] begins crawling down into \the [src].") , \
		span_xenonotice("We begin crawling down into \the [src] to <b>[targettunnel.tunnel_desc]</b>.") )

	if(isxenolarva(M)) //Larva can zip through near-instantly, they are wormlike after all
		tunnel_time = 5

	if(!do_after(M, tunnel_time, IGNORE_HELD_ITEM, src, BUSY_ICON_GENERIC))
		balloon_alert(M, "Crawling interrupted")
		return
	if(!targettunnel || !isturf(targettunnel.loc)) //Make sure the end tunnel is still there
		balloon_alert(M, "Tunnel ended unexpectedly")
		return
	M.forceMove(targettunnel)
	var/double_check = tgui_alert(M, "Emerge here?", "Tunnel: [targettunnel]", list("Yes","Pick another tunnel"), 0)
	if(M.loc != targettunnel) //double check that we're still in the tunnel in the event it gets destroyed while we still have the interface open
		return
	if(double_check == "Pick another tunnel")
		return targettunnel.pick_a_tunnel(M)
	M.forceMove(targettunnel.loc)
	M.visible_message(span_xenonotice("\The [M] pops out of \the [src].") , \
	span_xenonotice("We pop out through the other side!") )

///Makes sure the tunnel is visible to other xenos even through obscuration.
/obj/structure/xeno/tunnel/proc/hud_set_xeno_tunnel()
	var/image/holder = hud_list[XENO_TACTICAL_HUD]
	if(!holder)
		return
	holder.icon = 'icons/mob/hud.dmi'
	holder.icon_state = "hudtraitor"
	hud_list[XENO_TACTICAL_HUD] = holder

//Resin Water Well
/obj/structure/xeno/acidwell
	name = "acid well"
	desc = "An acid well. It stores acid to put out fires."
	icon = 'icons/Xeno/acid_pool.dmi'
	icon_state = "well"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 5

	hit_sound = "alien_resin_move"
	destroy_sound = "alien_resin_move"
	///How many charges of acid this well contains
	var/charges = 1
	///If a xeno is charging this well
	var/charging = FALSE
	///What xeno created this well
	var/mob/living/carbon/xenomorph/creator = null

/obj/structure/xeno/acidwell/Initialize(mapload, _creator)
	. = ..()
	creator = _creator
	RegisterSignal(creator, COMSIG_QDELETING, PROC_REF(clear_creator))
	update_icon()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/xeno/acidwell/Destroy()
	creator = null
	return ..()

///Signal handler for creator destruction to clear reference
/obj/structure/xeno/acidwell/proc/clear_creator()
	SIGNAL_HANDLER
	creator = null

///Ensures that no acid gas will be released when the well is crushed by a shuttle
/obj/structure/xeno/acidwell/proc/shuttle_crush()
	SIGNAL_HANDLER
	qdel(src)


/obj/structure/xeno/acidwell/obj_destruction(damage_amount, damage_type, damage_flag)
	if(!QDELETED(creator) && creator.stat == CONSCIOUS && creator.z == z)
		var/area/A = get_area(src)
		if(A)
			to_chat(creator, span_xenoannounce("You sense your acid well at [A.name] has been destroyed!") )

	if(damage_amount || damage_flag) //Spawn the gas only if we actually get destroyed by damage
		var/datum/effect_system/smoke_spread/xeno/acid/A = new(get_turf(src))
		A.set_up(clamp(CEILING(charges*0.5, 1),0,3),src) //smoke scales with charges
		A.start()
	return ..()

/obj/structure/xeno/acidwell/examine(mob/user)
	. = ..()
	if(!isxeno(user) && !isobserver(user))
		return
	. += span_xenonotice("An acid well made by [creator]. It currently has <b>[charges]/[XENO_ACID_WELL_MAX_CHARGES] charges</b>.")

/obj/structure/xeno/acidwell/deconstruct(disassembled = TRUE)
	visible_message(span_danger("[src] suddenly collapses!") )
	return ..()

/obj/structure/xeno/acidwell/update_icon()
	. = ..()
	set_light(charges , charges / 2, LIGHT_COLOR_GREEN)

/obj/structure/xeno/acidwell/update_overlays()
	. = ..()
	if(!charges)
		return
	. += mutable_appearance(icon, "[charges]", alpha = src.alpha)
	. += emissive_appearance(icon, "[charges]", alpha = src.alpha)

/obj/structure/xeno/acidwell/flamer_fire_act(burnlevel) //Removes a charge of acid, but fire is extinguished
	acid_well_fire_interaction()

/obj/structure/xeno/acidwell/fire_act() //Removes a charge of acid, but fire is extinguished
	acid_well_fire_interaction()

///Handles fire based interactions with the acid well. Depletes 1 charge if there are any to extinguish all fires in the turf while producing acid smoke.
/obj/structure/xeno/acidwell/proc/acid_well_fire_interaction()
	if(!charges)
		take_damage(50, BURN, FIRE)
		return

	charges--
	update_icon()
	var/turf/T = get_turf(src)
	var/datum/effect_system/smoke_spread/xeno/acid/acid_smoke = new(T) //spawn acid smoke when charges are actually used
	acid_smoke.set_up(0, src) //acid smoke in the immediate vicinity
	acid_smoke.start()

	for(var/obj/flamer_fire/F in T) //Extinguish all flames in turf
		qdel(F)

/obj/structure/xeno/acidwell/attackby(obj/item/I, mob/user, params)
	if(!isxeno(user))
		return ..()
	attack_alien(user)

/obj/structure/xeno/acidwell/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.a_intent == INTENT_HARM && (CHECK_BITFIELD(X.xeno_caste.caste_flags, CASTE_IS_BUILDER) || X == creator) ) //If we're a builder caste or the creator and we're on harm intent, deconstruct it.
		balloon_alert(X, "Removing...")
		if(!do_after(X, XENO_ACID_WELL_FILL_TIME, IGNORE_HELD_ITEM, src, BUSY_ICON_HOSTILE))
			balloon_alert(X, "Stopped removing")
			return
		playsound(src, "alien_resin_break", 25)
		deconstruct(TRUE, X)
		return

	if(charges >= 5)
		balloon_alert(X, "Already full")
		return
	if(charging)
		balloon_alert(X, "Already being filled")
		return

	if(X.plasma_stored < XENO_ACID_WELL_FILL_COST) //You need to have enough plasma to attempt to fill the well
		balloon_alert(X, "Need [XENO_ACID_WELL_FILL_COST - X.plasma_stored] more plasma")
		return

	charging = TRUE

	balloon_alert(X, "Refilling...")
	if(!do_after(X, XENO_ACID_WELL_FILL_TIME, IGNORE_HELD_ITEM, src, BUSY_ICON_BUILD))
		charging = FALSE
		balloon_alert(X, "Aborted refilling")
		return

	if(X.plasma_stored < XENO_ACID_WELL_FILL_COST)
		charging = FALSE
		balloon_alert(X, "Need [XENO_ACID_WELL_FILL_COST - X.plasma_stored] more plasma")
		return

	X.plasma_stored -= XENO_ACID_WELL_FILL_COST
	charges++
	charging = FALSE
	update_icon()
	balloon_alert(X, "Now has [charges] / [XENO_ACID_WELL_MAX_CHARGES] charges")
	to_chat(X,span_xenonotice("We add acid to [src]. It is currently has <b>[charges] / [XENO_ACID_WELL_MAX_CHARGES] charges</b>.") )

/obj/structure/xeno/acidwell/proc/on_cross(datum/source, atom/movable/A, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(CHECK_MULTIPLE_BITFIELDS(A.allow_pass_flags, HOVERING))
		return
	if(iscarbon(A))
		HasProximity(A)

/obj/structure/xeno/acidwell/HasProximity(atom/movable/AM)
	if(!charges)
		return
	if(!isliving(AM))
		return
	var/mob/living/stepper = AM
	if(stepper.stat == DEAD)
		return

	var/charges_used = 0

	for(var/obj/item/explosive/grenade/sticky/sticky_bomb in stepper.contents)
		if(charges_used >= charges)
			break
		if(sticky_bomb.stuck_to == stepper)
			sticky_bomb.clean_refs()
			sticky_bomb.forceMove(loc)
			charges_used ++

	if(stepper.on_fire && (charges_used < charges))
		stepper.ExtinguishMob()
		charges_used ++

	if(!isxeno(stepper))
		stepper.next_move_slowdown += charges * 2 //Acid spray has slow down so this should too; scales with charges, Min 2 slowdown, Max 10
		stepper.apply_damage(charges * 10, BURN, BODY_ZONE_PRECISE_L_FOOT, ACID,  penetration = 33)
		stepper.apply_damage(charges * 10, BURN, BODY_ZONE_PRECISE_R_FOOT, ACID,  penetration = 33)
		stepper.visible_message(span_danger("[stepper] is immersed in [src]'s acid!") , \
		span_danger("We are immersed in [src]'s acid!") , null, 5)
		playsound(stepper, "sound/bullets/acid_impact1.ogg", 10 * charges)
		new /obj/effect/temp_visual/acid_bath(get_turf(stepper))
		charges_used = charges //humans stepping on it empties it out

	if(!charges_used)
		return

	var/datum/effect_system/smoke_spread/xeno/acid/acid_smoke
	acid_smoke = new(get_turf(stepper)) //spawn acid smoke when charges are actually used
	acid_smoke.set_up(0, src) //acid smoke in the immediate vicinity
	acid_smoke.start()

	charges -= charges_used
	update_icon()

/obj/structure/xeno/resin_jelly_pod
	name = "Resin jelly pod"
	desc = "A large resin pod. Inside is a thick, viscous fluid that looks like it doesnt burn easily."
	icon = 'icons/Xeno/resinpod.dmi'
	icon_state = "resinpod"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 250
	layer = RESIN_STRUCTURE_LAYER
	pixel_x = -16
	pixel_y = -16
	xeno_structure_flags = IGNORE_WEED_REMOVAL

	hit_sound = "alien_resin_move"
	destroy_sound = "alien_resin_move"
	///How many actual jellies the pod has stored
	var/chargesleft = 0
	///Max amount of jellies the pod can hold
	var/maxcharges = 10
	///Every 5 times this number seconds we will create a jelly
	var/recharge_rate = 10
	///Countdown to the next time we generate a jelly
	var/nextjelly = 0

/obj/structure/xeno/resin_jelly_pod/Initialize(mapload, _hivenumber)
	. = ..()
	add_overlay(image(icon, "resinpod_inside", layer + 0.01, dir))
	START_PROCESSING(SSslowprocess, src)

/obj/structure/xeno/resin_jelly_pod/Destroy()
	STOP_PROCESSING(SSslowprocess, src)
	return ..()

/obj/structure/xeno/resin_jelly_pod/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(isxeno(user))
		. += "It has [chargesleft] jelly globules remaining[datum_flags & DF_ISPROCESSING ? ", and will create a new jelly in [(recharge_rate-nextjelly)*5] seconds": " and seems latent"]."

/obj/structure/xeno/resin_jelly_pod/process()
	if(nextjelly <= recharge_rate)
		nextjelly++
		return
	nextjelly = 0
	chargesleft++
	if(chargesleft >= maxcharges)
		return PROCESS_KILL

/obj/structure/xeno/resin_jelly_pod/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if((X.a_intent == INTENT_HARM && isxenohivelord(X)) || X.hivenumber != hivenumber)
		balloon_alert(X, "Destroying...")
		if(do_after(X, HIVELORD_TUNNEL_DISMANTLE_TIME, IGNORE_HELD_ITEM, src, BUSY_ICON_BUILD))
			deconstruct(FALSE)
		return

	if(!chargesleft)
		balloon_alert(X, "No jelly remaining")
		to_chat(X, span_xenonotice("We reach into \the [src], but only find dregs of resin. We should wait some more.") )
		return
	balloon_alert(X, "Retrieved jelly")
	new /obj/item/resin_jelly(loc)
	chargesleft--
	if(!(datum_flags & DF_ISPROCESSING) && (chargesleft < maxcharges))
		START_PROCESSING(SSslowprocess, src)

/obj/structure/xeno/silo
	name = "Resin silo"
	icon = 'icons/Xeno/resin_silo.dmi'
	icon_state = "weed_silo"
	desc = "A slimy, oozy resin bed filled with foul-looking egg-like ...things."
	bound_width = 96
	bound_height = 96
	max_integrity = 1000
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE | PLASMACUTTER_IMMUNE
	xeno_structure_flags = IGNORE_WEED_REMOVAL|CRITICAL_STRUCTURE
	///How many larva points one silo produce in one minute
	var/larva_spawn_rate = 0.5
	var/turf/center_turf
	var/number_silo
	///For minimap icon change if silo takes damage or nearby hostile
	var/warning
	COOLDOWN_DECLARE(silo_damage_alert_cooldown)
	COOLDOWN_DECLARE(silo_proxy_alert_cooldown)

/obj/structure/xeno/silo/Initialize(mapload, _hivenumber)
	. = ..()
	center_turf = get_step(src, NORTHEAST)
	if(!istype(center_turf))
		center_turf = loc

	if(SSticker.mode?.flags_round_type & MODE_SILO_RESPAWN)
		for(var/turfs in RANGE_TURFS(XENO_SILO_DETECTION_RANGE, src))
			RegisterSignal(turfs, COMSIG_ATOM_ENTERED, PROC_REF(resin_silo_proxy_alert))

	if(SSticker.mode?.flags_round_type & MODE_SILOS_SPAWN_MINIONS)
		SSspawning.registerspawner(src, INFINITY, GLOB.xeno_ai_spawnable, 0, 0, null)
		SSspawning.spawnerdata[src].required_increment = 2 * max(45 SECONDS, 3 MINUTES - SSmonitor.maximum_connected_players_count * SPAWN_RATE_PER_PLAYER)/SSspawning.wait
		SSspawning.spawnerdata[src].max_allowed_mobs = max(1, MAX_SPAWNABLE_MOB_PER_PLAYER * SSmonitor.maximum_connected_players_count * 0.5)
	update_minimap_icon()

	return INITIALIZE_HINT_LATELOAD


/obj/structure/xeno/silo/LateInitialize()
	. = ..()
	var/siloprefix = GLOB.hive_datums[hivenumber].name
	number_silo = length(GLOB.xeno_resin_silos_by_hive[hivenumber]) + 1
	name = "[siloprefix == "Normal" ? "" : "[siloprefix] "][name] [number_silo]"
	LAZYADDASSOC(GLOB.xeno_resin_silos_by_hive, hivenumber, src)

	if(!locate(/obj/alien/weeds) in center_turf)
		new /obj/alien/weeds/node(center_turf)
	if(GLOB.hive_datums[hivenumber])
		RegisterSignals(GLOB.hive_datums[hivenumber], list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK), PROC_REF(is_burrowed_larva_host))
		if(length(GLOB.xeno_resin_silos_by_hive[hivenumber]) == 1)
			GLOB.hive_datums[hivenumber].give_larva_to_next_in_queue()
	var/turf/tunnel_turf = get_step(center_turf, NORTH)
	if(tunnel_turf.can_dig_xeno_tunnel())
		var/obj/structure/xeno/tunnel/newt = new(tunnel_turf, hivenumber)
		newt.tunnel_desc = "[AREACOORD_NO_Z(newt)]"
		newt.name += " [name]"

/obj/structure/xeno/silo/obj_destruction(damage_amount, damage_type, damage_flag)
	if(GLOB.hive_datums[hivenumber])
		UnregisterSignal(GLOB.hive_datums[hivenumber], list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK))
		GLOB.hive_datums[hivenumber].xeno_message("A resin silo has been destroyed at [AREACOORD_NO_Z(src)]!", "xenoannounce", 5, FALSE,src.loc, 'sound/voice/alien_help2.ogg',FALSE , null, /atom/movable/screen/arrow/silo_damaged_arrow)
		notify_ghosts("\ A resin silo has been destroyed at [AREACOORD_NO_Z(src)]!", source = get_turf(src), action = NOTIFY_JUMP)
		playsound(loc,'sound/effects/alien_egg_burst.ogg', 75)
	return ..()

/obj/structure/xeno/silo/Destroy()
	GLOB.xeno_resin_silos_by_hive[hivenumber] -= src

	for(var/i in contents)
		var/atom/movable/AM = i
		AM.forceMove(get_step(center_turf, pick(CARDINAL_ALL_DIRS)))
	center_turf = null

	STOP_PROCESSING(SSslowprocess, src)
	return ..()

/obj/structure/xeno/silo/examine(mob/user)
	. = ..()
	var/current_integrity = (obj_integrity / max_integrity) * 100
	switch(current_integrity)
		if(0 to 20)
			. += span_warning("It's barely holding, there's leaking oozes all around, and most eggs are broken. Yet it is not inert.")
		if(20 to 40)
			. += span_warning("It looks severely damaged, its movements slow.")
		if(40 to 60)
			. += span_warning("It's quite beat up, but it seems alive.")
		if(60 to 80)
			. += span_warning("It's slightly damaged, but still seems healthy.")
		if(80 to 100)
			. += span_info("It appears in good shape, pulsating healthily.")


/obj/structure/xeno/silo/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()

	//We took damage, so it's time to start regenerating if we're not already processing
	if(!CHECK_BITFIELD(datum_flags, DF_ISPROCESSING))
		START_PROCESSING(SSslowprocess, src)

	resin_silo_damage_alert()

/obj/structure/xeno/silo/proc/resin_silo_damage_alert()
	if(!COOLDOWN_CHECK(src, silo_damage_alert_cooldown))
		return
	warning = TRUE
	update_minimap_icon()
	GLOB.hive_datums[hivenumber].xeno_message("Our [name] at [AREACOORD_NO_Z(src)] is under attack! It has [obj_integrity]/[max_integrity] Health remaining.", "xenoannounce", 5, FALSE, src, 'sound/voice/alien_help1.ogg',FALSE, null, /atom/movable/screen/arrow/silo_damaged_arrow)
	COOLDOWN_START(src, silo_damage_alert_cooldown, XENO_SILO_HEALTH_ALERT_COOLDOWN) //set the cooldown.
	addtimer(CALLBACK(src, PROC_REF(clear_warning)), XENO_SILO_HEALTH_ALERT_COOLDOWN) //clear warning

///Alerts the Hive when hostiles get too close to their resin silo
/obj/structure/xeno/silo/proc/resin_silo_proxy_alert(datum/source, atom/movable/hostile, direction)
	SIGNAL_HANDLER

	if(!COOLDOWN_CHECK(src, silo_proxy_alert_cooldown)) //Proxy alert triggered too recently; abort
		return

	if(!isliving(hostile))
		return

	var/mob/living/living_triggerer = hostile
	if(living_triggerer.stat == DEAD) //We don't care about the dead
		return

	if(isxeno(hostile))
		var/mob/living/carbon/xenomorph/X = hostile
		if(X.hive == GLOB.hive_datums[hivenumber]) //Trigger proxy alert only for hostile xenos
			return

	warning = TRUE
	update_minimap_icon()
	GLOB.hive_datums[hivenumber].xeno_message("Our [name] has detected a nearby hostile [hostile] at [get_area(hostile)] (X: [hostile.x], Y: [hostile.y]).", "xenoannounce", 5, FALSE, hostile, 'sound/voice/alien_help1.ogg', FALSE, null, /atom/movable/screen/arrow/leader_tracker_arrow)
	COOLDOWN_START(src, silo_proxy_alert_cooldown, XENO_SILO_DETECTION_COOLDOWN) //set the cooldown.
	addtimer(CALLBACK(src, PROC_REF(clear_warning)), XENO_SILO_DETECTION_COOLDOWN) //clear warning

///Clears the warning for minimap if its warning for hostiles
/obj/structure/xeno/silo/proc/clear_warning()
	warning = FALSE
	update_minimap_icon()

/obj/structure/xeno/silo/process()
	//Regenerate if we're at less than max integrity
	if(obj_integrity < max_integrity)
		obj_integrity = min(obj_integrity + 25, max_integrity) //Regen 5 HP per sec

/obj/structure/xeno/silo/proc/is_burrowed_larva_host(datum/source, list/mothers, list/silos)
	SIGNAL_HANDLER
	if(GLOB.hive_datums[hivenumber])
		silos += src

///Change minimap icon if silo is under attack or not
/obj/structure/xeno/silo/proc/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, "silo[warning ? "_warn" : "_passive"]"))

/obj/structure/xeno/xeno_turret
	icon = 'icons/Xeno/acidturret.dmi'
	icon_state = XENO_TURRET_ACID_ICONSTATE
	name = "acid turret"
	desc = "A menacing looking construct of resin, it seems to be alive. It fires acid against intruders."
	bound_width = 32
	bound_height = 32
	obj_integrity = 600
	max_integrity = 1500
	layer = ABOVE_MOB_LAYER
	density = TRUE
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE |PORTAL_IMMUNE
	xeno_structure_flags = IGNORE_WEED_REMOVAL|HAS_OVERLAY
	allow_pass_flags = PASS_AIR|PASS_THROW
	///What kind of spit it uses
	var/datum/ammo/ammo = /datum/ammo/xeno/acid/heavy/turret
	///Range of the turret
	var/range = 7
	///Target of the turret
	var/atom/hostile
	///Last target of the turret
	var/atom/last_hostile
	///Potential list of targets found by scan
	var/list/atom/potential_hostiles
	///Fire rate of the target in ticks
	var/firerate = 5
	///The last time the sentry did a scan
	var/last_scan_time
	///light color that gets set in initialize
	var/light_initial_color = LIGHT_COLOR_GREEN
	///For minimap icon change if sentry is firing
	var/firing

///Change minimap icon if its firing or not firing
/obj/structure/xeno/xeno_turret/proc/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, "xeno_turret[firing ? "_firing" : "_passive"]"))

/obj/structure/xeno/xeno_turret/Initialize(mapload, _hivenumber)
	. = ..()
	ammo = GLOB.ammo_list[ammo]
	potential_hostiles = list()
	LAZYADDASSOC(GLOB.xeno_resin_turrets_by_hive, hivenumber, src)
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/automatedfire/xeno_turret_autofire, firerate)
	RegisterSignal(src, COMSIG_AUTOMATIC_SHOOTER_SHOOT, PROC_REF(shoot))
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, PROC_REF(destroy_on_hijack))
	if(light_initial_color)
		set_light(2, 2, light_initial_color)
	update_minimap_icon()
	update_icon()

///Signal handler to delete the turret when the alamo is hijacked
/obj/structure/xeno/xeno_turret/proc/destroy_on_hijack()
	SIGNAL_HANDLER
	qdel(src)

/obj/structure/xeno/xeno_turret/obj_destruction(damage_amount, damage_type, damage_flag)
	if(damage_amount) //Spawn the gas only if we actually get destroyed by damage
		var/datum/effect_system/smoke_spread/xeno/smoke = new /datum/effect_system/smoke_spread/xeno/acid(src)
		smoke.set_up(1, get_turf(src))
		smoke.start()
	return ..()

/obj/structure/xeno/xeno_turret/Destroy()
	GLOB.xeno_resin_turrets_by_hive[hivenumber] -= src
	set_hostile(null)
	set_last_hostile(null)
	STOP_PROCESSING(SSobj, src)
	playsound(loc,'sound/effects/xeno_turret_death.ogg', 70)
	return ..()

/obj/structure/xeno/xeno_turret/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(1500, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(750, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(300, BRUTE, BOMB)

/obj/structure/xeno/xeno_turret/flamer_fire_act(burnlevel)
	take_damage(burnlevel * 2, BURN, FIRE)
	ENABLE_BITFIELD(resistance_flags, ON_FIRE)

/obj/structure/xeno/xeno_turret/fire_act()
	take_damage(60, BURN, FIRE)
	ENABLE_BITFIELD(resistance_flags, ON_FIRE)

/obj/structure/xeno/xeno_turret/update_overlays()
	. = ..()
	if(!(xeno_structure_flags & HAS_OVERLAY))
		return
	if(obj_integrity <= max_integrity / 2)
		. += image('icons/Xeno/acidturret.dmi', src, "+turret_damage")
	if(CHECK_BITFIELD(resistance_flags, ON_FIRE))
		. += image('icons/Xeno/acidturret.dmi', src, "+turret_on_fire")

/obj/structure/xeno/xeno_turret/process()
	//Turrets regen some HP, every 2 sec
	if(obj_integrity < max_integrity)
		obj_integrity = min(obj_integrity + TURRET_HEALTH_REGEN, max_integrity)
		update_icon()
		DISABLE_BITFIELD(resistance_flags, ON_FIRE)
	if(world.time > last_scan_time + TURRET_SCAN_FREQUENCY)
		scan()
		last_scan_time = world.time
	if(!length(potential_hostiles))
		return
	set_hostile(get_target())
	if (!hostile)
		if(last_hostile)
			set_last_hostile(null)
		return
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_XENO_TURRETS_ALERT))
		GLOB.hive_datums[hivenumber].xeno_message("Our [name] is attacking a nearby hostile [hostile] at [get_area(hostile)] (X: [hostile.x], Y: [hostile.y]).", "xenoannounce", 5, FALSE, hostile, 'sound/voice/alien_help1.ogg', FALSE, null, /atom/movable/screen/arrow/turret_attacking_arrow)
		TIMER_COOLDOWN_START(src, COOLDOWN_XENO_TURRETS_ALERT, 20 SECONDS)
	if(hostile != last_hostile)
		set_last_hostile(hostile)
		SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_START_SHOOTING_AT)

/obj/structure/xeno/xeno_turret/attackby(obj/item/I, mob/living/user, params)
	if(I.flags_item & NOBLUDGEON || !isliving(user))
		return attack_hand(user)

	user.changeNext_move(I.attack_speed)
	user.do_attack_animation(src, used_item = I)

	var/damage = I.force
	var/multiplier = 1
	if(I.damtype == BURN) //Burn damage deals extra vs resin structures (mostly welders).
		multiplier += 1

	if(istype(I, /obj/item/tool/pickaxe/plasmacutter) && !user.do_actions)
		var/obj/item/tool/pickaxe/plasmacutter/P = I
		if(P.start_cut(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD))
			multiplier += PLASMACUTTER_RESIN_MULTIPLIER
			P.cut_apart(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD)

	damage *= max(0, multiplier)
	take_damage(damage, BRUTE, MELEE)
	playsound(src, "alien_resin_break", 25)

///Signal handler for hard del of hostile
/obj/structure/xeno/xeno_turret/proc/unset_hostile()
	SIGNAL_HANDLER
	hostile = null

///Signal handler for hard del of last_hostile
/obj/structure/xeno/xeno_turret/proc/unset_last_hostile()
	SIGNAL_HANDLER
	last_hostile = null

///Setter for hostile with hard del in mind
/obj/structure/xeno/xeno_turret/proc/set_hostile(_hostile)
	if(hostile != _hostile)
		hostile = _hostile
		RegisterSignal(hostile, COMSIG_QDELETING, PROC_REF(unset_hostile))

///Setter for last_hostile with hard del in mind
/obj/structure/xeno/xeno_turret/proc/set_last_hostile(_last_hostile)
	if(last_hostile)
		UnregisterSignal(last_hostile, COMSIG_QDELETING)
	last_hostile = _last_hostile

///Look for the closest human in range and in light of sight. If no human is in range, will look for xenos of other hives
/obj/structure/xeno/xeno_turret/proc/get_target()
	var/distance = range + 0.5 //we add 0.5 so if a potential target is at range, it is accepted by the system
	var/buffer_distance
	var/list/turf/path = list()
	for (var/atom/nearby_hostile AS in potential_hostiles)
		if(isliving(nearby_hostile))
			var/mob/living/nearby_living_hostile = nearby_hostile
			if(nearby_living_hostile.stat == DEAD)
				continue
		if(HAS_TRAIT(nearby_hostile, TRAIT_TURRET_HIDDEN))
			continue
		buffer_distance = get_dist(nearby_hostile, src)
		if (distance <= buffer_distance) //If we already found a target that's closer
			continue
		path = getline(src, nearby_hostile)
		path -= get_turf(src)
		if(!length(path)) //Can't shoot if it's on the same turf
			continue
		var/blocked = FALSE
		for(var/turf/T AS in path)
			if(IS_OPAQUE_TURF(T) || T.density && !(T.allow_pass_flags & PASS_PROJECTILE))
				blocked = TRUE
				break //LoF Broken; stop checking; we can't proceed further.

			for(var/obj/machinery/MA in T)
				if(MA.opacity || MA.density && !(MA.allow_pass_flags & PASS_PROJECTILE))
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.

			for(var/obj/structure/S in T)
				if(S.opacity || S.density && !(S.allow_pass_flags & PASS_PROJECTILE))
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.
		if(!blocked)
			distance = buffer_distance
			. = nearby_hostile

///Return TRUE if a possible target is near
/obj/structure/xeno/xeno_turret/proc/scan()
	potential_hostiles.Cut()
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(src, TURRET_SCAN_RANGE))
		if(nearby_human.stat == DEAD)
			continue
		if(nearby_human.get_xeno_hivenumber() == hivenumber)
			continue
		potential_hostiles += nearby_human
	for (var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(src, range))
		if(GLOB.hive_datums[hivenumber] == nearby_xeno.hive)
			continue
		if(nearby_xeno.stat == DEAD)
			continue
		potential_hostiles += nearby_xeno
	for(var/obj/vehicle/unmanned/vehicle AS in GLOB.unmanned_vehicles)
		if(vehicle.z == z && get_dist(vehicle, src) <= range)
			potential_hostiles += vehicle
	for(var/obj/vehicle/sealed/mecha/mech AS in GLOB.mechas_list)
		if(mech.z == z && get_dist(mech, src) <= range)
			potential_hostiles += mech

///Signal handler to make the turret shoot at its target
/obj/structure/xeno/xeno_turret/proc/shoot()
	SIGNAL_HANDLER
	if(!hostile)
		SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_STOP_SHOOTING_AT)
		firing = FALSE
		update_minimap_icon()
		return
	face_atom(hostile)
	var/obj/projectile/newshot = new(loc)
	newshot.generate_bullet(ammo)
	newshot.def_zone = pick(GLOB.base_miss_chance)
	newshot.fire_at(hostile, src, null, ammo.max_range, ammo.shell_speed)
	if(istype(ammo, /datum/ammo/xeno/hugger))
		var/datum/ammo/xeno/hugger/hugger_ammo = ammo
		newshot.color = initial(hugger_ammo.hugger_type.color)
		hugger_ammo.hivenumber = hivenumber
	firing = TRUE
	update_minimap_icon()

/obj/structure/xeno/xeno_turret/sticky
	name = "Sticky resin turret"
	icon = 'icons/Xeno/acidturret.dmi'
	icon_state = XENO_TURRET_STICKY_ICONSTATE
	desc = "A menacing looking construct of resin, it seems to be alive. It fires resin against intruders."
	light_initial_color = LIGHT_COLOR_PURPLE
	ammo = /datum/ammo/xeno/sticky/turret
	firerate = 5

/obj/structure/xeno/xeno_turret/hugger_turret
	name = "hugger turret"
	icon_state = "hugger_turret"
	desc = "A menacing looking construct of resin, it seems to be alive. It fires huggers against intruders."
	obj_integrity = 400
	max_integrity = 400
	light_initial_color = LIGHT_COLOR_BROWN
	ammo = /datum/ammo/xeno/hugger
	firerate = 5 SECONDS

/obj/structure/xeno/evotower
	name = "evolution tower"
	desc = "A sickly outcrop from the ground. It seems to ooze a strange chemical that shimmers and warps the ground around it."
	icon = 'icons/Xeno/2x2building.dmi'
	icon_state = "evotower"
	bound_width = 64
	bound_height = 64
	obj_integrity = 600
	max_integrity = 600
	xeno_structure_flags = CRITICAL_STRUCTURE
	///boost amt to be added per tower per cycle
	var/boost_amount = 0.2

/obj/structure/xeno/evotower/Initialize(mapload, _hivenumber)
	. = ..()
	GLOB.hive_datums[hivenumber].evotowers += src
	set_light(2, 2, LIGHT_COLOR_GREEN)

/obj/structure/xeno/evotower/Destroy()
	GLOB.hive_datums[hivenumber].evotowers -= src
	return ..()

/obj/structure/xeno/evotower/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(700, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(500, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(300, BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(100, BRUTE, BOMB)

/obj/structure/xeno/psychictower
	name = "Psychic Relay"
	desc = "A sickly outcrop from the ground. It seems to allow for more advanced growth of the Xenomorphs."
	icon = 'icons/Xeno/2x2building.dmi'
	icon_state = "maturitytower"
	bound_width = 64
	bound_height = 64
	obj_integrity = 400
	max_integrity = 400
	xeno_structure_flags = CRITICAL_STRUCTURE

/obj/structure/xeno/psychictower/Initialize(mapload, _hivenumber)
	. = ..()
	GLOB.hive_datums[hivenumber].psychictowers += src
	set_light(2, 2, LIGHT_COLOR_GREEN)

/obj/structure/xeno/psychictower/Destroy()
	GLOB.hive_datums[hivenumber].psychictowers -= src
	return ..()

/obj/structure/xeno/psychictower/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(700, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(500, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(300, BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(100, BRUTE, BOMB)

/obj/structure/xeno/pherotower
	name = "Pheromone tower"
	desc = "A resin formation that looks like a small pillar. A faint, weird smell can be perceived from it."
	icon = 'icons/Xeno/1x1building.dmi'
	icon_state = "recoverytower"
	bound_width = 32
	bound_height = 32
	obj_integrity = 400
	max_integrity = 400
	xeno_structure_flags = CRITICAL_STRUCTURE
	///The type of pheromone currently being emitted.
	var/datum/aura_bearer/current_aura
	///Strength of pheromones given by this tower.
	var/aura_strength = 5
	///Radius (in tiles) of the pheromones given by this tower.
	var/aura_radius = 32

/obj/structure/xeno/pherotower/Initialize(mapload, _hivenumber)
	. = ..()
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, "phero"))
	GLOB.hive_datums[hivenumber].pherotowers += src

//Pheromone towers start off with recovery.
	current_aura = SSaura.add_emitter(src, AURA_XENO_RECOVERY, aura_radius, aura_strength, -1, FACTION_XENO, hivenumber)
	playsound(src, "alien_drool", 25)
	update_icon()

/obj/structure/xeno/pherotower/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(700, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(500, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(300, BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(100, BRUTE, BOMB)

/obj/structure/xeno/pherotower/Destroy()
	GLOB.hive_datums[hivenumber].pherotowers -= src
	return ..()

// Clicking on the tower brings up a radial menu that allows you to select the type of pheromone that this tower will emit.
/obj/structure/xeno/pherotower/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	var/phero_choice = show_radial_menu(X, src, GLOB.pheromone_images_list, radius = 35, require_near = TRUE)

	if(!phero_choice)
		return

	QDEL_NULL(current_aura)
	current_aura = SSaura.add_emitter(src, phero_choice, aura_radius, aura_strength, -1, FACTION_XENO, hivenumber)
	balloon_alert(X, "[phero_choice]")
	playsound(src, "alien_drool", 25)
	update_icon()

/obj/structure/xeno/pherotower/update_icon_state()
	switch(current_aura.aura_types[1])
		if(AURA_XENO_RECOVERY)
			icon_state = "recoverytower"
			set_light(2, 2, LIGHT_COLOR_BLUE)
		if(AURA_XENO_WARDING)
			icon_state = "wardingtower"
			set_light(2, 2, LIGHT_COLOR_GREEN)
		if(AURA_XENO_FRENZY)
			icon_state = "frenzytower"
			set_light(2, 2, LIGHT_COLOR_RED)

/obj/structure/xeno/spawner
	name = "spawner"
	desc = "A slimy, oozy resin bed filled with foul-looking egg-like ...things."
	icon = 'icons/Xeno/3x3building.dmi'
	icon_state = "spawner"
	bound_width = 96
	bound_height = 96
	max_integrity = 500
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE
	xeno_structure_flags = IGNORE_WEED_REMOVAL | CRITICAL_STRUCTURE
	///For minimap icon change if silo takes damage or nearby hostile
	var/warning
	COOLDOWN_DECLARE(spawner_damage_alert_cooldown)
	COOLDOWN_DECLARE(spawner_proxy_alert_cooldown)
	var/linked_minions = list()

/obj/structure/xeno/spawner/Initialize(mapload, _hivenumber)
	. = ..()
	LAZYADDASSOC(GLOB.xeno_spawners_by_hive, hivenumber, src)
	SSspawning.registerspawner(src, INFINITY, GLOB.xeno_ai_spawnable, 0, 0, CALLBACK(src, PROC_REF(on_spawn)))
	SSspawning.spawnerdata[src].required_increment = max(45 SECONDS, 3 MINUTES - SSmonitor.maximum_connected_players_count * SPAWN_RATE_PER_PLAYER)/SSspawning.wait
	SSspawning.spawnerdata[src].max_allowed_mobs = max(2, MAX_SPAWNABLE_MOB_PER_PLAYER * SSmonitor.maximum_connected_players_count)
	for(var/turfs in RANGE_TURFS(XENO_SILO_DETECTION_RANGE, src))
		RegisterSignal(turfs, COMSIG_ATOM_ENTERED, PROC_REF(spawner_proxy_alert))
	update_minimap_icon()

/obj/structure/xeno/spawner/examine(mob/user)
	. = ..()
	var/current_integrity = (obj_integrity / max_integrity) * 100
	switch(current_integrity)
		if(0 to 20)
			. += span_warning("It's barely holding, there's leaking oozes all around, and most eggs are broken. Yet it is not inert.")
		if(20 to 40)
			. += span_warning("It looks severely damaged, its movements slow.")
		if(40 to 60)
			. += span_warning("It's quite beat up, but it seems alive.")
		if(60 to 80)
			. += span_warning("It's slightly damaged, but still seems healthy.")
		if(80 to 100)
			. += span_info("It appears in good shape, pulsating healthily.")


/obj/structure/xeno/spawner/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	spawner_damage_alert()

///Alert if spawner is receiving damage
/obj/structure/xeno/spawner/proc/spawner_damage_alert()
	if(!COOLDOWN_CHECK(src, spawner_damage_alert_cooldown))
		warning = FALSE
		return
	warning = TRUE
	update_minimap_icon()
	GLOB.hive_datums[hivenumber].xeno_message("Our [name] at [AREACOORD_NO_Z(src)] is under attack! It has [obj_integrity]/[max_integrity] Health remaining.", "xenoannounce", 5, FALSE, src, 'sound/voice/alien_help1.ogg',FALSE, null, /atom/movable/screen/arrow/silo_damaged_arrow)
	COOLDOWN_START(src, spawner_damage_alert_cooldown, XENO_SILO_HEALTH_ALERT_COOLDOWN) //set the cooldown.
	addtimer(CALLBACK(src, PROC_REF(clear_warning)), XENO_SILO_DETECTION_COOLDOWN) //clear warning

///Alerts the Hive when hostiles get too close to their spawner
/obj/structure/xeno/spawner/proc/spawner_proxy_alert(datum/source, atom/movable/hostile, direction)
	SIGNAL_HANDLER

	if(!COOLDOWN_CHECK(src, spawner_proxy_alert_cooldown)) //Proxy alert triggered too recently; abort
		warning = FALSE
		return

	if(!isliving(hostile))
		return

	var/mob/living/living_triggerer = hostile
	if(living_triggerer.stat == DEAD) //We don't care about the dead
		return

	if(isxeno(hostile))
		var/mob/living/carbon/xenomorph/X = hostile
		if(X.hivenumber == hivenumber) //Trigger proxy alert only for hostile xenos
			return

	warning = TRUE
	update_minimap_icon()
	GLOB.hive_datums[hivenumber].xeno_message("Our [name] has detected a nearby hostile [hostile] at [get_area(hostile)] (X: [hostile.x], Y: [hostile.y]).", "xenoannounce", 5, FALSE, hostile, 'sound/voice/alien_help1.ogg', FALSE, null, /atom/movable/screen/arrow/leader_tracker_arrow)
	COOLDOWN_START(src, spawner_proxy_alert_cooldown, XENO_SILO_DETECTION_COOLDOWN) //set the cooldown.
	addtimer(CALLBACK(src, PROC_REF(clear_warning)), XENO_SILO_DETECTION_COOLDOWN) //clear warning

///Clears the warning for minimap if its warning for hostiles
/obj/structure/xeno/spawner/proc/clear_warning()
	warning = FALSE
	update_minimap_icon()

/obj/structure/xeno/spawner/Destroy()
	GLOB.xeno_spawners_by_hive[hivenumber] -= src
	return ..()

///Change minimap icon if spawner is under attack or not
/obj/structure/xeno/spawner/proc/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, "spawner[warning ? "_warn" : "_passive"]"))

/obj/structure/xeno/spawner/proc/on_spawn(list/squad)
	if(!isxeno(squad[length(squad)]))
		CRASH("Xeno spawner somehow tried to spawn a non xeno (tried to spawn [squad[length(squad)]])")
	var/mob/living/carbon/xenomorph/X = squad[length(squad)]
	X.transfer_to_hive(hivenumber)
	linked_minions = squad
	if(hivenumber == XENO_HIVE_FALLEN) //snowflake so valhalla isnt filled with minions after you're done
		RegisterSignal(src, COMSIG_QDELETING, PROC_REF(kill_linked_minions))

/obj/structure/xeno/spawner/proc/kill_linked_minions()
	for(var/mob/living/carbon/xenomorph/linked in linked_minions)
		linked.death(TRUE)
	UnregisterSignal(src, COMSIG_QDELETING)

///Those structures need time to grow and are supposed to be extremely weak healh-wise
/obj/structure/xeno/plant
	name = "Xeno Plant"
	max_integrity = 5
	icon = 'icons/Xeno/plants.dmi'
	interaction_flags = INTERACT_CHECK_INCAPACITATED
	///The plant's icon once it's fully grown
	var/mature_icon_state
	///Is the plant ready to be used ?
	var/mature = FALSE
	///How long does it take for the plant to be useable
	var/maturation_time = 2 MINUTES

/obj/structure/xeno/plant/Initialize(mapload, _hivenumber)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(on_mature)), maturation_time)

/obj/structure/xeno/plant/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(!mature && isxeno(user))
		balloon_alert(user, "Not fully grown")
		return FALSE

/obj/structure/xeno/plant/update_icon_state()
	. = ..()
	icon_state = (mature) ? mature_icon_state : initial(icon_state)

///Called whenever someone uses the plant, xeno or marine
/obj/structure/xeno/plant/proc/on_use(mob/user)
	mature = FALSE
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(on_mature)), maturation_time)
	return TRUE

///Called when the plant reaches maturity
/obj/structure/xeno/plant/proc/on_mature(mob/user)
	playsound(src, "alien_resin_build", 25)
	mature = TRUE
	update_icon()

/obj/structure/xeno/plant/attack_hand(mob/living/user)
	if(!can_interact(user))
		return ..()
	return on_use(user)

/obj/structure/xeno/plant/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if((X.status_flags & INCORPOREAL))
		return FALSE

	if(X.a_intent == INTENT_HARM && isxenodrone(X))
		balloon_alert(X, "Uprooted the plant")
		X.do_attack_animation(src)
		deconstruct(FALSE)
		return FALSE
	if(can_interact(X))
		return on_use(X)
	return TRUE

/obj/structure/xeno/plant/heal_fruit
	name = "life fruit"
	desc = "It would almost be appetizing wasn't it for the green colour and the shifting fluids inside..."
	icon_state = "heal_fruit_immature"
	mature_icon_state = "heal_fruit"
	///Minimum amount of health recovered
	var/healing_amount_min = 125
	///Maximum amount of health recovered, depends on the xeno's max health
	var/healing_amount_max_health_scaling = 0.5

/obj/structure/xeno/plant/heal_fruit/on_use(mob/user)
	balloon_alert(user, "Consuming...")
	if(!do_after(user, 2 SECONDS, IGNORE_HELD_ITEM, src))
		return FALSE
	if(!isxeno(user))
		var/datum/effect_system/smoke_spread/xeno/acid/plant_explosion = new(get_turf(src))
		plant_explosion.set_up(3,src)
		plant_explosion.start()
		visible_message(span_danger("[src] bursts, releasing toxic gas!"))
		qdel(src)
		return TRUE

	var/mob/living/carbon/xenomorph/X = user
	var/heal_amount = max(healing_amount_min, healing_amount_max_health_scaling * X.xeno_caste.max_health)
	HEAL_XENO_DAMAGE(X, heal_amount, FALSE)
	playsound(user, "alien_drool", 25)
	balloon_alert(X, "Health restored")
	to_chat(X, span_xenowarning("We feel a sudden soothing chill as [src] tends to our wounds."))

	return ..()

/obj/structure/xeno/plant/armor_fruit
	name = "hard fruit"
	desc = "The contents of this fruit are protected by a tough outer shell."
	icon_state = "armor_fruit_immature"
	mature_icon_state = "armor_fruit"
	///How much total sunder should we remove
	var/sunder_removal = 30

/obj/structure/xeno/plant/armor_fruit/on_use(mob/user)
	balloon_alert(user, "Consuming...")
	if(!do_after(user, 2 SECONDS, IGNORE_HELD_ITEM, src))
		return FALSE
	if(!isxeno(user))
		var/turf/far_away_lands = get_turf(user)
		for(var/x in 1 to 20)
			var/turf/next_turf = get_step(far_away_lands, REVERSE_DIR(user.dir))
			if(!next_turf)
				break
			far_away_lands = next_turf

		user.throw_at(far_away_lands, 20, spin = TRUE)
		to_chat(user, span_warning("[src] bursts, releasing a strong gust of pressurised gas!"))
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.adjust_stagger(3 SECONDS)
			H.apply_damage(30, BRUTE, "chest", BOMB)
		qdel(src)
		return TRUE

	balloon_alert(user, "Armor restored")
	to_chat(user, span_xenowarning("We shed our shattered scales as new ones grow to replace them!"))
	var/mob/living/carbon/xenomorph/X = user
	X.adjust_sunder(-sunder_removal)
	playsound(user, "alien_drool", 25)
	return ..()

/obj/structure/xeno/plant/plasma_fruit
	name = "power fruit"
	desc = "A cyan fruit, beating like a creature's heart"
	icon_state = "plasma_fruit_immature"
	mature_icon_state = "plasma_fruit"
	///How much bonus plasma should we restore during the duration, 1 being 100% from base regen
	var/bonus_regen = 1
	///How long should the buff last
	var/duration = 1 MINUTES

/obj/structure/xeno/plant/plasma_fruit/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(!isxeno(user))
		return
	var/mob/living/carbon/xenomorph/X = user
	if(X.has_status_effect(STATUS_EFFECT_PLASMA_SURGE))
		balloon_alert(X, "Already increased plasma regen")
		return FALSE

/obj/structure/xeno/plant/plasma_fruit/on_use(mob/user)
	balloon_alert(user, "Consuming...")
	if(!do_after(user, 2 SECONDS, IGNORE_HELD_ITEM, src))
		return FALSE
	if(!isxeno(user))
		visible_message(span_warning("[src] releases a sticky substance before spontaneously bursting into flames!"))
		flame_radius(3, get_turf(src), colour = "green")
		qdel(src)
		return TRUE

	var/mob/living/carbon/xenomorph/X = user
	if(!(X.xeno_caste.can_flags & CASTE_CAN_BE_GIVEN_PLASMA))
		to_chat(X, span_xenowarning("But our body rejects the fruit, we do not share the same plasma type!"))
		return FALSE
	X.apply_status_effect(/datum/status_effect/plasma_surge, X.xeno_caste.plasma_max, bonus_regen, duration)
	balloon_alert(X, "Plasma restored")
	to_chat(X, span_xenowarning("[src] Restores our plasma reserves, our organism is on overdrive!"))
	playsound(user, "alien_drool", 25)
	return ..()


/obj/structure/xeno/plant/stealth_plant
	name = "night shade"
	desc = "A beautiful flower, what purpose it could serve to the alien hive is beyond you however..."
	icon_state = "stealth_plant_immature"
	mature_icon_state = "stealth_plant"
	maturation_time = 4 MINUTES
	///The radius of the passive structure camouflage, requires line of sight
	var/camouflage_range = 7
	///The range of the active stealth ability, does not require line of sight
	var/active_camouflage_pulse_range = 10
	///How long should veil last
	var/active_camouflage_duration = 20 SECONDS
	///How long until the plant can be activated again
	var/cooldown = 2 MINUTES
	///Is the active ability veil on cooldown ?
	var/on_cooldown = FALSE
	///The list of passively camouflaged structures
	var/list/obj/structure/xeno/camouflaged_structures = list()
	////The list of actively camouflaged xenos by veil
	var/list/mob/living/carbon/xenomorph/camouflaged_xenos = list()

/obj/structure/xeno/plant/stealth_plant/on_mature(mob/user)
	. = ..()
	START_PROCESSING(SSslowprocess, src)

/obj/structure/xeno/plant/stealth_plant/Destroy()
	for(var/obj/structure/xeno/xeno_struct AS in camouflaged_structures)
		xeno_struct.alpha = initial(xeno_struct.alpha)
	unveil()
	STOP_PROCESSING(SSslowprocess, src)
	return ..()

/obj/structure/xeno/plant/stealth_plant/process()
	for(var/turf/tile AS in RANGE_TURFS(camouflage_range, loc))
		for(var/obj/structure/xeno/xeno_struct in tile)
			if(istype(xeno_struct, /obj/structure/xeno/plant) || !line_of_sight(src, xeno_struct)) //We don't hide plants
				continue
			camouflaged_structures.Add(xeno_struct)
			xeno_struct.alpha = STEALTH_PLANT_PASSIVE_CAMOUFLAGE_ALPHA

/obj/structure/xeno/plant/stealth_plant/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(ishuman(user))
		balloon_alert(user, "Nothing happens")
		to_chat(user, span_notice("You caress [src]'s petals, nothing happens."))
		return FALSE
	if(on_cooldown)
		balloon_alert(user, "Not ready yet")
		to_chat(user, span_xenowarning("[src] soft light shimmers, we should give it more time to recover!"))
		return FALSE

/obj/structure/xeno/plant/stealth_plant/on_use(mob/user)
	balloon_alert(user, "Shaking...")
	if(!do_after(user, 2 SECONDS, IGNORE_HELD_ITEM, src))
		return FALSE
	visible_message(span_danger("[src] releases a burst of glowing pollen!"))
	veil()
	return TRUE

///Hides all nearby xenos
/obj/structure/xeno/plant/stealth_plant/proc/veil()
	for(var/turf/tile in RANGE_TURFS(camouflage_range, loc))
		for(var/mob/living/carbon/xenomorph/X in tile)
			if(X.stat == DEAD || isxenohunter(X) || X.alpha != 255) //We don't mess with xenos capable of going stealth by themselves
				continue
			X.alpha = HUNTER_STEALTH_RUN_ALPHA
			new /obj/effect/temp_visual/alien_fruit_eaten(get_turf(X))
			balloon_alert(X, "We now blend in")
			to_chat(X, span_xenowarning("The pollen from [src] reacts with our scales, we are blending with our surroundings!"))
			camouflaged_xenos.Add(X)
	on_cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(unveil)), active_camouflage_duration)
	addtimer(CALLBACK(src, PROC_REF(ready)), cooldown)

///Called when veil() can be used once again
/obj/structure/xeno/plant/stealth_plant/proc/ready()
	visible_message(span_danger("[src] petals shift in hue, it is ready to release more pollen."))
	on_cooldown = FALSE

///Reveals all xenos hidden by veil()
/obj/structure/xeno/plant/stealth_plant/proc/unveil()
	for(var/mob/living/carbon/xenomorph/X AS in camouflaged_xenos)
		X.alpha = initial(X.alpha)
		balloon_alert(X, "Effect wears off")
		to_chat(X, span_xenowarning("The effect of [src] wears off!"))
