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
		new /obj/effect/alien/weeds/node(X.loc, src, X)
		playsound(X.loc, "alien_resin_build", 25)
		round_statistics.weeds_planted++

// Resting
/datum/action/xeno_action/xeno_resting
	name = "Rest"
	action_icon_state = "resting"
	mechanics_text = "Rest on weeds to regenerate health and plasma."

//resting action can be done even when lying down
/datum/action/xeno_action/xeno_resting/can_use_action()
	var/mob/living/carbon/Xenomorph/X = owner

	if (!X || X.is_mob_incapacitated(1) || X.buckled || X.fortify || X.crest_defense)
		return

	return TRUE

/datum/action/xeno_action/xeno_resting/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	X.lay_down()
	X.update_action_buttons() //extra responsive, uh?



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
			M.KnockDown(1)
			M.adjust_blindness(-1)

		X.visible_message("<span class='xenowarning'>\The [X] hurls out the contents of their stomach!</span>", \
		"<span class='xenowarning'>You hurl out the contents of your stomach!</span>", null, 5)
	else
		to_chat(X, "<span class='warning'>There's nothing in your belly that needs regurgitating.</span>")


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

/datum/action/xeno_action/activable/secrete_resin/hivelord
	name = "Secrete Resin (100)"
	resin_plasma_cost = 100


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

/datum/action/xeno_action/activable/corrosive_acid/drone
	name = "Corrosive Acid (75)"
	acid_plasma_cost = 75
	acid_type = /obj/effect/xenomorph/acid/weak

/datum/action/xeno_action/activable/corrosive_acid/Boiler
	name = "Corrosive Acid (200)"
	acid_plasma_cost = 200
	acid_type = /obj/effect/xenomorph/acid/strong

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

// Warrior Agility
/datum/action/xeno_action/activable/toggle_agility
	name = "Toggle Agility"
	action_icon_state = "agility_on"
	mechanics_text = "Move an all fours for greater speed. Cannot use abilities while in this mode."
	ability_name = "toggle agility"

/datum/action/xeno_action/activable/toggle_agility/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	X.toggle_agility()

/datum/action/xeno_action/activable/toggle_agility/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_toggle_agility


// Warrior Lunge
/datum/action/xeno_action/activable/lunge
	name = "Lunge"
	action_icon_state = "lunge"
	mechanics_text = "Pounce up to 5 tiles and grab a target, knocking them down and putting them in your grasp."
	ability_name = "lunge"

/datum/action/xeno_action/activable/lunge/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.lunge(A)

/datum/action/xeno_action/activable/lunge/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_lunge


// Warrior Fling
/datum/action/xeno_action/activable/fling
	name = "Fling"
	action_icon_state = "fling"
	mechanics_text = "Knock a target flying up to 5 tiles."
	ability_name = "Fling"

/datum/action/xeno_action/activable/fling/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.fling(A)

/datum/action/xeno_action/activable/fling/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_fling


// Warrior Punch
/datum/action/xeno_action/activable/punch
	name = "Punch"
	action_icon_state = "punch"
	mechanics_text = "Strike a target up to 1 tile away with a chance to break bones."
	ability_name = "punch"

/datum/action/xeno_action/activable/punch/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.punch(A)

/datum/action/xeno_action/activable/punch/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_punch


// Defender Headbutt
/datum/action/xeno_action/activable/headbutt
	name = "Headbutt"
	action_icon_state = "headbutt"
	mechanics_text = "Charge a target up to 2 tiles away, knocking them away and down and disarming them."
	ability_name = "headbutt"

/datum/action/xeno_action/activable/headbutt/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.headbutt(A)

/datum/action/xeno_action/activable/headbutt/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_headbutt


// Defender Tail Sweep
/datum/action/xeno_action/activable/tail_sweep
	name = "Tail Sweep"
	action_icon_state = "tail_sweep"
	mechanics_text = "Hit all adjacent units around you, knocking them away and down."
	ability_name = "tail sweep"

/datum/action/xeno_action/activable/tail_sweep/use_ability()
	var/mob/living/carbon/Xenomorph/X = owner
	X.tail_sweep()

/datum/action/xeno_action/activable/tail_sweep/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_tail_sweep


// Defender Toggle Crest Defense
/datum/action/xeno_action/activable/toggle_crest_defense
	name = "Toggle Crest Defense"
	action_icon_state = "crest_defense"
	mechanics_text = "Increase your resistance to projectiles at the cost of move speed. Can use abilities while in Crest Defense."
	ability_name = "toggle crest defense"

/datum/action/xeno_action/activable/toggle_crest_defense/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	X.toggle_crest_defense()

/datum/action/xeno_action/activable/toggle_crest_defense/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_crest_defense


// Defender Fortify
/datum/action/xeno_action/activable/fortify
	name = "Fortify"
	action_icon_state = "fortify"	// TODO
	mechanics_text = "Plant yourself for a large defensive boost."
	ability_name = "fortify"

/datum/action/xeno_action/activable/fortify/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	X.fortify()

/datum/action/xeno_action/activable/fortify/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_fortify


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
	if(X.is_mob_incapacitated() || X.lying || X.buckled)
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

/datum/action/xeno_action/activable/salvage_plasma
	name = "Salvage Plasma"
	action_icon_state = "salvage_plasma"
	ability_name = "salvage plasma"
	var/plasma_salvage_amount = PLASMA_SALVAGE_AMOUNT
	var/salvage_delay = 5 SECONDS
	var/max_range = 1

datum/action/xeno_action/activable/salvage_plasma/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	if(owner.action_busy)
		return
	X.xeno_salvage_plasma(A, plasma_salvage_amount, salvage_delay, max_range)

datum/action/xeno_action/activable/salvage_plasma/improved
	plasma_salvage_amount = PLASMA_SALVAGE_AMOUNT * 2
	salvage_delay = 3 SECONDS
	max_range = 4

//Boiler abilities

/datum/action/xeno_action/toggle_long_range
	name = "Toggle Long Range Sight (20)"
	action_icon_state = "toggle_long_range"
	mechanics_text = "Activates your weapon sight in the direction you are facing. Must remain stationary to use."
	plasma_cost = 20

/datum/action/xeno_action/toggle_long_range/can_use_action()
	var/mob/living/carbon/Xenomorph/Boiler/X = owner
	if(X && !X.is_mob_incapacitated() && !X.lying && !X.buckled && (X.is_zoomed || X.plasma_stored >= plasma_cost) && !X.stagger)
		return TRUE

/datum/action/xeno_action/toggle_long_range/action_activate()
	var/mob/living/carbon/Xenomorph/Boiler/X = owner
	if(X.is_zoomed)
		X.zoom_out()
		X.visible_message("<span class='notice'>[X] stops looking off into the distance.</span>", \
		"<span class='notice'>You stop looking off into the distance.</span>", null, 5)
	else
		X.visible_message("<span class='notice'>[X] starts looking off into the distance.</span>", \
			"<span class='notice'>You start focusing your sight to look off into the distance.</span>", null, 5)
		if(!do_after(X, 20, FALSE)) return
		if(X.is_zoomed) return
		X.zoom_in()
		..()

/datum/action/xeno_action/toggle_bomb
	name = "Toggle Bombard Type"
	action_icon_state = "toggle_bomb0"
	mechanics_text = "Switches Boiler Bombard type between Corrosive Acid and Neurotoxin."
	plasma_cost = 0

/datum/action/xeno_action/toggle_bomb/action_activate()
	var/mob/living/carbon/Xenomorph/Boiler/X = owner
	to_chat(X, "<span class='notice'>You will now fire [X.ammo.type == /datum/ammo/xeno/boiler_gas ? "corrosive acid. This is lethal!" : "neurotoxic gas. This is nonlethal."]</span>")
	button.overlays.Cut()
	if(X.ammo.type == /datum/ammo/xeno/boiler_gas)
		X.ammo = GLOB.ammo_list[/datum/ammo/xeno/boiler_gas/corrosive]
		button.overlays += image('icons/mob/actions.dmi', button, "toggle_bomb1")
	else
		X.ammo = GLOB.ammo_list[/datum/ammo/xeno/boiler_gas]
		button.overlays += image('icons/mob/actions.dmi', button, "toggle_bomb0")

/datum/action/xeno_action/bombard
	name = "Bombard"
	action_icon_state = "bombard"
	mechanics_text = "Launch a glob of neurotoxin or acid. Must remain stationary for a few seconds to use."
	plasma_cost = 0

/datum/action/xeno_action/bombard/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Boiler/X = owner
	return !X.bomb_cooldown

/datum/action/xeno_action/bombard/action_activate()
	var/mob/living/carbon/Xenomorph/Boiler/X = owner

	if(X.is_bombarding)
		if(X.client)
			X.client.mouse_pointer_icon = initial(X.client.mouse_pointer_icon) //Reset the mouse pointer.
		X.is_bombarding = 0
		to_chat(X, "<span class='notice'>You relax your stance.</span>")
		return

	if(X.bomb_cooldown)
		to_chat(X, "<span class='warning'>You are still preparing another spit. Be patient!</span>")
		return

	if(!isturf(X.loc))
		to_chat(X, "<span class='warning'>You can't do that from there.</span>")
		return

	X.visible_message("<span class='notice'>\The [X] begins digging their claws into the ground.</span>", \
	"<span class='notice'>You begin digging yourself into place.</span>", null, 5)
	if(do_after(X, 30, FALSE, 5, BUSY_ICON_GENERIC))
		if(X.is_bombarding) return
		X.is_bombarding = 1
		X.visible_message("<span class='notice'>\The [X] digs itself into the ground!</span>", \
		"<span class='notice'>You dig yourself into place! If you move, you must wait again to fire.</span>", null, 5)
		X.bomb_turf = get_turf(X)
		if(X.client)
			X.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
	else
		X.is_bombarding = 0
		if(X.client)
			X.client.mouse_pointer_icon = initial(X.client.mouse_pointer_icon)

//Carrier Abilities

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

/datum/action/xeno_action/activable/retrieve_egg
	name = "Retrieve Egg"
	action_icon_state = "retrieve_egg"
	mechanics_text = "Store an egg on your body for future use. The egg has to be unplanted."
	ability_name = "retrieve egg"

/datum/action/xeno_action/activable/retrieve_egg/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Carrier/X = owner
	X.retrieve_egg(A)

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


//Crusher abilities
/datum/action/xeno_action/activable/stomp
	name = "Stomp (50)"
	action_icon_state = "stomp"
	mechanics_text = "Knocks all adjacent targets away and down."
	ability_name = "stomp"

/datum/action/xeno_action/activable/stomp/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Crusher/X = owner
	if(world.time >= X.has_screeched + CRUSHER_STOMP_COOLDOWN)
		return TRUE

/datum/action/xeno_action/activable/stomp/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Crusher/X = owner
	X.stomp()

/datum/action/xeno_action/ready_charge
	name = "Toggle Charging"
	action_icon_state = "ready_charge"
	mechanics_text = "Toggles the Crusher’s movement based charge on and off."
	plasma_cost = 0

/datum/action/xeno_action/ready_charge/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state()) return FALSE
	if(X.legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't charge with that thing on your leg!</span>")
		X.is_charging = 0
	else
		X.is_charging = !X.is_charging
		to_chat(X, "<span class='xenonotice'>You will [X.is_charging ? "now" : "no longer"] charge when moving.</span>")

//Hivelord Abilities

/datum/action/xeno_action/toggle_speed
	name = "Resin Walker (50)"
	action_icon_state = "toggle_speed"
	mechanics_text = "Move faster on resin."
	plasma_cost = 50

/datum/action/xeno_action/toggle_speed/can_use_action()
	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	if(X && !X.is_mob_incapacitated() && !X.lying && !X.buckled && (X.speed_activated || X.plasma_stored >= plasma_cost) && !X.stagger)
		return TRUE

/datum/action/xeno_action/toggle_speed/action_activate()
	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	if(!X.check_state())
		return

	if(X.speed_activated)
		to_chat(X, "<span class='warning'>You feel less in tune with the resin.</span>")
		X.speed_activated = 0
		return

	if(!X.check_plasma(50))
		return
	X.speed_activated = 1
	X.use_plasma(50)
	to_chat(X, "<span class='notice'>You become one with the resin. You feel the urge to run!</span>")

/datum/action/xeno_action/build_tunnel
	name = "Dig Tunnel (200)"
	action_icon_state = "build_tunnel"
	mechanics_text = "Create a tunnel entrance. Use again to create the tunnel exit."
	plasma_cost = 200

/datum/action/xeno_action/build_tunnel/can_use_action()
	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	if(X.tunnel_delay) return FALSE
	return ..()

/datum/action/xeno_action/build_tunnel/action_activate()
	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	X.build_tunnel()

//Queen Abilities

/datum/action/xeno_action/grow_ovipositor
	name = "Grow Ovipositor (700)"
	action_icon_state = "grow_ovipositor"
	mechanics_text = "Grow an ovipositor to lay eggs and access new abilities. Takes 20 seconds and you cannot move while on the ovipositor."
	plasma_cost = 700

/datum/action/xeno_action/grow_ovipositor/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return

	var/turf/current_turf = get_turf(X)
	if(!current_turf || !istype(current_turf))
		return

	if(X.ovipositor_cooldown > world.time)
		to_chat(X, "<span class='xenowarning'>You're still recovering from detaching your old ovipositor. Wait [round((X.ovipositor_cooldown-world.time)*0.1)] seconds</span>")
		return

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf

	if(!alien_weeds)
		to_chat(X, "<span class='xenowarning'>You need to be on resin to grow an ovipositor.</span>")
		return

	if(!X.check_alien_construction(current_turf))
		return

	if(X.action_busy)
		return

	if(X.check_plasma(plasma_cost))
		X.visible_message("<span class='xenowarning'>\The [X] starts to grow an ovipositor.</span>", \
		"<span class='xenowarning'>You start to grow an ovipositor...(takes 20 seconds, hold still)</span>")
		if(!do_after(X, 200, TRUE, 20, BUSY_ICON_FRIENDLY) && X.check_plasma(plasma_cost))
			return
		if(!X.check_state()) return
		if(!locate(/obj/effect/alien/weeds) in current_turf)
			return

		X.use_plasma(plasma_cost)
		X.visible_message("<span class='xenowarning'>\The [X] has grown an ovipositor!</span>", \
		"<span class='xenowarning'>You have grown an ovipositor!</span>")
		X.mount_ovipositor()

/datum/action/xeno_action/remove_eggsac
	name = "Remove Eggsac"
	action_icon_state = "grow_ovipositor"
	mechanics_text = "Get off your ovipositor, causing it to collapse. You must grow a new one the next time you wish to reattach."
	plasma_cost = 0

/datum/action/xeno_action/remove_eggsac/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return

	if(X.action_busy) return
	var/answer = alert(X, "Are you sure you want to remove your ovipositor? (5min cooldown to grow a new one)", , "Yes", "No")
	if(answer != "Yes")
		return
	if(!X.check_state())
		return
	if(!X.ovipositor)
		return
	X.visible_message("<span class='xenowarning'>\The [X] starts detaching itself from its ovipositor!</span>", \
		"<span class='xenowarning'>You start detaching yourself from your ovipositor.</span>")
	if(!do_after(X, 50, FALSE, 10, BUSY_ICON_HOSTILE)) return
	if(!X.check_state())
		return
	if(!X.ovipositor)
		return
	X.dismount_ovipositor()

/datum/action/xeno_action/activable/screech
	name = "Screech (250)"
	action_icon_state = "screech"
	mechanics_text = "A large area knockdown that causes pain and screen-shake."
	ability_name = "screech"

/datum/action/xeno_action/activable/screech/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	return !X.has_screeched

/datum/action/xeno_action/activable/screech/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	X.queen_screech()

/datum/action/xeno_action/activable/gut
	name = "Gut (200)"
	action_icon_state = "gut"
	ability_name = "gut"

/datum/action/xeno_action/activable/gut/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	X.queen_gut(A)

/datum/action/xeno_action/psychic_whisper
	name = "Psychic Whisper"
	action_icon_state = "psychic_whisper"
	plasma_cost = 0

/datum/action/xeno_action/psychic_whisper/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	var/list/target_list = list()
	for(var/mob/living/possible_target in view(7, X))
		if(possible_target == X || !possible_target.client) continue
		target_list += possible_target

	var/mob/living/M = input("Target", "Send a Psychic Whisper to whom?") as null|anything in target_list
	if(!M) return

	if(!X.check_state())
		return

	var/msg = sanitize(input("Message:", "Psychic Whisper") as text|null)
	if(msg)
		log_directed_talk(X, M, msg, LOG_SAY, "psychic whisper")
		to_chat(M, "<span class='alien'>You hear a strange, alien voice in your head. \italic \"[msg]\"</span>")
		to_chat(X, "<span class='xenonotice'>You said: \"[msg]\" to [M]</span>")

/datum/action/xeno_action/watch_xeno
	name = "Watch Xenomorph"
	action_icon_state = "watch_xeno"
	mechanics_text = "See from the target Xenomorphs vision."
	plasma_cost = 0

/datum/action/xeno_action/watch_xeno/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	if(!X.hive)
		return
	var/list/possible_xenos = X.hive.get_watchable_xenos()

	var/mob/living/carbon/Xenomorph/selected_xeno = input(X, "Target", "Watch which xenomorph?") as null|anything in possible_xenos
	if(!selected_xeno || selected_xeno.gc_destroyed || selected_xeno == X.observed_xeno || selected_xeno.stat == DEAD || is_centcom_level(selected_xeno.z) || !X.check_state())
		if(X.observed_xeno)
			X.set_queen_overwatch(X.observed_xeno, TRUE)
	else
		X.set_queen_overwatch(selected_xeno)

/datum/action/xeno_action/toggle_queen_zoom
	name = "Toggle Queen Zoom"
	action_icon_state = "toggle_queen_zoom"
	mechanics_text = "Zoom out for a larger view around wherever you are looking."
	plasma_cost = 0

/datum/action/xeno_action/toggle_queen_zoom/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	if(X.is_zoomed)
		X.zoom_out()
	else
		X.zoom_in(0, 12)

/datum/action/xeno_action/set_xeno_lead
	name = "Choose/Follow Xenomorph Leaders"
	action_icon_state = "xeno_lead"
	mechanics_text = "Make a target Xenomorph a leader."
	plasma_cost = 0

/datum/action/xeno_action/set_xeno_lead/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	if(!X.hive)
		return

	if(X.observed_xeno)
		if(!(X.observed_xeno.xeno_caste.caste_flags & CASTE_CAN_BE_LEADER))
			to_chat(X, "<span class='xenowarning'>This caste is unfit to lead.</span>")
			return
		if(X.queen_ability_cooldown > world.time)
			to_chat(X, "<span class='xenowarning'>You're still recovering from your last overwatch ability. Wait [round((X.queen_ability_cooldown-world.time)*0.1)] seconds.</span>")
			return
		if(X.xeno_caste.queen_leader_limit <= X.hive.xeno_leader_list.len && !X.observed_xeno.queen_chosen_lead)
			to_chat(X, "<span class='xenowarning'>You currently have [X.hive.xeno_leader_list.len] promoted leaders. You may not maintain additional leaders until your power grows.</span>")
			return
		var/mob/living/carbon/Xenomorph/T = X.observed_xeno
		X.queen_ability_cooldown = world.time + 150 //15 seconds
		if(!T.queen_chosen_lead)
			to_chat(X, "<span class='xenonotice'>You've selected [T] as a Hive Leader.</span>")
			to_chat(T, "<span class='xenoannounce'>[X] has selected you as a Hive Leader. The other Xenomorphs must listen to you. You will also act as a beacon for the Queen's pheromones.</span>")
			X.hive.add_leader(T)
		else
			to_chat(X, "<span class='xenonotice'>You've demoted [T] from Lead.</span>")
			to_chat(T, "<span class='xenoannounce'>[X] has demoted you from Hive Leader. Your leadership rights and abilities have waned.</span>")
			X.hive.remove_leader(T)
		T.hud_set_queen_overwatch()
		T.handle_xeno_leader_pheromones(X)
	else
		if(X.hive.xeno_leader_list.len > 1)
			var/mob/living/carbon/Xenomorph/selected_xeno = input(X, "Target", "Watch which xenomorph leader?") as null|anything in X.hive.xeno_leader_list
			if(!selected_xeno || !selected_xeno.queen_chosen_lead || selected_xeno == X.observed_xeno || selected_xeno.stat == DEAD || selected_xeno.z != X.z || !X.check_state())
				return
			X.set_queen_overwatch(selected_xeno)
		else if(X.hive.xeno_leader_list.len)
			X.set_queen_overwatch(X.hive.xeno_leader_list[1])
		else
			to_chat(X, "<span class='xenowarning'>There are no Xenomorph leaders. Overwatch a Xenomorph to make it a leader.</span>")

/datum/action/xeno_action/queen_heal
	name = "Heal Xenomorph (600)"
	action_icon_state = "heal_xeno"
	mechanics_text = "Heals a target Xenomorph (you must be overwatching them.)"
	plasma_cost = 600

/datum/action/xeno_action/queen_heal/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	if(X.queen_ability_cooldown > world.time)
		to_chat(X, "<span class='xenowarning'>You're still recovering from your last overwatch ability. Wait [round((X.queen_ability_cooldown-world.time)*0.1)] seconds.</span>")
		return
	if(!X.observed_xeno)
		to_chat(X, "<span class='warning'>You must overwatch the xeno you want to give healing to.</span>")
		return
	var/mob/living/carbon/Xenomorph/target = X.observed_xeno
	if(!(target.xeno_caste.caste_flags & CASTE_CAN_BE_QUEEN_HEALED))
		to_chat(X, "<span class='xenowarning'>You can't heal that caste.</span>")
		return
	if(X.loc.z != target.loc.z)
		to_chat(X, "<span class='xenowarning'>They are too far away to do this.</span>")
		return
	if(target.stat == DEAD)
		return
	if(target.health >= target.maxHealth)
		to_chat(X, "<span class='warning'>[target] is at full health.</span>")
		return
	if(X.check_plasma(600))
		X.use_plasma(600)
		target.adjustBruteLoss(-50)
		X.queen_ability_cooldown = world.time + 15 SECONDS //15 seconds
		to_chat(X, "<span class='xenonotice'>You channel your plasma to heal [target]'s wounds.</span>")

/datum/action/xeno_action/queen_give_plasma
	name = "Give Plasma (600)"
	action_icon_state = "queen_give_plasma"
	mechanics_text = "Give plasma to a target Xenomorph (you must be overwatching them.)"
	plasma_cost = 600

/datum/action/xeno_action/queen_give_plasma/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	if(X.queen_ability_cooldown > world.time)
		to_chat(X, "<span class='xenowarning'>You're still recovering from your last overwatch ability. Wait [round((X.queen_ability_cooldown-world.time)*0.1)] seconds.</span>")
		return
	if(!X.observed_xeno)
		to_chat(X, "<span class='warning'>You must overwatch the xeno you want to give plasma to.</span>")
		return
	var/mob/living/carbon/Xenomorph/target = X.observed_xeno
	if(target.stat == DEAD)
		return
	if(!(target.xeno_caste.caste_flags & CASTE_CAN_BE_GIVEN_PLASMA))
		to_chat(X, "<span class='warning'>You can't give that caste plasma.</span>")
		return
	if(target.plasma_stored >= target.xeno_caste.plasma_max)
		to_chat(X, "<span class='warning'>[target] is at full plasma.</span>")
		return
	if(X.check_plasma(600))
		X.use_plasma(600)
		target.gain_plasma(100)
		X.queen_ability_cooldown = world.time + 15 SECONDS //15 seconds
		to_chat(X, "<span class='xenonotice'>You transfer some plasma to [target].</span>")

/datum/action/xeno_action/queen_order
	name = "Give Order (100)"
	action_icon_state = "queen_order"
	plasma_cost = 100

/datum/action/xeno_action/queen_order/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	if(X.observed_xeno)
		var/mob/living/carbon/Xenomorph/target = X.observed_xeno
		if(target.stat != DEAD && target.client)
			if(X.check_plasma(100))
				var/input = stripped_input(X, "This message will be sent to the overwatched xeno.", "Queen Order", "")
				if(!input)
					return
				var/queen_order = "<span class='xenoannounce'><b>[X]</b> reaches you:\"[input]\"</span>"
				if(!X.check_state() || !X.check_plasma(100) || X.observed_xeno != target || target.stat == DEAD)
					return
				if(target.client)
					X.use_plasma(100)
					to_chat(target, "[queen_order]")
					log_admin("[key_name(X)] has given the following Queen order to [key_name(target)]: [input]")
					message_admins("[ADMIN_TPMONTY(X)] has given the following Queen order to [ADMIN_TPMONTY(target)]: [input]")

	else
		to_chat(X, "<span class='warning'>You must overwatch the Xenomorph you want to give orders to.</span>")

/datum/action/xeno_action/deevolve
	name = "De-Evolve a Xenomorph"
	action_icon_state = "xeno_deevolve"
	mechanics_text = "De-evolve a target Xenomorph of Tier 2 or higher to the next lowest tier."
	plasma_cost = 600

/datum/action/xeno_action/deevolve/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	if(!X.observed_xeno)
		to_chat(X, "<span class='warning'>You must overwatch the xeno you want to de-evolve.</span>")
		return

	var/mob/living/carbon/Xenomorph/T = X.observed_xeno
	if(!X.check_plasma(600)) // check plasma gives an error message itself
		return

	if(T.is_ventcrawling)
		to_chat(X, "<span class='warning'>[T] can't be deevolved here.</span>")
		return

	if(!isturf(T.loc))
		to_chat(X, "<span class='warning'>[T] can't be deevolved here.</span>")
		return

	if(T.health <= 0)
		to_chat(X, "<span class='warning'>[T] is too weak to be deevolved.</span>")
		return

	if(!T.xeno_caste.deevolves_to)
		to_chat(X, "<span class='xenowarning'>[T] can't be deevolved.</span>")
		return

	var/datum/xeno_caste/new_caste = GLOB.xeno_caste_datums[T.xeno_caste.deevolves_to][XENO_UPGRADE_ZERO]

	var/confirm = alert(X, "Are you sure you want to deevolve [T] from [T.xeno_caste.caste_name] to [new_caste.caste_name]?", , "Yes", "No")
	if(confirm == "No")
		return

	var/reason = stripped_input(X, "Provide a reason for deevolving this xenomorph, [T]")
	if(isnull(reason))
		to_chat(X, "<span class='xenowarning'>You must provide a reason for deevolving [T].</span>")
		return

	if(!X.check_state() || !X.check_plasma(600) || X.observed_xeno != T)
		return

	if(T.is_ventcrawling)
		return

	if(!isturf(T.loc))
		return

	if(T.health <= 0)
		return

	to_chat(T, "<span class='xenowarning'>The queen is deevolving you for the following reason: [reason]</span>")

	var/xeno_type = new_caste.caste_type_path

	//From there, the new xeno exists, hopefully
	var/mob/living/carbon/Xenomorph/new_xeno = new xeno_type(get_turf(T))

	if(!istype(new_xeno))
		//Something went horribly wrong!
		to_chat(X, "<span class='warning'>Something went terribly wrong here. Your new xeno is null! Tell a coder immediately!</span>")
		if(new_xeno)
			qdel(new_xeno)
		return

	if(T.mind)
		T.mind.transfer_to(new_xeno)
	else
		new_xeno.key = T.key
		if(new_xeno.client)
			new_xeno.client.change_view(world.view)
			new_xeno.client.pixel_x = 0
			new_xeno.client.pixel_y = 0

	//Pass on the unique nicknumber, then regenerate the new mob's name now that our player is inside
	new_xeno.nicknumber = T.nicknumber
	new_xeno.generate_name()

	if(T.xeno_mobhud)
		var/datum/mob_hud/H = huds[MOB_HUD_XENO_STATUS]
		H.add_hud_to(new_xeno) //keep our mobhud choice
		new_xeno.xeno_mobhud = TRUE

	new_xeno.middle_mouse_toggle = T.middle_mouse_toggle //Keep our toggle state

	for(var/obj/item/W in T.contents) //Drop stuff
		T.dropItemToGround(W)

	T.empty_gut()
	new_xeno.visible_message("<span class='xenodanger'>A [new_xeno.xeno_caste.caste_name] emerges from the husk of \the [T].</span>", \
	"<span class='xenodanger'>[X] makes you regress into your previous form.</span>")

	if(T.queen_chosen_lead)
		new_xeno.queen_chosen_lead = TRUE
		new_xeno.hud_set_queen_overwatch()

	if(X.hive.living_xeno_queen?.observed_xeno == T)
		X.hive.living_xeno_queen.set_queen_overwatch(new_xeno)

	// this sets the right datum
	new_xeno.upgrade_xeno(T.upgrade_next()) //a young Crusher de-evolves into a MATURE Hunter

	log_admin("[key_name(X)] has deevolved [key_name(T)]. Reason: [reason]")
	message_admins("[ADMIN_TPMONTY(X)] has deevolved [ADMIN_TPMONTY(T)]. Reason: [reason]")

	round_statistics.total_xenos_created-- //so an evolved xeno doesn't count as two.
	qdel(T)
	X.use_plasma(600)


/datum/action/xeno_action/activable/larva_growth
	name = "Advance Larval Growth (300)"
	action_icon_state = "larva_growth"
	mechanics_text = "Instantly cause the larva inside a host to grow a set amount."
	ability_name = "advance larval growth"

/datum/action/xeno_action/activable/larva_growth/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	if(world.time > X.last_larva_growth_used + XENO_LARVAL_ADVANCEMENT_COOLDOWN)
		return TRUE

/datum/action/xeno_action/activable/larva_growth/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state() || X.action_busy)
		return

	if(world.time < X.last_larva_growth_used + XENO_LARVAL_ADVANCEMENT_COOLDOWN)
		to_chat(X, "<span class='xenowarning'>You're still recovering from your previous larva growth advance. Wait [round((X.last_larva_growth_used + XENO_LARVAL_ADVANCEMENT_COOLDOWN - world.time) * 0.1)] seconds.</span>")
		return

	if(!istype(A, /mob/living/carbon/human))
		return

	var/mob/living/carbon/human/H = A

	var/obj/item/alien_embryo/E = locate(/obj/item/alien_embryo) in H

	if(!E)
		to_chat(X, "<span class='xenowarning'>[H] doesn't have a larva growing inside of them.</xenowarning>")
		return

	if(E.stage >= 3)
		to_chat(X, "<span class='xenowarning'>\The [E] inside of [H] is too old to be advanced.</xenowarning>")
		return

	if(X.check_plasma(300))
		X.visible_message("<span class='xenowarning'>\The [X] starts to advance larval growth inside of [H].</span>", \
		"<span class='xenowarning'>You start to advance larval growth inside of [H].</span>")
		if(!do_after(X, 50, TRUE, 20, BUSY_ICON_FRIENDLY) && X.check_plasma(300))
			return
		if(!X.check_state())
			return
		X.use_plasma(300)
		X.visible_message("<span class='xenowarning'>\The [E] inside of [H] grows a little!</span>", \
		"<span class='xenowarning'>\The [E] inside of [H] grows a little!</span>")

		E.stage++
		X.last_larva_growth_used = world.time

//Ravager Abilities

/datum/action/xeno_action/activable/charge
	name = "Eviscerating Charge (80)"
	action_icon_state = "charge"
	mechanics_text = "Charge up to 7 tiles and viciously attack your target."
	ability_name = "charge"

/datum/action/xeno_action/activable/charge/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Ravager/X = owner
	X.charge(A)

/datum/action/xeno_action/activable/charge/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Ravager/X = owner
	return !X.usedPounce


/datum/action/xeno_action/activable/ravage
	name = "Ravage (40)"
	action_icon_state = "ravage"
	mechanics_text = "Release all of your rage in a vicious melee attack against a single target. The more rage you have, the more damage is done."
	ability_name = "ravage"

/datum/action/xeno_action/activable/ravage/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Ravager/X = owner
	X.Ravage(A)

/datum/action/xeno_action/activable/ravage/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Ravager/X = owner
	return !X.ravage_used


/datum/action/xeno_action/activable/second_wind
	name = "Second Wind"
	action_icon_state = "second_wind"
	mechanics_text = "A channeled ability to restore health that uses plasma and rage. Must stand still for it to work."


/datum/action/xeno_action/activable/second_wind/action_activate(atom/A)
	var/mob/living/carbon/Xenomorph/Ravager/X = owner
	X.Second_Wind()


/datum/action/xeno_action/activable/second_wind/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Ravager/X = owner
	return !X.second_wind_used


//Ravenger
/datum/action/xeno_action/activable/breathe_fire
	name = "Breathe Fire"
	action_icon_state = "breathe_fire"
	mechanics_text = "Not as dangerous to yourself as you would think."
	ability_name = "breathe fire"

/datum/action/xeno_action/activable/breathe_fire/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Ravager/ravenger/X = owner
	X.breathe_fire(A)

/datum/action/xeno_action/activable/breathe_fire/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Ravager/ravenger/X = owner
	if(world.time > X.used_fire_breath + 75) return TRUE

//Xenoborg abilities

/datum/action/xeno_action/activable/fire_cannon
	name = "Fire Cannon (5)"
	action_icon_state = "fire_cannon"
	mechanics_text = "Pew pew pew, shoot your arm guns!"
	ability_name = "fire cannon"

/datum/action/xeno_action/activable/fire_cannon/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Xenoborg/X = owner
	X.fire_cannon(A)

//Runner abilities
/datum/action/xeno_action/toggle_savage
	name = "Toggle Savage"
	action_icon_state = "savage_on"
	mechanics_text = "Toggle on to add a vicious attack to your pounce."
	plasma_cost = 0

/datum/action/xeno_action/toggle_savage/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner

	if(!X.check_state())
		return

	if(X.savage)
		X.savage = FALSE
		to_chat(X, "<span class='xenowarning'>You untense your muscles, and relax. You will no longer savage when pouncing.</span>")
		button.overlays.Cut()
		button.overlays += image('icons/mob/actions.dmi', button, "savage_off")
	else
		X.savage = TRUE
		to_chat(X, "You ready yourself for a killing stroke. You will savage when pouncing.[X.savage_used ? " However, you're not quite yet able to savage again." : ""]")
		button.overlays.Cut()
		button.overlays += image('icons/mob/actions.dmi', button, "savage_on")

// Crusher Crest Toss
/datum/action/xeno_action/activable/cresttoss
	name = "Crest Toss"
	action_icon_state = "cresttoss"
	mechanics_text = "Fling an adjacent target over and behind you. Also works over barricades."
	ability_name = "crest toss"

/datum/action/xeno_action/activable/cresttoss/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.cresttoss(A)

/datum/action/xeno_action/activable/cresttoss/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.cresttoss_used

//Carrier abilities
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

//Hunter abilities
/datum/action/xeno_action/activable/stealth
	name = "Toggle Stealth"
	action_icon_state = "stealth_on"
	mechanics_text = "Become harder to see, almost invisible if you stand still, and ready a sneak attack. Uses plasma to move."
	ability_name = "stealth"

/datum/action/xeno_action/activable/stealth/action_activate()
	var/mob/living/carbon/Xenomorph/Hunter/X = owner
	X.Stealth()

/datum/action/xeno_action/activable/stealth/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Hunter/X = owner
	return !X.used_stealth

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

//Defiler abilities

/datum/action/xeno_action/neuroclaws
	name = "Toggle Neuroinjectors"
	action_icon_state = "neuroclaws_off"
	mechanics_text = "Toggle on to add neurotoxin to your melee slashes."

/datum/action/xeno_action/neuroclaws/action_activate()
	var/mob/living/carbon/Xenomorph/Defiler/X = owner

	if(!X.check_state())
		return

	if(world.time < X.last_use_neuroclaws + DEFILER_CLAWS_COOLDOWN)
		return

	X.neuro_claws = !X.neuro_claws
	X.last_use_neuroclaws = world.time
	to_chat(X, "<span class='notice'>You [X.neuro_claws ? "extend" : "retract"] your claws' neuro spines.</span>")
	button.overlays.Cut()
	if(X.neuro_claws)
		playsound(X, 'sound/weapons/slash.ogg', 15, 1)
		button.overlays += image('icons/mob/actions.dmi', button, "neuroclaws_on")
	else
		playsound(X, 'sound/weapons/slashmiss.ogg', 15, 1)
		button.overlays += image('icons/mob/actions.dmi', button, "neuroclaws_off")

/datum/action/xeno_action/emit_neurogas/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Defiler/X = owner
	if(world.time >= X.last_use_neuroclaws + DEFILER_CLAWS_COOLDOWN)
		return TRUE

//Defiler's Sting
/datum/action/xeno_action/activable/defiler_sting
	name = "Defile"
	action_icon_state = "defiler_sting"
	mechanics_text = "Channel to inject an adjacent target with larval growth serum. At the end of the channel your target will be infected."
	ability_name = "defiler sting"

/datum/action/xeno_action/activable/defiler_sting/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Defiler/X = owner
	X.defiler_sting(A)

/datum/action/xeno_action/activable/defiler_sting/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Defiler/X = owner
	if(world.time >= X.last_defiler_sting + DEFILER_STING_COOLDOWN)
		return TRUE

//Defiler Neurogas
/datum/action/xeno_action/activable/emit_neurogas
	name = "Emit Neurogas"
	action_icon_state = "emit_neurogas"
	mechanics_text = "Channel for 3 seconds to emit a cloud of noxious smoke that follows the Defiler. You must remain stationary while channeling; moving will cancel the ability but will still cost plasma."
	ability_name = "emit neurogas"

/datum/action/xeno_action/activable/emit_neurogas/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Defiler/X = owner
	if(world.time >= X.last_emit_neurogas + DEFILER_GAS_COOLDOWN)
		return TRUE

/datum/action/xeno_action/activable/emit_neurogas/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Defiler/X = owner
	X.emit_neurogas()

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

/////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/carbon/Xenomorph/proc/add_abilities()
	if(actions && actions.len)
		for(var/action_path in actions)
			if(ispath(action_path))
				actions -= action_path
				var/datum/action/xeno_action/A = new action_path()
				A.give_action(src)
