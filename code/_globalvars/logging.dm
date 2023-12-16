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

// All individual log files.
// These should be used where the log category cannot easily be a json log file.
DECLARE_LOG_NAMED(config_error_log, "config_error", DONT_START_LOG)

#ifdef REFERENCE_DOING_IT_LIVE
DECLARE_LOG_NAMED(harddel_log, "harddels", START_LOG)
#endif

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
DECLARE_LOG_NAMED(test_log, "tests", START_LOG)
#endif

/// All admin related log lines minus their categories
GLOBAL_LIST_EMPTY(admin_activities)
GLOBAL_PROTECT(admin_activities)

#undef DECLARE_LOG
#undef DECLARE_LOG_NAMED
#undef START_LOG
#undef DONT_START_LOG
