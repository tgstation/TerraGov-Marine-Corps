//config files
#define CONFIG_GET(X) global.config.Get(/datum/config_entry/##X)
#define CONFIG_SET(X, Y) global.config.Set(/datum/config_entry/##X, ##Y)

#define CONFIG_GROUND_MAPS_FILE "maps.txt"
#define CONFIG_SHIP_MAPS_FILE "shipmaps.txt"
#define CONFIG_MODES_FILE "modes.txt"

//flags
#define CONFIG_ENTRY_LOCKED (1<<0)	//can't edit
#define CONFIG_ENTRY_HIDDEN (1<<1)	//can't see value

// Config entry types
#define VALUE_MODE_NUM 0
#define VALUE_MODE_TEXT 1
#define VALUE_MODE_FLAG 2

#define KEY_MODE_TEXT 0
#define KEY_MODE_TYPE 1
