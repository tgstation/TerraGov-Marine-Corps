/**
 * The base class for datumized security levels. These are used by `SSsecurity_level`.
 *
 * Each subtype represents a possible security level for the security level subsystem.
 *
 * Base type is abstract: only subtypes will be seen by the security level system.
 */
/datum/security_level
	/// The name of this security level. Shown to players.
	/// For firealarm overlays to work, there must be an icon in
	/// fire_alarm.dmi named after this. `fire_oamber` as an example.
	var/name = "not set"
	/// The color of our announcement divider.
	var/announcement_color = "default"
	/// What we will set status display icons to when switching to this level.
	var/status_display_icon
	/// What color we will use on fire alarms when switching to this level.
	var/fire_alarm_light_color
	/// The numerical level of this security level, see defines for more information.
	var/number_level = -1
	/// Governs many behaviors for the security level, such as how it
	/// may be switched to by players, if it entails an evac/SD emergency, etc.
	/// See defines in __DEFINES\security_levels.dm
	var/sec_level_flags = SEC_LEVEL_FLAG_CAN_SWITCH_COMMS_CONSOLE
	/// The sound that we will play when lowering to this security level.
	var/lowering_sound
	/// The sound that we will play when elevating to this security level.
	var/elevating_sound
	/// Our announcement when lowering to this level.
	var/lowering_body
	/// Our announcement when elevating to this level.
	var/elevating_body
	/// Our configuration key for lowering to text, if set, will override the default lowering to announcement.
	var/lowering_to_configuration_key
	/// Our configuration key for elevating to text, if set, will override the default elevating to announcement.
	var/elevating_to_configuration_key

/datum/security_level/New()
	. = ..()
	if(lowering_to_configuration_key) // This is normally forbidden, but CONFIG_GET expects a typepath and not a var
		lowering_body = global.config.Get(lowering_to_configuration_key)
	if(elevating_to_configuration_key)
		elevating_body = global.config.Get(elevating_to_configuration_key)

/**
 * GREEN
 *
 * No threats
 */
/datum/security_level/green
	name = "green"
	lowering_body = "All clear."
	announcement_color = "green"
	status_display_icon = "default"
	fire_alarm_light_color = LIGHT_COLOR_EMISSIVE_GREEN
	number_level = SEC_LEVEL_GREEN
	lowering_sound = 'sound/AI/code_green.ogg'

/**
 * BLUE
 *
 * Caution advised
 */
/datum/security_level/blue
	name = "blue"
	lowering_body = "Potentially hostile activity on board. All shipside personnel should remain vigilant and wear a helmet."
	elevating_body = "Potentially hostile activity on board. All shipside personnel should remain vigilant and wear a helmet."
	announcement_color = "blue"
	status_display_icon = "default"
	fire_alarm_light_color = LIGHT_COLOR_BLUE
	number_level = SEC_LEVEL_BLUE
	lowering_sound = 'sound/AI/code_blue_lowered.ogg'
	elevating_sound = 'sound/AI/code_blue_elevated.ogg'

/**
 * RED
 *
 * Hostile threats on/about to be on ship
 */
/datum/security_level/red
	name = "red"
	lowering_body = "There is an immediate threat to the ship. Please prepare to evacuate or hold immediately."
	elevating_body = "There is an immediate threat to the ship. Please prepare to evacuate or hold immediately."
	announcement_color = "red"
	status_display_icon = "redalert"
	fire_alarm_light_color = LIGHT_COLOR_EMISSIVE_RED
	number_level = SEC_LEVEL_RED
	sec_level_flags = (SEC_LEVEL_FLAG_CAN_SWITCH_WITH_AUTH|SEC_LEVEL_FLAG_RED_LIGHTS)
	lowering_sound = 'sound/AI/code_red_lowered.ogg'
	elevating_sound = 'sound/AI/code_red_elevated.ogg'

/**
 * DELTA
 *
 * Ship destruction is imminent
 */
/datum/security_level/delta
	name = "delta"
	announcement_color = "purple"
	status_display_icon = "redalert"
	fire_alarm_light_color = LIGHT_COLOR_PINK
	number_level = SEC_LEVEL_DELTA
	sec_level_flags = (SEC_LEVEL_FLAG_CANNOT_SWITCH|SEC_LEVEL_FLAG_RED_LIGHTS|SEC_LEVEL_FLAG_STATE_OF_EMERGENCY)
	lowering_sound = 'sound/misc/airraid.ogg'
	elevating_sound = 'sound/misc/airraid.ogg'
	elevating_to_configuration_key = /datum/config_entry/string/alert_delta
