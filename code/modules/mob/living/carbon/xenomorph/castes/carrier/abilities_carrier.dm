#define LARVAL_HUGGER "larval hugger"
#define CLAWED_HUGGER "clawed hugger"
#define NEURO_HUGGER "neuro hugger"
#define ACID_HUGGER "acid hugger"
#define RESIN_HUGGER "resin hugger"

//List of huggie types
GLOBAL_LIST_INIT(hugger_type_list, list(
		/obj/item/clothing/mask/facehugger/larval,
		/obj/item/clothing/mask/facehugger/combat/slash,
		/obj/item/clothing/mask/facehugger/combat/neuro,
		/obj/item/clothing/mask/facehugger/combat/acid,
		/obj/item/clothing/mask/facehugger/combat/resin,
		))

GLOBAL_LIST_INIT(hugger_to_ammo, list(
	/obj/item/clothing/mask/facehugger/larval = /datum/ammo/xeno/hugger,
	/obj/item/clothing/mask/facehugger/combat/slash = /datum/ammo/xeno/hugger/slash,
	/obj/item/clothing/mask/facehugger/combat/neuro = /datum/ammo/xeno/hugger/neuro,
	/obj/item/clothing/mask/facehugger/combat/acid = /datum/ammo/xeno/hugger/acid,
	/obj/item/clothing/mask/facehugger/combat/resin = /datum/ammo/xeno/hugger/resin,
))

//List of huggie images
GLOBAL_LIST_INIT(hugger_images_list,  list(
		LARVAL_HUGGER = image('icons/mob/actions.dmi', icon_state = LARVAL_HUGGER),
		CLAWED_HUGGER = image('icons/mob/actions.dmi', icon_state = CLAWED_HUGGER),
		NEURO_HUGGER = image('icons/mob/actions.dmi', icon_state = NEURO_HUGGER ),
		ACID_HUGGER  = image('icons/mob/actions.dmi', icon_state = ACID_HUGGER),
		RESIN_HUGGER = image('icons/mob/actions.dmi', icon_state = RESIN_HUGGER),
		))

// ***************************************
// *********** Hugger throw
// ***************************************
/datum/action/xeno_action/activable/throw_hugger
	name = "Use/Throw Facehugger"
	action_icon_state = "throw_hugger"
	mechanics_text = "Click on a non tile and non mob to bring a facehugger into your hand. Click at a target or tile to throw a facehugger."
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
				to_chat(X, span_warning("That facehugger is tainted!"))
				X.dropItemToGround(A)
				return fail_activate()
			X.store_hugger(A)
			return succeed_activate()

	var/obj/item/clothing/mask/facehugger/F = X.get_active_held_item()
	if(!istype(F) || F.stat == DEAD) //empty active hand
		//if no hugger in active hand, we take one from our storage
		if(!X.huggers)
			to_chat(X, span_warning("We don't have any facehuggers to use!"))
			return fail_activate()

		F = new X.selected_hugger_type(get_turf(X), X.hivenumber, X)
		X.huggers--

		X.put_in_active_hand(F)
		to_chat(X, span_xenonotice("We grab one of the facehuggers in our storage. Now sheltering: [X.huggers] / [X.xeno_caste.huggers_max]."))

	if(!cooldown_id)
		X.dropItemToGround(F)
		playsound(X, 'sound/effects/throw.ogg', 30, TRUE)
		F.stat = CONSCIOUS //Hugger is conscious
		F.leaping = FALSE //Hugger is not leaping
		F.facehugger_register_source(X) //Set us as the source
		F.throw_at(A, CARRIER_HUGGER_THROW_DISTANCE, CARRIER_HUGGER_THROW_SPEED)
		X.visible_message(span_xenowarning("\The [X] throws something towards \the [A]!"), \
		span_xenowarning("We throw a facehugger towards \the [A]!"))
		add_cooldown()
		return succeed_activate()

/mob/living/carbon/xenomorph/carrier/proc/store_hugger(obj/item/clothing/mask/facehugger/F, message = TRUE, forced = FALSE)
	if(huggers < xeno_caste.huggers_max)
		if(F.stat == DEAD && !forced)
			to_chat(src, span_notice("This young one has already expired, we cannot salvage it."))
			return
		F.kill_hugger()
		huggers++
		if(message)
			playsound(src, 'sound/voice/alien_drool2.ogg', 50, 0, 1)
			to_chat(src, span_notice("We salvage this young one's biomass to produce another. Now sheltering: [huggers] / [xeno_caste.huggers_max]."))
	else if(message)
		to_chat(src, span_warning("We can't carry any more facehuggers!"))

// ***************************************
// ********* Trap
// ***************************************
/datum/action/xeno_action/place_trap
	name = "Place trap"
	action_icon_state = "place_trap"
	mechanics_text = "Place a hole on weeds that can be filled with a hugger or acid. Activates when a marine steps on it."
	plasma_cost = 400
	keybind_signal = COMSIG_XENOABILITY_PLACE_TRAP

/datum/action/xeno_action/place_trap/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!T || !T.is_weedable() || T.density)
		if(!silent)
			to_chat(owner, span_warning("We can't do that here."))
		return FALSE

	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(!owner_xeno.loc_weeds_type)
		if(!silent)
			to_chat(owner, span_warning("We can only shape on weeds. We must find some resin before we start building!"))
		return FALSE

	if(!T.check_alien_construction(owner, silent) || !T.check_disallow_alien_fortification(owner, silent))
		return FALSE

/datum/action/xeno_action/place_trap/action_activate()
	var/turf/T = get_turf(owner)

	succeed_activate()

	playsound(T, "alien_resin_build", 25)
	GLOB.round_statistics.trap_holes++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "carrier_traps")
	new /obj/structure/xeno/trap(T, owner)
	to_chat(owner, span_xenonotice("We place a trap on the weeds, but it still needs to be filled."))

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
	use_state_flags = XACT_USE_LYING

/datum/action/xeno_action/spawn_hugger/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We can now spawn another young one."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/spawn_hugger/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/carrier/X = owner
	if(X.huggers >= X.xeno_caste.huggers_max)
		if(!silent)
			to_chat(X, span_xenowarning("We can't host any more young ones!"))
		return FALSE

/datum/action/xeno_action/spawn_hugger/action_activate()
	var/mob/living/carbon/xenomorph/carrier/X = owner

	X.huggers++
	to_chat(X, span_xenowarning("We spawn a young one via the miracle of asexual internal reproduction, adding it to our stores. Now sheltering: [X.huggers] / [X.xeno_caste.huggers_max]."))
	playsound(X, 'sound/voice/alien_drool2.ogg', 50, 0, 1)
	succeed_activate()
	add_cooldown()

// ***************************************
// *********** Drop all hugger, panic button
// ***************************************
/datum/action/xeno_action/carrier_panic
	name = "Drop All Facehuggers"
	action_icon_state = "carrier_panic"
	mechanics_text = "Drop all stored huggers in a fit of panic. Uses all remaining plasma!"
	plasma_cost = 10
	cooldown_timer =180 SECONDS
	keybind_signal = COMSIG_XENOABILITY_DROP_ALL_HUGGER
	use_state_flags = XACT_USE_LYING

/datum/action/xeno_action/carrier_panic/give_action(mob/living/L)
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_DEATH, .proc/do_activate)

/datum/action/xeno_action/carrier_panic/remove_action(mob/living/L)
	UnregisterSignal(owner, COMSIG_MOB_DEATH)
	return ..()

/// Helper proc for action acitvation via signal
/datum/action/xeno_action/carrier_panic/proc/do_activate()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/action_activate)

/datum/action/xeno_action/carrier_panic/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/carrier/X = owner
	if(X.health > (X.maxHealth * 0.4))
		if(!silent)
			to_chat(X, span_xenowarning("We are not injured enough to panic yet!"))
		return FALSE
	if(X.huggers < 1)
		if(!silent)
			to_chat(X, span_xenowarning("We do not have any young ones to drop!"))
		return FALSE

/datum/action/xeno_action/carrier_panic/action_activate()
	var/mob/living/carbon/xenomorph/carrier/xeno_carrier = owner

	if(!xeno_carrier.huggers)
		return

	xeno_carrier.visible_message(span_xenowarning("A chittering mass of tiny aliens is trying to escape [xeno_carrier]!"))
	while(xeno_carrier.huggers > 0)
		var/obj/item/clothing/mask/facehugger/new_hugger = new xeno_carrier.selected_hugger_type(get_turf(xeno_carrier))
		step_away(new_hugger, xeno_carrier, 1)
		addtimer(CALLBACK(new_hugger, /obj/item/clothing/mask/facehugger.proc/go_active, TRUE), new_hugger.jump_cooldown)
		xeno_carrier.huggers--
	succeed_activate(INFINITY) //Consume all remaining plasma
	add_cooldown()

// ***************************************
// *********** Choose Hugger Type
// ***************************************
// Choose Hugger Type
/datum/action/xeno_action/choose_hugger_type
	name = "Choose Hugger Type"
	action_icon_state = "facehugger"
	mechanics_text = "Selects which hugger type you will build with the Spawn Hugger ability."
	keybind_signal = COMSIG_XENOABILITY_CHOOSE_HUGGER
	alternate_keybind_signal = COMSIG_XENOABILITY_SWITCH_HUGGER

/datum/action/xeno_action/choose_hugger_type/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	X.selected_hugger_type = GLOB.hugger_type_list[1] //Set our default
	update_button_icon() //Update immediately to get our default

/datum/action/xeno_action/choose_hugger_type/update_button_icon()
	var/mob/living/carbon/xenomorph/X = owner
	var/atom/A = X.selected_hugger_type
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, initial(A.name))
	return ..()

/datum/action/xeno_action/choose_hugger_type/alternate_action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	var/i = GLOB.hugger_type_list.Find(X.selected_hugger_type)
	if(length(GLOB.hugger_type_list) == i)
		X.selected_hugger_type = GLOB.hugger_type_list[1]
	else
		X.selected_hugger_type = GLOB.hugger_type_list[i+1]

	var/atom/A = X.selected_hugger_type
	to_chat(X, span_notice("We will now spawn <b>[initial(A.name)]\s</b> when using the Spawn Hugger ability."))
	update_button_icon()
	succeed_activate()
	return COMSIG_KB_ACTIVATED

/datum/action/xeno_action/choose_hugger_type/action_activate()
	var/hugger_choice = show_radial_menu(owner, owner, GLOB.hugger_images_list, radius = 48)
	if(!hugger_choice)
		return
	var/mob/living/carbon/xenomorph/X = owner
	for(var/obj/item/clothing/mask/facehugger/hugger_type AS in GLOB.hugger_type_list)
		if(initial(hugger_type.name) == hugger_choice)
			X.selected_hugger_type = hugger_type
			break
	to_chat(X, span_notice("We will now spawn <b>[hugger_choice]\s</b> when using the spawn hugger ability."))
	update_button_icon()
	return succeed_activate()

/datum/action/xeno_action/build_hugger_turret
	name = "build hugger turret"
	action_icon_state = "hugger_turret"
	mechanics_text = "Build a hugger turret"
	plasma_cost = 800
	cooldown_timer = 5 MINUTES

/datum/action/xeno_action/build_hugger_turret/can_use_action(silent, override_flags)
	. = ..()
	var/turf/T = get_turf(owner)
	var/mob/living/carbon/xenomorph/blocker = locate() in T
	if(blocker && blocker != owner && blocker.stat != DEAD)
		if(!silent)
			to_chat(owner, span_xenowarning("You cannot build with [blocker] in the way!"))
		return FALSE

	if(!T.is_weedable())
		return FALSE

	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(!owner_xeno.loc_weeds_type)
		if(!silent)
			to_chat(owner, span_xenowarning("No weeds here!"))
		return FALSE

	if(!T.check_alien_construction(owner, silent = silent, planned_building = /obj/structure/xeno/xeno_turret) || !T.check_disallow_alien_fortification(owner))
		return FALSE

	for(var/obj/structure/xeno/xeno_turret/turret AS in GLOB.xeno_resin_turrets)
		if(get_dist(turret, owner) < 6)
			if(!silent)
				to_chat(owner, span_xenowarning("Another turret is too close!"))
			return FALSE

/datum/action/xeno_action/build_hugger_turret/action_activate()
	if(!do_after(owner, 10 SECONDS, TRUE, owner, BUSY_ICON_BUILD))
		return FALSE

	if(!can_use_action())
		return FALSE

	var/mob/living/carbon/xenomorph/carrier/X = owner
	var/obj/structure/xeno/xeno_turret/hugger_turret/turret = new (get_turf(owner), X.hivenumber)
	turret.ammo = GLOB.ammo_list[GLOB.hugger_to_ammo[X.selected_hugger_type]]
	succeed_activate()
	add_cooldown()
