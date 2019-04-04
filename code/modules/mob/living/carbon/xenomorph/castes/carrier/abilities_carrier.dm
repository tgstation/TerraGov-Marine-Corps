// ***************************************
// *********** Hugger throw
// ***************************************
/datum/action/xeno_action/activable/throw_hugger
	name = "Use/Throw Facehugger"
	action_icon_state = "throw_hugger"
	mechanics_text = "Click once to bring a facehugger into your hand. Click again to ready that facehugger for throwing at a target or tile."
	ability_name = "throw facehugger"

/datum/action/xeno_action/activable/throw_hugger/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Carrier/X = owner
	X.throw_hugger(A)

/datum/action/xeno_action/activable/throw_hugger/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Carrier/X = owner
	return !X.threw_a_hugger

/mob/living/carbon/Xenomorph/Carrier/proc/throw_hugger(atom/T)
	if(!T)
		return

	if(!check_state())
		return

	//target a hugger on the ground to store it directly
	if(istype(T, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/F = T
		if(isturf(F.loc) && Adjacent(F))
			if(!issamexenohive(F))
				to_chat(src, "<span class='warning'>That facehugger is tainted!</span>")
				dropItemToGround(F)
				return
			store_hugger(F)
			return

	var/obj/item/clothing/mask/facehugger/F = get_active_held_item()
	if(!F) //empty active hand
		//if no hugger in active hand, we take one from our storage
		if(!length(huggers))
			to_chat(src, "<span class='warning'>You don't have any facehuggers to use!</span>")
			return
		F = pick_n_take(huggers)
		put_in_active_hand(F)
		F.GoActive(TRUE)
		to_chat(src, "<span class='xenonotice'>You grab one of the facehugger in your storage. Now sheltering: [huggers.len] / [xeno_caste.huggers_max].</span>")
		return

	if(!istype(F)) //something else in our hand
		to_chat(src, "<span class='warning'>You need a facehugger in your hand to throw one!</span>")
		return

	if(!threw_a_hugger)
		threw_a_hugger = TRUE
		update_action_button_icons()
		dropItemToGround(F)
		F.throw_at(T, CARRIER_HUGGER_THROW_DISTANCE, CARRIER_HUGGER_THROW_SPEED)
		visible_message("<span class='xenowarning'>\The [src] throws something towards \the [T]!</span>", \
		"<span class='xenowarning'>You throw a facehugger towards \the [T]!</span>")
		addtimer(CALLBACK(src, .hugger_throw_cooldown), xeno_caste.hugger_delay)

/mob/living/carbon/Xenomorph/Carrier/proc/hugger_throw_cooldown()
	threw_a_hugger = FALSE
	update_action_button_icons()

/mob/living/carbon/Xenomorph/Carrier/proc/store_hugger(obj/item/clothing/mask/facehugger/F, message = TRUE, forced = FALSE)
	if(huggers.len < xeno_caste.huggers_max)
		if(F.stat == CONSCIOUS || forced)
			transferItemToLoc(F, src)
			if(!F.stasis)
				F.GoIdle(TRUE)
			huggers.Add(F)
			if(message)
				to_chat(src, "<span class='notice'>You store the facehugger and carry it for safekeeping. Now sheltering: [huggers.len] / [xeno_caste.huggers_max].</span>")
		else if(message)
			to_chat(src, "<span class='warning'>This [F.name] looks too unhealthy.</span>")
	else if(message)
		to_chat(src, "<span class='warning'>You can't carry more facehuggers on you.</span>")

/mob/living/carbon/Xenomorph/Carrier/proc/store_egg(obj/item/xeno_egg/E)
	if(!issamexenohive(E))
		to_chat(src, "<span class='warning'>That egg is tainted!</span>")
		return
	if(eggs_cur >= xeno_caste.eggs_max)
		to_chat(src, "<span class='warning'>You can't carry more eggs on you.</span>")
		return
	eggs_cur++
	to_chat(src, "<span class='notice'>You store the egg and carry it for safekeeping. Now sheltering: [eggs_cur] / [xeno_caste.eggs_max].</span>")
	qdel(E)

// ***************************************
// *********** Retrieve egg
// ***************************************
/datum/action/xeno_action/activable/retrieve_egg
	name = "Retrieve Egg"
	action_icon_state = "retrieve_egg"
	mechanics_text = "Store an egg on your body for future use. The egg has to be unplanted."
	ability_name = "retrieve egg"

/datum/action/xeno_action/activable/retrieve_egg/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Carrier/X = owner
	X.retrieve_egg(A)

/mob/living/carbon/Xenomorph/Carrier/proc/retrieve_egg(atom/T)
	if(!T)
		return

	if(!check_state())
		return

	//target a hugger on the ground to store it directly
	if(istype(T, /obj/item/xeno_egg))
		var/obj/item/xeno_egg/E = T
		if(isturf(E.loc) && Adjacent(E))
			store_egg(E)
			return

	var/obj/item/xeno_egg/E = get_active_held_item()
	if(!E) //empty active hand
		//if no hugger in active hand, we take one from our storage
		if(eggs_cur <= 0)
			to_chat(src, "<span class='warning'>You don't have any egg to use!</span>")
			return
		E = new()
		E.hivenumber = hivenumber
		eggs_cur--
		put_in_active_hand(E)
		to_chat(src, "<span class='xenonotice'>You grab one of the eggs in your storage. Now sheltering: [eggs_cur] / [xeno_caste.eggs_max].</span>")
		return

	if(!istype(E)) //something else in our hand
		to_chat(src, "<span class='warning'>You need an empty hand to grab one of your stored eggs!</span>")
		return

// ***************************************
// *********** Hugger trap
// ***************************************
/datum/action/xeno_action/place_trap
	name = "Place hugger trap (200)"
	action_icon_state = "place_trap"
	mechanics_text = "Place a hole on weeds that can be filled with a hugger. Activates when a marine steps on it."
	plasma_cost = 200

/datum/action/xeno_action/place_trap/action_activate()
	var/mob/living/carbon/Xenomorph/Carrier/X = owner
	if(!X.check_state())
		return
	if(!X.check_plasma(plasma_cost))
		return
	var/turf/T = get_turf(X)

	if(!istype(T) || !T.is_weedable() || T.density)
		to_chat(X, "<span class='warning'>You can't do that here.</span>")
		return

	var/area/AR = get_area(T)
	if(istype(AR,/area/shuttle/drop1/lz1) || istype(AR,/area/shuttle/drop2/lz2) || istype(AR,/area/sulaco/hangar)) //Bandaid for atmospherics bug when Xenos build around the shuttles
		to_chat(X, "<span class='warning'>You sense this is not a suitable area for expanding the hive.</span>")
		return

	var/obj/effect/alien/weeds/alien_weeds = locate() in T

	if(!alien_weeds)
		to_chat(X, "<span class='warning'>You can only shape on weeds. Find some resin before you start building!</span>")
		return

	if(!X.check_alien_construction(T))
		return

	X.use_plasma(plasma_cost)
	playsound(X.loc, "alien_resin_build", 25)
	round_statistics.carrier_traps++
	new /obj/effect/alien/resin/trap(X.loc, X)
	to_chat(X, "<span class='xenonotice'>You place a hugger trap on the weeds, it still needs a facehugger.</span>")

// ***************************************
// *********** Spawn hugger
// ***************************************
/datum/action/xeno_action/spawn_hugger
	name = "Spawn Facehugger (100)"
	action_icon_state = "spawn_hugger"
	mechanics_text = "Spawn a facehugger that is stored on your body."
	plasma_cost = 100

/datum/action/xeno_action/spawn_hugger/action_activate()
	var/mob/living/carbon/Xenomorph/Carrier/X = owner
	X.Spawn_Hugger()

/datum/action/xeno_action/spawn_hugger/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Carrier/X = owner
	return !X.used_spawn_facehugger

/mob/living/carbon/Xenomorph/Carrier/proc/Spawn_Hugger(var/mob/living/carbon/M)
	if(stagger)
		to_chat(src, "<span class='xenowarning'>You try to spawn a young one but are unable to shake off the shock!</span>")
		return

	if(used_spawn_facehugger)
		to_chat(src, "<span class='xenowarning'>You're not yet ready to spawn another young one; you must wait [(last_spawn_facehugger + cooldown_spawn_facehugger - world.time) * 0.1] more seconds.</span>")
		return

	if(!check_plasma(CARRIER_SPAWN_HUGGER_COST))
		return

	if(huggers.len >= xeno_caste.huggers_max)
		to_chat(src, "<span class='xenowarning'>You can't host any more young ones!</span>")
		return

	var/obj/item/clothing/mask/facehugger/stasis/F = new
	F.hivenumber = hivenumber
	store_hugger(F, FALSE, TRUE) //Add it to our cache
	to_chat(src, "<span class='xenowarning'>You spawn a young one via the miracle of asexual internal reproduction, adding it to your stores. Now sheltering: [length(huggers)] / [xeno_caste.huggers_max].</span>")
	playsound(src, 'sound/voice/alien_drool2.ogg', 50, 0, 1)
	last_spawn_facehugger = world.time
	used_spawn_facehugger = TRUE
	use_plasma(CARRIER_SPAWN_HUGGER_COST)
	addtimer(CALLBACK(src, .hugger_spawn_cooldown), cooldown_spawn_facehugger)

/mob/living/carbon/Xenomorph/Carrier/proc/hugger_spawn_cooldown()
	if(!used_spawn_facehugger)//sanity check/safeguard
		return
	used_spawn_facehugger = FALSE
	to_chat(src, "<span class='xenodanger'>You can now spawn another young one.</span>")
	playsound(src, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
	update_action_buttons()
	