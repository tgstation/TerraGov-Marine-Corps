/**
 * # Discord Subsystem
 *
 * This subsystem handles some integrations with discord
 *
 * NOTES:
 * * There is a DB table to track ckeys and associated discord IDs. (discord_link)
 */
SUBSYSTEM_DEF(discord)
	name = "Discord"
	flags = SS_NO_FIRE

	/// People who have tried to verify this round already
	var/list/reverify_cache

	/// Common words list, used to generate one time tokens
	var/list/common_words

/datum/controller/subsystem/discord/Initialize(start_timeofday)
	common_words = file2list("strings/1000_most_common.txt")
	reverify_cache = list()
	return ..()

/**
 * Given a ckey, look up the discord user id attached to the user, if any
 *
 * This gets the most recent entry from the discord link table that is associated with the given ckey
 *
 * Arguments:
 * * lookup_ckey A string representing the ckey to search on
 */
/datum/controller/subsystem/discord/proc/lookup_id(lookup_ckey)
	var/datum/discord_link_record/link = find_discord_link_by_ckey(lookup_ckey)
	if(link)
		return link.discord_id

/**
 * Given a discord id as a string, look up the ckey attached to that account, if any
 *
 * This gets the most recent entry from the discord_link table that is associated with this discord id snowflake
 *
 * Arguments:
 * * lookup_id The discord id as a string
 */
/datum/controller/subsystem/discord/proc/lookup_ckey(lookup_id)
	var/datum/discord_link_record/link  = find_discord_link_by_discord_id(lookup_id)
	if(link)
		return link.ckey

/datum/controller/subsystem/discord/proc/get_or_generate_one_time_token_for_ckey(ckey)
	// Is there an existing valid one time token
	var/datum/discord_link_record/link = find_discord_link_by_ckey(ckey, timebound = TRUE)
	if(link)
		return link.one_time_token

	// Otherwise we make one
	return generate_one_time_token(ckey)

/**
 * Generate a timebound token for discord verification
 *
 * This uses the common word list to generate a six word random token, this token can then be fed to a discord bot that has access
 * to the same database, and it can use it to link a ckey to a discord id, with minimal user effort
 *
 * It returns the token to the calling proc, after inserting an entry into the discord_link table of the following form
 *
 * ```
 * (unique_id, ckey, null, the current time, the one time token generated)
 * the null value will be filled out with the discord id by the integrated discord bot when a user verifies
 * ```
 *
 * Notes:
 * * The token is guaranteed to unique during it's validity period
 * * The validity period is currently set at 4 hours
 * * a token may not be unique outside it's validity window (to reduce conflicts)
 *
 * Arguments:
 * * ckey_for a string representing the ckey this token is for
 *
 * Returns a string representing the one time token
 */
/datum/controller/subsystem/discord/proc/generate_one_time_token(ckey_for)

	var/not_unique = TRUE
	var/one_time_token = ""
	// While there's a collision in the token, generate a new one (should rarely happen)
	while(not_unique)
		//Column is varchar 100, so we trim just in case someone does us the dirty later
		one_time_token = trim("[pick(common_words)]-[pick(common_words)]-[pick(common_words)]-[pick(common_words)]-[pick(common_words)]-[pick(common_words)]", 100)

		not_unique = find_discord_link_by_token(one_time_token, timebound = TRUE)

	// Insert into the table, null in the discord id, id and timestamp and valid fields so the db fills them out where needed
	var/datum/db_query/query_insert_link_record = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("discord_links")] (ckey, one_time_token) VALUES(:ckey, :token)",
		list("ckey" = ckey_for, "token" = one_time_token)
	)

	if(!query_insert_link_record.Execute())
		qdel(query_insert_link_record)
		return ""

	//Cleanup
	qdel(query_insert_link_record)
	return one_time_token

/**
 * Find discord link entry by the passed in user token
 *
 * This will look into the discord link table and return the *first* entry that matches the given one time token
 *
 * Remember, multiple entries can exist, as they are only guaranteed to be unique for their validity period
 *
 * Arguments:
 * * one_time_token the string of words representing the one time token
 * * timebound A boolean flag, that specifies if it should only look for entries within the last 4 hours, off by default
 *
 * Returns a [/datum/discord_link_record]
 */
/datum/controller/subsystem/discord/proc/find_discord_link_by_token(one_time_token, timebound = FALSE)
	var/timeboundsql = ""
	if(timebound)
		timeboundsql = "AND timestamp >= Now() - INTERVAL 4 HOUR"
	var/query = "SELECT CAST(discord_id AS CHAR(25)), ckey, MAX(timestamp), one_time_token FROM [format_table_name("discord_links")] WHERE one_time_token = :one_time_token [timeboundsql] GROUP BY ckey, discord_id, one_time_token LIMIT 1"
	var/datum/db_query/query_get_discord_link_record = SSdbcore.NewQuery(
		query,
		list("one_time_token" = one_time_token)
	)
	if(!query_get_discord_link_record.Execute())
		qdel(query_get_discord_link_record)
		return
	if(query_get_discord_link_record.NextRow())
		var/result = query_get_discord_link_record.item
		. = new /datum/discord_link_record(result[2], result[1], result[4], result[3])

	//Make sure we clean up the query
	qdel(query_get_discord_link_record)

/**
 * Find discord link entry by the passed in user ckey
 *
 * This will look into the discord link table and return the *first* entry that matches the given ckey
 *
 * Remember, multiple entries can exist
 *
 * Arguments:
 * * ckey the users ckey as a string
 * * timebound should we search only in the last 4 hours
 *
 * Returns a [/datum/discord_link_record]
 */
/datum/controller/subsystem/discord/proc/find_discord_link_by_ckey(ckey, timebound = FALSE)
	var/timeboundsql = ""
	if(timebound)
		timeboundsql = "AND timestamp >= Now() - INTERVAL 4 HOUR"

	var/query = "SELECT CAST(discord_id AS CHAR(25)), ckey, MAX(timestamp), one_time_token FROM [format_table_name("discord_links")] WHERE ckey = :ckey [timeboundsql] GROUP BY ckey, discord_id, one_time_token LIMIT 1"
	var/datum/db_query/query_get_discord_link_record = SSdbcore.NewQuery(
		query,
		list("ckey" = ckey)
	)
	if(!query_get_discord_link_record.Execute())
		qdel(query_get_discord_link_record)
		return

	if(query_get_discord_link_record.NextRow())
		var/result = query_get_discord_link_record.item
		. = new /datum/discord_link_record(result[2], result[1], result[4], result[3])

	//Make sure we clean up the query
	qdel(query_get_discord_link_record)


/**
 * Find discord link entry by the passed in user ckey
 *
 * This will look into the discord link table and return the *first* entry that matches the given ckey
 *
 * Remember, multiple entries can exist
 *
 * Arguments:
 * * discord_id The users discord id (string)
 * * timebound should we search only in the last 4 hours
 *
 * Returns a [/datum/discord_link_record]
 */
/datum/controller/subsystem/discord/proc/find_discord_link_by_discord_id(discord_id, timebound = FALSE)
	var/timeboundsql = ""
	if(timebound)
		timeboundsql = "AND timestamp >= Now() - INTERVAL 4 HOUR"

	var/query = "SELECT CAST(discord_id AS CHAR(25)), ckey, MAX(timestamp), one_time_token FROM [format_table_name("discord_links")] WHERE discord_id = :discord_id [timeboundsql] GROUP BY ckey, discord_id, one_time_token LIMIT 1"
	var/datum/db_query/query_get_discord_link_record = SSdbcore.NewQuery(
		query,
		list("discord_id" = discord_id)
	)
	if(!query_get_discord_link_record.Execute())
		qdel(query_get_discord_link_record)
		return

	if(query_get_discord_link_record.NextRow())
		var/result = query_get_discord_link_record.item
		. = new /datum/discord_link_record(result[2], result[1], result[4], result[3])

	//Make sure we clean up the query
	qdel(query_get_discord_link_record)
