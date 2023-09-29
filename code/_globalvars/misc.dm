GLOBAL_VAR_INIT(timezoneOffset, 0)   // The difference betwen midnight (of the host computer) and 0 world.ticks.
GLOBAL_VAR_INIT(CELLRATE, 0.002)     // Multiplier for watts per tick <> cell storage (eg: 0.02 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
									// It's a conversion constant. power_used*CELLRATE = charge_provided, or charge_used/CELLRATE = power_provided
GLOBAL_VAR_INIT(CHARGELEVEL, 0.0005) // Cap for how fast cells charge, as a percentage-per-tick (0.01 means cellcharge is capped to 1% per second)

GLOBAL_VAR_INIT(TAB, "&nbsp;&nbsp;&nbsp;&nbsp;")

GLOBAL_LIST_INIT(duplicate_forbidden_vars, list(
	"tag", "_datum_components", "area", "type", "loc", "locs", "vars", "parent", "parent_type", "verbs", "ckey", "key",\
	"power_supply", "reagents", "stat", "x", "y", "z", "contents", "group", "atmos_adjacent_turfs", "_listen_lookup",\
	"actions", "actions_by_path", "overlays", "overlays_standing", "hud_list",\
	"appearance", "managed_overlays", "managed_vis_overlays", "computer_id", "ip_address",\
	"boxes", "click_border_start","storage_start", "storage_continue", "storage_end", "closer", "stored_start",\
	"stored_continue", "stored_end", "click_border_end", "opened"
))

GLOBAL_VAR_INIT(current_date_string, "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], [GAME_YEAR]")

// legacy economy bullshit
GLOBAL_VAR_INIT(num_financial_terminals, 1)
GLOBAL_VAR_INIT(next_account_number, 0)
GLOBAL_LIST_EMPTY(all_money_accounts)
GLOBAL_VAR_INIT(station_account, null)

GLOBAL_VAR_INIT(internal_tick_usage, 0.2 * world.tick_lag)

///All currently running polls held as datums
GLOBAL_LIST_EMPTY(polls)
GLOBAL_PROTECT(polls)

///All poll option datums of running polls
GLOBAL_LIST_EMPTY(poll_options)
GLOBAL_PROTECT(poll_options)

///Assoc list of key to timeofdeath (last death from an important role) to know if a player can respawn
GLOBAL_LIST_EMPTY(key_to_time_of_role_death)
GLOBAL_PROTECT(key_to_time_of_role_death)

GLOBAL_LIST_EMPTY(key_to_time_of_death)
GLOBAL_PROTECT(key_to_time_of_death)

GLOBAL_LIST_EMPTY(key_to_time_of_xeno_death)
GLOBAL_PROTECT(key_to_time_of_xeno_death)

///List of ssd living mobs
GLOBAL_LIST_EMPTY(ssd_living_mobs)
