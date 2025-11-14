///List of all vars that will not be copied over when using duplicate_object()
GLOBAL_LIST_INIT(duplicate_forbidden_vars, list(
	"AIStatus",
	"actions",
	"actions_by_path",
	"appearance",
	"area",
	"ckey",
	"client_mobs_in_contents",
	"closer",
	"_listen_lookup",
	"computer_id",
	"contents",
	"cooldowns",
	"_datum_components",
	"group",
	"hud_list",
	"implants",
	"important_recursive_contents",
	"ip_adress",
	"key",
	"lastKnownIP",
	"loc",
	"locs",
	"limbs",
	"managed_overlays",
	"managed_vis_overlays",
	"overlays",
	"overlays_standing",
	"opened",
	"parent",
	"parent_type",
	"reagents",
	"_signal_procs",
	"stat",
	"status_effects",
	"_status_traits",
	"boxes",
	"storage_continue",
	"storage_end",
	"storage_start",
	"stored_continue",
	"stored_end",
	"stored_start",
	"tag",
	"tgui_shared_states",
	"type",
	"update_on_z",
	"vars",
	"verbs",
	"x", "y", "z",
))
GLOBAL_PROTECT(duplicate_forbidden_vars)

/**
 * # duplicate_object
 *
 * Makes a copy of an item and transfers most vars over, barring GLOB.duplicate_forbidden_vars
 * Args:
 * original - Atom being duplicated
 * spawning_location - Turf where the duplicated atom will be spawned at.
 */
/proc/duplicate_object(atom/original, turf/spawning_location)
	RETURN_TYPE(original.type)
	if(!original)
		return

	var/atom/made_copy = new original.type(spawning_location)

	for(var/atom_vars in original.vars - GLOB.duplicate_forbidden_vars)
		if(islist(original.vars[atom_vars]))
			var/list/var_list = original.vars[atom_vars]
			made_copy.vars[atom_vars] = var_list.Copy()
			continue
		else if(istype(original.vars[atom_vars], /datum) || ismob(original.vars[atom_vars]))
			continue // this would reference the original's object, that will break when it is used or deleted.
		made_copy.vars[atom_vars] = original.vars[atom_vars]

	if(isliving(made_copy))
		if(iscarbon(made_copy))
			var/mob/living/carbon/made_carbon = made_copy
			made_carbon.regenerate_icons()
			if(ishuman(made_copy))
				var/mob/living/carbon/human/made_human = made_copy
				made_human.update_hair()
				made_human.update_body()

		var/mob/living/original_living = original
		//transfer implants, we do this so the original's implants being removed won't destroy ours.
		for(var/obj/item/implant/original_implants in original_living.embedded_objects)
			var/obj/item/implant/copied_implant = new original_implants.type
			copied_implant.implant(made_copy, original)

	return made_copy
