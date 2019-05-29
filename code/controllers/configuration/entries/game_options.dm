/datum/config_entry/number_list/repeated_mode_adjust

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

/datum/config_entry/flag/protect_roles_from_antagonist	//If security and such can be traitor/cult/other

/datum/config_entry/string/alert_green
	config_entry_value = "All threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced."

/datum/config_entry/string/alert_blue_upto
	config_entry_value = "The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible, random searches are permitted."

/datum/config_entry/string/alert_blue_downto
	config_entry_value = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."

/datum/config_entry/string/alert_red_upto
	config_entry_value = "There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."

/datum/config_entry/string/alert_red_downto
	config_entry_value = "The station's destruction has been averted. There is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised."

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
	/mob/living/simple_animal = 1,
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

/datum/config_entry/number/movedelay/ValidateAndSet()
	. = ..()
	if(.)
		update_mob_config_movespeeds()

/datum/config_entry/number/movedelay/vv_edit_var(var_name, var_value)
	. = ..()
	if(. && (var_name == NAMEOF(src, config_entry_value)))
		update_mob_config_movespeeds()

/datum/config_entry/number/movedelay/run_delay
	config_entry_value = 1
	integer = FALSE

/datum/config_entry/number/movedelay/walk_delay
	config_entry_value = 1
	integer = FALSE

/datum/config_entry/number/outdated_movedelay
	integer = FALSE
	var/movedelay_type

/datum/config_entry/number/outdated_movedelay/DeprecationUpdate(value)
	return "[movedelay_type] [value]"

/datum/config_entry/number/outdated_movedelay/human_delay
	config_entry_value = 0
	movedelay_type = /mob/living/carbon/human

/datum/config_entry/number/outdated_movedelay/monkey_delay
	config_entry_value = 0
	movedelay_type = /mob/living/carbon/monkey

/datum/config_entry/number/outdated_movedelay/animal_delay
	config_entry_value = 0
	movedelay_type = /mob/living/simple_animal

/datum/config_entry/number/gateway_delay	//How long the gateway takes before it activates. Default is half an hour. Only matters if roundstart_away is enabled.
	config_entry_value = 18000
	integer = FALSE
	min_val = 0

/datum/config_entry/number/organ_health_multiplier
	config_entry_value = 1

/datum/config_entry/number/organ_regeneration_multiplier
	config_entry_value = 1

/datum/config_entry/number/health_threshold_crit
	config_entry_value = 0

/datum/config_entry/number/health_threshold_dead
	config_entry_value = -100

/datum/config_entry/number/human_health_threshold_crit
	config_entry_value = -50

/datum/config_entry/number/maintdrone_health_threshold_dead
	config_entry_value = 0

/datum/config_entry/flag/limbs_can_break

/datum/config_entry/number/revive_grace_period
	config_entry_value = 3000
	min_val = 0

/datum/config_entry/flag/bones_can_break

/datum/config_entry/flag/unlimited_rotate_speed

/datum/config_entry/flag/allow_random_events

/datum/config_entry/flag/allow_synthetic_gun_use

/datum/config_entry/flag/remove_gun_restrictions

/datum/config_entry/flag/jobs_have_minimal_access

/datum/config_entry/number/minimal_access_threshold	//If the number of players is larger than this threshold, minimal access will be turned on.
	config_entry_value = 10
	min_val = 0

/datum/config_entry/flag/humans_need_surnames

/datum/config_entry/flag/allow_ai

/datum/config_entry/flag/allow_ai_multicam	// allow ai multicamera mode

/datum/config_entry/flag/fun_allowed //at the moment, when set equal to 1, allows players to *dab (and get limbs automatically blown off).

/datum/config_entry/flag/tank_mouth_noise //Causes the tank to sound like a 5 year old child is driving it.

/datum/config_entry/number/xeno_number
	integer = FALSE
	config_entry_value = 4
	min_val = 1

/datum/config_entry/number/min_xenos
	config_entry_value = 5
	min_val = 1

/datum/config_entry/number/xeno_coefficient
	integer = FALSE
	config_entry_value = 0.04
	min_val = 0.001

/datum/config_entry/number/survivor_coefficient
	integer = FALSE
	config_entry_value = 15
	min_val = 1

/datum/config_entry/number/latejoin_larva_required_num
	integer = FALSE
	min_val = 0
	config_entry_value = 4


/datum/config_entry/number/specialist_coefficient
	integer = FALSE
	config_entry_value = 5
	min_val = 0.001


/datum/config_entry/number/smartgunner_coefficient
	integer = FALSE
	config_entry_value = 5
	min_val = 0.001