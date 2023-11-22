
// Schema version must always be the very last element in the array.

// Current Schema: 1.0.0
// [timestamp, category, message, data, world_state, semver_store, id, schema_version]

/// A datum which contains log information.
/datum/log_entry
	/// Next id to assign to a log entry.
	var/static/next_id = 0

	/// Unique id of the log entry.
	var/id

	/// Schema version of the log entry.
	var/schema_version = "1.0.0"

	/// Unix timestamp of the log entry.
	var/timestamp

	/// Category of the log entry.
	var/category

	/// Message of the log entry.
	var/message

	/// Bitfield that describes how exactly to log stuff exactly
	/// See code/__DEFINES/logging/dm
	var/flags = NONE

	/// Data of the log entry; optional.
	var/list/data

	/// Semver store of the log entry, used to store the schema of data entries
	var/list/semver_store

GENERAL_PROTECT_DATUM(/datum/log_entry)

/datum/log_entry/New(timestamp, category, message, flags, list/data, list/semver_store)
	..()

	src.id = next_id++
	src.timestamp = timestamp
	src.category = category
	src.flags = flags
	src.message = message
	with_data(data)
	with_semver_store(semver_store)

/datum/log_entry/proc/with_data(list/data)
	if(!isnull(data))
		if(!islist(data))
			src.data = list("data" = data)
			stack_trace("Log entry data was not a list, it was [data.type].")
		else
			src.data = data
	return src

/datum/log_entry/proc/with_semver_store(list/semver_store)
	if(isnull(semver_store))
		return
	if(!islist(semver_store))
		stack_trace("Log entry semver store was not a list, it was [semver_store.type]. We cannot reliably convert it to a list.")
	else
		src.semver_store = semver_store
	return src

/// Converts the log entry to a human-readable string.
/datum/log_entry/proc/to_readable_text(format = TRUE)
	var/output = ""
	if(format)
		output += "\[[timestamp]\] [uppertext(category)]: [message]"
	else
		output += "[uppertext(category)]: [message]"

	if(flags & ENTRY_USE_DATA_W_READABLE)
#if DM_VERSION >= 515
		output += json_encode(data, JSON_PRETTY_PRINT)
#else
		output += json_encode(data)
#endif
	return output

#define MANUAL_JSON_ENTRY(list, key, value) list.Add("\"[key]\":[(!isnull(value)) ? json_encode(value) : "null"]")

/// Converts the log entry to a JSON string.
/datum/log_entry/proc/to_json_text()
	// I do not trust byond's json encoder, and need to ensure the order doesn't change.
	var/list/json_entries = list()
	MANUAL_JSON_ENTRY(json_entries, LOG_ENTRY_KEY_TIMESTAMP, timestamp)
	MANUAL_JSON_ENTRY(json_entries, LOG_ENTRY_KEY_CATEGORY, category)
	MANUAL_JSON_ENTRY(json_entries, LOG_ENTRY_KEY_MESSAGE, message)
	MANUAL_JSON_ENTRY(json_entries, LOG_ENTRY_KEY_DATA, data)
	MANUAL_JSON_ENTRY(json_entries, LOG_ENTRY_KEY_WORLD_STATE, world.get_world_state_for_logging())
	MANUAL_JSON_ENTRY(json_entries, LOG_ENTRY_KEY_SEMVER_STORE, semver_store)
	MANUAL_JSON_ENTRY(json_entries, LOG_ENTRY_KEY_ID, id)
	MANUAL_JSON_ENTRY(json_entries, LOG_ENTRY_KEY_SCHEMA_VERSION, schema_version)
	return "{[json_entries.Join(",")]}"

#undef MANUAL_JSON_ENTRY

/// Writes the log entry to a file.
/datum/log_entry/proc/write_entry_to_file(file)
	if(!fexists(file))
		CRASH("Attempted to log to an uninitialized file: [file]")
	WRITE_LOG_NO_FORMAT(file, "[to_json_text()]\n")

/// Writes the log entry to a file as a human-readable string.
/datum/log_entry/proc/write_readable_entry_to_file(file, format_internally = TRUE)
	if(!fexists(file))
		CRASH("Attempted to log to an uninitialized file: [file]")

	// If it's being formatted internally we need to manually add a newline
	if(format_internally)
		WRITE_LOG_NO_FORMAT(file, "[to_readable_text(format = TRUE)]\n")
	else
		WRITE_LOG(file, "[to_readable_text(format = FALSE)]")
