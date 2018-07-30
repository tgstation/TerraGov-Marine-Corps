/datum/action/xeno_action/plant_weeds
	name = "Plant Weeds (75)"
	action_icon_state = "plant_weeds"
	plasma_cost = 75

/datum/action/xeno_action/plant_weeds/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state()) return

	var/turf/T = X.loc

	if(!istype(T))
		X << "<span class='warning'>You can't do that here.</span>"
		return

	if(!T.is_weedable())
		X << "<span class='warning'>Bad place for a garden!</span>"
		return

	if(locate(/obj/effect/alien/weeds/node) in T)
		X << "<span class='warning'>There's a pod here already!</span>"
		return

	if(X.check_plasma(75))
		X.use_plasma(75)
		X.visible_message("<span class='xenonotice'>\The [X] regurgitates a pulsating node and plants it on the ground!</span>", \
		"<span class='xenonotice'>You regurgitate a pulsating node and plant it on the ground!</span>", null, 5)
		new /obj/effect/alien/weeds/node(X.loc, src, X)
		playsound(X.loc, "alien_resin_build", 25)


// Resting
/datum/action/xeno_action/xeno_resting
	name = "Rest"
	action_icon_state = "resting"

//resting action can be done even when lying down
/datum/action/xeno_action/xeno_resting/can_use_action()
	var/mob/living/carbon/Xenomorph/X = owner

	if (!X || X.is_mob_incapacitated(1) || X.buckled || X.fortify || X.crest_defense)
		return

	return 1

/datum/action/xeno_action/xeno_resting/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(X.is_mob_incapacitated(TRUE))
		return

	X.resting = !X.resting
	X << "\blue You are now [X.resting ? "resting" : "getting up"]"


// Shift Spits
/datum/action/xeno_action/shift_spits
	name = "Toggle Spit Type"
	action_icon_state = "shift_spit_neurotoxin"
	plasma_cost = 0

/datum/action/xeno_action/shift_spits/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state())
		return
	for(var/i in 1 to X.spit_types.len)
		if(X.ammo == ammo_list[X.spit_types[i]])
			if(i == X.spit_types.len)
				X.ammo = ammo_list[X.spit_types[1]]
			else
				X.ammo = ammo_list[X.spit_types[i+1]]
			break
	X << "<span class='notice'>You will now spit [X.ammo.name] ([X.ammo.spit_cost] plasma).</span>"
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, "shift_spit_[X.ammo.icon_state]")

// Regurgitate
/datum/action/xeno_action/regurgitate
	name = "Regurgitate"
	action_icon_state = "regurgitate"
	plasma_cost = 0

/datum/action/xeno_action/regurgitate/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state())
		return

	if(!isturf(X.loc))
		X << "<span class='warning'>You cannot regurgitate here.</span>"
		return

	if(X.stomach_contents.len)
		for(var/mob/M in X.stomach_contents)
			X.stomach_contents.Remove(M)
			M.acid_damage = 0 //Reset the acid damage
			if(M.loc != X)
				continue
			M.forceMove(X.loc)

		X.visible_message("<span class='xenowarning'>\The [X] hurls out the contents of their stomach!</span>", \
		"<span class='xenowarning'>You hurl out the contents of your stomach!</span>", null, 5)
	else
		X<< "<span class='warning'>There's nothing in your belly that needs regurgitating.</span>"


// Choose Resin
/datum/action/xeno_action/choose_resin
	name = "Choose Resin Structure"
	action_icon_state = "resin wall"
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

	X << "<span class='notice'>You will now build <b>[X.selected_resin]\s</b> when secreting resin.</span>"
	//update the button's overlay with new choice
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, X.selected_resin)


// Secrete Resin
/datum/action/xeno_action/activable/secrete_resin
	name = "Secrete Resin (75)"
	action_icon_state = "secrete_resin"
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
	ability_name = "spray acid"


/datum/action/xeno_action/activable/spray_acid/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner

	if (isXenoPraetorian(owner))
		X.acid_spray_cone(A)
		return

	var/mob/living/carbon/Xenomorph/Boiler/B = X
	B.acid_spray(A)

/datum/action/xeno_action/activable/spray_acid/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner

	if (isXenoPraetorian(owner))
		return !X.used_acid_spray

	var/mob/living/carbon/Xenomorph/Boiler/B = X
	return !B.acid_cooldown

// Warrior Agility
/datum/action/xeno_action/activable/toggle_agility
	name = "Toggle Agility"
	action_icon_state = "agility_on"
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
	plasma_cost = 0

/datum/action/xeno_action/xenohide/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state())
		return
	if(X.layer != XENO_HIDING_LAYER)
		X.layer = XENO_HIDING_LAYER
		X << "<span class='notice'>You are now hiding.</span>"
	else
		X.layer = MOB_LAYER
		X << "<span class='notice'>You have stopped hiding.</span>"

/datum/action/xeno_action/emit_pheromones
	name = "Emit Pheromones (30)"
	action_icon_state = "emit_pheromones"
	plasma_cost = 30

/datum/action/xeno_action/emit_pheromones/can_use_action()
	var/mob/living/carbon/Xenomorph/X = owner
	if(X && !X.is_mob_incapacitated() && !X.lying && !X.buckled && (!X.current_aura || X.plasma_stored >= plasma_cost))
		return TRUE

/datum/action/xeno_action/emit_pheromones/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state())
		return

	if(X.current_aura)
		X.current_aura = null
		X.visible_message("<span class='xenowarning'>\The [X] stops emitting pheromones.</span>", \
		"<span class='xenowarning'>You stop emitting pheromones.</span>", null, 5)
	else
		if(!X.check_plasma(30))
			return
		var/choice = input(X, "Choose a pheromone") in X.aura_allowed + "help" + "cancel"
		if(choice == "help")
			X << "<span class='notice'><br>Pheromones provide a buff to all Xenos in range at the cost of some stored plasma every second, as follows:<br><B>Frenzy</B> - Increased run speed, damage and tackle chance.<br><B>Warding</B> - Increased armor, reduced incoming damage and critical bleedout.<br><B>Recovery</B> - Increased plasma and health regeneration.<br></span>"
			return
		if(choice == "cancel") return
		if(!X.check_state()) return
		if(X.current_aura) //If they are stacking windows, disable all input
			return
		if(!X.check_plasma(30))
			return
		X.use_plasma(30)
		X.current_aura = choice
		X.visible_message("<span class='xenowarning'>\The [X] begins to emit strange-smelling pheromones.</span>", \
		"<span class='xenowarning'>You begin to emit '[choice]' pheromones.</span>", null, 5)
		playsound(X.loc, "alien_drool", 25)

	if(X.hivenumber && X.hivenumber <= hive_datum.len)
		var/datum/hive_status/hive = hive_datum[X.hivenumber]

		if(isXenoQueen(X) && hive.xeno_leader_list.len && X.anchored)
			var/mob/living/carbon/Xenomorph/Queen/Q = X
			for(var/mob/living/carbon/Xenomorph/L in hive.xeno_leader_list)
				L.handle_xeno_leader_pheromones(Q)

/datum/action/xeno_action/activable/transfer_plasma
	name = "Transfer Plasma"
	action_icon_state = "transfer_plasma"
	ability_name = "transfer plasma"
	var/plasma_transfer_amount = 50
	var/transfer_delay = 20
	var/max_range = 2

/datum/action/xeno_action/activable/transfer_plasma/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.xeno_transfer_plasma(A, plasma_transfer_amount, transfer_delay, max_range)

/datum/action/xeno_action/activable/transfer_plasma/hivelord
	plasma_transfer_amount = 200
	transfer_delay = 5
	max_range = 7

//Boiler abilities

/datum/action/xeno_action/toggle_long_range
	name = "Toggle Long Range Sight (20)"
	action_icon_state = "toggle_long_range"
	plasma_cost = 20

/datum/action/xeno_action/toggle_long_range/can_use_action()
	var/mob/living/carbon/Xenomorph/Boiler/X = owner
	if(X && !X.is_mob_incapacitated() && !X.lying && !X.buckled && (X.is_zoomed || X.plasma_stored >= plasma_cost))
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
	plasma_cost = 0

/datum/action/xeno_action/toggle_bomb/action_activate()
	var/mob/living/carbon/Xenomorph/Boiler/X = owner
	X << "<span class='notice'>You will now fire [X.ammo.type == /datum/ammo/xeno/boiler_gas ? "corrosive acid. This is lethal!" : "neurotoxic gas. This is nonlethal."]</span>"
	button.overlays.Cut()
	if(X.ammo.type == /datum/ammo/xeno/boiler_gas)
		X.ammo = ammo_list[/datum/ammo/xeno/boiler_gas/corrosive]
		button.overlays += image('icons/mob/actions.dmi', button, "toggle_bomb1")
	else
		X.ammo = ammo_list[/datum/ammo/xeno/boiler_gas]
		button.overlays += image('icons/mob/actions.dmi', button, "toggle_bomb0")

/datum/action/xeno_action/bombard
	name = "Bombard"
	action_icon_state = "bombard"
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
		X << "<span class='notice'>You relax your stance.</span>"
		return

	if(X.bomb_cooldown)
		X << "<span class='warning'>You are still preparing another spit. Be patient!</span>"
		return

	if(!isturf(X.loc))
		X << "<span class='warning'>You can't do that from there.</span>"
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
	ability_name = "retrieve egg"

/datum/action/xeno_action/activable/retrieve_egg/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Carrier/X = owner
	X.retrieve_egg(A)

/datum/action/xeno_action/place_trap
	name = "Place hugger trap (200)"
	action_icon_state = "place_trap"
	plasma_cost = 200

/datum/action/xeno_action/place_trap/action_activate()
	var/mob/living/carbon/Xenomorph/Carrier/X = owner
	if(!X.check_state())
		return
	if(!X.check_plasma(plasma_cost))
		return
	var/turf/T = get_turf(X)

	if(!istype(T) || !T.is_weedable() || T.density)
		X << "<span class='warning'>You can't do that here.</span>"
		return

	var/area/AR = get_area(T)
	if(istype(AR,/area/shuttle/drop1/lz1) || istype(AR,/area/shuttle/drop2/lz2) || istype(AR,/area/sulaco/hangar)) //Bandaid for atmospherics bug when Xenos build around the shuttles
		X << "<span class='warning'>You sense this is not a suitable area for expanding the hive.</span>"
		return

	var/obj/effect/alien/weeds/alien_weeds = locate() in T

	if(!alien_weeds)
		X << "<span class='warning'>You can only shape on weeds. Find some resin before you start building!</span>"
		return

	if(!X.check_alien_construction(T))
		return

	X.use_plasma(plasma_cost)
	playsound(X.loc, "alien_resin_build", 25)
	round_statistics.carrier_traps++
	new /obj/effect/alien/resin/trap(X.loc, X)
	X << "<span class='xenonotice'>You place a hugger trap on the weeds, it still needs a facehugger.</span>"


//Crusher abilities
/datum/action/xeno_action/activable/stomp
	name = "Stomp (50)"
	action_icon_state = "stomp"
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
	plasma_cost = 0

/datum/action/xeno_action/ready_charge/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state()) r_FAL
	if(X.legcuffed)
		src << "<span class='xenodanger'>You can't charge with that thing on your leg!</span>"
		X.is_charging = 0
	else
		X.is_charging = !X.is_charging
		X << "<span class='xenonotice'>You will [X.is_charging ? "now" : "no longer"] charge when moving.</span>"

//Hivelord Abilities

/datum/action/xeno_action/toggle_speed
	name = "Resin Walker (50)"
	action_icon_state = "toggle_speed"
	plasma_cost = 50

/datum/action/xeno_action/toggle_speed/can_use_action()
	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	if(X && !X.is_mob_incapacitated() && !X.lying && !X.buckled && (X.speed_activated || X.plasma_stored >= plasma_cost))
		return TRUE

/datum/action/xeno_action/toggle_speed/action_activate()
	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	if(!X.check_state())
		return

	if(X.speed_activated)
		X << "<span class='warning'>You feel less in tune with the resin.</span>"
		X.speed_activated = 0
		return

	if(!X.check_plasma(50))
		return
	X.speed_activated = 1
	X.use_plasma(50)
	X << "<span class='notice'>You become one with the resin. You feel the urge to run!</span>"

/datum/action/xeno_action/build_tunnel
	name = "Dig Tunnel (200)"
	action_icon_state = "build_tunnel"
	plasma_cost = 200

/datum/action/xeno_action/build_tunnel/can_use_action()
	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	if(X.tunnel_delay) return FALSE
	return ..()

/datum/action/xeno_action/build_tunnel/action_activate()
	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	if(!X.check_state())
		return

	if(X.action_busy)
		X << "<span class='warning'>You should finish up what you're doing before digging.</span>"
		return

	var/turf/T = X.loc
	if(!istype(T)) //logic
		X << "<span class='warning'>You can't do that from there.</span>"
		return

	if(!T.can_dig_xeno_tunnel())
		X << "<span class='warning'>You scrape around, but you can't seem to dig through that kind of floor.</span>"
		return

	if(locate(/obj/structure/tunnel) in X.loc)
		X << "<span class='warning'>There already is a tunnel here.</span>"
		return

	if(X.tunnel_delay)
		X << "<span class='warning'>You are not ready to dig a tunnel again.</span>"
		return

	if(X.get_active_hand())
		X << "<span class='xenowarning'>You need an empty claw for this!</span>"
		return

	if(!X.check_plasma(200))
		return

	X.visible_message("<span class='xenonotice'>[X] begins digging out a tunnel entrance.</span>", \
	"<span class='xenonotice'>You begin digging out a tunnel entrance.</span>", null, 5)
	if(!do_after(X, 100, TRUE, 5, BUSY_ICON_BUILD))
		X << "<span class='warning'>Your tunnel caves in as you stop digging it.</span>"
		return
	if(!X.check_plasma(200))
		return
	if(!X.start_dig) //Let's start a new one.
		X.visible_message("<span class='xenonotice'>\The [X] digs out a tunnel entrance.</span>", \
		"<span class='xenonotice'>You dig out the first entrance to your tunnel.</span>", null, 5)
		X.start_dig = new /obj/structure/tunnel(T)
	else
		X << "<span class='xenonotice'>You dig your tunnel all the way to the original entrance, connecting both entrances!</span>"
		var/obj/structure/tunnel/newt = new /obj/structure/tunnel(T)
		newt.other = X.start_dig
		X.start_dig.other = newt //Link the two together
		X.start_dig = null //Now clear it
		X.tunnel_delay = 1
		spawn(2400)
			X << "<span class='notice'>You are ready to dig a tunnel again.</span>"
			X.tunnel_delay = 0
		var/msg = copytext(sanitize(input("Add a description to the tunnel:", "Tunnel Description") as text|null), 1, MAX_MESSAGE_LEN)
		if(msg)
			newt.other.tunnel_desc = msg
			newt.tunnel_desc = msg

	X.use_plasma(200)
	playsound(X.loc, 'sound/weapons/pierce.ogg', 25, 1)


//Queen Abilities

/datum/action/xeno_action/grow_ovipositor
	name = "Grow Ovipositor (700)"
	action_icon_state = "grow_ovipositor"
	plasma_cost = 700

/datum/action/xeno_action/grow_ovipositor/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return

	var/turf/current_turf = get_turf(X)
	if(!current_turf || !istype(current_turf))
		return

	if(X.ovipositor_cooldown > world.time)
		X << "<span class='xenowarning'>You're still recovering from detaching your old ovipositor. Wait [round((X.ovipositor_cooldown-world.time)*0.1)] seconds</span>"
		return

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf

	if(!alien_weeds)
		X << "<span class='xenowarning'>You need to be on resin to grow an ovipositor.</span>"
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
		log_say("PsychicWhisper: [key_name(X)]->[M.key] : [msg]")
		M << "<span class='alien'>You hear a strange, alien voice in your head. \italic \"[msg]\"</span>"
		X << "<span class='xenonotice'>You said: \"[msg]\" to [M]</span>"

/datum/action/xeno_action/watch_xeno
	name = "Watch Xenomorph"
	action_icon_state = "watch_xeno"
	plasma_cost = 0

/datum/action/xeno_action/watch_xeno/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	var/list/possible_xenos = list()
	for(var/mob/living/carbon/Xenomorph/T in living_mob_list)
		if(T.z != ADMIN_Z_LEVEL && T.caste != "Queen" && X.hivenumber == T.hivenumber)
			possible_xenos += T

	var/mob/living/carbon/Xenomorph/selected_xeno = input(X, "Target", "Watch which xenomorph?") as null|anything in possible_xenos
	if(!selected_xeno || selected_xeno.disposed || selected_xeno == X.observed_xeno || selected_xeno.stat == DEAD || selected_xeno.z == ADMIN_Z_LEVEL || !X.check_state())
		if(X.observed_xeno)
			X.set_queen_overwatch(X.observed_xeno, TRUE)
	else
		X.set_queen_overwatch(selected_xeno)

/datum/action/xeno_action/toggle_queen_zoom
	name = "Toggle Queen Zoom"
	action_icon_state = "toggle_queen_zoom"
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
	plasma_cost = 0

/datum/action/xeno_action/set_xeno_lead/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	var/datum/hive_status/hive
	if(X.hivenumber && X.hivenumber <= hive_datum.len)
		hive = hive_datum[X.hivenumber]
	else
		return
	if(X.observed_xeno)
		if(X.queen_ability_cooldown > world.time)
			X << "<span class='xenowarning'>You're still recovering from your last overwatch ability. Wait [round((X.queen_ability_cooldown-world.time)*0.1)] seconds.</span>"
			return
		if(X.queen_leader_limit <= hive.xeno_leader_list.len && !X.observed_xeno.queen_chosen_lead)
			X << "<span class='xenowarning'>You currently have [hive.xeno_leader_list.len] promoted leaders. You may not maintain additional leaders until your power grows.</span>"
			return
		var/mob/living/carbon/Xenomorph/T = X.observed_xeno
		T.queen_chosen_lead = !T.queen_chosen_lead
		T.hud_set_queen_overwatch()
		X.queen_ability_cooldown = world.time + 150 //15 seconds
		if(T.queen_chosen_lead)
			X << "<span class='xenonotice'>You've selected [T] as a Hive Leader.</span>"
			T << "<span class='xenoannounce'>[X] has selected you as a Hive Leader. The other Xenomorphs must listen to you. You will also act as a beacon for the Queen's pheromones.</span>"
			hive.xeno_leader_list += T
		else
			X << "<span class='xenonotice'>You've demoted [T] from Lead.</span>"
			T << "<span class='xenoannounce'>[X] has demoted you from Hive Leader. Your leadership rights and abilities have waned.</span>"
			hive.xeno_leader_list -= T
		T.handle_xeno_leader_pheromones(X)
	else
		var/list/possible_xenos = list()
		for(var/mob/living/carbon/Xenomorph/T in hive.xeno_leader_list)
			possible_xenos += T

		if(possible_xenos.len > 1)
			var/mob/living/carbon/Xenomorph/selected_xeno = input(X, "Target", "Watch which xenomorph leader?") as null|anything in possible_xenos
			if(!selected_xeno || !selected_xeno.queen_chosen_lead || selected_xeno == X.observed_xeno || selected_xeno.stat == DEAD || selected_xeno.z != X.z || !X.check_state())
				return
			X.set_queen_overwatch(selected_xeno)
		else if(possible_xenos.len)
			X.set_queen_overwatch(possible_xenos[1])
		else
			X << "<span class='xenowarning'>There are no Xenomorph leaders. Overwatch a Xenomorph to make it a leader.</span>"

/datum/action/xeno_action/queen_heal
	name = "Heal Xenomorph (600)"
	action_icon_state = "heal_xeno"
	plasma_cost = 600

/datum/action/xeno_action/queen_heal/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	if(X.queen_ability_cooldown > world.time)
		X << "<span class='xenowarning'>You're still recovering from your last overwatch ability. Wait [round((X.queen_ability_cooldown-world.time)*0.1)] seconds.</span>"
		return
	if(X.observed_xeno)
		var/mob/living/carbon/Xenomorph/target = X.observed_xeno
		if(X.loc.z != target.loc.z)
			X << "<span class='xenowarning'>They are too far away to do this.</span>"
			return
		if(target.stat != DEAD)
			if(target.health < target.maxHealth)
				if(X.check_plasma(600))
					X.use_plasma(600)
					target.adjustBruteLoss(-50)
					X.queen_ability_cooldown = world.time + 150 //15 seconds
					X << "<span class='xenonotice'>You channel your plasma to heal [target]'s wounds.</span>"
			else

				X << "<span class='warning'>[target] is at full health.</span>"
	else
		X << "<span class='warning'>You must overwatch the xeno you want to give healing to.</span>"

/datum/action/xeno_action/queen_give_plasma
	name = "Give Plasma (600)"
	action_icon_state = "queen_give_plasma"
	plasma_cost = 600

/datum/action/xeno_action/queen_give_plasma/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	if(X.queen_ability_cooldown > world.time)
		X << "<span class='xenowarning'>You're still recovering from your last overwatch ability. Wait [round((X.queen_ability_cooldown-world.time)*0.1)] seconds.</span>"
		return
	if(X.observed_xeno)
		var/mob/living/carbon/Xenomorph/target = X.observed_xeno
		if(target.stat != DEAD)
			if(target.plasma_stored < target.plasma_max)
				if(X.check_plasma(600))
					X.use_plasma(600)
					target.gain_plasma(100)
					X.queen_ability_cooldown = world.time + 150 //15 seconds
					X << "<span class='xenonotice'>You transfer some plasma to [target].</span>"

			else

				X << "<span class='warning'>[target] is at full plasma.</span>"
	else
		X << "<span class='warning'>You must overwatch the xeno you want to give plasma to.</span>"

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
					target << "[queen_order]"
					log_admin("[queen_order]")
					message_admins("[key_name_admin(X)] has given the following Queen order to [target]: \"[input]\"", 1)

	else
		X << "<span class='warning'>You must overwatch the Xenomorph you want to give orders to.</span>"

/datum/action/xeno_action/deevolve
	name = "De-Evolve a Xenomorph"
	action_icon_state = "xeno_deevolve"
	plasma_cost = 600

/datum/action/xeno_action/deevolve/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return
	if(X.observed_xeno)
		var/mob/living/carbon/Xenomorph/T = X.observed_xeno
		if(!X.check_plasma(600)) return

		if(T.is_ventcrawling)
			X << "<span class='warning'>[T] can't be deevolved here.</span>"
			return

		if(!isturf(T.loc))
			X << "<span class='warning'>[T] can't be deevolved here.</span>"
			return

		if(T.health <= 0)
			X << "<span class='warning'>[T] is too weak to be deevolved.</span>"
			return

		var/newcaste = ""

		switch(T.caste)
			if("Hivelord")
				newcaste = "Drone"
			if("Carrier")
				newcaste = "Drone"
			if("Crusher")
				newcaste = "Warrior"
			if("Ravager")
				newcaste = "Lurker"
			if("Praetorian")
				newcaste = "Warrior"
			if("Boiler")
				newcaste = "Spitter"
			if("Spitter")
				newcaste = "Sentinel"
			if("Lurker")
				newcaste = "Runner"
			if("Warrior")
				newcaste = "Defender"

		if(!newcaste)
			X << "<span class='xenowarning'>[T] can't be deevolved.</span>"
			return

		var/confirm = alert(X, "Are you sure you want to deevolve [T] from [T.caste] to [newcaste]?", , "Yes", "No")
		if(confirm == "No")
			return

		var/reason = stripped_input(X, "Provide a reason for deevolving this xenomorph, [T]")
		if(isnull(reason))
			X << "<span class='xenowarning'>You must provide a reason for deevolving [T].</span>"
			return

		if(!X.check_state() || !X.check_plasma(600) || X.observed_xeno != T)
			return

		if(T.is_ventcrawling)
			return

		if(!isturf(T.loc))
			return

		if(T.health <= 0)
			return

		T << "<span class='xenowarning'>The queen is deevolving you for the following reason: [reason]</span>"

		var/xeno_type

		switch(newcaste)
			if("Runner")
				xeno_type = /mob/living/carbon/Xenomorph/Runner
			if("Drone")
				xeno_type = /mob/living/carbon/Xenomorph/Drone
			if("Sentinel")
				xeno_type = /mob/living/carbon/Xenomorph/Sentinel
			if("Spitter")
				xeno_type = /mob/living/carbon/Xenomorph/Spitter
			if("Lurker")
				xeno_type = /mob/living/carbon/Xenomorph/Lurker
			if("Warrior")
				xeno_type = /mob/living/carbon/Xenomorph/Warrior
			if("Defender")
				xeno_type = /mob/living/carbon/Xenomorph/Defender

		//From there, the new xeno exists, hopefully
		var/mob/living/carbon/Xenomorph/new_xeno = new xeno_type(get_turf(T))

		if(!istype(new_xeno))
			//Something went horribly wrong!
			X << "<span class='warning'>Something went terribly wrong here. Your new xeno is null! Tell a coder immediately!</span>"
			if(new_xeno)
				cdel(new_xeno)
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
			T.drop_inv_item_on_ground(W)

		T.empty_gut()
		new_xeno.visible_message("<span class='xenodanger'>A [new_xeno.caste] emerges from the husk of \the [T].</span>", \
		"<span class='xenodanger'>[X] makes you regress into your previous form.</span>")

		if(T.queen_chosen_lead)
			new_xeno.queen_chosen_lead = TRUE
			new_xeno.hud_set_queen_overwatch()

		var/datum/hive_status/hive = hive_datum[X.hivenumber]

		if(hive.living_xeno_queen && hive.living_xeno_queen.observed_xeno == T)
			hive.living_xeno_queen.set_queen_overwatch(new_xeno)

		new_xeno.upgrade_xeno(TRUE, min(T.upgrade+1,3)) //a young Crusher de-evolves into a MATURE Hunter

		message_admins("[key_name_admin(X)] has deevolved [key_name_admin(T)]. Reason: [reason]")
		log_admin("[key_name_admin(X)] has deevolved [key_name_admin(T)]. Reason: [reason]")

		round_statistics.total_xenos_created-- //so an evolved xeno doesn't count as two.
		cdel(T)
		X.use_plasma(600)

	else
		X << "<span class='warning'>You must overwatch the xeno you want to de-evolve.</span>"

//Ravager Abilities

/datum/action/xeno_action/activable/charge
	name = "Charge (20)"
	action_icon_state = "charge"
	ability_name = "charge"

/datum/action/xeno_action/activable/charge/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Ravager/X = owner
	X.charge(A)

/datum/action/xeno_action/activable/charge/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Ravager/X = owner
	return !X.usedPounce

//Ravenger

/datum/action/xeno_action/activable/breathe_fire
	name = "Breathe Fire"
	action_icon_state = "breathe_fire"
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
	ability_name = "fire cannon"

/datum/action/xeno_action/activable/fire_cannon/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Xenoborg/X = owner
	X.fire_cannon(A)

/////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/carbon/Xenomorph/proc/add_abilities()
	if(actions && actions.len)
		for(var/action_path in actions)
			if(ispath(action_path))
				actions -= action_path
				var/datum/action/xeno_action/A = new action_path()
				A.give_action(src)
