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
	if(!F) //empty active hand
		//if no hugger in active hand, we take one from our storage
		if(!X.huggers)
			to_chat(X, span_warning("We don't have any facehuggers to use!"))
			return fail_activate()

		F = new X.selected_hugger_type(get_turf(X), X.hivenumber, X)
		X.huggers--

		X.put_in_active_hand(F)
		to_chat(X, span_xenonotice("We grab one of the facehuggers in our storage. Now sheltering: [X.huggers] / [X.xeno_caste.huggers_max]."))

	if(!istype(F)) //something else in our hand
		to_chat(X, span_warning("We need a facehugger in our hand to throw one!"))
		return fail_activate()

	if(!cooldown_id)
		X.dropItemToGround(F)
		playsound(X, 'sound/effects/throw.ogg', 30, TRUE)
		F.throw_at(A, CARRIER_HUGGER_THROW_DISTANCE, CARRIER_HUGGER_THROW_SPEED)
		F.stat = CONSCIOUS //Hugger is conscious
		F.leaping = FALSE //Hugger is not leaping
		F.facehugger_register_source(X) //Set us as the source
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
// *********** Retrieve egg
// ***************************************
/datum/action/xeno_action/activable/retrieve_egg
	name = "Retrieve Egg"
	action_icon_state = "retrieve_egg"
	mechanics_text = "Store an egg on your body for future use. The egg has to be unplanted."
	ability_name = "retrieve egg"
	keybind_signal = COMSIG_XENOABILITY_RETRIEVE_EGG
	use_state_flags = XACT_USE_LYING

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
			to_chat(src, span_warning("We don't have any eggs to use!"))
			return
		E = new()
		E.hivenumber = hivenumber
		eggs_cur--
		put_in_active_hand(E)
		to_chat(src, span_xenonotice("We grab one of the eggs in our storage. Now sheltering: [eggs_cur] / [xeno_caste.eggs_max]."))
		return

	if(!istype(E)) //something else in our hand
		to_chat(src, span_warning("We need an empty hand to grab one of our stored eggs!"))
		return

/mob/living/carbon/xenomorph/carrier/proc/store_egg(obj/item/xeno_egg/E)
	if(!issamexenohive(E))
		to_chat(src, span_warning("That egg is tainted!"))
		return
	if(eggs_cur >= xeno_caste.eggs_max)
		to_chat(src, span_warning("We can't carry more eggs on ourselves."))
		return
	eggs_cur++
	to_chat(src, span_notice("We store the egg and carry it for safekeeping. Now sheltering: [eggs_cur] / [xeno_caste.eggs_max]."))
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
			to_chat(owner, span_warning("We can't do that here."))
		return FALSE

	if(!(locate(/obj/effect/alien/weeds) in T))
		if(!silent)
			to_chat(owner, span_warning("We can only shape on weeds. We must find some resin before we start building!"))
		return FALSE

	if(!T.check_alien_construction(owner, silent) || !T.check_disallow_alien_fortification(owner, silent))
		return FALSE

/datum/action/xeno_action/place_trap/action_activate()
	var/turf/T = get_turf(owner)

	succeed_activate()

	playsound(T, "alien_resin_build", 25)
	GLOB.round_statistics.carrier_traps++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "carrier_traps")
	new /obj/structure/xeno/trap(T)
	to_chat(owner, span_xenonotice("We place a hugger trap on the weeds, it still needs a facehugger."))

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

/datum/action/xeno_action/choose_hugger_type/alternate_keybind_action()
	var/mob/living/carbon/xenomorph/X = owner
	var/i = GLOB.hugger_type_list.Find(X.selected_hugger_type)
	if(length(GLOB.hugger_type_list) == i)
		X.selected_hugger_type = GLOB.hugger_type_list[1]
	else
		X.selected_hugger_type = GLOB.hugger_type_list[i+1]

	var/atom/A = X.selected_hugger_type
	to_chat(X, span_notice("We will now spawn <b>[initial(A.name)]\s</b> when using the Spawn Hugger ability."))
	update_button_icon()
	return succeed_activate()

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
