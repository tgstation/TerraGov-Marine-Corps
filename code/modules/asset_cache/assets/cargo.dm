/datum/asset/json/supply_packs
	name = "supply_packs"
	cross_round_cachable = TRUE

/datum/asset/json/supply_packs/generate()
	var/list/data = list()
	var/list/all_supplies = list()
	for(var/pack in subtypesof(/datum/supply_packs))
		var/datum/supply_packs/P = pack
		if(!initial(P.cost))
			continue
		P = new pack()
		if(!P.contains)
			continue
		all_supplies += P
	for(var/datum/supply_packs/pack AS in all_supplies)
		var/list/pack_data = list()
		pack_data["name"] = pack.name
		pack_data["notes"] = pack.notes
		pack_data["cost"] = pack.cost
		pack_data["group"] = pack.group
		pack_data["container_name"] = initial(pack.containertype.name)
		pack_data["available_against_xeno_only"] = pack.available_against_xeno_only
		var/list/contained = list()
		for(var/atom/atomtypepath AS in pack.contains)
			var/name = atomtypepath::name
			if(contained[name])
				contained[name]["amount"]++
			else
				contained[name] = list("amount" = 1)
		pack_data["contains"] = contained
		data[pack.type] = pack_data
	return data
