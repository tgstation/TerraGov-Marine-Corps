// ***************************************
// *********** Universal abilities
// ***************************************
// Resting
/datum/action/xeno_action/xeno_resting
	name = "Rest"
	action_icon_state = "resting"
	mechanics_text = "Rest on weeds to regenerate health and plasma."
	use_state_flags = XACT_USE_LYING|XACT_USE_CRESTED|XACT_USE_AGILITY

/datum/action/xeno_action/xeno_resting/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(!istype(X))
		return
	X.lay_down()
	return succeed_activate()

//*********
// Headbite
//*********
/datum/action/xeno_action/activable/headbite
	name = "Headbite"
	action_icon_state = "headbite"
	mechanics_text = "Permanently kill a target."
	use_state_flags = XACT_USE_STAGGERED|XACT_USE_FORTIFIED|XACT_USE_CRESTED //can't use while staggered, defender fortified or crest down
	keybind_signal = COMSIG_XENOABILITY_HEADBITE
	plasma_cost = 100
	gamemode_flags = ABILITY_HUNT

/datum/action/xeno_action/activable/headbite/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..() //do after checking the below stuff
	if(!.)
		return
	if(!iscarbon(A))
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/victim = A //target of ability
	if(X.do_actions) //can't use if busy
		return FALSE
	if(!X.Adjacent(victim)) //checks if owner next to target
		return FALSE
	if(X.on_fire)
		if(!silent)
			to_chat(X, span_warning("We're too busy being on fire to do this!"))
		return FALSE
	if(victim.stat != DEAD)
		if(!silent)
			to_chat(X, span_warning("This creature is struggling too much for us to aim precisely."))
		return FALSE
	if(victim.headbitten)
		if(!silent)
			to_chat(X, span_warning("This creature has already been headbitten."))
		return FALSE
	if(victim.chestburst)
		if(!silent)
			to_chat(X, span_warning("This creature has already served its purpose."))
		return FALSE
	if(X.issamexenohive(victim)) //checks if target and victim are in the same hive
		if(!silent)
			to_chat(X, span_warning("We can't bring ourselves to harm a fellow sister to this magnitude."))
		return FALSE
	if(issynth(victim)) //checks if target is a synth
		if(!silent)
			to_chat(X, span_warning("We have no reason to bite this non-living thing."))
		return FALSE
	X.face_atom(victim) //Face towards the target so we don't look silly
	X.visible_message(span_xenowarning("\The [X] begins opening its mouth and extending a second jaw towards \the [victim]."), \
	span_danger("We prepare our inner jaw for a finishing blow on \the [victim]!"), null, 20)
	if(!do_after(X, 10 SECONDS, FALSE, victim, BUSY_ICON_DANGER, extra_checks = CALLBACK(X, /mob.proc/break_do_after_checks, list("health" = X.health))))
		X.visible_message(span_xenowarning("\The [X] retracts its inner jaw."), \
		span_danger("We retract our inner jaw."), null, 20)
		return FALSE
	succeed_activate() //dew it

/datum/action/xeno_action/activable/headbite/use_ability(mob/M)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/victim = M

	X.visible_message(span_xenodanger("\The [X] viciously bites into \the [victim]'s head with its inner jaw!"), \
	span_xenodanger("We suddenly bite into the \the [victim]'s head with our second jaw!"))

	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		victim.emote_burstscream()
		var/datum/internal_organ/O
		O = H.internal_organs_by_name["brain"] //This removes (and later garbage collects) the organ. No brain means instant death.
		H.internal_organs_by_name -= "brain"
		H.internal_organs -= O
		ADD_TRAIT(H, TRAIT_PSY_DRAINED, TRAIT_PSY_DRAINED) //for xeno hud
		if(HAS_TRAIT(H, TRAIT_UNDEFIBBABLE)) //If true then force a hud update because SSmobs will not
			H.med_hud_set_status()
		else
			H.set_undefibbable()

	X.do_attack_animation(victim, ATTACK_EFFECT_BITE)
	playsound(victim, pick( 'sound/weapons/alien_tail_attack.ogg', 'sound/weapons/alien_bite1.ogg'), 50)
	victim.death()
	victim.headbitten = TRUE
	victim.update_headbite()

	log_combat(victim, owner, "was headbitten.")
	log_game("[key_name(victim)] was headbitten at [AREACOORD(victim.loc)].")

	GLOB.round_statistics.xeno_headbites++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_headbites")

// ***************************************
// *********** Drone-y abilities
// ***************************************
/datum/action/xeno_action/plant_weeds
	name = "Plant Weeds"
	action_icon_state = "plant_weeds"
	plasma_cost = 75
	mechanics_text = "Plant a weed node (purple sac) on your tile."
	keybind_signal = COMSIG_XENOABILITY_DROP_WEEDS
	use_state_flags = XACT_USE_LYING


/datum/action/xeno_action/plant_weeds/action_activate()
	var/turf/T = get_turf(owner)

	if(!T.check_alien_construction(owner, FALSE))
		return fail_activate()

	if(locate(/obj/structure/xeno/trap) in T)
		to_chat(owner, span_warning("There is a resin trap in the way!"))
		return fail_activate()

	if(!T.is_weedable())
		to_chat(owner, span_warning("Bad place for a garden!"))
		return fail_activate()

	if(locate(/obj/effect/alien/weeds/node) in T)
		to_chat(owner, span_warning("There's a pod here already!"))
		return fail_activate()

	owner.visible_message(span_xenonotice("\The [owner] regurgitates a pulsating node and plants it on the ground!"), \
		span_xenonotice("We regurgitate a pulsating node and plant it on the ground!"), null, 5)
	new /obj/effect/alien/weeds/node(owner.loc)
	playsound(owner.loc, "alien_resin_build", 25)
	GLOB.round_statistics.weeds_planted++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "weeds_planted")
	add_cooldown()
	return succeed_activate()

//AI stuff
/datum/action/xeno_action/plant_weeds/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/plant_weeds/ai_should_use(target)
	if(!can_use_action(override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	if(locate(/obj/effect/alien/weeds/node) in owner.loc) //NODE SPAMMMM
		//There's already a node on this loc don't plant anything
		return ..()
	return TRUE

/datum/action/xeno_action/plant_weeds/slow
	cooldown_timer = 12 SECONDS

/datum/action/xeno_action/plant_weeds/slow/action_activate()
	if(locate(/obj/effect/alien/weeds) in range(1, owner.loc))
		return ..()
	var/mob/living/carbon/xenomorph/hivemind/hiveminde = owner
	hiveminde.forceMove(get_turf(hiveminde.core))
	to_chat(hiveminde, span_xenonotice("We can't plant a node without weeds nearby, we've been moved back to our core."))
	return fail_activate()

// Secrete Resin
/datum/action/xeno_action/activable/secrete_resin
	name = "Secrete Resin"
	action_icon_state = "resin wall"
	mechanics_text = "Builds whatever resin you selected"
	ability_name = "secrete resin"
	plasma_cost = 75
	keybind_signal = COMSIG_XENOABILITY_SECRETE_RESIN
	///Minimum time to build a resin structure
	var/base_wait = 1 SECONDS
	///Multiplicator factor to add to the building time, depends on the health of the structure built
	var/scaling_wait = 1 SECONDS
	///List of buildable structures
	var/list/buildable_structures = list(
		/turf/closed/wall/resin/regenerating,
		/obj/effect/alien/resin/sticky,
		/obj/structure/mineral_door/resin)

/datum/action/xeno_action/activable/secrete_resin/update_button_icon()
	var/mob/living/carbon/xenomorph/X = owner
	var/atom/A = X.selected_resin
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, initial(A.name))
	return ..()

/datum/action/xeno_action/activable/secrete_resin/action_activate()

	var/mob/living/carbon/xenomorph/X = owner
	if(X.selected_ability != src)
		return ..()
	. = ..()
	var/i = buildable_structures.Find(X.selected_resin)
	if(length(buildable_structures) == i)
		X.selected_resin = buildable_structures[1]
	else
		X.selected_resin = buildable_structures[i+1]
	var/atom/A = X.selected_resin
	to_chat(X, span_notice("We will now build <b>[initial(A.name)]\s</b> when secreting resin."))
	update_button_icon()


/datum/action/xeno_action/activable/secrete_resin/use_ability(atom/A)
	build_resin(get_turf(owner))

/datum/action/xeno_action/activable/secrete_resin/proc/get_wait()
	. = base_wait
	if(!scaling_wait)
		return
	var/mob/living/carbon/xenomorph/X = owner

	var/build_resin_modifier = 1
	switch(X.selected_resin)
		if(/obj/effect/alien/resin/sticky)
			build_resin_modifier = 0.5
		if(/obj/structure/mineral_door/resin)
			build_resin_modifier = 2

	return (base_wait + scaling_wait - max(0, (scaling_wait * X.health / X.maxHealth))) * build_resin_modifier

/datum/action/xeno_action/activable/secrete_resin/proc/build_resin(turf/T)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/xenomorph/blocker = locate() in T
	if(blocker && blocker != X && blocker.stat != DEAD)
		to_chat(X, span_warning("Can't do that with [blocker] in the way!"))
		return fail_activate()

	if(!T.is_weedable())
		to_chat(X, span_warning("We can't do that here."))
		return fail_activate()

	var/obj/effect/alien/weeds/alien_weeds = locate() in T

	for(var/obj/effect/forcefield/fog/F in range(1, X))
		to_chat(X, span_warning("We can't build so close to the fog!"))
		return fail_activate()

	if(!alien_weeds)
		to_chat(X, span_warning("We can only shape on weeds. We must find some resin before we start building!"))
		return fail_activate()

	if(!T.check_alien_construction(X, planned_building = X.selected_resin) || !T.check_disallow_alien_fortification(X))
		return fail_activate()

	if(X.selected_resin == /obj/structure/mineral_door/resin)
		var/wall_support = FALSE
		for(var/D in GLOB.cardinals)
			var/turf/TS = get_step(T,D)
			if(TS)
				if(TS.density)
					wall_support = TRUE
					break
				else if(locate(/obj/structure/mineral_door/resin) in TS)
					wall_support = TRUE
					break
		if(!wall_support)
			to_chat(X, span_warning("Resin doors need a wall or resin door next to them to stand up."))
			return fail_activate()

	if(!do_after(X, get_wait(), TRUE, T, BUSY_ICON_BUILD))
		return fail_activate()

	blocker = locate() in T
	if(blocker && blocker != X && blocker.stat != DEAD)
		return fail_activate()

	if(!can_use_ability(T))
		return fail_activate()

	if(!T.is_weedable())
		return fail_activate()

	alien_weeds = locate() in T
	if(!alien_weeds)
		return fail_activate()

	if(!T.check_alien_construction(X, planned_building = X.selected_resin) || !T.check_disallow_alien_fortification(X))
		return fail_activate()

	if(X.selected_resin == /obj/structure/mineral_door/resin)
		var/wall_support = FALSE
		for(var/D in GLOB.cardinals)
			var/turf/TS = get_step(T,D)
			if(TS)
				if(TS.density)
					wall_support = TRUE
					break
				else if(locate(/obj/structure/mineral_door/resin) in TS)
					wall_support = TRUE
					break
		if(!wall_support)
			to_chat(X, span_warning("Resin doors need a wall or resin door next to them to stand up."))
			return fail_activate()
	var/atom/AM = X.selected_resin
	X.visible_message(span_xenowarning("\The [X] regurgitates a thick substance and shapes it into \a [initial(AM.name)]!"), \
	span_xenonotice("We regurgitate some resin and shape it into \a [initial(AM.name)]."), null, 5)
	playsound(owner.loc, "alien_resin_build", 25)

	var/atom/new_resin

	if(ispath(X.selected_resin, /turf)) // We should change turfs, not spawn them in directly
		var/list/baseturfs = islist(T.baseturfs) ? T.baseturfs : list(T.baseturfs)
		baseturfs |= T.type
		T.ChangeTurf(X.selected_resin, baseturfs)
		new_resin = T
	else
		new_resin = new X.selected_resin(T)

	switch(X.selected_resin)
		if(/obj/effect/alien/resin/sticky)
			plasma_cost = initial(plasma_cost) / 3
		if(/obj/structure/mineral_door/resin)
			plasma_cost = initial(plasma_cost) * 3

	if(new_resin)
		add_cooldown()
		succeed_activate()

	plasma_cost = initial(plasma_cost) //Reset the plasma cost

// Slower version of the secret resin
/datum/action/xeno_action/activable/secrete_resin/slow
	cooldown_timer = 5 SECONDS
	base_wait = 2.5 SECONDS
	scaling_wait = 0


/datum/action/xeno_action/toggle_pheromones
	name = "Open/Collapse Pheromone Options"
	action_icon_state = "emit_pheromones"
	mechanics_text = "Opens your pheromone options."
	plasma_cost = 0
	var/PheromonesOpen = FALSE //If the  pheromone choices buttons are already displayed or not

/datum/action/xeno_action/toggle_pheromones/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/toggle_pheromones/ai_should_use(target)
	if(PheromonesOpen)
		return ..()
	return TRUE

/datum/action/xeno_action/toggle_pheromones/can_use_action()
	return TRUE //No actual gameplay impact; should be able to collapse or open pheromone choices at any time

/datum/action/xeno_action/toggle_pheromones/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(PheromonesOpen)
		PheromonesOpen = FALSE
		for(var/datum/action/path in owner.actions)
			if(istype(path, /datum/action/xeno_action/pheromones))
				path.remove_action(X)
	else
		PheromonesOpen = TRUE
		var/list/subtypeactions = subtypesof(/datum/action/xeno_action/pheromones)
		for(var/path in subtypeactions)
			var/datum/action/xeno_action/pheromones/A = new path()
			A.give_action(X)

/datum/action/xeno_action/pheromones
	name = "SHOULD NOT EXIST"
	plasma_cost = 30 //Base plasma cost for begin to emit pheromones
	var/aura_type = null //String for aura to emit
	use_state_flags = XACT_USE_STAGGERED|XACT_USE_NOTTURF|XACT_USE_BUSY|XACT_USE_LYING

/datum/action/xeno_action/pheromones/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/pheromones/ai_should_use(target)
	var/mob/living/carbon/xenomorph/X = owner
	if(X.current_aura)
		return ..()
	if(prob(33)) //Since the pheromones go from recovery => warding => frenzy, this enables AI to somewhat randomly pick one of the three pheros to emit
		return ..()
	return TRUE

/datum/action/xeno_action/pheromones/action_activate() //Must pass the basic plasma cost; reduces copy pasta
	var/mob/living/carbon/xenomorph/X = owner
	if(!aura_type)
		return FALSE

	if(X.current_aura == aura_type)
		X.visible_message(span_xenowarning("\The [X] stops emitting strange pheromones."), \
		span_xenowarning("We stop emitting [X.current_aura] pheromones."), null, 5)
		X.current_aura = null
		if(isxenoqueen(X))
			X.hive?.update_leader_pheromones()
		X.hud_set_pheromone()
		return fail_activate() // dont use plasma

	X.current_aura = aura_type
	X.visible_message(span_xenowarning("\The [X] begins to emit strange-smelling pheromones."), \
	span_xenowarning("We begin to emit '[X.current_aura]' pheromones."), null, 5)
	playsound(X.loc, "alien_drool", 25)

	if(isxenoqueen(X))
		X.hive?.update_leader_pheromones()
	X.hud_set_pheromone() //Visual feedback that the xeno has immediately started emitting pheromones
	return succeed_activate()

/datum/action/xeno_action/pheromones/emit_recovery //Type casted for easy removal/adding
	name = "Emit Recovery Pheromones"
	action_icon_state = "emit_recovery"
	mechanics_text = "Increases healing for yourself and nearby teammates."
	aura_type = "recovery"
	keybind_signal = COMSIG_XENOABILITY_EMIT_RECOVERY

/datum/action/xeno_action/pheromones/emit_warding
	name = "Emit Warding Pheromones"
	action_icon_state = "emit_warding"
	mechanics_text = "Increases armor for yourself and nearby teammates."
	aura_type = "warding"
	keybind_signal = COMSIG_XENOABILITY_EMIT_WARDING

/datum/action/xeno_action/pheromones/emit_frenzy
	name = "Emit Frenzy Pheromones"
	action_icon_state = "emit_frenzy"
	mechanics_text = "Increases damage for yourself and nearby teammates."
	aura_type = "frenzy"
	keybind_signal = COMSIG_XENOABILITY_EMIT_FRENZY


/datum/action/xeno_action/activable/transfer_plasma
	name = "Transfer Plasma"
	action_icon_state = "transfer_plasma"
	mechanics_text = "Give some of your plasma to a teammate."
	ability_name = "transfer plasma"
	var/plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT
	var/transfer_delay = 2 SECONDS
	var/max_range = 2
	keybind_signal = COMSIG_XENOABILITY_TRANSFER_PLASMA
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/transfer_plasma/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!isxeno(A) || A == owner || !owner.issamexenohive(A))
		return FALSE

	var/mob/living/carbon/xenomorph/target = A

	if(!(target.xeno_caste.caste_flags & CASTE_CAN_BE_GIVEN_PLASMA))
		if(!silent)
			to_chat(owner, span_warning("We can't give that caste plasma."))
			return FALSE

	if(get_dist(owner, target) > max_range)
		if(!silent)
			to_chat(owner, span_warning("We need to be closer to [target]."))
		return FALSE

	if(target.plasma_stored >= target.xeno_caste.plasma_max) //We can't select targets that won't benefit
		to_chat(owner, span_xenowarning("[target] already has full plasma."))
		return FALSE

/datum/action/xeno_action/activable/transfer_plasma/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/xenomorph/target = A

	to_chat(X, span_notice("We start focusing our plasma towards [target]."))
	new /obj/effect/temp_visual/transfer_plasma(get_turf(X)) //Cool SFX that confirms our source and our target
	new /obj/effect/temp_visual/transfer_plasma(get_turf(target)) //Cool SFX that confirms our source and our target
	playsound(X, "alien_drool", 25)

	X.face_atom(target) //Face our target so we don't look silly

	if(!do_after(X, transfer_delay, TRUE, null, BUSY_ICON_FRIENDLY))
		return fail_activate()

	if(!can_use_ability(A))
		return fail_activate()

	target.beam(X,"drain_life", time = 1 SECONDS, maxdistance = 10) //visual SFX
	target.add_filter("transfer_plasma_outline", 3, outline_filter(1, COLOR_STRONG_MAGENTA))
	addtimer(CALLBACK(target, /atom.proc/remove_filter, "transfer_plasma_outline"), 1 SECONDS) //Failsafe blur removal

	var/amount = plasma_transfer_amount
	if(X.plasma_stored < plasma_transfer_amount)
		amount = X.plasma_stored //Just use all of it

	else //Otherwise transfer as much as the target can use
		amount = clamp(target.xeno_caste.plasma_max - target.plasma_stored, 0, plasma_transfer_amount)

	X.use_plasma(amount)
	target.gain_plasma(amount)
	to_chat(target, span_xenodanger("[X] has transfered [amount] units of plasma to us. We now have [target.plasma_stored]/[target.xeno_caste.plasma_max]."))
	to_chat(X, span_xenodanger("We have transferred [amount] units of plasma to [target]. We now have [X.plasma_stored]/[X.xeno_caste.plasma_max]."))
	playsound(X, "alien_drool", 25)

//Xeno Larval Growth Sting
/datum/action/xeno_action/activable/larval_growth_sting
	name = "Larval Growth Sting"
	action_icon_state = "drone_sting"
	mechanics_text = "Inject an impregnated host with growth serum, causing the larva inside to grow quicker."
	ability_name = "larval growth sting"
	plasma_cost = 150
	cooldown_timer = 12 SECONDS
	keybind_signal = COMSIG_XENOABILITY_LARVAL_GROWTH_STING
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/larval_growth_sting/on_cooldown_finish()
	playsound(owner.loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(owner, span_xenodanger("We feel our growth toxin glands refill. We can use Growth Sting again."))
	return ..()

/datum/action/xeno_action/activable/larval_growth_sting/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(QDELETED(A))
		return FALSE

	if(!A?.can_sting())
		if(!silent)
			to_chat(owner, span_warning("Our sting won't affect this target!"))
		return FALSE

	if(!owner.Adjacent(A))
		var/mob/living/carbon/xenomorph/X = owner
		if(!silent && world.time > (X.recent_notice + X.notice_delay))
			to_chat(X, span_warning("We can't reach this target!"))
			X.recent_notice = world.time //anti-notice spam
		return FALSE

	var/mob/living/carbon/C = A
	if (isnestedhost(C))
		if(!silent)
			to_chat(owner, span_warning("Ashamed, we reconsider bullying the poor, nested host with our stinger."))
		return FALSE

/datum/action/xeno_action/activable/larval_growth_sting/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	succeed_activate()

	GLOB.round_statistics.larval_growth_stings++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "larval_growth_stings")

	add_cooldown()
	X.recurring_injection(A, /datum/reagent/toxin/xeno_growthtoxin, XENO_LARVAL_CHANNEL_TIME, XENO_LARVAL_AMOUNT_RECURRING)

// ***************************************
// *********** Corrosive Acid
// ***************************************

/datum/action/xeno_action/activable/corrosive_acid
	name = "Corrosive Acid"
	action_icon_state = "corrosive_acid"
	mechanics_text = "Cover an object with acid to slowly melt it. Takes a few seconds."
	ability_name = "corrosive acid"
	plasma_cost = 100
	var/acid_type = /obj/effect/xenomorph/acid
	keybind_signal = COMSIG_XENOABILITY_CORROSIVE_ACID
	use_state_flags = XACT_USE_BUCKLED

/datum/action/xeno_action/activable/corrosive_acid/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!owner.Adjacent(A))
		if(!silent)
			to_chat(owner, span_warning("\The [A] is too far away."))
		return FALSE
	if(isobj(A))
		var/obj/O = A
		if(CHECK_BITFIELD(O.resistance_flags, RESIST_ALL))
			if(!silent)
				to_chat(owner, span_warning("We cannot dissolve \the [O]."))
			return FALSE
		if(O.acid_check(acid_type))
			if(!silent)
				to_chat(owner, span_warning("This object is already subject to a more or equally powerful acid."))
			return FALSE
		if(istype(O, /obj/structure/window_frame))
			var/obj/structure/window_frame/WF = O
			if(WF.reinforced && acid_type != /obj/effect/xenomorph/acid/strong)
				if(!silent)
					to_chat(owner, span_warning("This [WF.name] is too tough to be melted by our weak acid."))
				return FALSE
	else if(isturf(A))
		var/turf/T = A
		if(T.acid_check(acid_type))
			if(!silent)
				to_chat(owner, span_warning("This object is already subject to a more or equally powerful acid."))
			return FALSE
		if(iswallturf(T))
			var/turf/closed/wall/wall_target = T
			if(wall_target.acided_hole)
				if(!silent)
					to_chat(owner, span_warning("[wall_target] is already weakened."))
				return FALSE

/obj/proc/acid_check(obj/effect/xenomorph/acid/new_acid)
	if(!new_acid)
		return TRUE
	if(!current_acid)
		return FALSE

	if(initial(new_acid.acid_strength) > current_acid.acid_strength)
		return FALSE
	return TRUE

/turf/proc/acid_check(obj/effect/xenomorph/acid/new_acid)
	if(!new_acid)
		return TRUE
	if(!current_acid)
		return FALSE

	if(initial(new_acid.acid_strength) > current_acid.acid_strength)
		return FALSE
	return TRUE

/datum/action/xeno_action/activable/corrosive_acid/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	X.face_atom(A)

	var/wait_time = 10

	var/turf/T
	var/obj/O

	if(isobj(A))
		O = A
		if(O.density || istype(O, /obj/structure))
			wait_time = 40 //dense objects are big, so takes longer to melt.

	else if(isturf(A))
		T = A
		var/dissolvability = T.can_be_dissolved()
		switch(dissolvability)
			if(0)
				to_chat(X, span_warning("We cannot dissolve \the [T]."))
				return fail_activate()
			if(1)
				wait_time = 50
			if(2)
				if(acid_type != /obj/effect/xenomorph/acid/strong)
					to_chat(X, span_warning("This [T.name] is too tough to be melted by our weak acid."))
					return fail_activate()
				wait_time = 100
			else
				return fail_activate()
		to_chat(X, span_xenowarning("We begin generating enough acid to melt through \the [T]."))
	else
		to_chat(X, span_warning("We cannot dissolve \the [A]."))
		return fail_activate()

	if(!do_after(X, wait_time, TRUE, A, BUSY_ICON_HOSTILE))
		return fail_activate()

	if(!can_use_ability(A, TRUE))
		return

	var/obj/effect/xenomorph/acid/newacid = new acid_type(get_turf(A), A)

	succeed_activate()

	if(istype(A, /obj/vehicle/multitile/root/cm_armored))
		var/obj/vehicle/multitile/root/cm_armored/R = A
		R.take_damage_type( (1 * newacid.acid_strength) * 20, "acid", X)
		X.visible_message(span_xenowarning("\The [X] vomits globs of vile stuff at \the [R]. It sizzles under the bubbling mess of acid!"), \
			span_xenowarning("We vomit globs of vile stuff at \the [R]. It sizzles under the bubbling mess of acid!"), null, 5)
		playsound(X.loc, "sound/bullets/acid_impact1.ogg", 25)
		QDEL_IN(newacid, 20)
		return TRUE

	if(isturf(A))
		newacid.icon_state += "_wall"
		if(T.current_acid)
			acid_progress_transfer(newacid, null, T)
		T.current_acid = newacid

	else if(istype(A, /obj/structure) || istype(A, /obj/machinery)) //Always appears above machinery
		newacid.layer = A.layer + 0.1
		if(O.current_acid)
			acid_progress_transfer(newacid, O)
		O.current_acid = newacid

	else if(istype(O)) //If not, appear on the floor or on an item
		if(O.current_acid)
			acid_progress_transfer(newacid, O)
		newacid.layer = LOWER_ITEM_LAYER //below any item, above BELOW_OBJ_LAYER (smartfridge)
		O.current_acid = newacid
	else
		return fail_activate()

	newacid.name = newacid.name + " (on [A.name])" //Identify what the acid is on

	if(!isturf(A))
		log_combat(X, A, "spat on", addition="with corrosive acid")
	X.visible_message(span_xenowarning("\The [X] vomits globs of vile stuff all over \the [A]. It begins to sizzle and melt under the bubbling mess of acid!"), \
	span_xenowarning("We vomit globs of vile stuff all over \the [A]. It begins to sizzle and melt under the bubbling mess of acid!"), null, 5)
	playsound(X.loc, "sound/bullets/acid_impact1.ogg", 25)

/datum/action/xeno_action/activable/corrosive_acid/proc/acid_progress_transfer(acid_type, obj/O, turf/T)
	if(!O && !T)
		return

	var/obj/effect/xenomorph/acid/new_acid = acid_type

	var/obj/effect/xenomorph/acid/current_acid

	if(T)
		current_acid = T.current_acid

	else if(O)
		current_acid = O.current_acid

	if(!current_acid) //Sanity check. No acid
		return
	new_acid.ticks = current_acid.ticks //Inherit the old acid's progress
	qdel(current_acid)


// ***************************************
// *********** Super strong acid
// ***************************************

/datum/action/xeno_action/activable/corrosive_acid/strong
	name = "Corrosive Acid"
	plasma_cost = 200
	acid_type = /obj/effect/xenomorph/acid/strong


/datum/action/xeno_action/activable/spray_acid
	keybind_signal = COMSIG_XENOABILITY_SPRAY_ACID
	use_state_flags = XACT_USE_BUCKLED

/datum/action/xeno_action/activable/spray_acid/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE

	var/turf/T = get_turf(owner)
	var/turf/T2 = get_turf(A)
	if(T == T2)
		if(!silent)
			to_chat(owner, span_warning("That's far too close!"))
		return FALSE


/datum/action/xeno_action/activable/spray_acid/on_cooldown_finish()
	playsound(owner.loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(owner, span_xenodanger("We feel our acid glands refill. We can spray acid again."))
	return ..()

/datum/action/xeno_action/activable/spray_acid/proc/acid_splat_turf(turf/T)
	. = locate(/obj/effect/xenomorph/spray) in T
	if(!.)
		var/mob/living/carbon/xenomorph/X = owner

		. = new /obj/effect/xenomorph/spray(T, X.xeno_caste.acid_spray_duration, X.xeno_caste.acid_spray_damage, owner)

		for(var/i in T)
			var/atom/A = i
			if(!A)
				continue
			A.acid_spray_act(owner)


/datum/action/xeno_action/activable/xeno_spit
	name = "Xeno Spit"
	action_icon_state = "shift_spit_neurotoxin"
	mechanics_text = "Spit neurotoxin or acid at your target up to 7 tiles away."
	ability_name = "xeno spit"
	keybind_signal = COMSIG_XENOABILITY_XENO_SPIT
	use_state_flags = XACT_USE_LYING|XACT_USE_BUCKLED
	plasma_cost = 10
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/xeno_spit/update_button_icon()
	var/mob/living/carbon/xenomorph/X = owner
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, "shift_spit_[X.ammo.icon_state]")

/datum/action/xeno_action/activable/xeno_spit/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.selected_ability != src)
		return ..()
	for(var/i in 1 to X.xeno_caste.spit_types.len)
		if(X.ammo == GLOB.ammo_list[X.xeno_caste.spit_types[i]])
			if(i == X.xeno_caste.spit_types.len)
				X.ammo = GLOB.ammo_list[X.xeno_caste.spit_types[1]]
				break
			X.ammo = GLOB.ammo_list[X.xeno_caste.spit_types[i+1]]
			break
	to_chat(X, span_notice("We will now spit [X.ammo.name] ([X.ammo.spit_cost] plasma)."))
	update_button_icon()

/datum/action/xeno_action/activable/xeno_spit/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	if(!X.check_state())
		return FALSE
	if(X.ammo?.spit_cost > X.plasma_stored)
		if(!silent)
			to_chat(X, span_warning("We need [X.ammo?.spit_cost - X.plasma_stored] more plasma!"))
		return FALSE

/datum/action/xeno_action/activable/xeno_spit/get_cooldown()
	var/mob/living/carbon/xenomorph/X = owner
	return (X.xeno_caste.spit_delay + X.ammo?.added_spit_delay)

/datum/action/xeno_action/activable/xeno_spit/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, span_notice("We feel our neurotoxin glands swell with ichor. We can spit again."))
	return ..()

/datum/action/xeno_action/activable/xeno_spit/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	var/turf/current_turf = get_turf(owner)

	if(!current_turf)
		return fail_activate()

	X.visible_message(span_xenowarning("\The [X] spits at \the [A]!"), \
	span_xenowarning("We spit at \the [A]!") )
	var/sound_to_play = pick(1, 2) == 1 ? 'sound/voice/alien_spitacid.ogg' : 'sound/voice/alien_spitacid2.ogg'
	playsound(X.loc, sound_to_play, 25, 1)

	var/obj/projectile/newspit = new /obj/projectile(current_turf)
	plasma_cost = X.ammo.spit_cost
	newspit.generate_bullet(X.ammo, X.ammo.damage * SPIT_UPGRADE_BONUS(X))
	newspit.permutated += X
	newspit.def_zone = X.get_limbzone_target()

	newspit.fire_at(A, X, null, X.ammo.max_range, X.ammo.shell_speed)

	add_cooldown()

	return succeed_activate()

/datum/action/xeno_action/activable/xeno_spit/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/xeno_spit/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > 6)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE


/datum/action/xeno_action/xenohide
	name = "Hide"
	action_icon_state = "xenohide"
	mechanics_text = "Causes your sprite to hide behind certain objects and under tables. Not the same as stealth. Does not use plasma."
	keybind_signal = COMSIG_XENOABILITY_HIDE

/datum/action/xeno_action/xenohide/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.layer != XENO_HIDING_LAYER)
		X.layer = XENO_HIDING_LAYER
		to_chat(X, span_notice("We are now hiding."))
	else
		X.layer = MOB_LAYER
		to_chat(X, span_notice("We have stopped hiding."))


//Neurotox Sting
/datum/action/xeno_action/activable/neurotox_sting
	name = "Neurotoxin Sting"
	action_icon_state = "neuro_sting"
	mechanics_text = "A channeled melee attack that injects the target with neurotoxin over a few seconds, temporarily stunning them."
	ability_name = "neurotoxin sting"
	cooldown_timer = 12 SECONDS
	plasma_cost = 150
	keybind_signal = COMSIG_XENOABILITY_NEUROTOX_STING
	target_flags = XABB_MOB_TARGET
	use_state_flags = XACT_USE_BUCKLED

/datum/action/xeno_action/activable/neurotox_sting/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!A?.can_sting())
		if(!silent)
			to_chat(owner, span_warning("Our sting won't affect this target!"))
		return FALSE
	if(!owner.Adjacent(A))
		var/mob/living/carbon/xenomorph/X = owner
		if(!silent && world.time > (X.recent_notice + X.notice_delay)) //anti-notice spam
			to_chat(X, span_warning("We can't reach this target!"))
			X.recent_notice = world.time //anti-notice spam
		return FALSE
	var/mob/living/carbon/C = A
	if (isnestedhost(C))
		if(!silent)
			to_chat(owner, span_warning("Ashamed, we reconsider bullying the poor, nested host with our stinger."))
		return FALSE

/datum/action/xeno_action/activable/neurotox_sting/on_cooldown_finish()
	playsound(owner.loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(owner, span_xenodanger("We feel our neurotoxin glands refill. We can use our Neurotoxin Sting again."))
	return ..()

/datum/action/xeno_action/activable/neurotox_sting/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	succeed_activate()

	add_cooldown()

	GLOB.round_statistics.sentinel_neurotoxin_stings++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "sentinel_neurotoxin_stings")

	X.recurring_injection(A, /datum/reagent/toxin/xeno_neurotoxin, XENO_NEURO_CHANNEL_TIME, XENO_NEURO_AMOUNT_RECURRING)


// ***************************************
// *********** Psychic Whisper
// ***************************************
/datum/action/xeno_action/psychic_whisper
	name = "Psychic Whisper"
	action_icon_state = "psychic_whisper"
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_WHISPER
	use_state_flags = XACT_USE_LYING
	target_flags = XABB_MOB_TARGET


/datum/action/xeno_action/psychic_whisper/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	var/list/target_list = list()
	for(var/mob/living/possible_target in view(WORLD_VIEW, X))
		if(possible_target == X || !possible_target.client || isxeno(possible_target))
			continue
		target_list += possible_target

	if(!length(target_list))
		to_chat(X, span_warning("There's nobody nearby to whisper to."))
		return

	var/mob/living/L = tgui_input_list(X, "Target", "Send a Psychic Whisper to whom?", target_list)
	if(!L)
		return

	if(!X.check_state())
		return

	var/msg = stripped_input("Message:", "Psychic Whisper")
	if(!msg)
		return

	log_directed_talk(X, L, msg, LOG_SAY, "psychic whisper")
	to_chat(L, span_alien("You hear a strange, alien voice in your head. <i>\"[msg]\"</i>"))
	to_chat(X, span_xenonotice("We said: \"[msg]\" to [L]"))


// ***************************************
// *********** Lay Egg
// ***************************************
/datum/action/xeno_action/lay_egg
	name = "Lay Egg"
	action_icon_state = "lay_egg"
	plasma_cost = 200
	cooldown_timer = 12 SECONDS
	keybind_signal = COMSIG_XENOABILITY_LAY_EGG


/datum/action/xeno_action/lay_egg/action_activate()
	var/mob/living/carbon/xenomorph/xeno = owner
	var/turf/current_turf = get_turf(owner)

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf
	if(!alien_weeds)
		to_chat(owner, span_warning("Our eggs wouldn't grow well enough here. Lay them on resin."))
		return FALSE

	if(!do_after(owner, 3 SECONDS, FALSE, alien_weeds))
		return FALSE

	if(!current_turf.check_alien_construction(owner) || !current_turf.check_disallow_alien_fortification(owner))
		return FALSE

	owner.visible_message(span_xenowarning("\The [owner] has laid an egg!"), \
		span_xenowarning("We have laid an egg!"))

	new /obj/item/xeno_egg(current_turf, xeno.hivenumber)
	playsound(owner.loc, 'sound/effects/splat.ogg', 25)

	succeed_activate()
	add_cooldown()

////////////////////
/// Build hunt den
///////////////////
/datum/action/xeno_action/activable/build_hunt_den
	name = "Create Hunting Den"
	action_icon_state = "resin_silo"
	mechanics_text = "Create a new hunting den, using 3 headbiten corpses."
	ability_name = "build hunt den"
	plasma_cost = 150
	keybind_signal = COMSIG_XENOABILITY_SECRETE_RESIN_SILO
	cooldown_timer = 60 SECONDS
	gamemode_flags = ABILITY_HUNT
	/// How long does it take to build
	var/build_time = 10 SECONDS
	/// how many dead / non-chestbursted mobs are required to build the silo
	var/required_mobs = 3

/datum/action/xeno_action/activable/build_hunt_den/use_ability(atom/A)
	var/list/mob/living/valid_mobs = list()
	for(var/thing in get_turf(A))
		if(!ishuman(thing))
			continue
		var/mob/living/turf_mob = thing
		if(turf_mob.stat == DEAD && turf_mob.chestburst == 0)
			valid_mobs += turf_mob

	if(length(valid_mobs) < required_mobs)
		to_chat(owner, span_warning("There are not enough dead bodies, we need [required_mobs] bodies for a silo!"))
		return fail_activate()

	if(!do_after(owner, build_time, TRUE, A, BUSY_ICON_BUILD))
		return fail_activate()

	var/obj/structure/xeno/resin/silo/hivesilo = new(get_step(A, SOUTHWEST))

	var/moved_human_number = 0
	for(var/mob/living/to_use AS in valid_mobs)
		if(moved_human_number >= required_mobs)
			break
		to_use.chestburst = 2
		to_use.update_burst()
		to_use.forceMove(hivesilo)
		moved_human_number++

	succeed_activate()

////////////////////
/// Build silo
///////////////////
/datum/action/xeno_action/activable/build_silo
	name = "Secrete resin silo"
	action_icon_state = "resin_silo"
	mechanics_text = "Creates a new silo"
	ability_name = "secrete resin silo"
	plasma_cost = 150
	keybind_signal = COMSIG_XENOABILITY_SECRETE_RESIN_SILO
	cooldown_timer = 60 SECONDS
	gamemode_flags = ABILITY_DISTRESS
	/// How long does it take to build
	var/build_time = 10 SECONDS
	psych_cost = SILO_PRICE

/datum/action/xeno_action/activable/build_silo/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return FALSE

	var/turf/T = get_turf(A)
	if(T?.density)
		to_chat(owner, span_xenowarning("You need open ground to place that!"))
		return FALSE

	for(var/direction in GLOB.cardinals - REVERSE_DIR(Get_Angle(owner, A)))
		T = get_step(A, direction)
		if(!T || T.density)
			to_chat(owner, span_xenowarning("You need open ground to place that!"))
			return FALSE

	if(!in_range(owner, A))
		if(!silent)
			to_chat(owner, span_warning("We need to get closer!."))
		return FALSE

	var/mob/living/carbon/xenomorph/X = owner
	if(SSpoints.xeno_points_by_hive[X.hivenumber] < psych_cost)
		to_chat(owner, span_xenowarning("The hive doesn't have the necessary psychic points for you to do that!"))
		return FALSE

	for(var/obj/structure/xeno/resin/silo/silo AS in GLOB.xeno_resin_silos)
		if(get_dist(silo, A) < 15)
			to_chat(owner, span_xenowarning("Another silo is too close!"))
			return FALSE

/datum/action/xeno_action/activable/build_silo/use_ability(atom/A)
	if(!do_after(owner, build_time, TRUE, A, BUSY_ICON_BUILD))
		return fail_activate()

	var/mob/living/carbon/xenomorph/X = owner
	if(SSpoints.xeno_points_by_hive[X.hivenumber] < psych_cost)
		to_chat(owner, span_xenowarning("Someone used all the psych points while we were building!"))
		return fail_activate()

	to_chat(owner, span_notice("We build a new silo for [psych_cost] psy points."))
	SSpoints.xeno_points_by_hive[X.hivenumber] -= psych_cost
	log_game("[owner] has built a silo in [AREACOORD(A)], spending [psych_cost] psy points in the process")
	succeed_activate()
	new /obj/structure/xeno/resin/silo (get_step(A, SOUTHWEST))
	xeno_message("[X.name] has built a silo at [get_area(A)]!", "xenoannounce", 5, X.hivenumber)


////////////////////
/// Build xeno turret
///////////////////

/datum/action/xeno_action/activable/build_turret
	name = "Secrete acid turret"
	action_icon_state = "xeno_turret"
	mechanics_text = "Creates a new xeno acid turret for 100 points"
	ability_name = "secrete acid turret"
	plasma_cost = 150
	cooldown_timer = 60 SECONDS
	gamemode_flags = ABILITY_DISTRESS
	/// How long does it take to build
	var/build_time = 15 SECONDS
	psych_cost = XENO_TURRET_PRICE

/datum/action/xeno_action/activable/build_turret/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!in_range(owner, A))
		if(!silent)
			to_chat(owner, span_warning("We need to get closer!."))
		return FALSE
	var/turf/T = get_turf(A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/xenomorph/blocker = locate() in T
	if(blocker && blocker != X && blocker.stat != DEAD)
		to_chat(X, span_warning("Can't do that with [blocker] in the way!"))
		return FALSE

	if(!T.is_weedable())
		to_chat(X, span_warning("We can't do that here."))
		return FALSE

	var/obj/effect/alien/weeds/alien_weeds = locate() in T

	for(var/obj/effect/forcefield/fog/F in range(1, X))
		to_chat(X, span_warning("We can't build so close to the fog!"))
		return FALSE

	for(var/obj/structure/xeno/resin/xeno_turret/turret AS in GLOB.xeno_resin_turrets)
		if(get_dist(turret, A) < 6)
			to_chat(owner, span_xenowarning("Another turret is too close!") )
			return FALSE

	if(!alien_weeds)
		to_chat(X, span_warning("We can only shape on weeds. We must find some resin before we start building!"))
		return FALSE

	if(!T.check_alien_construction(X, planned_building = /obj/structure/xeno/resin/xeno_turret) || !T.check_disallow_alien_fortification(X))
		return FALSE

	if(SSpoints.xeno_points_by_hive[X.hivenumber] < psych_cost)
		to_chat(owner, span_xenowarning("The hive doesn't have the necessary psychic points for you to do that!"))
		return FALSE

/datum/action/xeno_action/activable/build_turret/use_ability(atom/A)
	if(!do_after(owner, build_time, TRUE, A, BUSY_ICON_BUILD))
		return fail_activate()

	var/mob/living/carbon/xenomorph/X = owner

	if(SSpoints.xeno_points_by_hive[X.hivenumber] < psych_cost)
		to_chat(owner, span_xenowarning("Someone used all the psych points while we were building!"))
		return fail_activate()

	to_chat(owner, span_xenowarning("We build a new acid turret, spending 100 psychic points in the process"))
	new /obj/structure/xeno/resin/xeno_turret(get_turf(A), X.hivenumber)

	SSpoints.xeno_points_by_hive[X.hivenumber] -= psych_cost
	log_game("[owner] built a turret in [AREACOORD(A)], spending [psych_cost] psy points in the process")
	xeno_message("[X.name] has built a new turret at [get_area(A)]!", "xenoannounce", 5, X.hivenumber)

	succeed_activate()

/////////////////////////////////////////////////////////////////////////////////////////////

////////////////////
/// Rally Hive
///////////////////
/datum/action/xeno_action/activable/rally_hive
	name = "Rally Hive"
	action_icon_state = "rally_hive"
	mechanics_text = "Rallies the hive to a congregate at a target location, along with an arrow pointer. Gives the Hive your current health status. 60 second cooldown."
	ability_name = "rally hive"
	plasma_cost = 0
	keybind_signal = COMSIG_XENOABILITY_RALLY_HIVE
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	cooldown_timer = 60 SECONDS
	use_state_flags = XACT_USE_LYING|XACT_USE_BUCKLED


/datum/action/xeno_action/activable/rally_hive/use_ability()

	var/mob/living/carbon/xenomorph/X = owner

	xeno_message("Our leader [X] is rallying the hive to [AREACOORD_NO_Z(X.loc)]!", "xenoannounce", 6, X.hivenumber, FALSE, X, 'sound/voice/alien_distantroar_3.ogg',TRUE,null,/obj/screen/arrow/leader_tracker_arrow)
	notify_ghosts("\ [X] is rallying the hive to [AREACOORD_NO_Z(X.loc)]!", source = X, action = NOTIFY_JUMP)

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.xeno_rally_hive++ //statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_rally_hive")

/////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/carbon/xenomorph/proc/add_abilities()
	for(var/action_path in xeno_caste.actions)
		var/datum/action/xeno_action/action = new action_path()
		if(SSticker.mode.flags_xeno_abilities & action.gamemode_flags)
			action.give_action(src)


/mob/living/carbon/xenomorph/proc/remove_abilities()
	for(var/action_datum in xeno_abilities)
		qdel(action_datum)

/datum/action/xeno_action/activable/rally_hive/hivemind //Halve the cooldown for Hiveminds as their relative omnipresence means they can actually make use of this lower cooldown.
	cooldown_timer = 30 SECONDS

//*********
// Psy Drain
//*********
/datum/action/xeno_action/activable/psydrain
	name = "Psy drain"
	action_icon_state = "headbite"
	mechanics_text = "Drain the victim of its life force to gain larva and psych points"
	use_state_flags = XACT_USE_STAGGERED|XACT_USE_FORTIFIED|XACT_USE_CRESTED //can't use while staggered, defender fortified or crest down
	keybind_signal = COMSIG_XENOABILITY_HEADBITE
	gamemode_flags = ABILITY_DISTRESS
	plasma_cost = 100
	///How much psy points it give
	var/psy_points_reward = PSY_DRAIN_REWARD
	///How much larva points it gives (8 points for one larva in distress)
	var/larva_point_reward = 1

/datum/action/xeno_action/activable/psydrain/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..() //do after checking the below stuff
	if(!.)
		return
	if(!iscarbon(A))
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/victim = A //target of ability
	if(X.do_actions) //can't use if busy
		return FALSE
	if(!X.Adjacent(victim)) //checks if owner next to target
		return FALSE
	if(X.on_fire)
		if(!silent)
			to_chat(X, span_warning("We're too busy being on fire to do this!"))
		return FALSE
	if(victim.stat != DEAD)
		if(!silent)
			to_chat(X, span_warning("This creature is struggling too much for us to drain its life force."))
		return FALSE
	if(HAS_TRAIT(victim, TRAIT_PSY_DRAINED))
		if(!silent)
			to_chat(X, span_warning("There is no longer any life force in this creature!"))
		return FALSE
	if(!ishuman(victim))
		if(!silent)
			to_chat(X, span_warning("We can't drain something that is not human."))
		return FALSE
	if(issynth(victim)) //checks if target is a synth
		if(!silent)
			to_chat(X, span_warning("This artificial construct has no life force to drain"))
		return FALSE
	X.face_atom(victim) //Face towards the target so we don't look silly
	X.visible_message(span_xenowarning("\The [X] begins opening its mouth and extending a second jaw towards \the [victim]."), \
	span_danger("We slowly drain \the [victim]'s life force!"), null, 20)
	var/channel = SSsounds.random_available_channel()
	playsound(X, 'sound/magic/nightfall.ogg', 40, channel = channel)
	if(!do_after(X, 5 SECONDS, FALSE, victim, BUSY_ICON_DANGER, extra_checks = CALLBACK(X, /mob.proc/break_do_after_checks, list("health" = X.health))))
		X.visible_message(span_xenowarning("\The [X] retracts its inner jaw."), \
		span_danger("We retract our inner jaw."), null, 20)
		X.stop_sound_channel(channel)
		return FALSE
	X.stop_sound_channel(channel)
	succeed_activate() //dew it

/datum/action/xeno_action/activable/psydrain/use_ability(mob/M)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/victim = M

	if(HAS_TRAIT(victim, TRAIT_PSY_DRAINED))
		to_chat(X, span_warning("Someone drained the life force of our victim before we could do it!"))
		return fail_activate()

	playsound(X, 'sound/magic/end_of_psy_drain.ogg', 40)

	X.visible_message(span_xenodanger("\The [victim]'s life force is drained by \the [X]!"), \
	span_xenodanger("We suddenly feel \the [victim]'s life force streaming into us!"))

	victim.do_jitter_animation(2)

	ADD_TRAIT(victim, TRAIT_PSY_DRAINED, TRAIT_PSY_DRAINED)
	if(HAS_TRAIT(victim, TRAIT_UNDEFIBBABLE))
		victim.med_hud_set_status()

	SSpoints.add_psy_points(X.hivenumber, psy_points_reward)
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	xeno_job.add_job_points(larva_point_reward)
	GLOB.round_statistics.larva_from_psydrain +=larva_point_reward / xeno_job.job_points_needed

	log_combat(victim, owner, "was drained.")
	log_game("[key_name(victim)] was drained at [AREACOORD(victim.loc)].")

/////////////////////////////////
// Devour
/////////////////////////////////
/datum/action/xeno_action/activable/devour
	name = "Devour"
	action_icon_state = "regurgitate"
	mechanics_text = "Devour your victim to be able to carry it faster."
	use_state_flags = XACT_USE_STAGGERED|XACT_USE_FORTIFIED|XACT_USE_CRESTED //can't use while staggered, defender fortified or crest down
	keybind_signal = COMSIG_XENOABILITY_REGURGITATE
	plasma_cost = 100
	gamemode_flags = ABILITY_HUNT

/datum/action/xeno_action/activable/devour/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/xenomorph/X = owner
	if(LAZYLEN(X.stomach_contents)) //Only one thing in the stomach at a time, please
		succeed_activate()
	if(!ishuman(A) || issynth(A))
		to_chat(owner, span_warning("That wouldn't taste very good."))
		return FALSE
	var/mob/living/carbon/human/victim = A
	if(owner.do_actions) //can't use if busy
		return FALSE
	if(!owner.Adjacent(victim)) //checks if owner next to target
		return FALSE
	if(victim.stat != DEAD)
		if(!silent)
			to_chat(owner, span_warning("This creature is struggling too much for us to devour it."))
		return FALSE
	if(victim.buckled)
		if(!silent)
			to_chat(owner, span_warning("[victim] is buckled to something."))
		return FALSE
	if(X.on_fire)
		if(!silent)
			to_chat(X, span_warning("We're too busy being on fire to do this!"))
		return FALSE
	for(var/obj/effect/forcefield/fog in range(1, X))
		if(!silent)
			to_chat(X, span_warning("We are too close to the fog."))
		return FALSE
	X.face_atom(victim)
	X.visible_message(span_danger("[X] starts to devour [victim]!"), \
	span_danger("We start to devour [victim]!"), null, 5)

	succeed_activate()

/datum/action/xeno_action/activable/devour/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(!LAZYLEN(X.stomach_contents))
		. = ..()
		return
	var/channel = SSsounds.random_available_channel()
	playsound(X, 'sound/vore/escape.ogg', 40, channel = channel)
	if(!do_after(X, 3 SECONDS, FALSE, null, BUSY_ICON_DANGER))
		to_chat(owner, span_warning("We moved too soon!"))
		X.stop_sound_channel(channel)
		return fail_activate()
	X.eject_victim()

/datum/action/xeno_action/activable/devour/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	if(LAZYLEN(X.stomach_contents))
		return
	var/mob/living/carbon/human/victim = A
	var/channel = SSsounds.random_available_channel()
	playsound(X, 'sound/vore/struggle.ogg', 40, channel = channel)
	if(!do_after(X, 7 SECONDS, FALSE, victim, BUSY_ICON_DANGER, extra_checks = CALLBACK(owner, /mob.proc/break_do_after_checks, list("health" = X.health))))
		to_chat(owner, span_warning("We stop devouring \the [victim]. They probably tasted gross anyways."))
		X.stop_sound_channel(channel)
		return fail_activate()
	owner.visible_message(span_warning("[X] devours [victim]!"), \
	span_warning("We devour [victim]!"), null, 5)
	LAZYADD(X.stomach_contents, victim)
	victim.forceMove(X)


/////////////////////////////////
// Cocoon
/////////////////////////////////
/datum/action/xeno_action/activable/cocoon
	name = "Cocoon"
	action_icon_state = "regurgitate"
	mechanics_text = "Devour your victim to cocoon it in your belly. This cocoon will automatically be ejected later, and while the marine inside it still has life force it will give psychic points."
	use_state_flags = XACT_USE_STAGGERED|XACT_USE_FORTIFIED|XACT_USE_CRESTED //can't use while staggered, defender fortified or crest down
	keybind_signal = COMSIG_XENOABILITY_REGURGITATE
	plasma_cost = 100
	gamemode_flags = ABILITY_DISTRESS
	///In how much time the cocoon will be ejected
	var/cocoon_production_time = 3 SECONDS

/datum/action/xeno_action/activable/cocoon/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return
	if(!ishuman(A) || issynth(A))
		to_chat(owner, span_warning("That wouldn't taste very good."))
		return FALSE
	var/mob/living/carbon/human/victim = A
	if(owner.do_actions) //can't use if busy
		return FALSE
	if(!owner.Adjacent(victim)) //checks if owner next to target
		return FALSE
	if(victim.stat != DEAD)
		if(!silent)
			to_chat(owner, span_warning("This creature is struggling too much for us to devour it."))
		return FALSE
	if(HAS_TRAIT(victim, TRAIT_PSY_DRAINED))
		if(!silent)
			to_chat(owner, span_warning("There is no longer any life force in this creature!"))
		return FALSE
	if(victim.buckled)
		if(!silent)
			to_chat(owner, span_warning("[victim] is buckled to something."))
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	if(X.on_fire)
		if(!silent)
			to_chat(X, span_warning("We're too busy being on fire to do this!"))
		return FALSE
	if(LAZYLEN(X.stomach_contents)) //Only one thing in the stomach at a time, please
		if(!silent)
			to_chat(X, span_warning("We already have something in our stomach, there's no way that will fit."))
		return FALSE
	for(var/obj/effect/forcefield/fog in range(1, X))
		if(!silent)
			to_chat(X, span_warning("We are too close to the fog."))
		return FALSE
	X.face_atom(victim)
	X.visible_message(span_danger("[X] starts to devour [victim]!"), \
	span_danger("We start to devour [victim]!"), null, 5)

	succeed_activate()

/datum/action/xeno_action/activable/cocoon/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/human/victim = A
	var/channel = SSsounds.random_available_channel()
	playsound(X, 'sound/vore/struggle.ogg', 40, channel = channel)
	if(!do_after(X, 7 SECONDS, FALSE, victim, BUSY_ICON_DANGER, extra_checks = CALLBACK(owner, /mob.proc/break_do_after_checks, list("health" = X.health))))
		to_chat(owner, span_warning("We stop devouring \the [victim]. They probably tasted gross anyways."))
		X.stop_sound_channel(channel)
		return fail_activate()
	if(HAS_TRAIT(victim, TRAIT_PSY_DRAINED))
		to_chat(owner, span_warning("Someone drained the life force of our victim before we could devour it!"))
		return fail_activate()
	owner.visible_message(span_warning("[X] devours [victim]!"), \
	span_warning("We devour [victim]!"), null, 5)
	to_chat(owner, span_warning("We will eject the cocoon in [cocoon_production_time / 10] seconds! Do not move until it is done."))
	LAZYADD(X.stomach_contents, victim)
	var/turf/starting_turf = get_turf(victim)
	victim.forceMove(X)
	X.do_jitter_animation()
	succeed_activate()
	channel = SSsounds.random_available_channel()
	playsound(X, 'sound/vore/escape.ogg', 40, channel = channel)
	if(!do_after(X, cocoon_production_time, FALSE, null, BUSY_ICON_DANGER))
		to_chat(owner, span_warning("We moved too soon and we will have to devour our victim again!"))
		X.eject_victim(FALSE, starting_turf)
		X.stop_sound_channel(channel)
		return fail_activate()
	victim.dead_ticks = 0
	ADD_TRAIT(victim, TRAIT_STASIS, TRAIT_STASIS)
	X.eject_victim(TRUE, starting_turf)
