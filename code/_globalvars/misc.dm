GLOBAL_VAR_INIT(timezoneOffset, 0)   // The difference betwen midnight (of the host computer) and 0 world.ticks.
GLOBAL_VAR_INIT(CELLRATE, 0.002)     // Multiplier for watts per tick <> cell storage (eg: 0.02 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
						             // It's a conversion constant. power_used*CELLRATE = charge_provided, or charge_used/CELLRATE = power_provided
GLOBAL_VAR_INIT(CHARGELEVEL, 0.0005) // Cap for how fast cells charge, as a percentage-per-tick (0.01 means cellcharge is capped to 1% per second)

GLOBAL_VAR_INIT(ready_players, 0)

GLOBAL_VAR_INIT(TAB, "&nbsp;&nbsp;&nbsp;&nbsp;")

GLOBAL_LIST_INIT(duplicate_forbidden_vars, list("tag", "datum_components", "area", "type", "loc", "locs", "vars",\
	"parent", "parent_type", "verbs", "ckey", "key", "power_supply", "reagents", "stat", "x", "y", "z", "contents", \
	"group", "atmos_adjacent_turfs", "comp_lookup", "boxes", "click_border_start","storage_start", "storage_continue",\
	"storage_end", "closer", "stored_start", "stored_continue", "stored_end", "click_border_end", "opened"))

GLOBAL_VAR_INIT(current_date_string, "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], [GAME_YEAR]")

// legacy economy bullshit
GLOBAL_VAR_INIT(num_financial_terminals, 1)
GLOBAL_VAR_INIT(next_account_number, 0)
GLOBAL_LIST_EMPTY(all_money_accounts)
GLOBAL_VAR_INIT(station_account, null)
