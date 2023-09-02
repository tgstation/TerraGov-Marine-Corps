GLOBAL_VAR(log_directory)
GLOBAL_PROTECT(log_directory)

GLOBAL_VAR(round_id)
GLOBAL_PROTECT(round_id)

#define DECLARE_LOG_NAMED(log_var_name, log_file_name, start)\
GLOBAL_VAR(##log_var_name);\
GLOBAL_PROTECT(##log_var_name);\
/world/_initialize_log_files(temp_log_override = null){\
	..();\
	GLOB.##log_var_name = temp_log_override || "[GLOB.log_directory]/[##log_file_name].log";\
	if(!temp_log_override && ##start){\
		start_log(GLOB.##log_var_name);\
	}\
}

#define DECLARE_LOG(log_name, start) DECLARE_LOG_NAMED(##log_name, "[copytext(#log_name, 1, length(#log_name) - 4)]", start)
#define START_LOG TRUE
#define DONT_START_LOG FALSE

/// Populated by log declaration macros to set log file names and start messages
/world/proc/_initialize_log_files(temp_log_override = null)
	// Needs to be here to avoid compiler warnings
	SHOULD_CALL_PARENT(TRUE)
	return

DECLARE_LOG_NAMED(world_game_log, "game", START_LOG)
DECLARE_LOG_NAMED(world_mecha_log, "mecha", DONT_START_LOG)
DECLARE_LOG_NAMED(world_asset_log, "asset", DONT_START_LOG)
DECLARE_LOG_NAMED(world_runtime_log, "runtime", START_LOG)
DECLARE_LOG_NAMED(world_debug_log, "debug", START_LOG)
DECLARE_LOG_NAMED(world_qdel_log, "qdel", DONT_START_LOG)
DECLARE_LOG_NAMED(world_attack_log, "attack", START_LOG)
DECLARE_LOG_NAMED(world_href_log, "href", START_LOG)
DECLARE_LOG_NAMED(world_mob_tag_log, "mob_tag", START_LOG)
DECLARE_LOG_NAMED(config_error_log, "config_error", DONT_START_LOG)
DECLARE_LOG_NAMED(sql_error_log, "sql_error", START_LOG)
DECLARE_LOG_NAMED(world_telecomms_log, "tcomms", START_LOG)
DECLARE_LOG_NAMED(world_speech_indicators_log, "speech_indicators", DONT_START_LOG)
DECLARE_LOG_NAMED(world_manifest_log, "manifest", START_LOG)
DECLARE_LOG_NAMED(world_paper_log, "paper", START_LOG)
DECLARE_LOG_NAMED(filter_log, "filter", DONT_START_LOG)
DECLARE_LOG_NAMED(tgui_log, "tgui", DONT_START_LOG)

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
DECLARE_LOG_NAMED(test_log, "tests", START_LOG)
#endif

GLOBAL_LIST_EMPTY(admin_log)
GLOBAL_PROTECT(admin_log)
GLOBAL_LIST_EMPTY(adminprivate_log)
GLOBAL_PROTECT(adminprivate_log)
GLOBAL_LIST_EMPTY(asay_log)
GLOBAL_PROTECT(asay_log)
GLOBAL_LIST_EMPTY(msay_log)
GLOBAL_PROTECT(msay_log)
GLOBAL_LIST_EMPTY(dsay_log)
GLOBAL_PROTECT(dsay_log)

GLOBAL_LIST_EMPTY(game_log)
GLOBAL_PROTECT(game_log)
GLOBAL_LIST_EMPTY(access_log)
GLOBAL_PROTECT(access_log)
GLOBAL_LIST_EMPTY(manifest_log)
GLOBAL_PROTECT(manifest_log)
GLOBAL_LIST_EMPTY(say_log)
GLOBAL_PROTECT(say_log)
GLOBAL_LIST_EMPTY(telecomms_log)
GLOBAL_PROTECT(telecomms_log)

GLOBAL_LIST_EMPTY(attack_log)
GLOBAL_PROTECT(attack_log)
GLOBAL_LIST_EMPTY(ffattack_log)
GLOBAL_PROTECT(ffattack_log)
GLOBAL_LIST_EMPTY(explosion_log)
GLOBAL_PROTECT(explosion_log)
