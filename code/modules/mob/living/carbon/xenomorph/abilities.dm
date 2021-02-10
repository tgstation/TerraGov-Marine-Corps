// ***************************************
// *********** Universal abilities
// ***************************************
// Resting
/datum/action/xeno_action/xeno_resting
	name = "Rest"
	action_icon_state = "resting"
	mechanics_text = "Rest on weeds to regenerate health and plasma."
	use_state_flags = XACT_USE_LYING

/datum/action/xeno_action/xeno_resting/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(!istype(X))
		return
	X.lay_down()
	return succeed_activate()

// Regurgitate
/datum/action/xeno_action/regurgitate
	name = "Regurgitate"
	action_icon_state = "regurgitate"
	mechanics_text = "Vomit whatever you have devoured."
	use_state_flags = XACT_USE_STAGGERED|XACT_USE_FORTIFIED|XACT_USE_CRESTED
	keybind_signal = COMSIG_XENOABILITY_REGURGITATE

/datum/action/xeno_action/regurgitate/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/devourer = owner
	if(!LAZYLEN(devourer.stomach_contents))
		if(!silent)
			to_chat(devourer, "<span class='warning'>There's nothing in our stomach that needs regurgitating.</span>")
		return FALSE

/datum/action/xeno_action/regurgitate/action_activate()
	var/mob/living/carbon/xenomorph/spewer = owner
	spewer.empty_gut(TRUE)

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

/datum/action/xeno_action/activable/headbite/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..() //do after checking the below stuff
	if(!.)
		return
	if(!iscarbon(A))
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/victim = A //target of ability
	if(X.action_busy) //can't use if busy
		return FALSE
	if(!X.Adjacent(victim)) //checks if owner next to target
		return FALSE
	if(X.on_fire)
		if(!silent)
			to_chat(X, "<span class='warning'>We're too busy being on fire to do this!</span>")
		return FALSE
	if(victim.stat != DEAD)
		if(!silent)
			to_chat(X, "<span class='warning'>This creature is struggling too much for us to aim precisely.</span>")
		return FALSE
	if(victim.headbitten)
		if(!silent)
			to_chat(X, "<span class='warning'>This creature has already been headbitten.</span>")
		return FALSE
	if(victim.chestburst)
		if(!silent)
			to_chat(X, "<span class='warning'>This creature has already served its purpose.</span>")
		return FALSE
	if(X.issamexenohive(victim)) //checks if target and victim are in the same hive
		if(!silent)
			to_chat(X, "<span class='warning'>We can't bring ourselves to harm a fellow sister to this magnitude.</span>")
		return FALSE
	if(issynth(victim)) //checks if target is a synth
		if(!silent)
			to_chat(X, "<span class='warning'>We have no reason to bite this non-living thing.</span>")
		return FALSE
	X.face_atom(victim) //Face towards the target so we don't look silly
	X.visible_message("<span class='xenowarning'>\The [X] begins opening its mouth and extending a second jaw towards \the [victim].</span>", \
	"<span class='danger'>We prepare our inner jaw for a finishing blow on \the [victim]!</span>", null, 20)
	if(!do_after(X, 10 SECONDS, FALSE, victim, BUSY_ICON_DANGER, extra_checks = CALLBACK(X, /mob.proc/break_do_after_checks, list("health" = X.health))))
		X.visible_message("<span class='xenowarning'>\The [X] retracts its inner jaw.</span>", \
		"<span class='danger'>We retract our inner jaw.</span>", null, 20)
		return FALSE
	succeed_activate() //dew it

/datum/action/xeno_action/activable/headbite/use_ability(mob/M)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/victim = M

	X.visible_message("<span class='xenodanger'>\The [X] viciously bites into \the [victim]'s head with its inner jaw!</span>", \
	"<span class='xenodanger'>We suddenly bite into the \the [victim]'s head with our second jaw!</span>")

	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		victim.emote_burstscream()
		var/datum/internal_organ/O
		O = H.internal_organs_by_name["brain"] //This removes (and later garbage collects) the organ. No brain means instant death.
		H.internal_organs_by_name -= "brain"
		H.internal_organs -= O

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


/datum/action/xeno_action/plant_weeds/action_activate()
	var/turf/T = get_turf(owner)

	if(!T.check_alien_construction(owner, FALSE))
		return fail_activate()

	if(locate(/obj/effect/alien/resin/trap) in T)
		to_chat(owner, "<span class='warning'>There is a resin trap in the way!</span>")
		return fail_activate()

	if(!T.is_weedable())
		to_chat(owner, "<span class='warning'>Bad place for a garden!</span>")
		return fail_activate()

	if(locate(/obj/effect/alien/weeds/node) in T)
		to_chat(owner, "<span class='warning'>There's a pod here already!</span>")
		return fail_activate()

	owner.visible_message("<span class='xenonotice'>\The [owner] regurgitates a pulsating node and plants it on the ground!</span>", \
		"<span class='xenonotice'>We regurgitate a pulsating node and plant it on the ground!</span>", null, 5)
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
	to_chat(hiveminde, "<span class='xenonotice'>We can't plant a node without weeds nearby, we've been moved back to our core.</span>")
	return fail_activate()

// Choose Resin
/datum/action/xeno_action/choose_resin
	name = "Choose Resin Structure"
	action_icon_state = "resin wall"
	mechanics_text = "Selects which structure you will build with the (secrete resin) ability."
	keybind_signal = COMSIG_XENOABILITY_CHOOSE_RESIN
	var/list/buildable_structures = list(
		/turf/closed/wall/resin/regenerating,
		/obj/structure/bed/nest,
		/obj/effect/alien/resin/sticky,
		/obj/structure/mineral_door/resin)

/datum/action/xeno_action/choose_resin/update_button_icon()
	var/mob/living/carbon/xenomorph/X = owner
	var/atom/A = X.selected_resin
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, initial(A.name))
	return ..()

/datum/action/xeno_action/choose_resin/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	var/i = buildable_structures.Find(X.selected_resin)
	if(length(buildable_structures) == i)
		X.selected_resin = buildable_structures[1]
	else
		X.selected_resin = buildable_structures[i+1]

	var/atom/A = X.selected_resin
	to_chat(X, "<span class='notice'>We will now build <b>[initial(A.name)]\s</b> when secreting resin.</span>")
	update_button_icon()
	return succeed_activate()

// Secrete Resin
/datum/action/xeno_action/activable/secrete_resin
	name = "Secrete Resin"
	action_icon_state = "secrete_resin"
	mechanics_text = "Builds whatever you’ve selected with (choose resin structure) on your tile."
	ability_name = "secrete resin"
	plasma_cost = 75
	keybind_signal = COMSIG_XENOABILITY_SECRETE_RESIN
	var/base_wait = 1 SECONDS
	var/scaling_wait = 1 SECONDS

/datum/action/xeno_action/activable/secrete_resin/use_ability(atom/A)
	build_resin(get_turf(owner))

/datum/action/xeno_action/activable/secrete_resin/proc/get_wait()
	. = base_wait
	if(!scaling_wait)
		return
	var/mob/living/carbon/xenomorph/X = owner

	var/sticky_resin_modifier = 1
	if(X.selected_resin == /obj/effect/alien/resin/sticky) //Sticky resin builds twice as fast
		sticky_resin_modifier = 0.5

	return (base_wait + scaling_wait - max(0, (scaling_wait * X.health / X.maxHealth))) * sticky_resin_modifier

/datum/action/xeno_action/activable/secrete_resin/proc/build_resin(turf/T)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/xenomorph/blocker = locate() in T
	if(blocker && blocker != X && blocker.stat != DEAD)
		to_chat(X, "<span class='warning'>Can't do that with [blocker] in the way!</span>")
		return fail_activate()

	if(!T.is_weedable())
		to_chat(X, "<span class='warning'>We can't do that here.</span>")
		return fail_activate()

	var/obj/effect/alien/weeds/alien_weeds = locate() in T

	for(var/obj/effect/forcefield/fog/F in range(1, X))
		to_chat(X, "<span class='warning'>We can't build so close to the fog!</span>")
		return fail_activate()

	if(!alien_weeds)
		to_chat(X, "<span class='warning'>We can only shape on weeds. We must find some resin before we start building!</span>")
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
			to_chat(X, "<span class='warning'>Resin doors need a wall or resin door next to them to stand up.</span>")
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
			to_chat(X, "<span class='warning'>Resin doors need a wall or resin door next to them to stand up.</span>")
			return fail_activate()
	var/atom/AM = X.selected_resin
	X.visible_message("<span class='xenonotice'>\The [X] regurgitates a thick substance and shapes it into \a [initial(AM.name)]!</span>", \
	"<span class='xenonotice'>We regurgitate some resin and shape it into \a [initial(AM.name)].</span>", null, 5)
	playsound(owner.loc, "alien_resin_build", 25)

	var/atom/new_resin

	if(ispath(X.selected_resin, /turf)) // We should change turfs, not spawn them in directly
		var/list/baseturfs = islist(T.baseturfs) ? T.baseturfs : list(T.baseturfs)
		baseturfs |= T.type
		T.ChangeTurf(X.selected_resin, baseturfs)
		new_resin = T
	else
		new_resin = new X.selected_resin(T)

	if(X.selected_resin == /obj/effect/alien/resin/sticky) //Sticky resin is discounted because let's face it, it's nowhere near as good as a wall or door
		plasma_cost = 25

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
	use_state_flags = XACT_USE_STAGGERED|XACT_USE_NOTTURF|XACT_USE_BUSY

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
		X.visible_message("<span class='xenowarning'>\The [X] stops emitting strange pheromones.</span>", \
		"<span class='xenowarning'>We stop emitting [X.current_aura] pheromones.</span>", null, 5)
		X.current_aura = null
		if(isxenoqueen(X))
			X.hive?.update_leader_pheromones()
		X.hud_set_pheromone()
		return fail_activate() // dont use plasma

	X.current_aura = aura_type
	X.visible_message("<span class='xenowarning'>\The [X] begins to emit strange-smelling pheromones.</span>", \
	"<span class='xenowarning'>We begin to emit '[X.current_aura]' pheromones.</span>", null, 5)
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

/datum/action/xeno_action/activable/transfer_plasma/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!isxeno(A) || A == owner || !owner.issamexenohive(A))
		return FALSE

	var/mob/living/carbon/xenomorph/target = A

	if(get_dist(owner, target) > max_range)
		if(!silent)
			to_chat(owner, "<span class='warning'>We need to be closer to [target].</span>")
		return FALSE

	if(target.plasma_stored >= target.xeno_caste.plasma_max) //We can't select targets that won't benefit
		to_chat(owner, "<span class='xenowarning'>[target] already has full plasma.</span>")
		return FALSE

/datum/action/xeno_action/activable/transfer_plasma/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/xenomorph/target = A

	to_chat(X, "<span class='notice'>We start focusing our plasma towards [target].</span>")
	new /obj/effect/temp_visual/transfer_plasma(get_turf(X)) //Cool SFX that confirms our source and our target
	new /obj/effect/temp_visual/transfer_plasma(get_turf(target)) //Cool SFX that confirms our source and our target
	playsound(X, "alien_drool", 25)

	X.face_atom(target) //Face our target so we don't look silly

	if(!do_after(X, transfer_delay, TRUE, null, BUSY_ICON_FRIENDLY))
		return fail_activate()

	if(!can_use_ability(A))
		return fail_activate()

	target.beam(X,"drain_life",'icons/effects/beam.dmi',10, 10,/obj/effect/ebeam,1) //visual SFX
	target.add_filter("transfer_plasma_outline", 3, outline_filter(1, COLOR_STRONG_MAGENTA))
	addtimer(CALLBACK(target, /atom.proc/remove_filter, "transfer_plasma_outline"), 1 SECONDS) //Failsafe blur removal

	var/amount = plasma_transfer_amount
	if(X.plasma_stored < plasma_transfer_amount)
		amount = X.plasma_stored //Just use all of it

	else //Otherwise transfer as much as the target can use
		amount = clamp(target.xeno_caste.plasma_max - target.plasma_stored, 0, plasma_transfer_amount)

	X.use_plasma(amount)
	target.gain_plasma(amount)
	to_chat(target, "<span class='xenodanger'>[X] has transfered [amount] units of plasma to us. We now have [target.plasma_stored]/[target.xeno_caste.plasma_max].</span>")
	to_chat(X, "<span class='xenodanger'>We have transferred [amount] units of plasma to [target]. We now have [X.plasma_stored]/[X.xeno_caste.plasma_max].</span>")
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
	to_chat(owner, "<span class='xenodanger'>We feel our growth toxin glands refill. We can use Growth Sting again.</span>")
	return ..()

/datum/action/xeno_action/activable/larval_growth_sting/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(QDELETED(A))
		return FALSE

	if(!A?.can_sting())
		if(!silent)
			to_chat(owner, "<span class='warning'>Our sting won't affect this target!</span>")
		return FALSE

	if(!owner.Adjacent(A))
		var/mob/living/carbon/xenomorph/X = owner
		if(!silent && world.time > (X.recent_notice + X.notice_delay))
			to_chat(X, "<span class='warning'>We can't reach this target!</span>")
			X.recent_notice = world.time //anti-notice spam
		return FALSE

	var/mob/living/carbon/C = A
	if (isnestedhost(C))
		if(!silent)
			to_chat(owner, "<span class='warning'>Ashamed, we reconsider bullying the poor, nested host with our stinger.</span>")
		return FALSE

/datum/action/xeno_action/activable/larval_growth_sting/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	succeed_activate()

	GLOB.round_statistics.larval_growth_stings++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "larval_growth_stings")

	add_cooldown()
	X.recurring_injection(A, /datum/reagent/toxin/xeno_growthtoxin, XENO_LARVAL_CHANNEL_TIME, XENO_LARVAL_AMOUNT_RECURRING)

// ***************************************
// *********** Spitter-y abilities
// ***************************************
// Shift Spits
/datum/action/xeno_action/shift_spits
	name = "Toggle Spit Type"
	action_icon_state = "shift_spit_neurotoxin"
	mechanics_text = "Switch from neurotoxin to acid spit."
	use_state_flags = XACT_USE_STAGGERED|XACT_USE_NOTTURF|XACT_USE_BUSY
	keybind_signal = COMSIG_XENOABILITY_SHIFT_SPITS

/datum/action/xeno_action/shift_spits/update_button_icon()
	var/mob/living/carbon/xenomorph/X = owner
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, "shift_spit_[X.ammo.icon_state]")

/datum/action/xeno_action/shift_spits/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	for(var/i in 1 to X.xeno_caste.spit_types.len)
		if(X.ammo == GLOB.ammo_list[X.xeno_caste.spit_types[i]])
			if(i == X.xeno_caste.spit_types.len)
				X.ammo = GLOB.ammo_list[X.xeno_caste.spit_types[1]]
			else
				X.ammo = GLOB.ammo_list[X.xeno_caste.spit_types[i+1]]
			break
	to_chat(X, "<span class='notice'>We will now spit [X.ammo.name] ([X.ammo.spit_cost] plasma).</span>")
	update_button_icon()


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

/datum/action/xeno_action/activable/corrosive_acid/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!owner.Adjacent(A))
		if(!silent)
			to_chat(owner, "<span class='warning'>\The [A] is too far away.</span>")
		return FALSE
	if(isobj(A))
		var/obj/O = A
		if(CHECK_BITFIELD(O.resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
			if(!silent)
				to_chat(owner, "<span class='warning'>We cannot dissolve \the [O].</span>")
			return FALSE
		if(O.acid_check(acid_type))
			if(!silent)
				to_chat(owner, "<span class='warning'>This object is already subject to a more or equally powerful acid.</span>")
			return FALSE
		if(istype(O, /obj/structure/window_frame))
			var/obj/structure/window_frame/WF = O
			if(WF.reinforced && acid_type != /obj/effect/xenomorph/acid/strong)
				if(!silent)
					to_chat(owner, "<span class='warning'>This [WF.name] is too tough to be melted by our weak acid.</span>")
				return FALSE
	else if(isturf(A))
		var/turf/T = A
		if(T.acid_check(acid_type))
			if(!silent)
				to_chat(owner, "<span class='warning'>This object is already subject to a more or equally powerful acid.</span>")
			return FALSE
		if(iswallturf(T))
			var/turf/closed/wall/wall_target = T
			if(wall_target.acided_hole)
				if(!silent)
					to_chat(owner, "<span class='warning'>[wall_target] is already weakened.</span>")
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
				to_chat(X, "<span class='warning'>We cannot dissolve \the [T].</span>")
				return fail_activate()
			if(1)
				wait_time = 50
			if(2)
				if(acid_type != /obj/effect/xenomorph/acid/strong)
					to_chat(X, "<span class='warning'>This [T.name] is too tough to be melted by our weak acid.</span>")
					return fail_activate()
				wait_time = 100
			else
				return fail_activate()
		to_chat(X, "<span class='xenowarning'>We begin generating enough acid to melt through \the [T].</span>")
	else
		to_chat(X, "<span class='warning'>We cannot dissolve \the [A].</span>")
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
		X.visible_message("<span class='xenowarning'>\The [X] vomits globs of vile stuff at \the [R]. It sizzles under the bubbling mess of acid!</span>", \
			"<span class='xenowarning'>We vomit globs of vile stuff at \the [R]. It sizzles under the bubbling mess of acid!</span>", null, 5)
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
	X.visible_message("<span class='xenowarning'>\The [X] vomits globs of vile stuff all over \the [A]. It begins to sizzle and melt under the bubbling mess of acid!</span>", \
	"<span class='xenowarning'>We vomit globs of vile stuff all over \the [A]. It begins to sizzle and melt under the bubbling mess of acid!</span>", null, 5)
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
			to_chat(owner, "<span class='warning'>That's far too close!</span>")
		return FALSE


/datum/action/xeno_action/activable/spray_acid/on_cooldown_finish()
	playsound(owner.loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(owner, "<span class='xenodanger'>We feel our acid glands refill. We can spray acid again.</span>")
	return ..()

/datum/action/xeno_action/activable/spray_acid/proc/acid_splat_turf(turf/T)
	. = locate(/obj/effect/xenomorph/spray) in T
	if(!.)
		var/mob/living/carbon/xenomorph/X = owner

		. = new /obj/effect/xenomorph/spray(T, X.xeno_caste.acid_spray_duration, X.xeno_caste.acid_spray_damage)

		for(var/i in T)
			var/atom/A = i
			if(!A)
				continue
			A.acid_spray_act(owner)


/datum/action/xeno_action/activable/xeno_spit
	name = "Xeno Spit"
	action_icon_state = "xeno_spit"
	mechanics_text = "Spit neurotoxin or acid at your target up to 7 tiles away."
	ability_name = "xeno spit"
	keybind_signal = COMSIG_XENOABILITY_XENO_SPIT
	plasma_cost = 10

/datum/action/xeno_action/activable/xeno_spit/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	if(X.ammo?.spit_cost > X.plasma_stored)
		if(!silent)
			to_chat(X, "<span class='warning'>We need [X.ammo?.spit_cost - X.plasma_stored] more plasma!</span>")
		return FALSE

/datum/action/xeno_action/activable/xeno_spit/get_cooldown()
	var/mob/living/carbon/xenomorph/X = owner
	return (X.xeno_caste.spit_delay + X.ammo?.added_spit_delay)

/datum/action/xeno_action/activable/xeno_spit/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, "<span class='notice'>We feel our neurotoxin glands swell with ichor. We can spit again.</span>")
	return ..()

/datum/action/xeno_action/activable/xeno_spit/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	var/turf/current_turf = get_turf(owner)

	if(!current_turf)
		return fail_activate()

	X.visible_message("<span class='xenowarning'>\The [X] spits at \the [A]!</span>", \
	"<span class='xenowarning'>We spit at \the [A]!</span>" )
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
		to_chat(X, "<span class='notice'>We are now hiding.</span>")
	else
		X.layer = MOB_LAYER
		to_chat(X, "<span class='notice'>We have stopped hiding.</span>")


//Neurotox Sting
/datum/action/xeno_action/activable/neurotox_sting
	name = "Neurotoxin Sting"
	action_icon_state = "neuro_sting"
	mechanics_text = "A channeled melee attack that injects the target with neurotoxin over a few seconds, temporarily stunning them."
	ability_name = "neurotoxin sting"
	cooldown_timer = 12 SECONDS
	plasma_cost = 150
	keybind_signal = COMSIG_XENOABILITY_NEUROTOX_STING

/datum/action/xeno_action/activable/neurotox_sting/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!A?.can_sting())
		if(!silent)
			to_chat(owner, "<span class='warning'>Our sting won't affect this target!</span>")
		return FALSE
	if(!owner.Adjacent(A))
		var/mob/living/carbon/xenomorph/X = owner
		if(!silent && world.time > (X.recent_notice + X.notice_delay)) //anti-notice spam
			to_chat(X, "<span class='warning'>We can't reach this target!</span>")
			X.recent_notice = world.time //anti-notice spam
		return FALSE
	var/mob/living/carbon/C = A
	if (isnestedhost(C))
		if(!silent)
			to_chat(owner, "<span class='warning'>Ashamed, we reconsider bullying the poor, nested host with our stinger.</span>")
		return FALSE

/datum/action/xeno_action/activable/neurotox_sting/on_cooldown_finish()
	playsound(owner.loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(owner, "<span class='xenodanger'>We feel our neurotoxin glands refill. We can use our Neurotoxin Sting again.</span>")
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


/datum/action/xeno_action/psychic_whisper/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	var/list/target_list = list()
	for(var/mob/living/possible_target in view(WORLD_VIEW, X))
		if(possible_target == X || !possible_target.client || isxeno(possible_target))
			continue
		target_list += possible_target

	if(!length(target_list))
		to_chat(X, "<span class='warning'>There's nobody nearby to whisper to.</span>")
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
	to_chat(L, "<span class='alien'>You hear a strange, alien voice in your head. <i>\"[msg]\"</i></span>")
	to_chat(X, "<span class='xenonotice'>We said: \"[msg]\" to [L]</span>")


// ***************************************
// *********** Lay Egg
// ***************************************
/datum/action/xeno_action/lay_egg
	name = "Lay Egg"
	action_icon_state = "lay_egg"
	plasma_cost = 400
	cooldown_timer = 12 SECONDS
	keybind_signal = COMSIG_XENOABILITY_LAY_EGG


/datum/action/xeno_action/lay_egg/action_activate()
	var/mob/living/carbon/xenomorph/xeno = owner
	var/turf/current_turf = get_turf(owner)

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf
	if(!alien_weeds)
		to_chat(owner, "<span class='warning'>Our eggs wouldn't grow well enough here. Lay them on resin.</span>")
		return FALSE

	if(!do_after(owner, 3 SECONDS, FALSE, alien_weeds))
		return FALSE

	if(!current_turf.check_alien_construction(owner) || !current_turf.check_disallow_alien_fortification(owner))
		return FALSE

	owner.visible_message("<span class='xenowarning'>\The [owner] has laid an egg!</span>", \
		"<span class='xenowarning'>We have laid an egg!</span>")

	new /obj/item/xeno_egg(current_turf, xeno.hivenumber)
	playsound(owner.loc, 'sound/effects/splat.ogg', 25)

	succeed_activate()
	add_cooldown()


////////////////////
/// Build silo
///////////////////
/datum/action/xeno_action/activable/build_silo
	name = "Secrete resin silo"
	action_icon_state = "resin_silo"
	mechanics_text = "Creates a new resin silo on a tile with a nest."
	ability_name = "secrete resin"
	plasma_cost = 150
	keybind_signal = COMSIG_XENOABILITY_SECRETE_RESIN_SILO
	cooldown_timer = 60 SECONDS

	/// How long does it take to build
	var/build_time = 10 SECONDS

	/// how many dead / non-chestbursted mobs are required to build the silo
	var/required_mobs = 3

/datum/action/xeno_action/activable/build_silo/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!in_range(owner, A))
		if(!silent)
			to_chat(owner, "<span class='warning'>We need to get closer!.</span>")
		return FALSE
	var/obj/structure/bed/nest/found_nest = locate() in get_turf(A)
	if(!found_nest)
		if(!silent)
			to_chat(owner, "<span class='warning'>You must build a resin nest and have [required_mobs] bodies for a silo!</span>")
		return FALSE


/datum/action/xeno_action/activable/build_silo/use_ability(atom/A)
	// we do this check here so we can clear the mobs afterwards
	var/list/mob/living/valid_mobs = list()
	for(var/thing in get_turf(A))
		if(!ishuman(thing))
			continue
		var/mob/living/turf_mob = thing
		if(turf_mob.stat == DEAD && turf_mob.chestburst == 0)
			valid_mobs += turf_mob

	if(length(valid_mobs) < required_mobs)
		to_chat(owner, "<span class='warning'>There are not enough dead bodies, you need [required_mobs] bodies for a silo!</span>")
		return fail_activate()

	if(!do_after(owner, build_time, TRUE, A, BUSY_ICON_BUILD))
		return fail_activate()

	var/obj/structure/resin/silo/hivesilo = new(get_step(A, SOUTHWEST))

	// Throw the mobs inside the silo
	for(var/iter in valid_mobs)
		var/mob/living/to_move = iter
		to_move.chestburst = 2 //So you can't reuse corpses if the silo is destroyed
		to_move.update_burst()
		to_move.forceMove(hivesilo)

	// Just to protect against two people doing the action at the same time
	if(!QDELETED(A))
		qdel(A)

	succeed_activate()

// Salvage Biomass
/datum/action/xeno_action/activable/salvage_biomass
	name = "Salvage Biomass"
	action_icon_state = "salvage_plasma"
	ability_name = "salvage biomass"
	keybind_signal = COMSIG_XENOABILITY_SALVAGE_PLASMA
	cooldown_timer = DRONE_SALVAGE_COOLDOWN

/datum/action/xeno_action/activable/salvage_biomass/on_cooldown_finish()
	owner.playsound_local(owner, 'sound/voice/alien_drool1.ogg', 25, 0, 1)
	to_chat(owner, "<span class='notice'>We are ready to salvage xeno biomass again.</span>")
	return ..()

/datum/action/xeno_action/activable/salvage_biomass/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/xenomorph/X = owner
	if(!isxeno(A))
		to_chat(X, "<span class='xenowarning'>We can only salvage the biomass of deceased xenomorphs!</span>")
		return FALSE

	var/mob/living/carbon/xenomorph/target = A

	if(target.stat != DEAD)
		to_chat(X, "<span class='xenowarning'>We can't salvage the biomass of living sisters!</span>")
		return FALSE

	var/distance = get_dist(X, target)
	if(distance > DRONE_SALVAGE_BIOMASS_RANGE)
		to_chat(X, "<span class='xenowarning'>We need to be [distance -  DRONE_SALVAGE_BIOMASS_RANGE] tiles closer to [target].</span>")
		return FALSE


/datum/action/xeno_action/activable/salvage_biomass/use_ability(atom/A)

	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/xenomorph/target = A


	X.face_atom(target) //Face the target so we don't look like an ass
	to_chat(X, "<span class='xenowarning'>We begin to salvage the biomass of [target]...</span>")
	playsound(X, pick('sound/voice/alien_drool1.ogg','sound/voice/alien_drool2.ogg'), 25)

	if(!do_after(X, DRONE_SALVAGE_BIOMASS_WINDUP, TRUE, target, BUSY_ICON_FRIENDLY)) //Wind up
		return fail_activate()


	X.face_atom(target) //Face the target so we don't look like an ass

	if(!can_use_ability(target, FALSE, XACT_IGNORE_PLASMA)) //Check to make sure the target hasn't gone anywhere/been exploded/etc
		return fail_activate()

	succeed_activate()

	var/upgrade_amount = target.upgrade_stored * DRONE_SALVAGE_BIOMASS_SALVAGE_RATIO //We only recover a small portion of the target's upgrade and evo points.
	var/evo_amount = target.evolution_stored * DRONE_SALVAGE_BIOMASS_SALVAGE_RATIO

	//Take all the plas-mar
	X.gain_plasma(target.plasma_stored)

	//Distribute the upgrade and evo points the target had to the hive:
	var/list/list_of_upgrade_xenos = list()
	var/list/list_of_evolve_xenos = list()

	for(var/mob/living/carbon/xenomorph/filter in X.hive.get_all_xenos())
		if(!(filter.upgrade in DRONE_SALVAGE_UPGRADE_FILTER_LIST)) //Only Xenos who can use the salvage get it; filter them
			list_of_upgrade_xenos += filter
		if(!(filter.tier in DRONE_SALVAGE_EVOLUTION_FILTER_LIST) && (filter.evolution_stored < filter.xeno_caste.evolution_threshold))
			list_of_evolve_xenos += filter

	if(length(list_of_upgrade_xenos))
		upgrade_amount /= length(list_of_upgrade_xenos) //get the amount distributed to each xeno; protect against dividing by 0
		for(var/mob/living/carbon/xenomorph/beneficiary in list_of_upgrade_xenos) //Distribute the upgrade salvage to those who can use it
			beneficiary.upgrade_stored += upgrade_amount

	if(length(list_of_evolve_xenos))
		evo_amount /= length(list_of_evolve_xenos)
		for(var/mob/living/carbon/xenomorph/beneficiary in list_of_evolve_xenos) //Distribute the evolve salvage to those who can use it
			beneficiary.evolution_stored = min(beneficiary.xeno_caste.evolution_threshold, beneficiary.evolution_stored + evo_amount) //Prevents janky overflow

	playsound(target, 'sound/effects/alien_egg_burst.ogg', 25)
	X.hive.xeno_message("[target]'s remains were salvaged by [X], recovering [upgrade_amount] upgrade points for [length(list_of_upgrade_xenos)] sisters and [evo_amount] evolution points for [length(list_of_evolve_xenos) ] sisters.") //Notify hive and give credit to the good boy drone
	X.visible_message("<span class='xenowarning'>\ [X] gruesomely absorbs and devours the remains of [target]!</span>", \
	"<span class='xenowarning'>We messily devour the remains of [target], absorbing [target.plasma_stored] plasma and distributing our deceased sister's essence throughout the hive. We now have [X.plasma_stored]/[X.xeno_caste.plasma_max] plasma stored.</span>") //Narrative description.

	target.gib() //Destroy the corpse

	GLOB.round_statistics.drone_salvage_biomass++ //Statistic incrementation
	SSblackbox.record_feedback("tally", "round_statistics", 1, "drone_salvage_biomass")

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

/datum/action/xeno_action/activable/rally_hive/use_ability()

	var/mob/living/carbon/xenomorph/X = owner

	xeno_message("<span class='xenoannounce'>Our leader [X] is rallying the hive to [AREACOORD_NO_Z(X.loc)]!</span>", 3, X.hivenumber, FALSE, X, 'sound/voice/alien_distantroar_3.ogg',TRUE,null,/obj/screen/arrow/leader_tracker_arrow)
	notify_ghosts("\ [X] is rallying the hive to [AREACOORD_NO_Z(X.loc)]!", source = X, action = NOTIFY_JUMP)

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.xeno_rally_hive++ //statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_rally_hive")

/////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/carbon/xenomorph/proc/add_abilities()
	for(var/action_path in xeno_caste.actions)
		var/datum/action/xeno_action/A = new action_path()
		A.give_action(src)


/mob/living/carbon/xenomorph/proc/remove_abilities()
	for(var/action_datum in xeno_abilities)
		qdel(action_datum)

/datum/action/xeno_action/activable/rally_hive/hivemind //Halve the cooldown for Hiveminds as their relative omnipresence means they can actually make use of this lower cooldown.
	cooldown_timer = 30 SECONDS
