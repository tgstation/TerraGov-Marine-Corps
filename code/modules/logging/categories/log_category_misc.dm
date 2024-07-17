/datum/log_category/mecha
	category = LOG_CATEGORY_MECHA
	config_flag = /datum/config_entry/flag/log_mecha

/datum/log_category/paper
	category = LOG_CATEGORY_PAPER

/datum/log_category/manifest
	category = LOG_CATEGORY_MANIFEST
	config_flag = /datum/config_entry/flag/log_manifest

/datum/log_category/config
	category = LOG_CATEGORY_CONFIG

/datum/log_category/filter
	category = LOG_CATEGORY_FILTER

/datum/log_category/signal
	category = LOG_CATEGORY_SIGNAL

/datum/log_category/telecomms
	category = LOG_CATEGORY_TELECOMMS
	config_flag = /datum/config_entry/flag/log_telecomms

/datum/log_category/speech_indicator
	category = LOG_CATEGORY_SPEECH_INDICATOR
	config_flag = /datum/config_entry/flag/log_speech_indicators

// Logs seperately, printed into on server shutdown to store hard deletes and such
/datum/log_category/qdel
	category = LOG_CATEGORY_QDEL
	// We want this human readable so it's easy to see at a glance
	entry_flags = ENTRY_USE_DATA_W_READABLE
