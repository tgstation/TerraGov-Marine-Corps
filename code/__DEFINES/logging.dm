/// The number of entries to store per category, don't make this too large or you'll start to see performance issues
#define CONFIG_MAX_CACHED_LOG_ENTRIES 1000

/// The number of *minimum* ticks between each log re-render, making this small will cause performance issues
/// Admins can still manually request a re-render
#define LOG_UPDATE_TIMEOUT 5 SECONDS

// Logging types for log_message()
#define LOG_ATTACK (1 << 0)
#define LOG_SAY (1 << 1)
#define LOG_WHISPER (1 << 2)
#define LOG_EMOTE (1 << 3)
#define LOG_DSAY (1 << 4)
#define LOG_PRAYER (1 << 5)
#define LOG_HIVEMIND (1 << 6)
#define LOG_TELECOMMS (1 << 7)
#define LOG_OOC (1 << 8)
#define LOG_LOOC (1 << 9)
#define LOG_XOOC (1 << 10)
#define LOG_MOOC (1 << 11)
#define LOG_ADMIN (1 << 12)
#define LOG_GAME (1 << 13)
#define LOG_ADMIN_PRIVATE (1 << 14)
#define LOG_ASAY (1 << 15)
#define LOG_MSAY (1 << 16)
#define LOG_MECHA (1 << 17)
#define LOG_SPEECH_INDICATORS (1 << 18)
#define LOG_VICTIM (1 << 19)

//Individual logging panel pages
#define INDIVIDUAL_GAME_LOG (LOG_GAME)
#define INDIVIDUAL_ATTACK_LOG (LOG_ATTACK | LOG_VICTIM)
#define INDIVIDUAL_SAY_LOG (LOG_SAY | LOG_WHISPER | LOG_DSAY | LOG_PRAYER | LOG_SPEECH_INDICATORS)
#define INDIVIDUAL_EMOTE_LOG (LOG_EMOTE)
#define INDIVIDUAL_COMMS_LOG (LOG_HIVEMIND | LOG_TELECOMMS)
#define INDIVIDUAL_OOC_LOG (LOG_OOC | LOG_LOOC | LOG_XOOC | LOG_MOOC | LOG_ADMIN)
#define INDIVIDUAL_SHOW_ALL_LOG (LOG_ATTACK | LOG_SAY | LOG_WHISPER | LOG_EMOTE | LOG_HIVEMIND | LOG_DSAY | LOG_TELECOMMS | LOG_OOC | LOG_LOOC | LOG_XOOC | LOG_MOOC | LOG_ADMIN | LOG_GAME | LOG_ADMIN_PRIVATE | LOG_ASAY | LOG_MSAY | LOG_MECHA | LOG_SPEECH_INDICATORS | LOG_VICTIM)

#define LOGSRC_CLIENT "Client"
#define LOGSRC_MOB "Mob"

// Log header keys
#define LOG_HEADER_CATEGORY "cat"
#define LOG_HEADER_CATEGORY_LIST "cat-list"
#define LOG_HEADER_INIT_TIMESTAMP "ts"
#define LOG_HEADER_ROUND_ID "round-id"
#define LOG_HEADER_SECRET "secret"

// Log json keys
#define LOG_JSON_CATEGORY "cat"
#define LOG_JSON_ENTRIES "entries"
#define LOG_JSON_LOGGING_START "log-start"

// Log entry keys
#define LOG_ENTRY_KEY_TIMESTAMP "ts"
#define LOG_ENTRY_KEY_CATEGORY "cat"
#define LOG_ENTRY_KEY_MESSAGE "msg"
#define LOG_ENTRY_KEY_DATA "data"
#define LOG_ENTRY_KEY_WORLD_STATE "w-state"
#define LOG_ENTRY_KEY_SEMVER_STORE "s-store"
#define LOG_ENTRY_KEY_ID "id"
#define LOG_ENTRY_KEY_SCHEMA_VERSION "s-ver"

// Category for invalid/missing categories
#define LOG_CATEGORY_NOT_FOUND "invalid-category"

// Misc categories
#define LOG_CATEGORY_CONFIG "config"
#define LOG_CATEGORY_FILTER "filter"
#define LOG_CATEGORY_MANIFEST "manifest"
#define LOG_CATEGORY_MECHA "mecha"
#define LOG_CATEGORY_PAPER "paper"
#define LOG_CATEGORY_QDEL "qdel"
#define LOG_CATEGORY_RUNTIME "runtime"
#define LOG_CATEGORY_SIGNAL "signal"
#define LOG_CATEGORY_SPEECH_INDICATOR "speech-indicator"
#define LOG_CATEGORY_TELECOMMS "telecomms"
#define LOG_CATEGORY_TOOL "tool"

// Admin categories
#define LOG_CATEGORY_ADMIN "admin"
#define LOG_CATEGORY_ADMIN_DSAY "admin-dsay"

// Admin private categories
#define LOG_CATEGORY_ADMIN_PRIVATE "adminprivate"
#define LOG_CATEGORY_ADMIN_PRIVATE_ASAY "adminprivate-asay"
#define LOG_CATEGORY_ADMIN_PRIVATE_MSAY "adminprivate-msay"

// Attack categories
#define LOG_CATEGORY_ATTACK "attack"
#define LOG_CATEGORY_ATTACK_FF "attack-ff"

// Debug categories
#define LOG_CATEGORY_DEBUG "debug"
#define LOG_CATEGORY_DEBUG_ASSET "debug-asset"
#define LOG_CATEGORY_DEBUG_JOB "debug-job"
#define LOG_CATEGORY_DEBUG_MAPPING "debug-mapping"
#define LOG_CATEGORY_DEBUG_MOBTAG "debug-mobtag"
#define LOG_CATEGORY_DEBUG_SQL "debug-sql"

// Compatibility categories, for when stuff is changed and you need existing functionality to work
#define LOG_CATEGORY_COMPAT_GAME "game-compat"

// Game categories
#define LOG_CATEGORY_GAME "game"
#define LOG_CATEGORY_GAME_ACCESS "game-access"
#define LOG_CATEGORY_GAME_EMOTE "game-emote"
#define LOG_CATEGORY_GAME_HIVEMIND "game-hivemind"
#define LOG_CATEGORY_GAME_MINIMAP_DRAWING "game-minimap-drawing"
#define LOG_CATEGORY_GAME_OOC "game-ooc"
#define LOG_CATEGORY_GAME_LOOC "game-looc"
#define LOG_CATEGORY_GAME_XOOC "game-xooc"
#define LOG_CATEGORY_GAME_MOOC "game-mooc"
#define LOG_CATEGORY_GAME_PRAYER "game-prayer"
#define LOG_CATEGORY_GAME_SAY "game-say"
#define LOG_CATEGORY_GAME_TOPIC "game-topic"
#define LOG_CATEGORY_GAME_VOTE "game-vote"
#define LOG_CATEGORY_GAME_WHISPER "game-whisper"

// HREF categories
#define LOG_CATEGORY_HREF "href"
#define LOG_CATEGORY_HREF_TGUI "href-tgui"

// Flags that apply to the entry_flags var on logging categories
// These effect how entry datums process the inputs passed into them
/// Enables data list usage for readable log entries
/// You'll likely want to disable internal formatting to make this work properly
#define ENTRY_USE_DATA_W_READABLE (1<<0)

#define SCHEMA_VERSION "schema-version"

// Default log schema version
#define LOG_CATEGORY_SCHEMA_VERSION_NOT_SET "0.0.1"

//wrapper macros for easier grepping
#define DIRECT_OUTPUT(A, B) A << B
#define DIRECT_INPUT(A, B) A >> B
#define SEND_IMAGE(target, image) DIRECT_OUTPUT(target, image)
#define SEND_SOUND(target, sound) DIRECT_OUTPUT(target, sound)
#define SEND_TEXT(target, text) DIRECT_OUTPUT(target, text)
#define WRITE_FILE(file, text) DIRECT_OUTPUT(file, text)
#define READ_FILE(file, text) DIRECT_INPUT(file, text)
//This is an external call, "true" and "false" are how rust parses out booleans
#define WRITE_LOG(log, text) rustg_log_write(log, text, "true")
#define WRITE_LOG_NO_FORMAT(log, text) rustg_log_write(log, text, "false")
