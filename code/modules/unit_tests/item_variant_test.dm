/datum/unit_test/item_variant_test/Run()
	for(var/obj/item/item_type AS in subtypesof(/obj/item))
		if(!initial(item_type.current_variant) && !length(initial(item_type.icon_state_variants)))
			continue
		var/obj/item/item_to_test = allocate(item_type)
		for(var/variant in item_to_test.icon_state_variants)
			var/found = FALSE
			for(var/key in GLOB.loadout_variant_keys)
				if(GLOB.loadout_variant_keys[key] != variant)
					continue
				found = TRUE
				break
			if(found)
				continue
			Fail("[item_type] has the variant '[variant]' in its icon_state_variants, \
				but it has not been added to GLOB.loadout_variant_keys.")
