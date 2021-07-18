/obj/structure/xeno
	///Bitflags specific to xeno structures
	var/xeno_structure_flags

/obj/structure/xeno/Initialize()
	. = ..()
	if(!(xeno_structure_flags & IGNORE_WEED_REMOVAL))
		RegisterSignal(loc, COMSIG_TURF_WEED_REMOVED, .proc/weed_removed)

/// Destroy the xeno structure when the weed it was on is destroyed
/obj/structure/xeno/proc/weed_removed()
	SIGNAL_HANDLER
	obj_destruction(damage_flag = "melee")

//Carrier trap
/obj/structure/xeno/trap
	desc = "It looks like a hiding hole."
	name = "resin hole"
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "trap0"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 5
	layer = RESIN_STRUCTURE_LAYER
	destroy_sound = "alien_resin_break"
	xeno_structure_flags = IGNORE_WEED_REMOVAL
	///The hugger inside our trap
	var/obj/item/clothing/mask/facehugger/hugger = null

/obj/structure/xeno/trap/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_SHUTTLE_CRUSH, .proc/shuttle_crush)
	RegisterSignal(src, COMSIG_MOVABLE_CROSSED_BY, .proc/trigger_hugger_trap) //Set up the trap signal on our turf

/obj/structure/xeno/trap/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(400)
		if(EXPLODE_HEAVY)
			take_damage(200)
		if(EXPLODE_LIGHT)
			take_damage(100)

/obj/structure/xeno/trap/obj_destruction(damage_amount, damage_type, damage_flag)
	if((damage_amount || damage_flag) && hugger && loc)
		drop_hugger()

	return ..()

///Ensures that no huggies will be released when the trap is crushed by a shuttle; no more trapping shuttles with huggies
/obj/structure/xeno/trap/proc/shuttle_crush()
	SIGNAL_HANDLER
	qdel(src)

/obj/structure/xeno/trap/examine(mob/user)
	. = ..()
	if(!isxeno(user))
		return
	to_chat(user, "A hole for a little one to hide in ambush.")
	if(hugger)
		to_chat(user, "There's a little one inside.")
		return
	to_chat(user, "It's empty.")

/obj/structure/xeno/trap/flamer_fire_act()
	if(!hugger)
		return
	hugger.forceMove(loc)
	hugger.kill_hugger()
	hugger = null
	icon_state = "trap0"

/obj/structure/xeno/trap/fire_act()
	if(!hugger)
		return
	hugger.forceMove(loc)
	hugger.kill_hugger()
	hugger = null
	icon_state = "trap0"

///Triggers the hugger trap
/obj/structure/xeno/trap/proc/trigger_hugger_trap(datum/source, atom/movable/AM, oldloc)
	SIGNAL_HANDLER
	if(!iscarbon(AM) || !hugger)
		return
	var/mob/living/carbon/C = AM
	if(!C.can_be_facehugged(hugger))
		return
	playsound(src, "alien_resin_break", 25)
	C.visible_message("<span class='warning'>[C] trips on [src]!</span>",\
						"<span class='danger'>You trip on [src]!</span>")
	C.Paralyze(4 SECONDS)
	xeno_message("A facehugger trap at [AREACOORD_NO_Z(src)] has been triggered!", "xenoannounce", 5, hugger.hivenumber,  FALSE, get_turf(src), 'sound/voice/alien_talk2.ogg', FALSE, null, /obj/screen/arrow/attack_order_arrow, COLOR_ORANGE, TRUE) //Follow the trend of hive wide alerts for important events
	drop_hugger()

/// Move the hugger out of the trap
/obj/structure/xeno/trap/proc/drop_hugger()
	hugger.forceMove(loc)
	hugger.go_active(TRUE, TRUE) //Removes stasis
	icon_state = "trap0"
	visible_message("<span class='warning'>[hugger] gets out of [src]!</span>")
	hugger = null

/obj/structure/xeno/trap/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if(X.a_intent == INTENT_HARM)
		return ..()
	if(!(X.xeno_caste.caste_flags & CASTE_CAN_HOLD_FACEHUGGERS))
		return
	if(!hugger)
		to_chat(X, "<span class='warning'>[src] is empty.</span>")
		return
	icon_state = "trap0"
	X.put_in_active_hand(hugger)
	hugger.go_active(TRUE)
	hugger = null
	to_chat(X, "<span class='xenonotice'>We remove the facehugger from [src].</span>")

/obj/structure/xeno/trap/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!istype(I, /obj/item/clothing/mask/facehugger) || !isxeno(user))
		return
	var/obj/item/clothing/mask/facehugger/FH = I
	if(hugger)
		to_chat(user, "<span class='warning'>There is already a facehugger in [src].</span>")
		return

	if(FH.stat == DEAD)
		to_chat(user, "<span class='warning'>You can't put a dead facehugger in [src].</span>")
		return

	user.transferItemToLoc(FH, src)
	FH.go_idle(TRUE)
	hugger = FH
	icon_state = "trap1"
	to_chat(user, "<span class='xenonotice'>You place a facehugger in [src].</span>")

/*
TUNNEL
*/
/obj/structure/xeno/tunnel
	name = "tunnel"
	desc = "A tunnel entrance. Looks like it was dug by some kind of clawed beast."
	icon = 'icons/Xeno/effects.dmi'
	icon_state = "hole"

	density = FALSE
	opacity = FALSE
	anchored = TRUE
	resistance_flags = UNACIDABLE
	layer = RESIN_STRUCTURE_LAYER

	max_integrity = 140

	hud_possible = list(XENO_TACTICAL_HUD)
	xeno_structure_flags = IGNORE_WEED_REMOVAL
	///Description added by the hivelord.
	var/tunnel_desc = ""
	///What hivelord created that tunnel. Can be null
	var/mob/living/carbon/xenomorph/hivelord/creator = null
	///Hive number of the structure; defaults to standard.
	var/hivenumber = XENO_HIVE_NORMAL

/obj/structure/xeno/tunnel/Initialize(mapload)
	. = ..()
	GLOB.xeno_tunnels += src
	prepare_huds()
	for(var/datum/atom_hud/xeno_tactical/xeno_tac_hud in GLOB.huds) //Add to the xeno tachud
		xeno_tac_hud.add_to_hud(src)
	hud_set_xeno_tunnel()
	SSminimaps.add_marker(src, src.z, MINIMAP_FLAG_XENO, "xenotunnel")

/obj/structure/xeno/tunnel/Destroy()
	var/turf/drop_loc = get_turf(src)
	for(var/atom/movable/thing AS in contents) //Empty the tunnel of contents
		thing.forceMove(drop_loc)

	if(!QDELETED(creator))
		to_chat(creator, "<span class='xenoannounce'>You sense your [name] at [tunnel_desc] has been destroyed!</span>") //Alert creator

	xeno_message("Hive tunnel [name] at [tunnel_desc] has been destroyed!", "xenoannounce", 5, hivenumber) //Also alert hive because tunnels matter.

	GLOB.xeno_tunnels -= src
	if(creator)
		creator.tunnels -= src

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
		to_chat(user, "<span class='info'>The Hivelord scent reads: \'[tunnel_desc]\'</span>")

/obj/structure/xeno/tunnel/deconstruct(disassembled = TRUE)
	visible_message("<span class='danger'>[src] suddenly collapses!</span>")
	return ..()

/obj/structure/xeno/tunnel/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(210)
		if(EXPLODE_HEAVY)
			take_damage(140)
		if(EXPLODE_LIGHT)
			take_damage(70)

/obj/structure/xeno/tunnel/attackby(obj/item/I, mob/user, params)
	if(!isxeno(user))
		return ..()
	attack_alien(user)

/obj/structure/xeno/tunnel/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(!istype(X) || X.stat || X.lying_angle || X.status_flags & INCORPOREAL)
		return

	if(X.a_intent == INTENT_HARM && X == creator)
		to_chat(X, "<span class='xenowarning'>We begin filling in our tunnel...</span>")
		if(do_after(X, HIVELORD_TUNNEL_DISMANTLE_TIME, FALSE, src, BUSY_ICON_BUILD))
			deconstruct(FALSE)
		return

	//Prevents using tunnels by the queen to bypass the fog.
	if(SSticker?.mode && SSticker.mode.flags_round_type & MODE_FOG_ACTIVATED)
		if(!X.hive.living_xeno_ruler)
			to_chat(X, "<span class='xenowarning'>There is no ruler. We must choose one first.</span>")
			return FALSE
		else if(isxenoqueen(X))
			to_chat(X, "<span class='xenowarning'>There is no reason to leave the safety of the caves yet.</span>")
			return FALSE

	if(X.anchored)
		to_chat(X, "<span class='xenowarning'>We can't climb through a tunnel while immobile.</span>")
		return FALSE

	if(length(GLOB.xeno_tunnels) < 2)
		to_chat(X, "<span class='warning'>There are no other tunnels in the network!</span>")
		return FALSE

	pick_a_tunnel(X)

/obj/structure/xeno/tunnel/attack_larva(mob/living/carbon/xenomorph/larva/L) //So larvas can actually use tunnels
	attack_alien(L)

///Here we pick a tunnel to go to, then travel to that tunnel and peep out, confirming whether or not we want to emerge or go to another tunnel.
/obj/structure/xeno/tunnel/proc/pick_a_tunnel(mob/living/carbon/xenomorph/M)
	var/obj/structure/xeno/tunnel/targettunnel = tgui_input_list(M, "Choose a tunnel to crawl to", "Tunnel", GLOB.xeno_tunnels)
	if(QDELETED(src)) //Make sure we still exist in the event the player keeps the interface open
		return
	if(!M.Adjacent(src) && M.loc != src) //Make sure we're close enough to our tunnel; either adjacent to or in one
		return
	if(QDELETED(targettunnel)) //Make sure our target destination still exists in the event the player keeps the interface open
		to_chat(M, "<span class='warning'>That tunnel no longer exists!</span>")
		if(M.loc == src) //If we're in the tunnel and cancelling out, spit us out.
			M.forceMove(loc)
		return
	if(targettunnel == src)
		to_chat(M, "<span class='warning'>We're already here!</span>")
		if(M.loc == src) //If we're in the tunnel and cancelling out, spit us out.
			M.forceMove(loc)
		return
	if(targettunnel.z != z)
		to_chat(M, "<span class='warning'>That tunnel isn't connected to this one!</span>")
		if(M.loc == src) //If we're in the tunnel and cancelling out, spit us out.
			M.forceMove(loc)
		return
	var/distance = get_dist(get_turf(src), get_turf(targettunnel))
	var/tunnel_time = clamp(distance, HIVELORD_TUNNEL_MIN_TRAVEL_TIME, HIVELORD_TUNNEL_SMALL_MAX_TRAVEL_TIME)

	if(M.mob_size == MOB_SIZE_BIG) //Big xenos take longer
		tunnel_time = clamp(distance * 1.5, HIVELORD_TUNNEL_MIN_TRAVEL_TIME, HIVELORD_TUNNEL_LARGE_MAX_TRAVEL_TIME)
		M.visible_message("<span class='xenonotice'>[M] begins heaving their huge bulk down into \the [src].</span>", \
		"<span class='xenonotice'>We begin heaving our monstrous bulk into \the [src] to <b>[targettunnel.tunnel_desc]</b>.</span>")
	else
		M.visible_message("<span class='xenonotice'>\The [M] begins crawling down into \the [src].</span>", \
		"<span class='xenonotice'>We begin crawling down into \the [src] to <b>[targettunnel.tunnel_desc]</b>.</span>")

	if(isxenolarva(M)) //Larva can zip through near-instantly, they are wormlike after all
		tunnel_time = 5

	if(!do_after(M, tunnel_time, FALSE, src, BUSY_ICON_GENERIC))
		to_chat(M, "<span class='warning'>Our crawling was interrupted!</span>")
		return
	if(!targettunnel || !isturf(targettunnel.loc)) //Make sure the end tunnel is still there
		to_chat(M, "<span class='warning'>\The [src] ended unexpectedly, so we return back up.</span>")
		return
	M.forceMove(targettunnel)
	var/double_check = tgui_alert(M, "Emerge here?", "Tunnel: [targettunnel]", list("Yes","Pick another tunnel"))
	if(M.loc != targettunnel) //double check that we're still in the tunnel in the event it gets destroyed while we still have the interface open
		return
	if(double_check == "Pick another tunnel")
		return targettunnel.pick_a_tunnel(M)
	M.forceMove(targettunnel.loc)
	M.visible_message("<span class='xenonotice'>\The [M] pops out of \the [src].</span>", \
	"<span class='xenonotice'>We pop out through the other side!</span>")

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
	icon_state = "fullwell"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 5
	layer = RESIN_STRUCTURE_LAYER

	hit_sound = "alien_resin_move"
	destroy_sound = "alien_resin_move"
	///How many charges of acid this well contains
	var/charges = 1
	///If a xeno is charging this well
	var/charging = FALSE
	///What xeno created this well
	var/mob/living/carbon/xenomorph/creator = null

/obj/structure/xeno/acidwell/Initialize()
	. = ..()
	update_icon()

/obj/structure/xeno/acidwell/Destroy()
	creator = null
	return ..()

///Ensures that no acid gas will be released when the well is crushed by a shuttle
/obj/structure/xeno/acidwell/proc/shuttle_crush()
	SIGNAL_HANDLER
	qdel(src)


/obj/structure/xeno/acidwell/obj_destruction(damage_amount, damage_type, damage_flag)
	if(!QDELETED(creator) && creator.stat == CONSCIOUS && creator.z == z)
		var/area/A = get_area(src)
		if(A)
			to_chat(creator, "<span class='xenoannounce'>You sense your acid well at [A.name] has been destroyed!</span>")

	if(damage_amount || damage_flag) //Spawn the gas only if we actually get destroyed by damage
		var/datum/effect_system/smoke_spread/xeno/acid/A = new(get_turf(src))
		A.set_up(clamp(CEILING(charges*0.5, 1),0,3),src) //smoke scales with charges
		A.start()
	return ..()

/obj/structure/xeno/acidwell/examine(mob/user)
	..()
	if(!isxeno(user) && !isobserver(user))
		return
	to_chat(user, "<span class='xenonotice'>An acid well made by [creator]. It currently has <b>[charges]/[XENO_ACID_WELL_MAX_CHARGES] charges</b>.</span>")

/obj/structure/xeno/acidwell/deconstruct(disassembled = TRUE)
	visible_message("<span class='danger'>[src] suddenly collapses!</span>")
	return ..()

/obj/structure/xeno/acidwell/update_icon()
	. = ..()
	icon_state = "well[charges]"
	set_light(charges , charges / 2, LIGHT_COLOR_GREEN)

/obj/structure/xeno/acidwell/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(210)
		if(EXPLODE_HEAVY)
			take_damage(140)
		if(EXPLODE_LIGHT)
			take_damage(70)

/obj/structure/xeno/acidwell/flamer_fire_act() //Removes a charge of acid, but fire is extinguished
	acid_well_fire_interaction()

/obj/structure/xeno/acidwell/fire_act() //Removes a charge of acid, but fire is extinguished
	acid_well_fire_interaction()

///Handles fire based interactions with the acid well. Depletes 1 charge if there are any to extinguish all fires in the turf while producing acid smoke.
/obj/structure/xeno/acidwell/proc/acid_well_fire_interaction()
	if(!charges)
		take_damage(50, BURN, "fire")
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
		to_chat(X, "<span class='xenodanger'>We begin removing \the [src]...</span>")
		if(!do_after(X, XENO_ACID_WELL_FILL_TIME, FALSE, src, BUSY_ICON_HOSTILE))
			to_chat(X, "<span class='xenodanger'>We stop removing \the [src]...</span>")
			return
		playsound(src, "alien_resin_break", 25)
		deconstruct(TRUE, X)
		return

	if(charges >= 5)
		to_chat(X, "<span class='xenodanger'>[src] is already full!</span>")
		return
	if(charging)
		to_chat(X, "<span class='xenodanger'>[src] is already being filled!</span>")
		return

	if(X.plasma_stored < XENO_ACID_WELL_FILL_COST) //You need to have enough plasma to attempt to fill the well
		to_chat(X, "<span class='xenodanger'>We don't have enough plasma to fill [src]! We need <b>[XENO_ACID_WELL_FILL_COST - X.plasma_stored]</b> more plasma!</span>")
		return

	charging = TRUE
	to_chat(X, "<span class='xenodanger'>We begin refilling [src]...</span>")
	if(!do_after(X, XENO_ACID_WELL_FILL_TIME, FALSE, src, BUSY_ICON_BUILD))
		charging = FALSE
		to_chat(X, "<span class='xenodanger'>We abort refilling [src]!</span>")
		return

	if(X.plasma_stored < XENO_ACID_WELL_FILL_COST)
		charging = FALSE
		to_chat(X, "<span class='xenodanger'>We don't have enough plasma to fill [src]! We need <b>[XENO_ACID_WELL_FILL_COST - X.plasma_stored]</b> more plasma!</span>")
		return

	X.plasma_stored -= XENO_ACID_WELL_FILL_COST
	charges++
	charging = FALSE
	update_icon()
	to_chat(X,"<span class='xenonotice'>We add acid to [src]. It is currently has <b>[charges] / [XENO_ACID_WELL_MAX_CHARGES] charges</b>.</span>")

/obj/structure/xeno/acidwell/Crossed(atom/A)
	. = ..()
	if(CHECK_MULTIPLE_BITFIELDS(A.flags_pass, HOVERING))
		return
	if(iscarbon(A))
		HasProximity(A)

/obj/structure/xeno/acidwell/HasProximity(atom/movable/AM)
	if(!isliving(AM))
		return
	var/mob/living/stepper = AM
	if(stepper.stat == DEAD)
		return
	if(!charges)
		return

	var/datum/effect_system/smoke_spread/xeno/acid/acid_smoke

	if(isxeno(stepper))
		if(!(stepper.on_fire))
			return
		acid_smoke = new(get_turf(stepper)) //spawn acid smoke when charges are actually used
		acid_smoke.set_up(0, src) //acid smoke in the immediate vicinity
		acid_smoke.start()
		stepper.ExtinguishMob()
		charges--
		update_icon()
		return

	stepper.next_move_slowdown += charges * 2 //Acid spray has slow down so this should too; scales with charges, Min 2 slowdown, Max 10
	stepper.apply_damage(charges * 10, BURN, BODY_ZONE_PRECISE_L_FOOT, stepper.run_armor_check(BODY_ZONE_PRECISE_L_FOOT, "acid") * 0.66) //33% armor pen
	stepper.apply_damage(charges * 10, BURN, BODY_ZONE_PRECISE_R_FOOT, stepper.run_armor_check(BODY_ZONE_PRECISE_R_FOOT, "acid") * 0.66) //33% armor pen
	stepper.visible_message("<span class='danger'>[stepper] is immersed in [src]'s acid!</span>", \
	"<span class='danger'>We are immersed in [src]'s acid!</span>", null, 5)
	playsound(stepper, "sound/bullets/acid_impact1.ogg", 10 * charges)
	new /obj/effect/temp_visual/acid_bath(get_turf(stepper))
	acid_smoke = new(get_turf(stepper)) //spawn acid smoke when charges are actually used
	acid_smoke.set_up(0, src) //acid smoke in the immediate vicinity
	acid_smoke.start()
	charges = 0
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

/obj/structure/xeno/resin_jelly_pod/Initialize()
	. = ..()
	add_overlay(image(icon, "resinpod_inside", layer + 0.01, dir))
	START_PROCESSING(SSslowprocess, src)

/obj/structure/xeno/resin_jelly_pod/Destroy()
	STOP_PROCESSING(SSslowprocess, src)
	return ..()

/obj/structure/xeno/resin_jelly_pod/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(210)
		if(EXPLODE_HEAVY)
			take_damage(140)
		if(EXPLODE_LIGHT)
			take_damage(70)

/obj/structure/xeno/resin_jelly_pod/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(isxeno(user))
		to_chat(user, "It has [chargesleft] jelly globules remaining[datum_flags & DF_ISPROCESSING ? ", and will create a new jelly in [(recharge_rate-nextjelly)*5] seconds": " and seems latent"].")

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

	if(X.a_intent == INTENT_HARM && isxenohivelord(X))
		to_chat(X, "<span class='xenowarning'>We begin tearing at the [src]...</span>")
		if(do_after(X, HIVELORD_TUNNEL_DISMANTLE_TIME, FALSE, src, BUSY_ICON_BUILD))
			deconstruct(FALSE)
		return

	if(!chargesleft)
		to_chat(X, "<span class='xenonotice'>We reach into \the [src], but only find dregs of resin. We should wait some more.</span>")
		return
	to_chat(X, "<span class='xenonotice'>We retrieve a resin jelly from \the [src].</span>")
	new /obj/item/resin_jelly(loc)
	chargesleft--
	if(!(datum_flags & DF_ISPROCESSING) && (chargesleft < maxcharges))
		START_PROCESSING(SSslowprocess, src)

/obj/structure/xeno/resin
	hit_sound = "alien_resin_break"
	layer = RESIN_STRUCTURE_LAYER
	resistance_flags = UNACIDABLE


/obj/structure/xeno/resin/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(210)
		if(EXPLODE_HEAVY)
			take_damage(140)
		if(EXPLODE_LIGHT)
			take_damage(70)

/obj/structure/xeno/resin/attack_hand(mob/living/user)
	to_chat(user, "<span class='warning'>You scrape ineffectively at \the [src].</span>")
	return TRUE

/obj/structure/xeno/resin/flamer_fire_act()
	take_damage(10, BURN, "fire")

/obj/structure/xeno/resin/fire_act()
	take_damage(10, BURN, "fire")


/obj/structure/xeno/resin/silo
	name = "resin silo"
	icon = 'icons/Xeno/resin_silo.dmi'
	icon_state = "weed_silo"
	desc = "A slimy, oozy resin bed filled with foul-looking egg-like ...things."
	bound_width = 96
	bound_height = 96
	max_integrity = 1000
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE
	xeno_structure_flags = IGNORE_WEED_REMOVAL
	///How many larva points one silo produce in one minute
	var/larva_spawn_rate = 0.5
	var/turf/center_turf
	var/datum/hive_status/associated_hive
	var/silo_area
	var/number_silo
	COOLDOWN_DECLARE(silo_damage_alert_cooldown)
	COOLDOWN_DECLARE(silo_proxy_alert_cooldown)

/obj/structure/xeno/resin/silo/Initialize()
	. = ..()
	var/static/number = 1
	name = "[name] [number]"
	number_silo = number
	number++
	GLOB.xeno_resin_silos += src
	center_turf = get_step(src, NORTHEAST)
	if(!istype(center_turf))
		center_turf = loc

	if(SSticker.mode?.flags_round_type & MODE_SILO_RESPAWN)
		for(var/turfs in RANGE_TURFS(XENO_SILO_DETECTION_RANGE, src))
			RegisterSignal(turfs, COMSIG_ATOM_ENTERED, .proc/resin_silo_proxy_alert)

	SSminimaps.add_marker(src, z, hud_flags = MINIMAP_FLAG_XENO, iconstate = "silo")
	return INITIALIZE_HINT_LATELOAD


/obj/structure/xeno/resin/silo/LateInitialize()
	. = ..()
	if(!locate(/obj/effect/alien/weeds) in center_turf)
		new /obj/effect/alien/weeds/node(center_turf)
	associated_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(associated_hive)
		RegisterSignal(associated_hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK), .proc/is_burrowed_larva_host)
		if(length(GLOB.xeno_resin_silos) == 1)
			associated_hive.give_larva_to_next_in_queue()
		associated_hive.handle_silo_death_timer()
	silo_area = get_area(src)
	var/turf/tunnel_turf = get_step(center_turf, NORTH)
	if(tunnel_turf.can_dig_xeno_tunnel())
		var/obj/structure/xeno/tunnel/newt = new(tunnel_turf)
		newt.tunnel_desc = "[AREACOORD_NO_Z(newt)]"
		newt.name += " [name]"

/obj/structure/xeno/resin/silo/obj_destruction(damage_amount, damage_type, damage_flag)
	if(associated_hive)
		UnregisterSignal(associated_hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK))
		associated_hive.xeno_message("A resin silo has been destroyed at [AREACOORD_NO_Z(src)]!", "xenoannounce", 5, FALSE,src.loc, 'sound/voice/alien_help2.ogg',FALSE , null, /obj/screen/arrow/silo_damaged_arrow)
		INVOKE_NEXT_TICK(associated_hive, /datum/hive_status.proc/handle_silo_death_timer) // checks all silos next tick after this one is gone
		associated_hive = null
		notify_ghosts("\ A resin silo has been destroyed at [AREACOORD_NO_Z(src)]!", source = get_turf(src), action = NOTIFY_JUMP)
		playsound(loc,'sound/effects/alien_egg_burst.ogg', 75)
	return ..()


/obj/structure/xeno/resin/silo/Destroy()
	GLOB.xeno_resin_silos -= src

	for(var/i in contents)
		var/atom/movable/AM = i
		AM.forceMove(get_step(center_turf, pick(CARDINAL_ALL_DIRS)))

	silo_area = null
	center_turf = null
	STOP_PROCESSING(SSslowprocess, src)
	return ..()


/obj/structure/xeno/resin/silo/examine(mob/user)
	. = ..()
	var/current_integrity = (obj_integrity / max_integrity) * 100
	switch(current_integrity)
		if(0 to 20)
			to_chat(user, "<span class='warning'>It's barely holding, there's leaking oozes all around, and most eggs are broken. Yet it is not inert.</span>")
		if(20 to 40)
			to_chat(user, "<span class='warning'>It looks severely damaged, its movements slow.</span>")
		if(40 to 60)
			to_chat(user, "<span class='warning'>It's quite beat up, but it seems alive.</span>")
		if(60 to 80)
			to_chat(user, "<span class='warning'>It's slightly damaged, but still seems healthy.</span>")
		if(80 to 100)
			to_chat(user, "<span class='info'>It appears in good shape, pulsating healthily.</span>")


/obj/structure/xeno/resin/silo/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()

	//We took damage, so it's time to start regenerating if we're not already processing
	if(!CHECK_BITFIELD(datum_flags, DF_ISPROCESSING))
		START_PROCESSING(SSslowprocess, src)

	resin_silo_damage_alert()

/obj/structure/xeno/resin/silo/proc/resin_silo_damage_alert()
	if(!COOLDOWN_CHECK(src, silo_damage_alert_cooldown))
		return

	associated_hive.xeno_message("Our [name] at [AREACOORD_NO_Z(src)] is under attack! It has [obj_integrity]/[max_integrity] Health remaining.", "xenoannounce", 5, FALSE, src, 'sound/voice/alien_help1.ogg',FALSE, null, /obj/screen/arrow/silo_damaged_arrow)
	COOLDOWN_START(src, silo_damage_alert_cooldown, XENO_SILO_HEALTH_ALERT_COOLDOWN) //set the cooldown.

///Alerts the Hive when hostiles get too close to their resin silo
/obj/structure/xeno/resin/silo/proc/resin_silo_proxy_alert(datum/source, atom/hostile)
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
		if(X.hive == associated_hive) //Trigger proxy alert only for hostile xenos
			return

	associated_hive.xeno_message("Our [name] has detected a nearby hostile [hostile] at [get_area(hostile)] (X: [hostile.x], Y: [hostile.y]).", "xenoannounce", 5, FALSE, hostile, 'sound/voice/alien_help1.ogg', FALSE, null, /obj/screen/arrow/leader_tracker_arrow)
	COOLDOWN_START(src, silo_proxy_alert_cooldown, XENO_SILO_DETECTION_COOLDOWN) //set the cooldown.

/obj/structure/xeno/resin/silo/process()
	//Regenerate if we're at less than max integrity
	if(obj_integrity < max_integrity)
		obj_integrity = min(obj_integrity + 25, max_integrity) //Regen 5 HP per sec

/obj/structure/xeno/resin/silo/proc/is_burrowed_larva_host(datum/source, list/mothers, list/silos)
	SIGNAL_HANDLER
	if(associated_hive)
		silos += src


//*******************
//Corpse recyclinging
//*******************
/obj/structure/xeno/resin/silo/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!(SSticker.mode?.flags_round_type & MODE_SILOABLE_BODIES))
		return
	if(!isxeno(user)) //only xenos can deposit corpses
		return

	if(!istype(I, /obj/item/grab))
		return

	var/obj/item/grab/G = I
	if(!iscarbon(G.grabbed_thing))
		return
	var/mob/living/carbon/victim = G.grabbed_thing
	if(!(ishuman(victim) || ismonkey(victim))) //humans and monkeys only for now
		to_chat(user, "<span class='notice'>[src] can only process humanoid anatomies!</span>")
		return

	if(victim.stat != DEAD)
		to_chat(user, "<span class='notice'>[victim] is not dead!</span>")
		return

	if(victim.chestburst)
		to_chat(user, "<span class='notice'>[victim] has already been exhausted to incubate a sister!</span>")
		return

	if(issynth(victim))
		to_chat(user, "<span class='notice'>[victim] has no useful biomass for us.</span>")
		return

	visible_message("[user] starts putting [victim] into [src].", 3)

	if(!do_after(user, 20, FALSE, victim, BUSY_ICON_DANGER) || QDELETED(src))
		return

	victim.chestburst = 2 //So you can't reuse corpses if the silo is destroyed
	victim.update_burst()
	victim.forceMove(src)

	shake(4 SECONDS)

	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	xeno_job.add_job_points(1.75) //4.5 corpses per burrowed; 8 points per larva

	log_combat(victim, user, "was consumed by a resin silo")
	log_game("[key_name(victim)] was consumed by a resin silo at [AREACOORD(victim.loc)].")

	GLOB.round_statistics.xeno_silo_corpses++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_silo_corpses")

/// Make the silo shake
/obj/structure/xeno/resin/silo/proc/shake(duration)
	/// How important should be the shaking movement
	var/offset = prob(50) ? -2 : 2
	/// Track the last position of the silo for the animation
	var/old_pixel_x = pixel_x
	/// Sound played when shaking
	var/shake_sound = rand(1, 100) == 1 ? 'sound/machines/blender.ogg' : 'sound/machines/juicer.ogg'
	if(prob(1))
		playsound(src, shake_sound, 25, TRUE)
	animate(src, pixel_x = pixel_x + offset, time = 2, loop = -1) //start shaking
	addtimer(CALLBACK(src, .proc/stop_shake, old_pixel_x), duration)

/// Stop the shaking animation
/obj/structure/xeno/resin/silo/proc/stop_shake(old_px)
	animate(src)
	pixel_x = old_px

/obj/structure/xeno/resin/xeno_turret
	icon = 'icons/Xeno/acidturret.dmi'
	icon_state = "acid_turret"
	name = "resin acid turret"
	desc = "A menacing looking construct of resin, it seems to be alive. It fires acid against intruders."
	bound_width = 32
	bound_height = 32
	obj_integrity = 600
	max_integrity = 1500
	layer =  ABOVE_MOB_LAYER
	density = TRUE
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE
	xeno_structure_flags = IGNORE_WEED_REMOVAL
	///The hive it belongs to
	var/datum/hive_status/associated_hive
	///What kind of spit it uses
	var/datum/ammo/ammo
	///Range of the turret
	var/range = 7
	///Target of the turret
	var/mob/living/hostile
	///Last target of the turret
	var/mob/living/last_hostile
	///Potential list of targets found by scan
	var/list/mob/living/potential_hostiles
	///Fire rate of the target in ticks
	var/firerate = 5
	///The last time the sentry did a scan
	var/last_scan_time

/obj/structure/xeno/resin/xeno_turret/Initialize(mapload, hivenumber = XENO_HIVE_NORMAL)
	. = ..()
	ammo = GLOB.ammo_list[/datum/ammo/xeno/acid/heavy/turret]
	ammo.max_range = range + 2 //To prevent funny gamers to abuse the turrets that easily
	potential_hostiles = list()
	associated_hive = GLOB.hive_datums[hivenumber]
	GLOB.xeno_resin_turrets += src
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/automatedfire/xeno_turret_autofire, firerate)
	RegisterSignal(src, COMSIG_AUTOMATIC_SHOOTER_SHOOT, .proc/shoot)
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, .proc/destroy_on_hijack)
	set_light(2, 2, LIGHT_COLOR_GREEN)
	update_icon()

///Signal handler to delete the turret when the alamo is hijacked
/obj/structure/xeno/resin/xeno_turret/proc/destroy_on_hijack()
	SIGNAL_HANDLER
	qdel(src)

/obj/structure/xeno/resin/xeno_turret/obj_destruction(damage_amount, damage_type, damage_flag)
	if(damage_amount) //Spawn the gas only if we actually get destroyed by damage
		var/datum/effect_system/smoke_spread/xeno/smoke = new /datum/effect_system/smoke_spread/xeno/acid(src)
		smoke.set_up(1, get_turf(src))
		smoke.start()
	return ..()

/obj/structure/xeno/resin/xeno_turret/Destroy()
	GLOB.xeno_resin_turrets -= src
	set_hostile(null)
	set_last_hostile(null)
	STOP_PROCESSING(SSobj, src)
	playsound(loc,'sound/effects/xeno_turret_death.ogg', 70)
	return ..()

/obj/structure/xeno/resin/xeno_turret/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(1500)
		if(EXPLODE_HEAVY)
			take_damage(750)
		if(EXPLODE_LIGHT)
			take_damage(300)

/obj/structure/xeno/resin/xeno_turret/flamer_fire_act()
	take_damage(60, BURN, "fire")
	ENABLE_BITFIELD(resistance_flags, ON_FIRE)

/obj/structure/xeno/resin/xeno_turret/fire_act()
	take_damage(60, BURN, "fire")
	ENABLE_BITFIELD(resistance_flags, ON_FIRE)

/obj/structure/xeno/resin/xeno_turret/update_overlays()
	. = ..()
	if(obj_integrity <= max_integrity / 2)
		. += image('icons/Xeno/acidturret.dmi', src, "+turret_damage")
	if(CHECK_BITFIELD(resistance_flags, ON_FIRE))
		. += image('icons/Xeno/acidturret.dmi', src, "+turret_on_fire")

/obj/structure/xeno/resin/xeno_turret/process()
	//Turrets regen some HP, every 2 sec
	if(obj_integrity < max_integrity)
		obj_integrity = min(obj_integrity + TURRET_HEALTH_REGEN, max_integrity)
		update_icon()
		DISABLE_BITFIELD(resistance_flags, ON_FIRE)
	if(world.time > last_scan_time + TURRET_SCAN_FREQUENCY)
		scan()
		last_scan_time = world.time
	if(!potential_hostiles.len)
		return
	set_hostile(get_target())
	if (!hostile)
		if(last_hostile)
			set_last_hostile(null)
		return
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_XENO_TURRETS_ALERT))
		associated_hive.xeno_message("Our [name] is attacking a nearby hostile [hostile] at [get_area(hostile)] (X: [hostile.x], Y: [hostile.y]).", "xenoannounce", 5, FALSE, hostile, 'sound/voice/alien_help1.ogg', FALSE, null, /obj/screen/arrow/turret_attacking_arrow)
		TIMER_COOLDOWN_START(src, COOLDOWN_XENO_TURRETS_ALERT, 20 SECONDS)
	if(hostile != last_hostile)
		set_last_hostile(hostile)
		SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_START_SHOOTING_AT)

/obj/structure/xeno/resin/xeno_turret/attackby(obj/item/I, mob/living/user, params)
	if(I.flags_item & NOBLUDGEON || !isliving(user))
		return attack_hand(user)

	user.changeNext_move(I.attack_speed)
	user.do_attack_animation(src, used_item = I)

	var/damage = I.force
	var/multiplier = 1
	if(I.damtype == "fire") //Burn damage deals extra vs resin structures (mostly welders).
		multiplier += 1

	if(istype(I, /obj/item/tool/pickaxe/plasmacutter) && !user.do_actions)
		var/obj/item/tool/pickaxe/plasmacutter/P = I
		if(P.start_cut(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD))
			multiplier += PLASMACUTTER_RESIN_MULTIPLIER
			P.cut_apart(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD)

	damage *= max(0, multiplier)
	take_damage(damage)
	playsound(src, "alien_resin_break", 25)

///Signal handler for hard del of hostile
/obj/structure/xeno/resin/xeno_turret/proc/unset_hostile()
	SIGNAL_HANDLER
	hostile = null

///Signal handler for hard del of last_hostile
/obj/structure/xeno/resin/xeno_turret/proc/unset_last_hostile()
	SIGNAL_HANDLER
	last_hostile = null

///Setter for hostile with hard del in mind
/obj/structure/xeno/resin/xeno_turret/proc/set_hostile(_hostile)
	if(hostile != _hostile)
		hostile = _hostile
		RegisterSignal(hostile, COMSIG_PARENT_QDELETING, .proc/unset_hostile)

///Setter for last_hostile with hard del in mind
/obj/structure/xeno/resin/xeno_turret/proc/set_last_hostile(_last_hostile)
	if(last_hostile)
		UnregisterSignal(last_hostile, COMSIG_PARENT_QDELETING)
	last_hostile = _last_hostile

///Look for the closest human in range and in light of sight. If no human is in range, will look for xenos of other hives
/obj/structure/xeno/resin/xeno_turret/proc/get_target()
	var/distance = range + 0.5 //we add 0.5 so if a potential target is at range, it is accepted by the system
	var/buffer_distance
	var/list/turf/path = list()
	for (var/mob/living/nearby_hostile AS in potential_hostiles)
		if(nearby_hostile.stat == DEAD)
			continue
		buffer_distance = get_dist(nearby_hostile, src)
		if (distance <= buffer_distance) //If we already found a target that's closer
			continue
		path = getline(src, nearby_hostile)
		path -= get_turf(src)
		if(!path.len) //Can't shoot if it's on the same turf
			continue
		var/blocked = FALSE
		for(var/turf/T AS in path)
			if(IS_OPAQUE_TURF(T) || T.density && T.throwpass == FALSE)
				blocked = TRUE
				break //LoF Broken; stop checking; we can't proceed further.

			for(var/obj/machinery/MA in T)
				if(MA.opacity || MA.density && MA.throwpass == FALSE)
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.

			for(var/obj/structure/S in T)
				if(S.opacity || S.density && S.throwpass == FALSE )
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.
		if(!blocked)
			distance = buffer_distance
			. = nearby_hostile

///Return TRUE if a possible target is near
/obj/structure/xeno/resin/xeno_turret/proc/scan()
	potential_hostiles.Cut()
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(src, TURRET_SCAN_RANGE))
		if(nearby_human.stat == DEAD)
			continue
		potential_hostiles += nearby_human
	for (var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(src, range))
		if(associated_hive == nearby_xeno.hive) //Xenomorphs not in our hive will be attacked as well!
			continue
		if(nearby_xeno.stat == DEAD)
			continue
		potential_hostiles += nearby_xeno


///Signal handler to make the turret shoot at its target
/obj/structure/xeno/resin/xeno_turret/proc/shoot()
	SIGNAL_HANDLER
	if(!hostile)
		SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_STOP_SHOOTING_AT)
		return
	face_atom(hostile)
	var/obj/projectile/newshot = new(loc)
	newshot.generate_bullet(ammo)
	newshot.permutated += src
	newshot.def_zone = pick(GLOB.base_miss_chance)
	newshot.fire_at(hostile, src, null, ammo.max_range, ammo.shell_speed)
