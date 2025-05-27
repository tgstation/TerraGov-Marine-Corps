GLOBAL_LIST_EMPTY(active_alternate_appearances)

/atom/proc/remove_alt_appearance(key)
	if(alternate_appearances)
		for(var/K in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/AA = alternate_appearances[K]
			if(AA.appearance_key == key)
				AA.remove_from_hud(src)
				break

/atom/proc/add_alt_appearance(type, key, ...)
	if(!type || !key)
		return
	if(alternate_appearances && alternate_appearances[key])
		return
	if(!ispath(type, /datum/atom_hud/alternate_appearance))
		CRASH("Invalid type passed in: [type]")
	var/list/arguments = args.Copy(2)
	return new type(arglist(arguments))

/datum/atom_hud/alternate_appearance
	var/appearance_key
	var/transfer_overlays = FALSE

/datum/atom_hud/alternate_appearance/New(key)
	..()
	GLOB.active_alternate_appearances += src
	appearance_key = key

	for(var/mob AS in GLOB.player_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/Destroy()
	GLOB.active_alternate_appearances -= src
	return ..()

///Adds to a newly init'd mob if appropriate
/datum/atom_hud/alternate_appearance/proc/onNewMob(mob/M)
	if(mobShouldSee(M))
		add_hud_to(M)

///Logic for who should see this alt appearance
/datum/atom_hud/alternate_appearance/proc/mobShouldSee(mob/M) //this is checked early in init, so many things may not be set by the time this runs
	return FALSE

/datum/atom_hud/alternate_appearance/add_to_hud(atom/A, image/I)
	. = ..()
	if(.)
		LAZYINITLIST(A.alternate_appearances)
		A.alternate_appearances[appearance_key] = src

/datum/atom_hud/alternate_appearance/remove_from_hud(atom/A)
	. = ..()
	if(.)
		LAZYREMOVE(A.alternate_appearances, appearance_key)

/datum/atom_hud/alternate_appearance/proc/copy_overlays(atom/other, cut_old)
	return

//an alternate appearance that attaches a single image to a single atom
/datum/atom_hud/alternate_appearance/basic
	var/atom/target
	var/image/image
	var/add_ghost_version = FALSE
	var/ghost_appearance

/datum/atom_hud/alternate_appearance/basic/New(key, image/I, options = AA_TARGET_SEE_APPEARANCE)
	..()
	transfer_overlays = options & AA_MATCH_TARGET_OVERLAYS
	image = I
	target = I.loc
	LAZYADD(target.update_on_z, image)
	if(transfer_overlays)
		I.copy_overlays(target)

	hud_icons = list(appearance_key)
	add_to_hud(target, I)
	if((options & AA_TARGET_SEE_APPEARANCE) && ismob(target))
		add_hud_to(target)
	if(add_ghost_version)
		var/image/ghost_image = image(icon = I.icon , icon_state = I.icon_state, loc = I.loc)
		ghost_image.override = FALSE
		ghost_image.alpha = 128
		ghost_appearance = new /datum/atom_hud/alternate_appearance/basic/observers(key + "_observer", ghost_image, NONE)

/datum/atom_hud/alternate_appearance/basic/Destroy()
	. = ..()
	LAZYREMOVE(target.update_on_z, image)
	QDEL_NULL(image)
	target = null
	if(ghost_appearance)
		QDEL_NULL(ghost_appearance)

/datum/atom_hud/alternate_appearance/basic/add_to_hud(atom/A)
	LAZYINITLIST(A.hud_list)
	A.hud_list[appearance_key] = image
	. = ..()

/datum/atom_hud/alternate_appearance/basic/remove_from_hud(atom/A)
	. = ..()
	A.hud_list -= appearance_key

/datum/atom_hud/alternate_appearance/basic/copy_overlays(atom/other, cut_old)
	image.copy_overlays(other, cut_old)

/datum/atom_hud/alternate_appearance/basic/everyone
	add_ghost_version = TRUE

/datum/atom_hud/alternate_appearance/basic/everyone/mobShouldSee(mob/M)
	return !isdead(M)

/datum/atom_hud/alternate_appearance/basic/silicons

/datum/atom_hud/alternate_appearance/basic/silicons/mobShouldSee(mob/M)
	if(issilicon(M))
		return TRUE
	return FALSE

/datum/atom_hud/alternate_appearance/basic/observers
	add_ghost_version = FALSE //just in case, to prevent infinite loops

/datum/atom_hud/alternate_appearance/basic/observers/mobShouldSee(mob/M)
	return isobserver(M)

/datum/atom_hud/alternate_appearance/basic/one_person
	///The mob that can see this
	var/mob/seer

/datum/atom_hud/alternate_appearance/basic/one_person/mobShouldSee(mob/M)
	return M == seer

/datum/atom_hud/alternate_appearance/basic/one_person/New(key, image/I, mob/living/new_seer)
	seer = new_seer
	return ..(key, I, FALSE)

/datum/atom_hud/alternate_appearance/basic/one_person/Destroy()
	seer = null
	return ..()

/datum/atom_hud/alternate_appearance/basic/group
	///The mobs that can see this
	var/list/mob/seer_list

/datum/atom_hud/alternate_appearance/basic/group/mobShouldSee(mob/M)
	return M in seer_list

/datum/atom_hud/alternate_appearance/basic/group/New(key, image/I, list/new_seers)
	seer_list = new_seers
	return ..(key, I, FALSE)

/datum/atom_hud/alternate_appearance/basic/group/Destroy()
	seer_list = null
	return ..()

//Reverse of above
/datum/atom_hud/alternate_appearance/basic/all_but_one_person
	///The mob that CAN'T see this
	var/mob/seer

/datum/atom_hud/alternate_appearance/basic/all_but_one_person/mobShouldSee(mob/M)
	return M != seer

/datum/atom_hud/alternate_appearance/basic/all_but_one_person/New(key, image/I, mob/living/new_seer)
	seer = new_seer
	return ..(key, I, FALSE)

/datum/atom_hud/alternate_appearance/basic/all_but_one_person/Destroy()
	seer = null
	return ..()

/datum/atom_hud/alternate_appearance/basic/faction
	add_ghost_version = TRUE
	///The faction that will see this
	var/visible_faction

/datum/atom_hud/alternate_appearance/basic/faction/New(key, image/I, new_faction)
	visible_faction = new_faction
	return ..(key, I, FALSE)

/datum/atom_hud/alternate_appearance/basic/faction/mobShouldSee(mob/M)
	return M.faction == visible_faction

/datum/atom_hud/alternate_appearance/basic/not_faction
	add_ghost_version = TRUE
	///The faction that will NOT see this
	var/excluded_faction

/datum/atom_hud/alternate_appearance/basic/not_faction/New(key, image/I, new_faction)
	excluded_faction = new_faction
	return ..(key, I, FALSE)

/datum/atom_hud/alternate_appearance/basic/not_faction/mobShouldSee(mob/M)
	return M.faction != excluded_faction

/datum/atom_hud/alternate_appearance/basic/multi_faction
	add_ghost_version = TRUE
	///The faction that will see this
	var/list/visible_factions

/datum/atom_hud/alternate_appearance/basic/multi_faction/New(key, image/I, list/new_factions)
	visible_factions = new_factions
	return ..(key, I, FALSE)

/datum/atom_hud/alternate_appearance/basic/multi_faction/mobShouldSee(mob/M)
	for(var/option in visible_factions)
		if(M.faction != option)
			continue
		return TRUE
