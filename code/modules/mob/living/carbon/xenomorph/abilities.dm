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
	owner.lay_down()
	return succeed_activate()

// Regurgitate
/datum/action/xeno_action/regurgitate
	name = "Regurgitate"
	action_icon_state = "regurgitate"
	mechanics_text = "Vomit whatever you have devoured."
	use_state_flags = XACT_USE_STAGGERED|XACT_USE_FORTIFIED|XACT_USE_CRESTED

/datum/action/xeno_action/regurgitate/can_use_action()
	. = ..()
	var/mob/living/carbon/C = owner
	if(!length(C.stomach_contents))
		to_chat(C, "<span class='warning'>There's nothing in your belly that needs regurgitating.</span>")
		return FALSE

/datum/action/xeno_action/regurgitate/action_activate()
	var/mob/living/carbon/C = owner
	for(var/mob/M in C.stomach_contents)
		C.stomach_contents.Remove(M)
		if(M.loc != C)
			continue
		M.forceMove(C.loc)
		M.SetKnockeddown(1)
		M.adjust_blindness(-1)

	C.visible_message("<span class='xenowarning'>\The [C] hurls out the contents of their stomach!</span>", \
	"<span class='xenowarning'>You hurl out the contents of your stomach!</span>", null, 5)
	return succeed_activate()

// ***************************************
// *********** Drone-y abilities
// ***************************************
/datum/action/xeno_action/plant_weeds
	name = "Plant Weeds"
	action_icon_state = "plant_weeds"
	plasma_cost = 75
	mechanics_text = "Plant a weed node (purple sac) on your tile."

/datum/action/xeno_action/plant_weeds/action_activate()
	var/turf/T = owner.loc

	if(!T.is_weedable())
		to_chat(owner, "<span class='warning'>Bad place for a garden!</span>")
		return fail_activate()

	if(locate(/obj/effect/alien/weeds/node) in T)
		to_chat(owner, "<span class='warning'>There's a pod here already!</span>")
		return fail_activate()

	owner.visible_message("<span class='xenonotice'>\The [owner] regurgitates a pulsating node and plants it on the ground!</span>", \
		"<span class='xenonotice'>You regurgitate a pulsating node and plant it on the ground!</span>", null, 5)
	var/obj/effect/alien/weeds/node/N = new (owner.loc, src, owner)
	owner.transfer_fingerprints_to(N)
	playsound(owner.loc, "alien_resin_build", 25)
	round_statistics.weeds_planted++
	return succeed_activate()

// Choose Resin
/datum/action/xeno_action/choose_resin
	name = "Choose Resin Structure"
	action_icon_state = "resin wall"
	mechanics_text = "Selects which structure you will build with the (secrete resin) ability."
	var/list/buildable_structures = list(
		/turf/closed/wall/resin,
		/obj/structure/bed/nest,
		/obj/effect/alien/resin/sticky,
		/obj/structure/mineral_door/resin)

/datum/action/xeno_action/choose_resin/hivelord
	buildable_structures = list(
		/turf/closed/wall/resin/thick,
		/obj/structure/bed/nest,
		/obj/effect/alien/resin/sticky,
		/obj/structure/mineral_door/resin/thick)

/datum/action/xeno_action/choose_resin/update_button_icon()
	var/mob/living/carbon/Xenomorph/X = owner
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, X.selected_resin)
	return ..()

/datum/action/xeno_action/choose_resin/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	var/i = buildable_structures.Find(X.selected_resin)
	if(length(buildable_structures) == i)
		X.selected_resin = buildable_structures[1]
	else
		X.selected_resin = buildable_structures[i+1]

	var/atom/A = X.selected_resin
	to_chat(X, "<span class='notice'>You will now build <b>[initial(A.name)]\s</b> when secreting resin.</span>")
	return succeed_activate()

// Secrete Resin
/datum/action/xeno_action/activable/secrete_resin
	name = "Secrete Resin"
	action_icon_state = "secrete_resin"
	mechanics_text = "Builds whatever you’ve selected with (choose resin structure) on your tile."
	ability_name = "secrete resin"
	plasma_cost = 75

/datum/action/xeno_action/activable/secrete_resin/use_ability(atom/A)
	build_resin(get_turf(owner))

GLOBAL_LIST_INIT(thickenable_resin, typecacheof(list(
	/turf/closed/wall/resin,
	/turf/closed/wall/resin/membrane,
	/obj/structure/mineral_door/resin), FALSE, TRUE))

/datum/action/xeno_action/activable/secrete_resin/hivelord/use_ability(atom/A)
	if(get_dist(src,A) > 1)
		return ..()

	if(!is_type_in_typecache(A, GLOB.thickenable_resin))
		return build_resin(get_turf(A))

	if(istype(A, /turf/closed/wall/resin))
		var/turf/closed/wall/resin/WR = A
		var/oldname = WR.name
		if(WR.thicken())
			owner.visible_message("<span class='xenonotice'>\The [owner] regurgitates a thick substance and thickens [oldname].</span>", \
			"<span class='xenonotice'>You regurgitate some resin and thicken [oldname].</span>", null, 5)
			playsound(owner.loc, "alien_resin_build", 25)
			return succeed_activate()
		to_chat(owner, "<span class='xenowarning'>[WR] can't be made thicker.</span>")
		return fail_activate()

	if(istype(A, /obj/structure/mineral_door/resin))
		var/obj/structure/mineral_door/resin/DR = A
		var/oldname = DR.name
		if(DR.thicken())
			owner.visible_message("<span class='xenonotice'>\The [owner] regurgitates a thick substance and thickens [oldname].</span>", \
				"<span class='xenonotice'>You regurgitate some resin and thicken [oldname].</span>", null, 5)
			playsound(owner.loc, "alien_resin_build", 25)
			return succeed_activate()
		to_chat(owner, "<span class='xenowarning'>[DR] can't be made thicker.</span>")
		return fail_activate()

/datum/action/xeno_action/activable/secrete_resin/proc/build_resin(turf/T)
	var/mob/living/carbon/Xenomorph/X = owner
	var/mob/living/carbon/Xenomorph/blocker = locate() in T
	if(blocker && blocker != X && blocker.stat != DEAD)
		to_chat(X, "<span class='warning'>Can't do that with [blocker] in the way!</span>")
		return fail_activate()

	if(!T.is_weedable())
		to_chat(X, "<span class='warning'>You can't do that here.</span>")
		return fail_activate()

	var/obj/effect/alien/weeds/alien_weeds = locate() in T

	if(!alien_weeds)
		to_chat(X, "<span class='warning'>You can only shape on weeds. Find some resin before you start building!</span>")
		return fail_activate()

	if(!T.check_alien_construction(X))
		return fail_activate()

	if(X.selected_resin == /obj/structure/mineral_door/resin)
		var/wall_support = FALSE
		for(var/D in cardinal)
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

	var/wait_time = 10 + 30 - max(0,(30*X.health/X.maxHealth)) //Between 1 and 4 seconds, depending on health.

	if(!do_after(X, wait_time, TRUE, 5, BUSY_ICON_BUILD))
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

	if(!T.check_alien_construction(X))
		return fail_activate()

	if(X.selected_resin == /obj/structure/mineral_door/resin)
		var/wall_support = FALSE
		for(var/D in cardinal)
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
	"<span class='xenonotice'>You regurgitate some resin and shape it into \a [initial(AM.name)].</span>", null, 5)
	playsound(owner.loc, "alien_resin_build", 25)

	var/atom/new_resin

	if(istype(X.selected_resin, /turf/closed/wall/resin))
		T.ChangeTurf(X.selected_resin)
		new_resin = T
	else
		new_resin = new X.selected_resin(T)
	new_resin.add_hiddenprint(X) //so admins know who placed it
	succeed_activate()


/datum/action/xeno_action/toggle_pheromones
	name = "Open/Collapse Pheromone Options"
	action_icon_state = "emit_pheromones"
	mechanics_text = "Opens your pheromone options."
	plasma_cost = 0
	var/PheromonesOpen = FALSE //If the  pheromone choices buttons are already displayed or not

/datum/action/xeno_action/toggle_pheromones/can_use_action()
		return TRUE //No actual gameplay impact; should be able to collapse or open pheromone choices at any time

/datum/action/xeno_action/toggle_pheromones/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(PheromonesOpen)
		PheromonesOpen = FALSE
		to_chat(X, "<span class ='xenonotice'>You collapse the pheromone button choices.</span>")
		for(var/datum/action/path in owner.actions)
			if(istype(path, /datum/action/xeno_action/pheromones))
				path.remove_action(X)
	else
		PheromonesOpen = TRUE
		to_chat(X, "<span class ='xenonotice'>You open the pheromone button choices.</span>")
		var/list/subtypeactions = subtypesof(/datum/action/xeno_action/pheromones)
		for(var/path in subtypeactions)
			var/datum/action/xeno_action/pheromones/A = new path()
			A.give_action(X)

/datum/action/xeno_action/pheromones
	name = "SHOULD NOT EXIST"
	plasma_cost = 30 //Base plasma cost for begin to emit pheromones
	var/aura_type = null //String for aura to emit

/datum/action/xeno_action/pheromones/can_use_action()
	var/mob/living/carbon/Xenomorph/X = owner
	if(X.incapacitated() || X.lying || X.buckled)
		return FALSE
	return TRUE

/datum/action/xeno_action/pheromones/action_activate() //Must pass the basic plasma cost; reduces copy pasta
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_plasma(plasma_cost))
		to_chat(X, "<span class='xenowarning'>You need more than [plasma_cost] to emit this pheromone.</span>")
		return FALSE

	if(!aura_type)
		return FALSE

	if(X.current_aura == aura_type)
		X.visible_message("<span class='xenowarning'>\The [X] stops emitting strange pheromones.</span>", \
		"<span class='xenowarning'>You stop emitting [X.current_aura] pheromones.</span>", null, 5)
		X.current_aura = null

	else
		X.use_plasma(plasma_cost)
		X.current_aura = aura_type
		X.visible_message("<span class='xenowarning'>\The [X] begins to emit strange-smelling pheromones.</span>", \
		"<span class='xenowarning'>You begin to emit '[X.current_aura]' pheromones.</span>", null, 5)
		playsound(X.loc, "alien_drool", 25)

	if(isxenoqueen(X))
		X.hive?.update_leader_pheromones()

	return TRUE

/datum/action/xeno_action/pheromones/emit_recovery //Type casted for easy removal/adding
	name = "Emit Recovery Pheromones (30)"
	action_icon_state = "emit_recovery"
	mechanics_text = "Increases healing for yourself and nearby teammates."
	aura_type = "recovery"

/datum/action/xeno_action/pheromones/emit_warding
	name = "Emit Warding Pheromones (30)"
	action_icon_state = "emit_warding"
	mechanics_text = "Increases armor for yourself and nearby teammates."
	aura_type = "warding"

/datum/action/xeno_action/pheromones/emit_frenzy
	name = "Emit Frenzy Pheromones (30)"
	action_icon_state = "emit_frenzy"
	mechanics_text = "Increases damage for yourself and nearby teammates."
	aura_type = "frenzy"

/datum/action/xeno_action/activable/transfer_plasma
	name = "Transfer Plasma"
	action_icon_state = "transfer_plasma"
	mechanics_text = "Give some of your plasma to a teammate."
	ability_name = "transfer plasma"
	var/plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT
	var/transfer_delay = 2 SECONDS
	var/max_range = 2

/datum/action/xeno_action/activable/transfer_plasma/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.xeno_transfer_plasma(A, plasma_transfer_amount, transfer_delay, max_range)

/datum/action/xeno_action/activable/transfer_plasma/improved
	plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT * 4
	transfer_delay = 0.5 SECONDS
	max_range = 7

//Xeno Larval Growth Sting
/datum/action/xeno_action/activable/larval_growth_sting
	name = "Larval Growth Sting"
	action_icon_state = "drone_sting"
	mechanics_text = "Inject an impregnated host with growth serum, causing the larva inside to grow quicker."
	ability_name = "larval growth sting"

/datum/action/xeno_action/activable/larval_growth_sting/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.larval_growth_sting(A)

/datum/action/xeno_action/activable/larval_growth_sting/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	if(world.time >= X.last_larva_growth_used + XENO_LARVAL_GROWTH_COOLDOWN)
		return TRUE

// ***************************************
// *********** Spitter-y abilities
// ***************************************
// Shift Spits
/datum/action/xeno_action/shift_spits
	name = "Toggle Spit Type"
	action_icon_state = "shift_spit_neurotoxin"
	mechanics_text = "Switch from neurotoxin to acid spit."
	plasma_cost = 0

/datum/action/xeno_action/shift_spits/update_button_icon()
	var/mob/living/carbon/Xenomorph/X = owner
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, "shift_spit_[X.ammo.icon_state]")

/datum/action/xeno_action/shift_spits/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state())
		return
	for(var/i in 1 to X.xeno_caste.spit_types.len)
		if(X.ammo == GLOB.ammo_list[X.xeno_caste.spit_types[i]])
			if(i == X.xeno_caste.spit_types.len)
				X.ammo = GLOB.ammo_list[X.xeno_caste.spit_types[1]]
			else
				X.ammo = GLOB.ammo_list[X.xeno_caste.spit_types[i+1]]
			break
	to_chat(X, "<span class='notice'>You will now spit [X.ammo.name] ([X.ammo.spit_cost] plasma).</span>")
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, "shift_spit_[X.ammo.icon_state]")

// Corrosive Acid
/datum/action/xeno_action/activable/corrosive_acid
	name = "Corrosive Acid (100)"
	action_icon_state = "corrosive_acid"
	mechanics_text = "Cover an object with acid to slowly melt it. Takes a few seconds."
	ability_name = "corrosive acid"
	var/acid_plasma_cost = 100
	var/acid_type = /obj/effect/xenomorph/acid

/datum/action/xeno_action/activable/corrosive_acid/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.corrosive_acid(A, acid_type, acid_plasma_cost)

/datum/action/xeno_action/activable/spray_acid
	name = "Spray Acid"
	action_icon_state = "spray_acid"
	mechanics_text = "Spray a line or cone of dangerous acid at your target."
	ability_name = "spray acid"

/datum/action/xeno_action/activable/spray_acid/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner

	if (isxenopraetorian(owner))
		X.acid_spray_cone(A)
		return

	var/mob/living/carbon/Xenomorph/B = X
	B.acid_spray(A)

/datum/action/xeno_action/activable/spray_acid/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner

	if (isxenopraetorian(owner))
		return !X.used_acid_spray

	var/mob/living/carbon/Xenomorph/B = X
	return !B.acid_cooldown

/datum/action/xeno_action/activable/xeno_spit
	name = "Xeno Spit"
	action_icon_state = "xeno_spit"
	mechanics_text = "Spit neurotoxin or acid at your target up to 7 tiles away."
	ability_name = "xeno spit"

/datum/action/xeno_action/activable/xeno_spit/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.xeno_spit(A)

/datum/action/xeno_action/activable/xeno_spit/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	if(X.has_spat < world.time) return TRUE

/datum/action/xeno_action/xenohide
	name = "Hide"
	action_icon_state = "xenohide"
	mechanics_text = "Causes your sprite to hide behind certain objects and under tables. Not the same as stealth. Does not use plasma."
	plasma_cost = 0

/datum/action/xeno_action/xenohide/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state())
		return
	if(X.layer != XENO_HIDING_LAYER)
		X.layer = XENO_HIDING_LAYER
		to_chat(X, "<span class='notice'>You are now hiding.</span>")
	else
		X.layer = MOB_LAYER
		to_chat(X, "<span class='notice'>You have stopped hiding.</span>")


//Neurotox Sting
/datum/action/xeno_action/activable/neurotox_sting
	name = "Neurotoxin Sting"
	action_icon_state = "neuro_sting"
	mechanics_text = "A channeled melee attack that injects the target with neurotoxin over a few seconds, temporarily stunning them."
	ability_name = "neurotoxin sting"

/datum/action/xeno_action/activable/neurotox_sting/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.neurotoxin_sting(A)

/datum/action/xeno_action/activable/neurotox_sting/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	if(world.time >= X.last_neurotoxin_sting + XENO_NEURO_STING_COOLDOWN)
		return TRUE

// ***************************************
// *********** Pouncey abilities
// ***************************************
// Pounce
/datum/action/xeno_action/activable/pounce
	name = "Pounce"
	action_icon_state = "pounce"
	mechanics_text = "Leap at your target, tackling and disarming them."
	ability_name = "pounce"

/datum/action/xeno_action/activable/pounce/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.Pounce(A)

/datum/action/xeno_action/activable/pounce/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.usedPounce

/////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/carbon/Xenomorph/proc/add_abilities()
	if(actions && actions.len)
		for(var/action_path in actions)
			if(ispath(action_path))
				actions -= action_path
				var/datum/action/xeno_action/A = new action_path()
				A.give_action(src)
