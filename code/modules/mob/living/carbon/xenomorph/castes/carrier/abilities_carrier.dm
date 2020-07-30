// ***************************************
// *********** Hugger throw
// ***************************************
/datum/action/xeno_action/activable/throw_hugger
	name = "Use/Throw Facehugger"
	action_icon_state = "throw_hugger"
	mechanics_text = "Click once to bring a facehugger into your hand. Click again to ready that facehugger for throwing at a target or tile."
	ability_name = "throw facehugger"
	keybind_signal = COMSIG_XENOABILITY_THROW_HUGGER
	cooldown_timer = 3 SECONDS

/datum/action/xeno_action/activable/throw_hugger/get_cooldown()
	var/mob/living/carbon/xenomorph/carrier/X = owner
	return X.xeno_caste.hugger_delay

/datum/action/xeno_action/activable/throw_hugger/can_use_ability(atom/A, silent = FALSE, override_flags) // true
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE

/datum/action/xeno_action/activable/throw_hugger/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/carrier/X = owner

	//target a hugger on the ground to store it directly
	if(istype(A, /obj/item/clothing/mask/facehugger))
		if(isturf(get_turf(A)) && X.Adjacent(A))
			if(!X.issamexenohive(A))
				to_chat(X, "<span class='warning'>That facehugger is tainted!</span>")
				X.dropItemToGround(A)
				return fail_activate()
			X.store_hugger(A)
			return succeed_activate()

	var/obj/item/clothing/mask/facehugger/F = X.get_active_held_item()
	if(!F) //empty active hand
		//if no hugger in active hand, we take one from our storage
		if(!length(X.huggers))
			to_chat(X, "<span class='warning'>We don't have any facehuggers to use!</span>")
			return fail_activate()
		F = pick_n_take(X.huggers)
		X.put_in_active_hand(F)
		to_chat(X, "<span class='xenonotice'>We grab one of the facehugger in our storage. Now sheltering: [X.huggers.len] / [X.xeno_caste.huggers_max].</span>")
		add_cooldown()
		return succeed_activate()

	if(!istype(F)) //something else in our hand
		to_chat(X, "<span class='warning'>We need a facehugger in our hand to throw one!</span>")
		return fail_activate()

	if(!cooldown_id)
		X.dropItemToGround(F)
		F.go_active(TRUE)
		playsound(X, 'sound/effects/throw.ogg', 30, TRUE)
		F.throw_at(A, CARRIER_HUGGER_THROW_DISTANCE, CARRIER_HUGGER_THROW_SPEED)
		X.visible_message("<span class='xenowarning'>\The [X] throws something towards \the [A]!</span>", \
		"<span class='xenowarning'>We throw a facehugger towards \the [A]!</span>")

/mob/living/carbon/xenomorph/carrier/proc/store_hugger(obj/item/clothing/mask/facehugger/F, message = TRUE, forced = FALSE)
	if(huggers.len < xeno_caste.huggers_max)
		if(F.stat == DEAD && !forced)
			to_chat(src, "<span class='notice'>This young one has already expired, we cannot shelter it.</span>")
			return
		transferItemToLoc(F, src)
		if(!F.stasis)
			F.go_idle(TRUE)
		huggers.Add(F)
		if(message)
			to_chat(src, "<span class='notice'>We store the facehugger and carry it for safekeeping. Now sheltering: [huggers.len] / [xeno_caste.huggers_max].</span>")
	else if(message)
		to_chat(src, "<span class='warning'>We can't carry more facehuggers on ourselves.</span>")

// ***************************************
// *********** Retrieve egg
// ***************************************
/datum/action/xeno_action/activable/retrieve_egg
	name = "Retrieve Egg"
	action_icon_state = "retrieve_egg"
	mechanics_text = "Store an egg on your body for future use. The egg has to be unplanted."
	ability_name = "retrieve egg"
	keybind_signal = COMSIG_XENOABILITY_RETRIEVE_EGG

/datum/action/xeno_action/activable/retrieve_egg/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/carrier/X = owner
	X.retrieve_egg(A)

/mob/living/carbon/xenomorph/carrier/proc/retrieve_egg(atom/T)
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
			to_chat(src, "<span class='warning'>We don't have any eggs to use!</span>")
			return
		E = new()
		E.hivenumber = hivenumber
		eggs_cur--
		put_in_active_hand(E)
		to_chat(src, "<span class='xenonotice'>We grab one of the eggs in our storage. Now sheltering: [eggs_cur] / [xeno_caste.eggs_max].</span>")
		return

	if(!istype(E)) //something else in our hand
		to_chat(src, "<span class='warning'>We need an empty hand to grab one of our stored eggs!</span>")
		return

/mob/living/carbon/xenomorph/carrier/proc/store_egg(obj/item/xeno_egg/E)
	if(!issamexenohive(E))
		to_chat(src, "<span class='warning'>That egg is tainted!</span>")
		return
	if(eggs_cur >= xeno_caste.eggs_max)
		to_chat(src, "<span class='warning'>We can't carry more eggs on ourselves.</span>")
		return
	eggs_cur++
	to_chat(src, "<span class='notice'>We store the egg and carry it for safekeeping. Now sheltering: [eggs_cur] / [xeno_caste.eggs_max].</span>")
	qdel(E)

// ***************************************
// *********** Hugger trap
// ***************************************
/datum/action/xeno_action/place_trap
	name = "Place hugger trap"
	action_icon_state = "place_trap"
	mechanics_text = "Place a hole on weeds that can be filled with a hugger. Activates when a marine steps on it."
	plasma_cost = 400
	keybind_signal = COMSIG_XENOABILITY_PLACE_TRAP

/datum/action/xeno_action/place_trap/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!T || !T.is_weedable() || T.density)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do that here.</span>")
		return FALSE

	if(!(locate(/obj/effect/alien/weeds) in T))
		if(!silent)
			to_chat(owner, "<span class='warning'>We can only shape on weeds. We must find some resin before we start building!</span>")
		return FALSE

	if(!T.check_alien_construction(owner, silent))
		return FALSE

	if(locate(/obj/effect/alien/weeds/node) in T)
		if(!silent)
			to_chat(owner, "<span class='warning'>There is a resin node in the way!</span>")
		return FALSE


/datum/action/xeno_action/place_trap/action_activate()
	var/turf/T = get_turf(owner)

	succeed_activate()

	playsound(T, "alien_resin_build", 25)
	GLOB.round_statistics.carrier_traps++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "carrier_traps")
	new /obj/effect/alien/resin/trap(T, owner)
	to_chat(owner, "<span class='xenonotice'>We place a hugger trap on the weeds, it still needs a facehugger.</span>")

// ***************************************
// *********** Spawn hugger
// ***************************************
/datum/action/xeno_action/spawn_hugger
	name = "Spawn Facehugger"
	action_icon_state = "spawn_hugger"
	mechanics_text = "Spawn a facehugger that is stored on your body."
	plasma_cost = 200
	cooldown_timer = 10 SECONDS
	keybind_signal = COMSIG_XENOABILITY_SPAWN_HUGGER

/datum/action/xeno_action/spawn_hugger/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We can now spawn another young one.</span>")
	playsound(owner, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
	return ..()

/datum/action/xeno_action/spawn_hugger/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/carrier/X = owner
	if(X.huggers.len >= X.xeno_caste.huggers_max)
		if(!silent)
			to_chat(X, "<span class='xenowarning'>We can't host any more young ones!</span>")
		return FALSE

/datum/action/xeno_action/spawn_hugger/action_activate()
	var/mob/living/carbon/xenomorph/carrier/X = owner

	var/obj/item/clothing/mask/facehugger/stasis/F = new
	F.hivenumber = X.hivenumber
	X.store_hugger(F, FALSE, TRUE) //Add it to our cache
	to_chat(X, "<span class='xenowarning'>We spawn a young one via the miracle of asexual internal reproduction, adding it to our stores. Now sheltering: [length(X.huggers)] / [X.xeno_caste.huggers_max].</span>")
	playsound(X, 'sound/voice/alien_drool2.ogg', 50, 0, 1)
	succeed_activate()
	add_cooldown()

