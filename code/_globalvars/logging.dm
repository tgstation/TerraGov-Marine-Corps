GLOBAL_VAR(log_directory)
GLOBAL_PROTECT(log_directory)
GLOBAL_VAR(world_game_log)
GLOBAL_PROTECT(world_game_log)
GLOBAL_VAR(world_runtime_log)
GLOBAL_PROTECT(world_runtime_log)
GLOBAL_VAR(world_qdel_log)
GLOBAL_PROTECT(world_qdel_log)
GLOBAL_VAR(world_attack_log)
GLOBAL_PROTECT(world_attack_log)
GLOBAL_VAR(world_href_log)
GLOBAL_PROTECT(world_href_log)
GLOBAL_VAR(round_id)
GLOBAL_PROTECT(round_id)
GLOBAL_VAR(config_error_log)
GLOBAL_PROTECT(config_error_log)
GLOBAL_VAR(sql_error_log)
GLOBAL_PROTECT(sql_error_log)
GLOBAL_VAR(world_manifest_log)
GLOBAL_PROTECT(world_manifest_log)


GLOBAL_LIST_EMPTY(admin_log)
GLOBAL_PROTECT(admin_log)

GLOBAL_LIST_EMPTY(combatlog)
GLOBAL_PROTECT(combatlog)
GLOBAL_LIST_EMPTY(IClog)
GLOBAL_PROTECT(IClog)
GLOBAL_LIST_EMPTY(OOClog)
GLOBAL_PROTECT(OOClog)

GLOBAL_LIST_EMPTY(active_turfs_startlist)

/////Picture logging
GLOBAL_VAR(picture_log_directory)
GLOBAL_PROTECT(picture_log_directory)

GLOBAL_VAR_INIT(picture_logging_id, TRUE)
GLOBAL_PROTECT(picture_logging_id)
GLOBAL_VAR(picture_logging_prefix)
GLOBAL_PROTECT(picture_logging_prefix)
/////