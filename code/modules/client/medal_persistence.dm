GLOBAL_LIST_EMPTY(medal_persistence_datums_by_ckey)
GLOBAL_VAR(medal_persistence_sealed)

///returns the medal persistance datu  for a given ckey
/proc/get_medal_persistence_for_ckey(ckey)
	RETURN_TYPE(/datum/medal_persistence)
	return (GLOB.medal_persistence_datums_by_ckey[ckey] ||= new /datum/medal_persistence(ckey))

///seals the medal persistenance and disallows issuing more medals
/proc/seal_persistent_medals()
	var/is_forced = FALSE
	if(IsAdminAdvancedProcCall())
		if(tgui_input_list(usr, "Are you sure you want to save all medals and seal?", "Save All Medals and Seal", list("Yes", "No")) != "Yes")
			return
		if(GLOB.medal_persistence_sealed && (tgui_input_list(usr, "Medals are already sealed. Do you want to force save?", "Force Save Medals", list("Yes", "No")) != "Yes"))
			return
		is_forced = TRUE
		message_admins("[ADMIN_LOOKUPFLW(usr)] is manually saving and sealing all medals.")

	if(GLOB.medal_persistence_sealed && !is_forced)
		return

	var/list/medal_persistence_datums_by_ckey = GLOB.medal_persistence_datums_by_ckey
	// go over all medals just incase there are any unsaved ones, medals already in the db will not be re-saved so this costs little, even in a worst case scenario
	for(var/datum/medal_persistence/medal_persistence as anything in medal_persistence_datums_by_ckey)
		for(var/name in medal_persistence.medals_by_real_name)
			for(var/datum/persistent_medal_info/medal as anything in medal_persistence.medals_by_real_name[name])
				medal_persistence.save_medal_to_db(null, medal) // not passing usr here even if forced, as this is a mass save

	if(!GLOB.medal_persistence_sealed)
		GLOB.medal_persistence_sealed = TRUE
	to_chat(world, span_notice("Persistent Medals have been saved and sealed. No further medal issuances will be saved without admin intervention."))

/datum/medal_persistence
	///ckey of the owner
	var/ckey
	///player details of the owning ckey
	var/datum/player_details/owner
	///assoc list of medals, list(real_name = list(medal1, medal2))
	var/list/list/datum/persistent_medal_info/medals_by_real_name

/datum/medal_persistence/New(ckey)
	src.ckey = ckey
	owner = GLOB.player_details[ckey]

/**
 * Actually creates and awards a medal based on the args passed and tries to save it in db
 */
/datum/medal_persistence/proc/award_medal(
	issued_to_real_name,
	issued_to_rank,
	issued_by_real_name,
	issued_by_rank,
	medal_uid,
	medal_citation,
	is_posthumous,
)
	var/datum/persistent_medal_info/medal = new
	medal.medal_persistence = src
	medal.issued_to_real_name = issued_to_real_name
	medal.issued_to_rank = issued_to_rank
	medal.issued_by_real_name = issued_by_real_name
	medal.issued_by_rank = issued_by_rank
	medal.medal_uid = medal_uid
	medal.medal_citation = medal_citation
	medal.is_posthumous = is_posthumous
	LAZYINITLIST(medals_by_real_name)
	if(!medals_by_real_name[medal.issued_to_real_name])
		medals_by_real_name[medal.issued_to_real_name] = list()
	medals_by_real_name[medal.issued_to_real_name] += medal
	save_medal_to_db(null, medal)
	return medal

/**
 * Load all medals from the database.
 * - mob/user - The mob to send messages to.
 */
/datum/medal_persistence/proc/load_medals_from_db(mob/user)
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT * FROM medals WHERE ckey = :ckey AND deleted = 0", list("ckey" = ckey))
	if(!query.warn_execute())
		to_chat(user, span_warning("Failed to load medals!"))
		qdel(query)
		return

	for(var/name in medals_by_real_name)
		QDEL_LIST_ASSOC_VAL(medals_by_real_name[name])
	medals_by_real_name = list()

	while(query.NextRow())
		var/datum/persistent_medal_info/medal = load_persistent_medal_from_data(query.item)
		if(!medal)
			stack_trace("Failed to load a medal from the database!")
			continue
		medal.medal_persistence = src
		if(!medals_by_real_name[medal.issued_to_real_name])
			medals_by_real_name[medal.issued_to_real_name] = list()
		medals_by_real_name[medal.issued_to_real_name] += medal

	qdel(query)

/**
 * Save the given medal to the database. If the id field is populated this does nothing.
 * - mob/user - The mob to send messages to.
 * - datum/persistent_medal_info/medal - The medal to save.
 */
/datum/medal_persistence/proc/save_medal_to_db(mob/user, datum/persistent_medal_info/medal)
	if(SSblackbox.sealed) // medals are not updated if the blackbox is sealed
		return

	if(medal.id)
		return
	var/datum/db_query/query = SSdbcore.NewQuery({"INSERT INTO [format_table_name("medals")] (
		ckey,
		issued_to_real_name,
		issued_to_rank,
		issued_by_real_name,
		issued_by_rank,
		medal_uid,
		medal_citation,
		is_posthumous
	) VALUES (
		:ckey,
		:issued_to_real_name,
		:issued_to_rank,
		:issued_by_real_name,
		:issued_by_rank,
		:medal_uid,
		:medal_citation,
		:is_posthumous
	)"}, list(
		"ckey" = ckey,
		"issued_to_real_name" = medal.issued_to_real_name,
		"issued_to_rank" = medal.issued_to_rank,
		"issued_by_real_name" = medal.issued_by_real_name,
		"issued_by_rank" = medal.issued_by_rank,
		"medal_uid" = medal.medal_uid,
		"medal_citation" = medal.medal_citation,
		"is_posthumous" = medal.is_posthumous,
	))
	if(!query.warn_execute())
		stack_trace("Failed to save in DB medal for ckey [ckey]")
		if(!isnull(user))
			to_chat(user, span_warning("Failed to save medal!"))
		qdel(query)
		return

	medal.id = query.last_insert_id
	qdel(query)

/**
 * Marks the given medal as deleted in the database.
 * Deleted medals are not actually removed from the database, but are instead marked as deleted; incase they need to be restored.
 * - datum/persistent_medal_info/medal - The medal to mark as deleted.
 */
/datum/medal_persistence/proc/mark_medal_as_deleted(datum/persistent_medal_info/medal)
	if(medal.id)
		var/datum/db_query/query = SSdbcore.NewQuery("UPDATE medals SET deleted = 1 WHERE id = :id", list("id" = medal.id))
		if(!query.warn_execute())
			stack_trace("Failed to mark medal as deleted!")
		qdel(query)
	medals_by_real_name[medal.issued_to_real_name] -= medal

/**
 * Give all medals to a player.
 * - mob/living/target - The player to give the medals to.
 */
/datum/medal_persistence/proc/give_medals_to(mob/living/target)
	if(!length(medals_by_real_name))
		return
	if(!length(medals_by_real_name[target.real_name]))
		return
	var/obj/item/storage/box/medal_box = new
	medal_box.name = "medal box"
	medal_box.desc = "A box containing medals."

	for(var/datum/persistent_medal_info/medal as anything in medals_by_real_name[target.real_name])
		medal.award_to(medal_box)

	if(!target.put_in_hands(medal_box))
		medal_box.forceMove(get_turf(target))
		to_chat(target, span_notice("There was no room in your hands for your medal box, so it was dropped on the ground."))
	to_chat(target, span_notice("Don't forget to protect your medals!"))

/**
 * A datum to store persistent medal information.
 */
/datum/persistent_medal_info
	var/datum/medal_persistence/medal_persistence //! The medal persistence object this medal is associated with

	var/id //! The row id of the medal in the database

	var/issued_to_real_name //! The real name of the player who was issued the medal
	var/issued_to_rank //! The rank of the player who was issued the medal

	var/issued_by_real_name //! The real name of the player who issued the medal
	var/issued_by_rank //! The rank of the player who issued the medal

	var/obj/item/clothing/tie/medal/medal //! The medal object
	var/obj/item/clothing/tie/medal/medal_uid //! The unique id of the medal
	var/medal_citation //! The citation on the medal

	var/issued_at //! The time the medal was issued
	var/is_posthumous //! Whether the medal was awarded posthumously

/datum/persistent_medal_info/Destroy(force, ...)
	if(medal)
		QDEL_NULL(medal)
	medal_persistence = null
	return ..()

/**
 * Load a medal from a data record.
 * - list/data - The data record to load the medal from.
 */
/proc/load_persistent_medal_from_data(list/data)
	RETURN_TYPE(/datum/persistent_medal_info)
	var/datum/persistent_medal_info/medal = new

	medal.id = data["id"]

	medal.issued_to_real_name = data["issued_to_real_name"]
	medal.issued_to_rank = data["issued_to_rank"]
	medal.issued_by_real_name = data["issued_by_real_name"]
	medal.issued_by_rank = data["issued_by_rank"]

	medal.medal_uid = data["medal_uid"]
	medal.medal_citation = data["medal_citation"]

	medal.medal.recipient_name = medal.issued_to_real_name
	medal.medal.recipient_rank = medal.issued_to_rank
	medal.medal.medal_citation = medal.medal_citation

	medal.issued_at = data["issued_at"]
	medal.is_posthumous = data["is_posthumous"]

	return medal

/datum/persistent_medal_info/proc/get_metal_typepath_from_uid()
	var/static/list/uid_map

	if(isnull(uid_map))
		uid_map = list()
		for(var/datum/persistent_medal_info/medal_type as anything in subtypesof(/obj/item/clothing/tie/medal))
			var/uid = medal_type::medal_uid
			if(uid in uid_map)
				stack_trace("duplicate medal_uid found: `[uid]` in `[medal_type]` and `[uid_map[uid]]`")
			uid_map[uid] = medal_type
	return uid_map[medal_uid]

/**
 * Generate the medal and put it in the provided container.
 * - atom/container - The place we want to create the medal. puts in in the hands of living mobs
 */
/datum/persistent_medal_info/proc/award_to(atom/container)
	var/wanted_type = get_metal_typepath_from_uid()
	if(isnull(wanted_type))
		stack_trace("Failed to find a medal type for medal_uid `[medal_uid]`")
		return

	medal = new wanted_type
	if(isliving(container))
		var/mob/living/mob = container
		mob.put_in_hands(medal)
		return
	medal.forceMove(container)
