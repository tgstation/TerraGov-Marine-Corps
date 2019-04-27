

/datum/chemical_reaction/explosion_potassium
	name = "Explosion"
	id = "explosion_potassium"
	required_reagents = list("water" = 1, "potassium" = 1)
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
	id = "emp_pulse"
	required_reagents = list("uranium" = 1, "iron" = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense

	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		// 100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
		// 200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
		empulse(location, round(created_volume / 24), round(created_volume / 14), 1)
		holder.clear_reagents()

/datum/chemical_reaction/pttoxin
	name = "Toxin"
	id = "pttoxin"
	results = list("pttoxin" = 2)
	required_reagents = list("paracetamol" = 1, "tramadol" = 1)

/datum/chemical_reaction/sdtoxin
	name = "Toxin"
	id = "sdtoxin2"
	results = list("sdtoxin" = 2)
	required_reagents = list("synaptizine" = 1, "dylovene" = 1)

/datum/chemical_reaction/sleeptoxin
	name = "Soporific"
	id = "sleeptoxin"
	results = list("sleeptoxin" = 5)
	required_reagents = list("chloralhydrate" = 1, "sugar" = 4)

/datum/chemical_reaction/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	results = list("mutagen" = 3)
	required_reagents = list("radium" = 1, "phosphorus" = 1, "chlorine" = 1)

/datum/chemical_reaction/water //I can't believe we never had this.
	name = "Water"
	id = "water"
	results = list("water" = 1)
	required_reagents = list("oxygen" = 1, "hydrogen" = 2)

/datum/chemical_reaction/thermite
	name = "Thermite"
	id = "thermite"
	results = list("thermite" = 3)
	required_reagents = list("aluminum" = 10, "iron" = 10, "oxygen" = 10, "phoron" = 1)

/datum/chemical_reaction/lexorin
	name = "Lexorin"
	id = "lexorin"
	results = list("lexorin" = 3)
	required_reagents = list("phoron" = 1, "hydrogen" = 1, "nitrogen" = 1)

/datum/chemical_reaction/space_drugs
	name = "Space Drugs"
	id = "space_drugs"
	results = list("space_drugs" = 3)
	required_reagents = list("mercury" = 1, "sugar" = 1, "lithium" = 1)

/datum/chemical_reaction/lube
	name = "Space Lube"
	id = "lube"
	results = list("lube" = 4)
	required_reagents = list("water" = 1, "silicon" = 1, "oxygen" = 1)

/datum/chemical_reaction/pacid
	name = "Polytrinic acid"
	id = "pacid"
	results = list("pacid" = 3)
	required_reagents = list("sacid" = 1, "chlorine" = 1, "potassium" = 1)

/datum/chemical_reaction/impedrezene
	name = "Impedrezene"
	id = "impedrezene"
	results = list("impedrezene" = 2)
	required_reagents = list("mercury" = 1, "oxygen" = 1, "sugar" = 1)

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = "virusfood"
	results = list("virusfood" = 5)
	required_reagents = list("water" = 1, "milk" = 1)

/datum/chemical_reaction/cryptobiolin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	results = list("cryptobiolin" = 3)
	required_reagents = list("potassium" = 1, "oxygen" = 1, "sugar" = 1)

/datum/chemical_reaction/glycerol
	name = "Glycerol"
	id = "glycerol"
	results = list("glycerol" = 1)
	required_reagents = list("cornoil" = 3, "sacid" = 1)

/datum/chemical_reaction/nitroglycerin
	name = "Nitroglycerin"
	id = "nitroglycerin"
	results = list("nitroglycerin" = 2)
	required_reagents = list("glycerol" = 1, "pacid" = 1, "sacid" = 1)

/datum/chemical_reaction/nitroglycerin/on_reaction(var/datum/reagents/holder, var/created_volume)
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
	id = "flash_powder"
	required_reagents = list("aluminum" = 1, "potassium" = 1, "sulfur" = 1 )

/datum/chemical_reaction/flash_powder/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(2, 1, location)
	s.start()
	for(var/mob/living/carbon/M in viewers(world.view, location))
		switch(get_dist(M, location))
			if(0 to 3)
				if(M.flash_eyes())
					M.KnockDown(15)

			if(4 to 5)
				if(M.flash_eyes())
					M.Stun(5)


/datum/chemical_reaction/napalm
	name = "Napalm"
	id = "napalm"
	required_reagents = list("aluminum" = 1, "phoron" = 1, "sacid" = 1 )

/datum/chemical_reaction/napalm/on_reaction(var/datum/reagents/holder, var/created_volume, var/radius)
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
	id = "chemsmoke"
	required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1)

/datum/chemical_reaction/chemsmoke/on_reaction(var/datum/reagents/holder, var/created_volume)
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
	id = "chloralhydrate"
	results = list("chloralhydrate" = 1)
	required_reagents = list("ethanol" = 1, "chlorine" = 3, "water" = 1)

/datum/chemical_reaction/potassium_chloride
	name = "Potassium Chloride"
	id = "potassium_chloride"
	results = list("potassium_chloride" = 2)
	required_reagents = list("sodiumchloride" = 1, "potassium" = 1)

/datum/chemical_reaction/potassium_chlorophoride
	name = "Potassium Chlorophoride"
	id = "potassium_chlorophoride"
	results = list("potassium_chlorophoride" = 4)
	required_reagents = list("potassium_chloride" = 1, "phoron" = 1, "chloralhydrate" = 1)

/datum/chemical_reaction/zombiepowder
	name = "Zombie Powder"
	id = "zombiepowder"
	results = list("zombiepowder" = 2)
	required_reagents = list("carpotoxin" = 5, "sleeptoxin" = 5, "copper" = 5)

/datum/chemical_reaction/rezadone
	name = "Rezadone"
	id = "rezadone"
	results = list("rezadone" = 3)
	required_reagents = list("carpotoxin" = 1, "cryptobiolin" = 1, "copper" = 1)

/datum/chemical_reaction/mindbreaker
	name = "Mindbreaker Toxin"
	id = "mindbreaker"
	results = list("mindbreaker" = 3)
	required_reagents = list("silicon" = 1, "hydrogen" = 1, "dylovene" = 1)

/datum/chemical_reaction/lipozine
	name = "Lipozine"
	id = "Lipozine"
	results = list("lipozine" = 3)
	required_reagents = list("sodiumchloride" = 1, "ethanol" = 1, "radium" = 1)

/datum/chemical_reaction/phoronsolidification
	name = "Solid Phoron"
	id = "solidphoron"
	required_reagents = list("iron" = 5, "frostoil" = 5, "phoron" = 20)

/datum/chemical_reaction/phoronsolidification/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/mineral/phoron(location)
	return

/datum/chemical_reaction/plastication
	name = "Plastic"
	id = "solidplastic"
	required_reagents = list("pacid" = 10, "plasticide" = 20)

/datum/chemical_reaction/plastication/on_reaction(var/datum/reagents/holder)
	new /obj/item/stack/sheet/mineral/plastic(get_turf(holder.my_atom),10)
	return

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = "virusfood"
	results = list("virusfood" = 15)
	required_reagents = list("water" = 5, "milk" = 5, "oxygen" = 5)


///////////////////////////////////////////////////////////////////////////////////

// foam and foam precursor

/datum/chemical_reaction/surfactant
	name = "Foam surfactant"
	id = "foam surfactant"
	results = list("fluorosurfactant" = 5)
	required_reagents = list("fluorine" = 2, "carbon" = 2, "sacid" = 1)


/datum/chemical_reaction/foam
	name = "Foam"
	id = "foam"
	required_reagents = list("fluorosurfactant" = 1, "water" = 1)
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
	id = "metalfoam"
	required_reagents = list("aluminum" = 3, "foaming_agent" = 1, "pacid" = 1)
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
	id = "ironlfoam"
	required_reagents = list("iron" = 3, "foaming_agent" = 1, "pacid" = 1)
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
	id = "foaming_agent"
	results = list("foaming_agent" = 1)
	required_reagents = list("lithium" = 1, "hydrogen" = 1)

/datum/chemical_reaction/ammonia
	name = "Ammonia"
	id = "ammonia"
	results = list("ammonia" = 3)
	required_reagents = list("hydrogen" = 3, "nitrogen" = 1)

/datum/chemical_reaction/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	results = list("diethylamine" = 2)
	required_reagents = list("ammonia" = 1, "ethanol" = 1)

/datum/chemical_reaction/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	results = list("cleaner" = 2)
	required_reagents = list("ammonia" = 1, "water" = 1)

/datum/chemical_reaction/plantbgone
	name = "Plant-B-Gone"
	id = "plantbgone"
	results = list("plantbgone" = 5)
	required_reagents = list("toxin" = 1, "water" = 4)
