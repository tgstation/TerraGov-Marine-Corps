// ***************************************
// *********** Universal abilities
// ***************************************
// Resting
/datum/action/xeno_action/xeno_resting
	name = "Rest"
	action_icon_state = "resting"
	mechanics_text = "Rest on weeds to regenerate health and plasma."

//resting action can be done even when lying down
/datum/action/xeno_action/xeno_resting/can_use_action()
	var/mob/living/carbon/Xenomorph/X = owner

	if (!X || X.incapacitated(1) || X.buckled || X.fortify || X.crest_defense)
		return

	return TRUE

/datum/action/xeno_action/xeno_resting/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	X.lay_down()
	X.update_action_buttons() //extra responsive, uh?

// Regurgitate
/datum/action/xeno_action/regurgitate
	name = "Regurgitate"
	action_icon_state = "regurgitate"
	mechanics_text = "Vomit whatever you have devoured."
	plasma_cost = 0

/datum/action/xeno_action/regurgitate/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state())
		return

	if(!isturf(X.loc))
		to_chat(X, "<span class='warning'>You cannot regurgitate here.</span>")
		return

	if(X.stomach_contents.len)
		for(var/mob/M in X.stomach_contents)
			X.stomach_contents.Remove(M)
			if(M.loc != X)
				continue
			M.forceMove(X.loc)
			M.SetKnockeddown(1)
			M.adjust_blindness(-1)

		X.visible_message("<span class='xenowarning'>\The [X] hurls out the contents of their stomach!</span>", \
		"<span class='xenowarning'>You hurl out the contents of your stomach!</span>", null, 5)
	else
		to_chat(X, "<span class='warning'>There's nothing in your belly that needs regurgitating.</span>")

// ***************************************
// *********** Drone-y abilities
// ***************************************
/datum/action/xeno_action/plant_weeds
	name = "Plant Weeds (75)"
	action_icon_state = "plant_weeds"
	plasma_cost = 75
	mechanics_text = "Plant a weed node (purple sac) on your tile."

/datum/action/xeno_action/plant_weeds/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state())
		return

	var/turf/T = X.loc

	if(!istype(T))
		to_chat(X, "<span class='warning'>You can't do that here.</span>")
		return

	if(!T.is_weedable())
		to_chat(X, "<span class='warning'>Bad place for a garden!</span>")
		return

	if(locate(/obj/effect/alien/weeds/node) in T)
		to_chat(X, "<span class='warning'>There's a pod here already!</span>")
		return

	if(X.check_plasma(75))
		X.use_plasma(75)
		X.visible_message("<span class='xenonotice'>\The [X] regurgitates a pulsating node and plants it on the ground!</span>", \
		"<span class='xenonotice'>You regurgitate a pulsating node and plant it on the ground!</span>", null, 5)
		var/obj/effect/alien/weeds/node/N = new (X.loc, src, X)
		X.transfer_fingerprints_to(N)
		playsound(X.loc, "alien_resin_build", 25)
		round_statistics.weeds_planted++

// Choose Resin
/datum/action/xeno_action/choose_resin
	name = "Choose Resin Structure"
	action_icon_state = "resin wall"
	mechanics_text = "Selects which structure you will build with the (secrete resin) ability."
	plasma_cost = 0

/datum/action/xeno_action/choose_resin/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state())
		return
	switch(X.selected_resin)
		if("resin door")
			X.selected_resin = "resin wall"
		if("resin wall")
			X.selected_resin = "resin nest"
		if("resin nest")
			X.selected_resin = "sticky resin"
		if("sticky resin")
			X.selected_resin = "resin door"
		else
			return //something went wrong

	to_chat(X, "<span class='notice'>You will now build <b>[X.selected_resin]\s</b> when secreting resin.</span>")
	//update the button's overlay with new choice
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, X.selected_resin)


// Secrete Resin
/datum/action/xeno_action/activable/secrete_resin
	name = "Secrete Resin (75)"
	action_icon_state = "secrete_resin"
	mechanics_text = "Builds whatever you’ve selected with (choose resin structure) on your tile."
	ability_name = "secrete resin"
	var/resin_plasma_cost = 75

/datum/action/xeno_action/activable/secrete_resin/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.build_resin(A, resin_plasma_cost)

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
