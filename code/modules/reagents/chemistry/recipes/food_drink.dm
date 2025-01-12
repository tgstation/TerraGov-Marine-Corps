//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/tofurecipe
	results = null
	required_reagents = list(/datum/reagent/consumable/soymilk = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/tofu/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.get_holder())
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/tofu(location)


/datum/chemical_reaction/chocolate_barrecipe
	results = null
	required_reagents = list(/datum/reagent/consumable/soymilk = 2, /datum/reagent/consumable/coco = 2, /datum/reagent/consumable/sugar = 2)

/datum/chemical_reaction/chocolate_bar/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.get_holder())
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)


/datum/chemical_reaction/chocolate_bar2recipe
	results = null
	required_reagents = list(/datum/reagent/consumable/milk = 2, /datum/reagent/consumable/coco = 2, /datum/reagent/consumable/sugar = 2)

/datum/chemical_reaction/chocolate_bar2/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.get_holder())
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)

/datum/chemical_reaction/soysaucerecipe
	results = list(/datum/reagent/consumable/soysauce = 5)
	required_reagents = list(/datum/reagent/consumable/soymilk = 4, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/condensedcapsaicinrecipe
	results = list(/datum/reagent/consumable/capsaicin/condensed = 1)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 2)
	required_catalysts = list(/datum/reagent/toxin/phoron = 5)

/datum/chemical_reaction/sodiumchloriderecipe
	results = list(/datum/reagent/consumable/sodiumchloride = 2)
	required_reagents = list(/datum/reagent/sodium = 1, /datum/reagent/chlorine = 1)

/datum/chemical_reaction/cheesewheelrecipe
	results = null
	required_reagents = list(/datum/reagent/consumable/milk = 40)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/cheesewheel/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.get_holder())
	new /obj/item/reagent_containers/food/snacks/sliceable/cheesewheel(location)


/datum/chemical_reaction/syntifleshrecipe
	results = null
	required_reagents = list(/datum/reagent/blood = 5, /datum/reagent/medicine/clonexadone = 1)

/datum/chemical_reaction/syntiflesh/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.get_holder())
	new /obj/item/reagent_containers/food/snacks/meat/syntiflesh(location)


/datum/chemical_reaction/hot_ramenrecipe
	results = list(/datum/reagent/consumable/hot_ramen = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/dry_ramen = 3)

/datum/chemical_reaction/hell_ramenrecipe
	results = list(/datum/reagent/consumable/hell_ramen = 6)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/hot_ramen = 6)

//Following drinks don't have TG equivalents

/datum/chemical_reaction/grenadinerecipe
	results = list(/datum/reagent/consumable/grenadine = 10)
	required_reagents = list(/datum/reagent/consumable/berryjuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/winerecipe
	results = list(/datum/reagent/consumable/ethanol/wine = 10)
	required_reagents = list(/datum/reagent/consumable/grapejuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/pwinerecipe
	results = list(/datum/reagent/consumable/ethanol/pwine = 10)
	required_reagents = list(/datum/reagent/consumable/poisonberryjuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/melonliquorrecipe
	results = list(/datum/reagent/consumable/ethanol/melonliquor = 10)
	required_reagents = list(/datum/reagent/consumable/watermelonjuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/bluecuracaorecipe
	results = list(/datum/reagent/consumable/ethanol/bluecuracao = 10)
	required_reagents = list(/datum/reagent/consumable/orangejuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/spacebeerrecipe
	results = list(/datum/reagent/consumable/ethanol/beer = 10)
	required_reagents = list(/datum/reagent/consumable/cornoil = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/phoron_specialrecipe
	results = list(/datum/reagent/consumable/ethanol/toxins_special = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/ethanol/vermouth = 1, /datum/reagent/toxin/phoron = 2)
