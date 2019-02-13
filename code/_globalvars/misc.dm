GLOBAL_VAR_INIT(timezoneOffset, 0)   // The difference betwen midnight (of the host computer) and 0 world.ticks.
GLOBAL_VAR_INIT(CELLRATE, 0.002)     // Multiplier for watts per tick <> cell storage (eg: 0.02 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
						             // It's a conversion constant. power_used*CELLRATE = charge_provided, or charge_used/CELLRATE = power_provided
GLOBAL_VAR_INIT(CHARGELEVEL, 0.0005) // Cap for how fast cells charge, as a percentage-per-tick (0.01 means cellcharge is capped to 1% per second)

GLOBAL_VAR_INIT(ready_players, 0)
GLOBAL_VAR_INIT(total_players, 0)