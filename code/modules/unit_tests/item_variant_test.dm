/datum/unit_test/item_variant_test/Run()
	for(var/obj/item/item_type in subtypesof(/obj/item))
		if(!initial(item_type.current_variant) && !length(initial(item_type.icon_state_variants)))
			continue
		var/obj/item/item_to_test = allocate(item_type)
		if(!(GLOB.loadout_variant_keys[item_to_test.current_variant]))
			Fail("[item_to_test] of type [item_type] has the variant '[item_to_test.current_variant]' in its icon_state_variants, \
				but it has not been added to GLOB.loadout_variant_keys.")
		for(var/key in item_to_test.icon_state_variants)
			if(GLOB.loadout_variant_keys[key])
				continue
			Fail("[item_to_test] of type [item_type] has the variant '[key]' in its icon_state_variants, \
				but it has not been added to GLOB.loadout_variant_keys.")

