/datum/chemical_reaction/reagent_explosion
	name = "Generic explosive"
	id = "reagent_explosion"
	var/strengthdiv = 10
	var/modifier = 0

/datum/chemical_reaction/reagent_explosion/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	var/inside_msg
	if(ismob(holder.my_atom))
		var/mob/M = holder.my_atom
		inside_msg = " inside [ADMIN_LOOKUPFLW(M)]"
	var/lastkey = holder.my_atom.fingerprintslast
	var/touch_msg = "N/A"
	if(lastkey)
		var/mob/toucher = get_mob_by_key(lastkey)
		touch_msg = "[ADMIN_LOOKUPFLW(toucher)]"
	message_admins("Reagent explosion reaction occurred at [ADMIN_VERBOSEJMP(T)][inside_msg]. Last Fingerprint: [touch_msg].")
	log_game("Reagent explosion reaction occurred at [AREACOORD(T)]. Last Fingerprint: [lastkey ? lastkey : "N/A"]." )
	var/datum/effect_system/reagents_explosion/e = new()
	e.set_up(modifier + round(created_volume/strengthdiv, 1), T, 0, 0)
	e.start()
	holder.clear_reagents()


/datum/chemical_reaction/reagent_explosion/nitroglycerin
	name = "Nitroglycerin"
	id = "nitroglycerin"
	results = list("nitroglycerin" = 2)
	required_reagents = list("glycerol" = 1, "facid" = 1, "sacid" = 1)
	strengthdiv = 2

/datum/chemical_reaction/reagent_explosion/nitroglycerin/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	holder.remove_reagent("nitroglycerin", created_volume*2)
	..()

/datum/chemical_reaction/reagent_explosion/nitroglycerin_explosion
	name = "Nitroglycerin explosion"
	id = "nitroglycerin_explosion"
	required_reagents = list("nitroglycerin" = 1)
	required_temp = 474
	strengthdiv = 2


/datum/chemical_reaction/reagent_explosion/potassium_explosion
	name = "Explosion"
	id = "potassium_explosion"
	required_reagents = list("water" = 1, "potassium" = 1)
	strengthdiv = 10


/datum/chemical_reaction/blackpowder
	name = "Black Powder"
	id = "blackpowder"
	results = list("blackpowder" = 3)
	required_reagents = list("saltpetre" = 1, "charcoal" = 1, "sulfur" = 1)

/datum/chemical_reaction/reagent_explosion/blackpowder_explosion
	name = "Black Powder Kaboom"
	id = "blackpowder_explosion"
	required_reagents = list("blackpowder" = 1)
	required_temp = 474
	strengthdiv = 6
	modifier = 1
	mix_message = "<span class='boldannounce'>Sparks start flying around the black powder!</span>"

/datum/chemical_reaction/reagent_explosion/blackpowder_explosion/on_reaction(datum/reagents/holder, created_volume)
	sleep(rand(50,100))
	..()

/datum/chemical_reaction/thermite
	name = "Thermite"
	id = "thermite"
	results = list("thermite" = 3)
	required_reagents = list("aluminium" = 1, "iron" = 1, "oxygen" = 1)

/datum/chemical_reaction/emp_pulse
	name = "EMP Pulse"
	id = "emp_pulse"
	required_reagents = list("uranium" = 1, "iron" = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense

/datum/chemical_reaction/emp_pulse/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	// 100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
	// 200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
	empulse(location, round(created_volume / 12), round(created_volume / 7), 1)
	holder.clear_reagents()


/datum/chemical_reaction/smoke_powder
	name = "smoke_powder"
	id = "smoke_powder"
	results = list("smoke_powder" = 3)
	required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1)

/datum/chemical_reaction/smoke_powder/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	holder.remove_reagent("smoke_powder", created_volume*3)
	var/smoke_radius = round(sqrt(created_volume * 1.5), 1)
	var/location = get_turf(holder.my_atom)
	var/datum/effect_system/smoke_spread/chem/S = new
	S.attach(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	if(S)
		S.set_up(holder, smoke_radius, location, 0)
		S.start()
	if(holder && holder.my_atom)
		holder.clear_reagents()

/datum/chemical_reaction/smoke_powder_smoke
	name = "smoke_powder_smoke"
	id = "smoke_powder_smoke"
	required_reagents = list("smoke_powder" = 1)
	required_temp = 374
	mob_react = FALSE

/datum/chemical_reaction/smoke_powder_smoke/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	var/smoke_radius = round(sqrt(created_volume / 2), 1)
	var/datum/effect_system/smoke_spread/chem/S = new
	S.attach(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	if(S)
		S.set_up(holder, smoke_radius, location, 0)
		S.start()
	if(holder && holder.my_atom)
		holder.clear_reagents()

/datum/chemical_reaction/napalm
	name = "Napalm"
	id = "napalm"
	results = list("napalm" = 3)
	required_reagents = list("oil" = 1, "welding_fuel" = 1, "ethanol" = 1 )

/datum/chemical_reaction/cryostylane
	name = "cryostylane"
	id = "cryostylane"
	results = list("cryostylane" = 3)
	required_reagents = list("water" = 1, "stable_plasma" = 1, "nitrogen" = 1)

/datum/chemical_reaction/cryostylane/on_reaction(datum/reagents/holder, created_volume)
	holder.chem_temp = 20 // cools the fuck down
	return

/datum/chemical_reaction/cryostylane_oxygen
	name = "ephemeral cryostylane reaction"
	id = "cryostylane_oxygen"
	results = list("cryostylane" = 1)
	required_reagents = list("cryostylane" = 1, "oxygen" = 1)
	mob_react = FALSE

/datum/chemical_reaction/cryostylane_oxygen/on_reaction(datum/reagents/holder, created_volume)
	holder.chem_temp = max(holder.chem_temp - 10*created_volume,0)

/datum/chemical_reaction/pyrosium_oxygen
	name = "ephemeral pyrosium reaction"
	id = "pyrosium_oxygen"
	results = list("pyrosium" = 1)
	required_reagents = list("pyrosium" = 1, "oxygen" = 1)
	mob_react = FALSE

/datum/chemical_reaction/pyrosium_oxygen/on_reaction(datum/reagents/holder, created_volume)
	holder.chem_temp += 10*created_volume

/datum/chemical_reaction/pyrosium
	name = "pyrosium"
	id = "pyrosium"
	results = list("pyrosium" = 3)
	required_reagents = list("stable_plasma" = 1, "radium" = 1, "phosphorus" = 1)

/datum/chemical_reaction/pyrosium/on_reaction(datum/reagents/holder, created_volume)
	holder.chem_temp = 20 // also cools the fuck down