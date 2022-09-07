/datum/config_entry/keyed_list/probability
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/keyed_list/probability/ValidateListEntry(key_name)
	return key_name in config.modes

/datum/config_entry/keyed_list/max_pop
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/keyed_list/max_pop/ValidateListEntry(key_name)
	return key_name in config.modes

/datum/config_entry/keyed_list/min_pop
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/keyed_list/min_pop/ValidateListEntry(key_name, key_value)
	return key_name in config.modes

/datum/config_entry/string/alert_delta
	config_entry_value = "Destruction of the station is imminent. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill."

/datum/config_entry/number/revival_brain_life
	config_entry_value = -1
	integer = FALSE
	min_val = -1

/datum/config_entry/keyed_list/multiplicative_movespeed
	key_mode = KEY_MODE_TYPE
	value_mode = VALUE_MODE_NUM
	config_entry_value = list(			//DEFAULTS
	/mob/living/simple_animal = 1
	)

/datum/config_entry/keyed_list/multiplicative_movespeed/ValidateAndSet()
	. = ..()
	if(.)
		update_config_movespeed_type_lookup(TRUE)

/datum/config_entry/keyed_list/multiplicative_movespeed/vv_edit_var(var_name, var_value)
	. = ..()
	if(. && (var_name == NAMEOF(src, config_entry_value)))
		update_config_movespeed_type_lookup(TRUE)

/datum/config_entry/number/movedelay	//Used for modifying movement speed for mobs.
	abstract_type = /datum/config_entry/number/movedelay

/datum/config_entry/number/movedelay/run_delay
	config_entry_value = 0
	integer = FALSE

/datum/config_entry/number/movedelay/walk_delay
	config_entry_value = 0
	integer = FALSE

/datum/config_entry/number/organ_regeneration_multiplier
	config_entry_value = 1

/datum/config_entry/flag/limbs_can_break

/datum/config_entry/number/revive_grace_period
	config_entry_value = 5 MINUTES
	min_val = 0

/datum/config_entry/flag/bones_can_break

/datum/config_entry/flag/allow_synthetic_gun_use

/datum/config_entry/flag/remove_gun_restrictions

/datum/config_entry/flag/jobs_have_minimal_access

/datum/config_entry/number/minimal_access_threshold	//If the number of players is larger than this threshold, minimal access will be turned on.
	config_entry_value = 10
	min_val = 0

/datum/config_entry/flag/humans_need_surnames

/datum/config_entry/flag/allow_ai

/datum/config_entry/flag/allow_ai_multicam	// allow ai multicamera mode

/datum/config_entry/flag/fun_allowed //a lot of LRP features

/datum/config_entry/flag/xenos_on_strike

/datum/config_entry/number/min_xenos
	config_entry_value = 5
	min_val = 1
/datum/config_entry/keyed_list/lobby_music
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_TEXT

/datum/config_entry/flag/infestation_ert_allowed
	config_entry_value = TRUE

/datum/config_entry/flag/events_disallowed
	config_entry_value = FALSE

/datum/config_entry/flag/monitor_disallowed
	config_entry_value = FALSE

/datum/config_entry/flag/aggressive_changelog

///If TRUE, the evo proc will consider spawn roony instead of runner on evo
/datum/config_entry/flag/roony
	config_entry_value = FALSE

/datum/config_entry/number/marine_respawn
	config_entry_value = 30 MINUTES
	max_val = 30 MINUTES
	min_val = 0
