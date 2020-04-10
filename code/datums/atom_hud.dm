/* HUD DATUMS */
GLOBAL_LIST_EMPTY(all_huds)


//GLOBAL HUD LIST
GLOBAL_LIST_INIT(huds, list(
	DATA_HUD_BASIC = new /datum/atom_hud/simple,
	DATA_HUD_SECURITY_ADVANCED = new /datum/atom_hud/security,
	DATA_HUD_MEDICAL_BASIC = new /datum/atom_hud/medical/basic,
	DATA_HUD_MEDICAL_ADVANCED = new /datum/atom_hud/medical/advanced,
	DATA_HUD_MEDICAL_ADVANCED_SYNTH = new /datum/atom_hud/medical/advanced/synthetic,
	DATA_HUD_MEDICAL_OBSERVER = new /datum/atom_hud/medical/observer,
	DATA_HUD_XENO_INFECTION = new /datum/atom_hud/xeno_infection,
	DATA_HUD_XENO_STATUS = new /datum/atom_hud/xeno,
	DATA_HUD_SQUAD = new /datum/atom_hud/squad,
	DATA_HUD_ORDER = new /datum/atom_hud/order,
	DATA_HUD_AI_DETECT = new /datum/atom_hud/ai_detector,
	DATA_HUD_MEDICAL_PAIN = new /datum/atom_hud/medical/pain
	))


/datum/atom_hud
	var/list/atom/hudatoms = list() //list of all atoms which display this hud
	var/list/mob/hudusers = list() //list with all mobs who can see the hud
	var/list/hud_icons = list() //these will be the indexes for the atom's hud_list

	var/list/next_time_allowed = list() //mobs associated with the next time this hud can be added to them
	var/list/queued_to_see = list() //mobs that have triggered the cooldown and are queued to see the hud, but do not yet


/datum/atom_hud/New()
	GLOB.all_huds += src


/datum/atom_hud/Destroy()
	for(var/v in hudusers)
		remove_hud_from(v)
	for(var/v in hudatoms)
		remove_from_hud(v)
	next_time_allowed.Cut()
	GLOB.all_huds -= src
	return ..()


/datum/atom_hud/proc/remove_hud_from(mob/M)
	if(!M || !hudusers[M])
		return
	hudusers -= M
	if(queued_to_see[M])
		queued_to_see -= M
		return
	for(var/h in hudatoms)
		var/atom/A = h
		remove_from_single_hud(M, A)


/datum/atom_hud/proc/remove_from_hud(atom/A)
	if(!A)
		return FALSE
	for(var/u in hudusers)
		var/mob/M = u
		remove_from_single_hud(M, A)
	hudatoms -= A
	return TRUE


/datum/atom_hud/proc/remove_from_single_hud(mob/M, atom/A) //unsafe, no sanity apart from client
	if(!M || !M.client || !A)
		return
	for(var/i in hud_icons)
		M.client.images -= A.hud_list[i]


/datum/atom_hud/proc/add_hud_to(mob/M)
	if(!M || hudusers[M])
		return
	hudusers[M] = TRUE
	if(next_time_allowed[M] > world.time)
		if(!queued_to_see[M])
			addtimer(CALLBACK(src, .proc/show_hud_images_after_cooldown, M), next_time_allowed[M] - world.time)
			queued_to_see[M] = TRUE
	else
		if(!next_time_allowed[M])
			RegisterSignal(M, COMSIG_PARENT_QDELETING, .proc/clean_mob_refs)
		next_time_allowed[M] = world.time + ADD_HUD_TO_COOLDOWN
		for(var/atom/A in hudatoms)
			add_to_single_hud(M, A)


/datum/atom_hud/proc/show_hud_images_after_cooldown(M)
	if(queued_to_see[M])
		queued_to_see -= M
		next_time_allowed[M] = world.time + ADD_HUD_TO_COOLDOWN
		for(var/h in hudatoms)
			var/atom/hud_atom = h
			add_to_single_hud(M, hud_atom)


/datum/atom_hud/proc/add_to_hud(atom/A)
	if(!A || (A in hudatoms))
		return FALSE
	hudatoms |= A
	for(var/u in hudusers)
		var/mob/M = u
		if(!queued_to_see[M])
			add_to_single_hud(M, A)
	return TRUE


/datum/atom_hud/proc/add_to_single_hud(mob/M, atom/A) //unsafe, no sanity apart from client
	if(!M || !M.client || !A)
		return
	for(var/i in hud_icons)
		if(A.hud_list[i])
			M.client.images |= A.hud_list[i]


/datum/atom_hud/proc/clean_mob_refs(datum/source, force)
	remove_hud_from(source)
	remove_from_hud(source)
	next_time_allowed -= source


/mob/proc/reload_huds()
	for(var/datum/atom_hud/hud in GLOB.all_huds)
		if(hud && hud.hudusers[src])
			for(var/atom/A in hud.hudatoms)
				hud.add_to_single_hud(src, A)


/mob/dead/new_player/reload_huds()
	return


/mob/proc/add_click_catcher()
	client.screen += client.void


/mob/dead/new_player/add_click_catcher()
	return
