

/datum/chemical_reaction/explosion_potassium
	name = "Explosion"
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/potassium = 1)
	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/atom/location = holder.my_atom.loc
		if(holder.my_atom && location) //It exists outside of null space.
			var/datum/effect_system/reagents_explosion/e = new()
			e.set_up(round (created_volume/10, 1), holder.my_atom, 0, 0)
			e.holder_damage(holder.my_atom)
			if(isliving(holder.my_atom))
				e.amount *= 0.5
				var/mob/living/L = holder.my_atom
				if(L.stat!=DEAD)
					e.amount *= 0.5
			if(e.start()) //Gets rid of doubling down on explosives for gameplay purposes. Hacky, but enough for now.
			//Should be removed when we actually balance out chemistry.
				var/obj/item/explosive/grenade/g
				var/obj/item/storage/s
				for(g in location) qdel(g) //Grab anything on our turf/something.
				if(istype(location, /obj/item/storage) || ismob(location)) //If we're in a bag or person.
					for(s in location) //Find all other containers.
						for(g in s) qdel(g) //Delete all the grenades.
				if(istype(location.loc, /obj/item/storage) || ismob(location.loc)) //If the container is in another container.
					for(g in location.loc) qdel(g) //Delete all the grenades inside.
					for(s in location.loc) //Search for more containers.
						if(s == location) continue //Don't search the container we're in.
						for(g in s) qdel(g) //Delete all the grenades inside.
		holder.clear_reagents()
		return

/datum/chemical_reaction/emp_pulse
	name = "EMP Pulse"
	required_reagents = list(/datum/reagent/uranium = 1, /datum/reagent/iron = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense

	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		// 100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
		// 200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
		empulse(location, round(created_volume / 24), round(created_volume / 14), 1)
		holder.clear_reagents()

/datum/chemical_reaction/water_two
	name = "Water"
	results = list(/datum/reagent/water = 2)
	required_reagents = list(/datum/reagent/medicine/paracetamol = 1, /datum/reagent/medicine/tramadol = 1)

/datum/chemical_reaction/toxin_two //Space Atropine!
	name = "Toxin"
	results = list(/datum/reagent/toxin = 3)
	required_reagents = list(/datum/reagent/medicine/synaptizine = 1, /datum/reagent/toxin/xeno_neurotoxin = 10)

/datum/chemical_reaction/sdtoxin
	name = "Toxin"
	results = list(/datum/reagent/toxin/sdtoxin = 2)
	required_reagents = list(/datum/reagent/medicine/synaptizine = 1, /datum/reagent/medicine/dylovene = 1)

/datum/chemical_reaction/sleeptoxin
	name = "Soporific"
	results = list(/datum/reagent/toxin/sleeptoxin = 5)
	required_reagents = list(/datum/reagent/toxin/chloralhydrate = 1, /datum/reagent/consumable/sugar = 4)

/datum/chemical_reaction/mutagen
	name = "Unstable mutagen"
	results = list(/datum/reagent/toxin/mutagen = 3)
	required_reagents = list(/datum/reagent/radium = 1, /datum/reagent/phosphorus = 1, /datum/reagent/chlorine = 1)

/datum/chemical_reaction/water //I can't believe we never had this.
	name = "Water"
	results = list(/datum/reagent/water = 1)
	required_reagents = list(/datum/reagent/oxygen = 1, /datum/reagent/hydrogen = 2)

/datum/chemical_reaction/thermite
	name = "Thermite"
	results = list(/datum/reagent/thermite = 3)
	required_reagents = list(/datum/reagent/aluminum = 10, /datum/reagent/iron = 10, /datum/reagent/oxygen = 10

/datum/chemical_reaction/lexorin
	name = "Lexorin"
	results = list(/datum/reagent/toxin/lexorin = 3)
	required_reagents = list(/datum/reagent/toxin/phoron = 1, /datum/reagent/hydrogen = 1, /datum/reagent/nitrogen = 1)

/datum/chemical_reaction/space_drugs
	name = "Space Drugs"
	results = list(/datum/reagent/space_drugs = 3)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/lithium = 1)

/datum/chemical_reaction/lube
	name = "Space Lube"
	results = list(/datum/reagent/lube = 4)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/silicon = 1, /datum/reagent/oxygen = 1)

/datum/chemical_reaction/pacid
	name = "Polytrinic acid"
	results = list(/datum/reagent/toxin/acid/polyacid = 3)
	required_reagents = list(/datum/reagent/toxin/acid = 1, /datum/reagent/chlorine = 1, /datum/reagent/potassium = 1)

/datum/chemical_reaction/impedrezene
	name = "Impedrezene"
	results = list(/datum/reagent/impedrezene = 2)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/oxygen = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	results = list(/datum/reagent/consumable/virus_food = 5)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/drink/milk = 1)

/datum/chemical_reaction/cryptobiolin
	name = "Cryptobiolin"
	results = list(/datum/reagent/cryptobiolin = 3)
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/oxygen = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/glycerol
	name = "Glycerol"
	results = list(/datum/reagent/glycerol = 1)
	required_reagents = list(/datum/reagent/consumable/cornoil = 3, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/nitroglycerin
	name = "Nitroglycerin"
	results = list(/datum/reagent/nitroglycerin = 2)
	required_reagents = list(/datum/reagent/glycerol = 1, /datum/reagent/toxin/acid/polyacid = 1, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/nitroglycerin/on_reaction(datum/reagents/holder, created_volume)
	var/datum/effect_system/reagents_explosion/e = new()
	e.set_up(round (created_volume/2, 1), holder.my_atom, 0, 0)
	e.holder_damage(holder.my_atom)
	if(isliving(holder.my_atom))
		e.amount *= 0.5
		var/mob/living/L = holder.my_atom
		if(L.stat!=DEAD)
			e.amount *= 0.5
	e.start()

	holder.clear_reagents()


/datum/chemical_reaction/flash_powder
	name = "Flash powder"
	required_reagents = list(/datum/reagent/aluminum = 1, /datum/reagent/potassium = 1, /datum/reagent/sulfur = 1 )

/datum/chemical_reaction/flash_powder/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(2, 1, location)
	s.start()
	for(var/mob/living/carbon/M in viewers(WORLD_VIEW, location))
		switch(get_dist(M, location))
			if(0 to 3)
				if(M.flash_eyes())
					M.Knockdown(30 SECONDS)

			if(4 to 5)
				if(M.flash_eyes())
					M.Stun(10 SECONDS)


/datum/chemical_reaction/napalm
	name = "Napalm"
	required_reagents = list(/datum/reagent/aluminum = 1, /datum/reagent/toxin/phoron = 1, /datum/reagent/toxin/acid = 1 )

/datum/chemical_reaction/napalm/on_reaction(datum/reagents/holder, created_volume, radius)
	var/location = get_turf(holder.my_atom)
	radius = round(created_volume/45)
	if(radius < 0) radius = 0
	if(radius > 3) radius = 3

	for(var/turf/T in range(radius,location))
		if(T.density)
			continue
		if(istype(T,/turf/open/space))
			continue
		T.ignite(5 + rand(0,11))


/datum/chemical_reaction/chemsmoke
	name = "Chemsmoke"
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/phosphorus = 1)

/datum/chemical_reaction/chemsmoke/on_reaction(datum/reagents/holder, created_volume)
	var/smoke_radius = round(sqrt(created_volume * 1.5), 1)
	var/location = get_turf(holder.my_atom)
	var/datum/effect_system/smoke_spread/chem/S = new(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	S?.set_up(holder, smoke_radius, location)
	S?.start()
	if(holder?.my_atom)
		holder.clear_reagents()


/datum/chemical_reaction/chloralhydrate
	name = "Chloral Hydrate"
	results = list(/datum/reagent/toxin/chloralhydrate = 1)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/chlorine = 3, /datum/reagent/water = 1)

/datum/chemical_reaction/potassium_chloride
	name = "Potassium Chloride"
	results = list(/datum/reagent/toxin/potassium_chloride = 2)
	required_reagents = list(/datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/potassium = 1)

/datum/chemical_reaction/potassium_chlorophoride
	name = "Potassium Chlorophoride"
	results = list(/datum/reagent/toxin/potassium_chlorophoride = 4)
	required_reagents = list(/datum/reagent/toxin/potassium_chloride = 1, /datum/reagent/toxin/phoron = 1, /datum/reagent/toxin/chloralhydrate = 1)

/datum/chemical_reaction/zombiepowder
	name = "Zombie Powder"
	results = list(/datum/reagent/toxin/zombiepowder = 2)
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 5, /datum/reagent/toxin/sleeptoxin = 5, /datum/reagent/copper = 5)

/datum/chemical_reaction/rezadone
	name = "Rezadone"
	results = list(/datum/reagent/medicine/rezadone = 3)
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 1, /datum/reagent/cryptobiolin = 1, /datum/reagent/copper = 1)

/datum/chemical_reaction/mindbreaker
	name = "Mindbreaker Toxin"
	results = list(/datum/reagent/toxin/mindbreaker = 3)
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/hydrogen = 1, /datum/reagent/medicine/dylovene = 1)

/datum/chemical_reaction/lipozine
	name = "Lipozine"
	results = list(/datum/reagent/lipozine = 3)
	required_reagents = list(/datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/ethanol = 1, /datum/reagent/radium = 1)

/datum/chemical_reaction/phoronsolidification
	name = "Solid Phoron"
	required_reagents = list(/datum/reagent/iron = 5, /datum/reagent/consumable/frostoil = 5, /datum/reagent/toxin/phoron = 20)

/datum/chemical_reaction/phoronsolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/mineral/phoron(location)
	return

/datum/chemical_reaction/plastication
	name = "Plastic"
	required_reagents = list(/datum/reagent/toxin/acid/polyacid = 10, /datum/reagent/toxin/plasticide = 20)

/datum/chemical_reaction/plastication/on_reaction(datum/reagents/holder)
	new /obj/item/stack/sheet/mineral/plastic(get_turf(holder.my_atom),10)
	return

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	results = list(/datum/reagent/consumable/virus_food = 15)
	required_reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/drink/milk = 5, /datum/reagent/oxygen = 5)


///////////////////////////////////////////////////////////////////////////////////

// foam and foam precursor

/datum/chemical_reaction/surfactant
	name = "Foam surfactant"
	results = list(/datum/reagent/fluorosurfactant = 5)
	required_reagents = list(/datum/reagent/fluorine = 2, /datum/reagent/carbon = 2, /datum/reagent/toxin/acid = 1)


/datum/chemical_reaction/foam
	name = "Foam"
	required_reagents = list(/datum/reagent/fluorosurfactant = 1, /datum/reagent/water = 1)
	mob_react = FALSE

/datum/chemical_reaction/foam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='warning'>The solution spews out foam!</span>")
	var/datum/effect_system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 0)
	s.start()
	holder.clear_reagents()
	return


/datum/chemical_reaction/metalfoam
	name = "Metal Foam"
	required_reagents = list(/datum/reagent/aluminum = 3, /datum/reagent/foaming_agent = 1, /datum/reagent/toxin/acid/polyacid = 1)
	mob_react = FALSE

/datum/chemical_reaction/metalfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='warning'>The solution spews out a metalic foam!</span>")

	var/datum/effect_system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 1)
	s.start()
	holder.clear_reagents()


/datum/chemical_reaction/ironfoam
	name = "Iron Foam"
	required_reagents = list(/datum/reagent/iron = 3, /datum/reagent/foaming_agent = 1, /datum/reagent/toxin/acid = 1)
	mob_react = FALSE

/datum/chemical_reaction/ironfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='warning'>The solution spews out a metallic foam!</span>")

	var/datum/effect_system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 2)
	s.start()
	holder.clear_reagents()

/datum/chemical_reaction/foaming_agent
	name = "Foaming Agent"
	results = list(/datum/reagent/foaming_agent = 1)
	required_reagents = list(/datum/reagent/lithium = 1, /datum/reagent/hydrogen = 1)

/datum/chemical_reaction/ammonia
	name = "Ammonia"
	results = list(/datum/reagent/ammonia = 3)
	required_reagents = list(/datum/reagent/hydrogen = 3, /datum/reagent/nitrogen = 1)

/datum/chemical_reaction/diethylamine
	name = "Diethylamine"
	results = list(/datum/reagent/diethylamine = 2)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/consumable/ethanol = 1)

/datum/chemical_reaction/space_cleaner
	name = "Space cleaner"
	results = list(/datum/reagent/space_cleaner = 2)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/plantbgone
	name = "Plant-B-Gone"
	results = list(/datum/reagent/toxin/plantbgone = 5)
	required_reagents = list(/datum/reagent/toxin = 1, /datum/reagent/water = 4)

/datum/chemical_reaction/laughter
	name = "laughter"
	results = list(/datum/reagent/consumable/laughter = 5)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/drink/banana = 1)
