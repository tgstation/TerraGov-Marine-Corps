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
		LARVAL_HUGGER = image('icons/Xeno/actions.dmi', icon_state = LARVAL_HUGGER),
		CLAWED_HUGGER = image('icons/Xeno/actions.dmi', icon_state = CLAWED_HUGGER),
		NEURO_HUGGER = image('icons/Xeno/actions.dmi', icon_state = NEURO_HUGGER ),
		ACID_HUGGER = image('icons/Xeno/actions.dmi', icon_state = ACID_HUGGER),
		RESIN_HUGGER = image('icons/Xeno/actions.dmi', icon_state = RESIN_HUGGER),
		))

// ***************************************
// *********** Hugger throw
// ***************************************
/datum/action/ability/activable/xeno/throw_hugger
	name = "Use/Throw Facehugger"
	action_icon_state = "throw_hugger"
	desc = "Click on a non tile and non mob to bring a facehugger into your hand. Click at a target or tile to throw a facehugger."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_THROW_HUGGER,
	)
	cooldown_duration = 3 SECONDS

/datum/action/ability/activable/xeno/throw_hugger/get_cooldown()
	var/mob/living/carbon/xenomorph/carrier/caster = owner
	return caster.xeno_caste.hugger_delay

/datum/action/ability/activable/xeno/throw_hugger/can_use_ability(atom/A, silent = FALSE, override_flags) // true
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE

/datum/action/ability/activable/xeno/throw_hugger/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/carrier/caster = owner

	//target a hugger on the ground to store it directly
	if(istype(A, /obj/item/clothing/mask/facehugger))
		if(isturf(get_turf(A)) && caster.Adjacent(A))
			if(!caster.issamexenohive(A))
				to_chat(caster, span_warning("That facehugger is tainted!"))
				caster.dropItemToGround(A)
				return fail_activate()
			caster.store_hugger(A)
			return succeed_activate()

	var/obj/item/clothing/mask/facehugger/F = caster.get_active_held_item()
	if(!istype(F) || F.stat == DEAD) //empty active hand
		//if no hugger in active hand, we take one from our storage
		if(!caster.huggers)
			to_chat(caster, span_warning("We don't have any facehuggers to use!"))
			return fail_activate()

		F = new caster.selected_hugger_type(get_turf(caster), caster.hivenumber, caster)
		caster.huggers--

		caster.put_in_active_hand(F)
		to_chat(caster, span_xenonotice("We grab one of the facehuggers in our storage. Now sheltering: [caster.huggers] / [caster.xeno_caste.huggers_max]."))

	if(!cooldown_timer)
		caster.dropItemToGround(F)
		playsound(caster, 'sound/effects/throw.ogg', 30, TRUE)
		F.stat = CONSCIOUS //Hugger is conscious
		F.leaping = FALSE //Hugger is not leaping
		F.facehugger_register_source(caster) //Set us as the source
		F.throw_at(A, CARRIER_HUGGER_THROW_DISTANCE, CARRIER_HUGGER_THROW_SPEED)
		caster.visible_message(span_xenowarning("\The [caster] throws something towards \the [A]!"), \
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
/datum/action/ability/xeno_action/place_trap
	name = "Place trap"
	action_icon_state = "place_trap"
	desc = "Place a hole on weeds that can be filled with a hugger or acid. Activates when a marine steps on it."
	ability_cost = 400
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PLACE_TRAP,
	)

/datum/action/ability/xeno_action/place_trap/can_use_action(silent = FALSE, override_flags)
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

/datum/action/ability/xeno_action/place_trap/action_activate()
	var/turf/T = get_turf(owner)

	succeed_activate()

	playsound(T, "alien_resin_build", 25)
	GLOB.round_statistics.trap_holes++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "carrier_traps")
	owner.record_traps_created()
	new /obj/structure/xeno/trap(T, owner.get_xeno_hivenumber())
	to_chat(owner, span_xenonotice("We place a trap on the weeds, but it still needs to be filled."))

// ***************************************
// *********** Spawn hugger
// ***************************************
/datum/action/ability/xeno_action/spawn_hugger
	name = "Spawn Facehugger"
	action_icon_state = "spawn_hugger"
	desc = "Spawn a facehugger that is stored on your body."
	ability_cost = 200
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SPAWN_HUGGER,
	)
	use_state_flags = ABILITY_USE_LYING

/datum/action/ability/xeno_action/spawn_hugger/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We can now spawn another young one."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/ability/xeno_action/spawn_hugger/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/carrier/caster = owner
	if(caster.huggers >= caster.xeno_caste.huggers_max)
		if(!silent)
			to_chat(caster, span_xenowarning("We can't host any more young ones!"))
		return FALSE

/datum/action/ability/xeno_action/spawn_hugger/action_activate()
	var/mob/living/carbon/xenomorph/carrier/caster = owner

	caster.huggers++
	to_chat(caster, span_xenowarning("We spawn a young one via the miracle of asexual internal reproduction, adding it to our stores. Now sheltering: [caster.huggers] / [caster.xeno_caste.huggers_max]."))
	playsound(caster, 'sound/voice/alien_drool2.ogg', 50, 0, 1)
	succeed_activate()
	add_cooldown()
	if(owner.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[owner.ckey]
		personal_statistics.huggers_created++

// ***************************************
// *********** Drop all hugger, panic button
// ***************************************
/datum/action/ability/xeno_action/carrier_panic
	name = "Drop All Facehuggers"
	action_icon_state = "carrier_panic"
	desc = "Drop all stored huggers in a fit of panic. Uses all remaining plasma!"
	ability_cost = 10
	cooldown_duration = 50 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DROP_ALL_HUGGER,
	)
	use_state_flags = ABILITY_USE_LYING

/datum/action/ability/xeno_action/carrier_panic/give_action(mob/living/L)
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_DEATH, PROC_REF(do_activate))

/datum/action/ability/xeno_action/carrier_panic/remove_action(mob/living/L)
	UnregisterSignal(owner, COMSIG_MOB_DEATH)
	return ..()

/// Helper proc for action acitvation via signal
/datum/action/ability/xeno_action/carrier_panic/proc/do_activate()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(action_activate))

/datum/action/ability/xeno_action/carrier_panic/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/carrier/caster = owner
	if(caster.health > (caster.maxHealth * 0.56))
		if(!silent)
			to_chat(caster, span_xenowarning("We are not injured enough to panic yet!"))
		return FALSE
	if(caster.huggers < 1)
		if(!silent)
			to_chat(caster, span_xenowarning("We do not have any young ones to drop!"))
		return FALSE

/datum/action/ability/xeno_action/carrier_panic/action_activate()
	var/mob/living/carbon/xenomorph/carrier/xeno_carrier = owner

	if(!xeno_carrier.huggers)
		return

	xeno_carrier.visible_message(span_xenowarning("A chittering mass of tiny aliens is trying to escape [xeno_carrier]!"))
	while(xeno_carrier.huggers > 0)
		var/obj/item/clothing/mask/facehugger/new_hugger = new /obj/item/clothing/mask/facehugger/larval(get_turf(xeno_carrier), xeno_carrier.hivenumber, xeno_carrier)
		step_away(new_hugger, xeno_carrier, 1)
		addtimer(CALLBACK(new_hugger, TYPE_PROC_REF(/obj/item/clothing/mask/facehugger, go_active), TRUE), new_hugger.jump_cooldown)
		xeno_carrier.huggers--
	succeed_activate(INFINITY) //Consume all remaining plasma
	add_cooldown()

// ***************************************
// *********** Choose Hugger Type
// ***************************************
// Choose Hugger Type
/datum/action/ability/xeno_action/choose_hugger_type
	name = "Choose Hugger Type"
	action_icon_state = "facehugger"
	desc = "Selects which hugger type you will build with the Spawn Hugger ability."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CHOOSE_HUGGER,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_SWITCH_HUGGER,
	)
	use_state_flags = ABILITY_USE_LYING

/datum/action/ability/xeno_action/choose_hugger_type/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/caster = owner
	caster.selected_hugger_type = GLOB.hugger_type_list[1] //Set our default
	update_button_icon() //Update immediately to get our default

/datum/action/ability/xeno_action/choose_hugger_type/update_button_icon()
	var/mob/living/carbon/xenomorph/caster = owner
	var/atom/A = caster.selected_hugger_type
	action_icon_state = initial(A.name)
	return ..()

/datum/action/ability/xeno_action/choose_hugger_type/alternate_action_activate()
	var/mob/living/carbon/xenomorph/caster = owner
	var/i = GLOB.hugger_type_list.Find(caster.selected_hugger_type)
	if(length(GLOB.hugger_type_list) == i)
		caster.selected_hugger_type = GLOB.hugger_type_list[1]
	else
		caster.selected_hugger_type = GLOB.hugger_type_list[i+1]

	var/atom/A = caster.selected_hugger_type
	to_chat(caster, span_notice("We will now spawn <b>[initial(A.name)]\s</b> when using the Spawn Hugger ability."))
	caster.balloon_alert(caster,"[initial(A.name)]")
	update_button_icon()
	succeed_activate()
	return COMSIG_KB_ACTIVATED

/datum/action/ability/xeno_action/choose_hugger_type/action_activate()
	var/hugger_choice = show_radial_menu(owner, owner, GLOB.hugger_images_list, radius = 48)
	if(!hugger_choice)
		return
	var/mob/living/carbon/xenomorph/caster = owner
	for(var/obj/item/clothing/mask/facehugger/hugger_type AS in GLOB.hugger_type_list)
		if(initial(hugger_type.name) == hugger_choice)
			caster.selected_hugger_type = hugger_type
			break
	to_chat(caster, span_notice("We will now spawn <b>[hugger_choice]\s</b> when using the spawn hugger ability."))
	caster.balloon_alert(caster, "[hugger_choice]")
	update_button_icon()
	return succeed_activate()

/datum/action/ability/xeno_action/build_hugger_turret
	name = "build hugger turret"
	action_icon_state = "hugger_turret"
	desc = "Build a hugger turret"
	ability_cost = 800
	cooldown_duration = 5 MINUTES
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BUILD_HUGGER_TURRET,
	)

/datum/action/ability/xeno_action/build_hugger_turret/can_use_action(silent, override_flags)
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

	for(var/obj/structure/xeno/xeno_turret/turret AS in GLOB.xeno_resin_turrets_by_hive[blocker.hivenumber])
		if(get_dist(turret, owner) < 6)
			if(!silent)
				to_chat(owner, span_xenowarning("Another turret is too close!"))
			return FALSE

/datum/action/ability/xeno_action/build_hugger_turret/action_activate()
	if(!do_after(owner, 10 SECONDS, NONE, owner, BUSY_ICON_BUILD))
		return FALSE

	if(!can_use_action())
		return FALSE

	var/mob/living/carbon/xenomorph/carrier/caster = owner
	var/obj/structure/xeno/xeno_turret/hugger_turret/turret = new (get_turf(owner), caster.hivenumber)
	turret.ammo = GLOB.ammo_list[GLOB.hugger_to_ammo[caster.selected_hugger_type]]
	succeed_activate()
	add_cooldown()

// ***************************************
// *********** Call of Younger
// ***************************************

/datum/action/ability/activable/xeno/call_younger
	name = "Call of Younger"
	action_icon_state = "call_younger"
	desc = "Appeals to the larva inside the Marine. The Marine loses his balance, and larva's progress accelerates."
	ability_cost = 150
	cooldown_duration = 20 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CALL_YOUNGER,
	)


/datum/action/ability/activable/xeno/call_younger/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return

	if(!ishuman(A))
		if(!silent)
			A.balloon_alert(owner, "Not human")
		return FALSE

	var/mob/living/carbon/human/target = A

	if(!(locate(/obj/item/alien_embryo) in target))
		if(!silent)
			target.balloon_alert(owner, "He's not infected")
		return FALSE

	if(target.stat == DEAD)
		if(!silent)
			target.balloon_alert(owner, "He's dead")
		return FALSE

	if(!line_of_sight(owner, target, 9))
		if(!silent)
			target.balloon_alert(owner, "Need line of sight")
		return FALSE
	return TRUE

/datum/action/ability/activable/xeno/call_younger/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/caster = owner
	var/mob/living/carbon/human/victim = A

	owner.face_atom(victim)

	if(!do_after(caster, 0.5 SECONDS, NONE, caster, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), A, FALSE, ABILITY_USE_BUSY)))
		return fail_activate()
	if(!can_use_ability(A))
		return fail_activate()

	var/obj/item/alien_embryo/young = locate() in victim
	var/debuff = young.stage + 1
	var/stamina_dmg = (victim.maxHealth + victim.max_stamina) * (debuff + caster.xeno_caste.aura_strength) * 0.1

	caster.emote("roar5")
	victim.emote("scream")
	owner.visible_message(span_xenowarning("\the [owner] emits an unusual roar!"), \
	span_xenowarning("We called out to the younger one inside [victim]!"))
	victim.visible_message(span_xenowarning("\The [victim] loses his balance, falling to the side!"), \
	span_xenowarning("You feel like something inside you is tearing out!"))

	victim.apply_effects(2 SECONDS, 1 SECONDS)
	victim.adjust_stagger(debuff SECONDS)
	victim.adjust_slowdown(debuff)
	victim.apply_damage(stamina_dmg, STAMINA)

	var/datum/internal_organ/O
	for(var/i in list("heart", "lungs", "liver"))
		O = victim.internal_organs_by_name[i]
		O.take_damage(debuff, TRUE)

	young.adjust_boost_timer(20, 40)

	if(young.stage <= 1)
		victim.throw_at(owner, 2, 1, owner)
	else if(young.stage > 1 && young.stage <= 5)
		victim.throw_at(owner, 3, 1, owner)
	else if(young.stage == 6)
		victim.throw_at(owner, 4, 1, owner)

	succeed_activate()
	add_cooldown()
