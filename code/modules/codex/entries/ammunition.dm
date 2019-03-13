/datum/codex_category/ammo/New()

	for(var/thing in subtypesof(/datum/ammo))
		var/datum/ammo/ammo = new thing()
		if(initial(ammo.hidden_from_codex))
			continue
		var/ammo_name = lowertext(initial(ammo.name))
		var/datum/codex_entry/entry = new( \
		 _display_name = "[ammo_name] (ammunition)", \
		 _associated_strings = list("[ammo_name]"))
		
		entry.mechanics_text += "<U>Basic statistics for this ammo is as follows</U>:<br>"
		entry.mechanics_text += "Damage: [ammo.damage]<br>"
		entry.mechanics_text += "Damage falloff: [ammo.damage_falloff] per tile<br>"
		entry.mechanics_text += "Damage type: [ammo.damage_type]<br>"
		entry.mechanics_text += "Armor penetration: [ammo.penetration]<br>"
		entry.mechanics_text += "Armor type: [ammo.armor_type]<br>"
		entry.mechanics_text += "Accuracy: [ammo.accuracy > 0 ? "+[ammo.accuracy]" : "[ammo.accuracy]"]%<br>"
		entry.mechanics_text += "Effective range: [ammo.accurate_range]<br>"
		entry.mechanics_text += "Maximum range: [ammo.max_range]<br>"
		entry.mechanics_text += "Burst mode scatter chance: [ammo.scatter > 0 ? "+[ammo.scatter]" : "[ammo.scatter]"]%<br>"

		SScodex.entries_by_string[entry.display_name] = entry
