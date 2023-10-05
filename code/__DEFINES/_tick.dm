/// Percentage of tick to leave for master controller to run
#define MAPTICK_MC_MIN_RESERVE 40
#define MAPTICK_LAST_INTERNAL_TICK_USAGE (world.map_cpu)
/// Amount of a tick to reserve for byond if MAPTICK_LAST_INTERNAL_TICK_USAGE is 0 or not working.
#define TICK_BYOND_RESERVE 2
/// Tick limit while running normally
#define TICK_LIMIT_RUNNING (max(100 - TICK_BYOND_RESERVE - MAPTICK_LAST_INTERNAL_TICK_USAGE, MAPTICK_MC_MIN_RESERVE))
/// Precent of a tick to require to even bother running anything. (10 percent of the tick_limit_running by default)
#define TICK_MIN_RUNTIME (TICK_LIMIT_RUNNING * 0.1)
/// Tick limit used to resume things in stoplag
#define TICK_LIMIT_TO_RUN (Master.current_ticklimit - TICK_MIN_RUNTIME)
/// Tick limit for MC while running
#define TICK_LIMIT_MC (TICK_LIMIT_RUNNING - TICK_MIN_RUNTIME)

/// for general usage of tick_usage
#define TICK_USAGE world.tick_usage
/// to be used where the result isn't checked
#define TICK_USAGE_REAL world.tick_usage

/// Returns true if tick_usage is above the limit
#define TICK_CHECK ( TICK_USAGE > Master.current_ticklimit )
/// runs stoplag if tick_usage is above the limit
#define CHECK_TICK ( TICK_CHECK ? stoplag() : 0 )

/// Checks if a sleeping proc is running before or after the master controller
#define RUNNING_BEFORE_MASTER ( Master.last_run != null && Master.last_run != world.time )
/// Returns true if a verb ought to yield to the MC (IE: queue up to be processed by a subsystem)
#define VERB_SHOULD_YIELD ( TICK_CHECK || RUNNING_BEFORE_MASTER )

/// Returns true if tick usage is above 95, for high priority usage
#define TICK_CHECK_HIGH_PRIORITY ( TICK_USAGE > 95 )
/// runs stoplag if tick_usage is above 95, for high priority usage
#define CHECK_TICK_HIGH_PRIORITY ( TICK_CHECK_HIGH_PRIORITY? stoplag() : 0 )
