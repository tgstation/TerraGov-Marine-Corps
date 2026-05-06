/// flag to turn on voicechat
/datum/config_entry/flag/enable_voicechat

///the port to run the node server on
/datum/config_entry/number/port_voicechat
	min_val = 1024
	default = 3000
	max_val = 65535
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN
