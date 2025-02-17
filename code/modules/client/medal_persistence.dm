GLOBAL_LIST_EMPTY(medal_persistence_datums_by_ckey)

/proc/get_medal_persistence(ckey)
	RETURN_TYPE(/datum/medal_persistence)
	return (GLOB.medal_persistence_datums_by_ckey[ckey] ||= new /datum/medal_persistence(ckey))

/datum/medal_persistence
	var/ckey
	var/datum/player_details/owner
	var/list/list/datum/persistent_medal_info/medals_by_real_name

/datum/medal_persistence/New(ckey)
	ckey = ckey
	owner = GLOB.player_details[ckey]
	load_medals_from_db()

/datum/medal_persistence/proc/award_medal(
	issued_to_real_name,
	issued_to_rank,
	issued_by_real_name,
	issued_by_rank,
	medal_typepath,
	medal_citation,
)
	var/datum/persistent_medal_info/medal = new
	medal.issued_to_real_name = issued_to_real_name
	medal.issued_to_rank = issued_to_rank
	medal.issued_by_real_name = issued_by_real_name
	medal.issued_by_rank = issued_by_rank
	medal.medal_typepath = medal_typepath
	medal.medal_citation = medal_citation
	medal.issued_at = SQLtime()
	medals_by_real_name[issued_to_real_name] ||= list(medal)
	medals_by_real_name[issued_to_real_name] += medal
	save_medals_to_db()
	return medal

/**
 * Load all medals from the database.
 * - mob/user - The mob to send messages to.
 */
/datum/medal_persistence/proc/load_medals_from_db(mob/user)
	set waitfor = FALSE

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT * FROM medals WHERE ckey = :ckey", list("ckey" = ckey))
	if(!query.warn_execute())
		to_chat(user, span_warning("Failed to load medals!"))
		qdel(query)
		return

	while(query.NextRow())
		var/datum/persistent_medal_info/medal = load_persistent_medal_from_data(query.item)
		if(!medal)
			stack_trace("Failed to load a medal from the database!")
			continue
		medals_by_real_name[medal.issued_to_real_name] ||= list(medal)
		medals_by_real_name[medal.issued_to_real_name] += medal

	qdel(query)

/**
 * Save all medals to the database.
 * - mob/user - The mob to send messages to.
 */
/datum/medal_persistence/proc/save_medals_to_db(mob/user)
	var/datum/db_query/query = SSdbcore.NewQuery("DELETE FROM [format_table_name("medals")] WHERE ckey = :ckey", list("ckey" = ckey))
	if(!query.warn_execute())
		stack_trace("Failed to reset medals for ckey [ckey]")
		qdel(query)
		return FALSE
	qdel(query)

	var/any_medal_failed_to_save = FALSE
	for(var/real_name in medals_by_real_name)
		for(var/datum/persistent_medal_info/medal in medals_by_real_name[real_name])
			var/datum/db_query/query = SSdbcore.NewQuery({"INSERT INTO [format_table_name("medals")] (
				ckey,
				issued_to_real_name,
				issued_to_rank,
				issued_by_real_name,
				issued_by_rank,
				medal_typepath,
				medal_citation,
				issued_at,
				is_posthumous
			) VALUES (
				:ckey,
				:issued_to_real_name,
				:issued_to_rank,
				:issued_by_real_name,
				:issued_by_rank,
				:medal_typepath,
				:medal_citation,
				:issued_at,
				:is_posthumous
			)"}, list(
				"ckey" = ckey,
				"issued_to_real_name" = medal.issued_to_real_name,
				"issued_to_rank" = medal.issued_to_rank,
				"issued_by_real_name" = medal.issued_by_real_name,
				"issued_by_rank" = medal.issued_by_rank,
				"medal_typepath" = medal.medal_typepath,
				"medal_citation" = medal.medal_citation,
				"issued_at" = medal.issued_at,
				"is_posthumous" = medal.is_posthumous,
			))
			if(!query.warn_execute())
				any_medal_failed_to_save = TRUE
				stack_trace("Failed to save medal for ckey [ckey]")
				qdel(query)
				continue
			qdel(query)
	if(any_medal_failed_to_save)
		to_chat(user, span_warning("Some of your medals failed to save!"))

/**
 * Give all medals to a player.
 * - mob/living/target - The player to give the medals to.
 */
/datum/medal_persistence/proc/give_medals_to(mob/living/target)
	if(target.ckey != ckey)
		stack_trace("Attempted to give medals to a player who does not match the ckey of the medal persistence object!")
		return

	var/obj/item/storage/box/medal_box = new
	medal_box.name = "medal box"
	medal_box.desc = "A box containing medals."

	for(var/datum/persistent_medal_info/medal in medals_by_real_name[target.real_name])
		medal.award_to(medal_box)

	if(!target.put_in_hands(medal_box))
		medal_box.forceMove(get_turf(target))
		to_chat(target, span_notice("There was no room in your hands for your medal box, so it was dropped on the ground."))
	to_chat(target, span_notice("Don't forget to protect your medals!"))

/**
 * A datum to store persistent medal information.
 */
/datum/persistent_medal_info
	var/issued_to_real_name //! The real name of the player who was issued the medal
	var/issued_to_rank //! The rank of the player who was issued the medal

	var/issued_by_real_name //! The real name of the player who issued the medal
	var/issued_by_rank //! The rank of the player who issued the medal

	var/obj/item/clothing/tie/medal/medal //! The medal object
	var/obj/item/clothing/tie/medal/medal_typepath //! The typepath of the medal
	var/medal_citation //! The citation on the medal

	var/issued_at //! The time the medal was issued
	var/is_posthumous //! Whether the medal was awarded posthumously

/**
 * Load a medal from a data record.
 * - list/data - The data record to load the medal from.
 */
/proc/load_persistent_medal_from_data(list/data)
	RETURN_TYPE(/datum/persistent_medal_info)
	var/datum/persistent_medal_info/medal = new

	medal.issued_to_real_name = data["issued_to_real_name"]
	medal.issued_to_rank = data["issued_to_rank"]
	medal.issued_by_real_name = data["issued_by_real_name"]
	medal.issued_by_rank = data["issued_by_rank"]

	var/wanted_typepath = text2path(data["medal_typepath"])
	if(!ispath(wanted_typepath, /obj/item/clothing/tie/medal))
		stack_trace("Attempted to load a medal with an invalid typepath: [wanted_typepath]")
		return null

	medal.medal_typepath = wanted_typepath
	medal.medal_citation = data["medal_citation"]

	medal.medal.recipient_name = medal.issued_to_real_name
	medal.medal.recipient_rank = medal.issued_to_rank
	medal.medal.medal_citation = medal.medal_citation

	medal.issued_at = data["issued_at"]
	medal.is_posthumous = data["is_posthumous"]

	return medal

/**
 * Generate the medal and put it in the provided container.
 * - mob/container - The mob being awarded the medal.
 */
/datum/persistent_medal_info/proc/award_to(atom/container)
	medal = new medal_typepath
	if(isliving(container))
		var/mob/living/mob = container
		mob.put_in_hands(medal)
		return
	medal.forceMove(container)
