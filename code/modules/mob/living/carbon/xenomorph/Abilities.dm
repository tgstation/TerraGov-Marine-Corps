


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

	if(T.slayer > 0)
		X << "<span class='warning'>It requires a solid ground. Dig it up!</span>"
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
		"<span class='xenonotice'>You regurgitate a pulsating node and plant it on the ground!</span>")
		new /obj/effect/alien/weeds/node(X.loc, src, X)
		playsound(X.loc, 'sound/effects/splat.ogg', 15, 1) //Splat!




/datum/action/xeno_action/activable/tail_attack
	name = "Tail Attack (20)(drain while active)"
	action_icon_state = "tail_attack"
	plasma_cost = 20
	ability_name = "ready tail attack"

/datum/action/xeno_action/activable/tail_attack/can_use_action()
	var/mob/living/carbon/Xenomorph/X = owner
	if(X && !X.is_mob_incapacitated() && !X.lying && !X.buckled && (X.readying_tail || X.storedplasma >= plasma_cost))
		return TRUE

/datum/action/xeno_action/activable/tail_attack/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.tail_attack(A)

/datum/action/xeno_action/activable/tail_attack/on_activation()
	var/mob/living/carbon/Xenomorph/X = owner
	X.readying_tail = 1
	X.visible_message("<span class='warning'>\The [X]'s tail starts to coil like a spring.</span>", \
	"<span class='notice'>You begin to ready your tail for a vicious attack. This will drain plasma to keep active.</span>")


/datum/action/xeno_action/activable/tail_attack/on_deactivation()
	var/mob/living/carbon/Xenomorph/X = owner
	X.readying_tail = 0
	X.visible_message("<span class='notice'>\The [X]'s tail relaxes.</span>", \
	"<span class='notice'>You relax your tail. You are no longer readying a tail attack.</span>")



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
		for(var/mob/M in X)
			if(M in X.stomach_contents)
				X.stomach_contents.Remove(M)
				M.forceMove(X.loc)
				M.acid_damage = 0 //Reset the acid damage
		X.visible_message("<span class='xenowarning'>\The [X] hurls out the contents of their stomach!</span>", \
		"<span class='xenowarning'>You hurl out the contents of your stomach!</span>")
	else
		X<< "<span class='warning'>There's nothing in your belly that needs regurgitating.</span>"





/datum/action/xeno_action/choose_resin
	name = "Choose Resin Structure"
	action_icon_state = "resin wall"
	plasma_cost = 0

/datum/action/xeno_action/choose_resin/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state())
		return
	var/choice = input("Choose what you wish to shape.","Resin building") as null|anything in list("resin door", "resin wall", "resin membrane", "resin nest", "sticky resin", "cancel")
	if(!choice || choice == "cancel")
		return
	if(!X.check_state())
		return
	X.selected_resin = choice
	//update the button's overlay with new choice
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, choice)
	X << "<span class='notice'>You will now build [X.selected_resin]\s when secreting resin.</span>"






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
	if(X && !X.is_mob_incapacitated() && !X.lying && !X.buckled && (!X.current_aura || X.storedplasma >= plasma_cost))
		return TRUE


/datum/action/xeno_action/emit_pheromones/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state())
		return

	if(X.current_aura)
		X.current_aura = null
		X.visible_message("<span class='xenowarning'>\The [X] stops emitting pheromones.</span>", \
		"<span class='xenowarning'>You stop emitting pheromones.</span>")
	else
		if(!X.check_plasma(30))
			return
		var/choice = input(X, "Choose a pheromone") in X.aura_allowed + "help" + "cancel"
		if(choice == "help")
			X << "<span class='notice'><br>Pheromones provide a buff to all Xenos in range at the cost of some stored plasma every second, as follows:<br><B>Frenzy</B> - Increased run speed and tackle chance.<br><B>Warding</B> - Increased armor, reduced incoming damage and critical bleedout.<br><B>Recovery</B> - Increased plasma and health regeneration.<br></span>"
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
		"<span class='xenowarning'>You begin to emit '[choice]' pheromones.</span>")






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
	if(X && !X.is_mob_incapacitated() && !X.lying && !X.buckled && (X.is_zoomed || X.storedplasma >= plasma_cost))
		return TRUE

/datum/action/xeno_action/toggle_long_range/action_activate()
	var/mob/living/carbon/Xenomorph/Boiler/X = owner
	if(X.is_zoomed)
		X.zoom_out()
		X.visible_message("<span class='notice'>[X] stops looking off into the distance.</span>", \
		"<span class='notice'>You stop looking off into the distance.</span>")
	else
		X.visible_message("<span class='notice'>[X] starts looking off into the distance.</span>", \
			"<span class='notice'>You start focusing your sight to look off into the distance.</span>")
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
	X << "<span class='notice'>You will now fire [X.ammo.type == /datum/ammo/xeno/boiler_gas ? "corrosive gas. This is lethal!" : "neurotoxic gas. This is nonlethal."]</span>"
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
	"<span class='notice'>You begin digging yourself into place.</span>")
	if(do_after(X, 30, FALSE))
		if(X.is_bombarding) return
		X.is_bombarding = 1
		X.visible_message("<span class='notice'>\The [X] digs itself into the ground!</span>", \
		"<span class='notice'>You dig yourself into place! If you move, you must wait again to fire.</span>")
		X.bomb_turf = get_turf(X)
		if(X.client)
			X.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
	else
		X.is_bombarding = 0
		if(X.client)
			X.client.mouse_pointer_icon = initial(X.client.mouse_pointer_icon)


/datum/action/xeno_action/activable/spray_acid
	name = "Spray Acid (10+)"
	action_icon_state = "spray_acid"
	ability_name = "spray acid"

/datum/action/xeno_action/activable/spray_acid/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Boiler/X = owner
	X.acid_spray(A)

/datum/action/xeno_action/activable/spray_acid/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Boiler/X = owner
	return !X.acid_cooldown



//Carrier Abilities

/datum/action/xeno_action/activable/throw_hugger
	name = "Throw Facehugger"
	action_icon_state = "throw_hugger"
	ability_name = "throw facehugger"

/datum/action/xeno_action/activable/throw_hugger/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Carrier/X = owner
	X.throw_hugger(A)

/datum/action/xeno_action/activable/throw_hugger/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Carrier/X = owner
	return !X.threw_a_hugger


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

	if(!istype(T) || !T.is_weedable())
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
	playsound(X.loc, 'sound/effects/splat.ogg', 15, 1) //Splat!
	new /obj/effect/alien/resin/trap(X.loc)
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
	var/mob/living/carbon/Xenomorph/Crusher/X = owner
	if(!X.check_state()) r_FAL
	X.is_charging = !X.is_charging
	X << "<span class='xenonotice'>You will [X.is_charging ? "now" : "no longer"] charge when moving.</span>"














//Hivelord Abilities

/datum/action/xeno_action/toggle_speed
	name = "Resin Walker (50)"
	action_icon_state = "toggle_speed"
	plasma_cost = 50

/datum/action/xeno_action/toggle_speed/can_use_action()
	var/mob/living/carbon/Xenomorph/Hivelord/X = owner
	if(X && !X.is_mob_incapacitated() && !X.lying && !X.buckled && (X.speed_activated || X.storedplasma >= plasma_cost))
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
	"<span class='xenonotice'>You begin digging out a tunnel entrance.</span>")
	if(!do_after(X, 100, TRUE, 5, BUSY_ICON_CLOCK))
		X << "<span class='warning'>Your tunnel caves in as you stop digging it.</span>"
		return
	if(!X.check_plasma(200))
		return
	if(!X.start_dig) //Let's start a new one.
		X.visible_message("<span class='xenonotice'>\The [X] digs out a tunnel entrance.</span>", \
		"<span class='xenonotice'>You dig out the first entrance to your tunnel.</span>")
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

/turf/proc/can_dig_xeno_tunnel()
	return FALSE

/turf/unsimulated/floor/gm/can_dig_xeno_tunnel()
	return TRUE

/turf/unsimulated/floor/gm/river/can_dig_xeno_tunnel()
	return FALSE

/turf/unsimulated/floor/snow/can_dig_xeno_tunnel()
	return TRUE

/turf/unsimulated/floor/mars/can_dig_xeno_tunnel()
	return TRUE




//Queen Abilities

/datum/action/xeno_action/lay_egg
	name = "Lay Egg (400)"
	action_icon_state = "lay_egg"
	plasma_cost = 400


/datum/action/xeno_action/lay_egg/action_activate()
	var/mob/living/carbon/Xenomorph/Queen/X = owner
	if(!X.check_state())
		return

	var/turf/current_turf = get_turf(X)
	if(!current_turf || !istype(current_turf))
		return

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf

	if(!alien_weeds)
		src << "<span class='warning'>Your eggs wouldn't grow well enough here. Lay them on resin.</span>"
		return

	if(!X.check_alien_construction(current_turf))
		return

	if(X.check_plasma(plasma_cost))
		X.use_plasma(plasma_cost)
		X.visible_message("<span class='xenowarning'>\The [X] has laid an egg!</span>", \
		"<span class='xenowarning'>You have laid an egg!</span>")
		new /obj/effect/alien/egg(current_turf)



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



//ravenger

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
