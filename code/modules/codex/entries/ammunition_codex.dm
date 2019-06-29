/datum/codex_category/ammo/New()

	for(var/thing in subtypesof(/datum/ammo))
		var/datum/ammo/ammo = thing
		if(initial(ammo.hidden_from_codex))
			continue		
		ammo = new thing()
		var/ammo_name = lowertext(initial(ammo.name))
		var/datum/codex_entry/entry = new( \
		_display_name = "[ammo_name] (ammunition)", \
		_associated_strings = list("[ammo_name]"))
		
		entry.mechanics_text += "<U>Basic statistics for this ammo is as follows</U>:<br>"
		if(ammo.damage)
			entry.mechanics_text += "Damage: [ammo.damage]<br>"
	
		if(ammo.damage_falloff)
			entry.mechanics_text += "Damage falloff: [ammo.damage_falloff] per tile<br>"
	
		if(ammo.damage_type)
			entry.mechanics_text += "Damage type: [ammo.damage_type]<br>"
	
		if(ammo.flags_ammo_behavior & AMMO_INCENDIARY)
			entry.mechanics_text += "Secondary effect: set target on fire.<br>"
	
		if(ammo.flags_ammo_behavior & AMMO_SKIPS_HUMANS)
			entry.mechanics_text += "Secondary effect: ignores friendlies.<br>"
	
		if(ammo.flags_ammo_behavior & AMMO_EXPLOSIVE)
			entry.mechanics_text += "Secondary effect: explosion.<br>"
	
		if(ammo.penetration)
			entry.mechanics_text += "Armor penetration: [ammo.penetration]<br>"
	
		if(ammo.armor_type)
			entry.mechanics_text += "Armor type: [ammo.armor_type]<br>"
	
		if(ammo.accuracy)
			entry.mechanics_text += "Accuracy: [ammo.accuracy > 0 ? "+[ammo.accuracy]" : "[ammo.accuracy]"]%<br>"
	
		if(ammo.accurate_range_min)
			entry.mechanics_text += "Effective range: [ammo.accurate_range_min] to [ammo.accurate_range]<br>"
		else if(ammo.accurate_range)
			entry.mechanics_text += "Effective range: [ammo.accurate_range]<br>"
	
		if(ammo.max_range)
			entry.mechanics_text += "Maximum range: [ammo.max_range]<br>"
	
		if(ammo.scatter)
			entry.mechanics_text += "Burst mode scatter chance: [ammo.scatter > 0 ? "+[ammo.scatter]" : "[ammo.scatter]"]%<br>"

		SScodex.entries_by_string[entry.display_name] = entry
