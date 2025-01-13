/**
 * Security levels
 *
 * The base class for datumized security levels. These are used by `SSsecurity_level`.
 *
 * Each subtype represents a possible security level for the security level subsystem.
 *
 * Base type is abstract
 */
/datum/security_level
	/// The name of this security level.
	var/name = "not set"
	/// The color of our announcement divider.
	var/announcement_color = "default"
	/// The numerical level of this security level, see defines for more information.
	var/number_level = -1
	/// The sound that we will play when this security level is set.
	var/sound
	/// Governs whether players can switch to this security level and, if so,
	/// what methods they can use to set it. See defines in __game.dm.
	/// If, for whatever reason, you want to use multiple flags, that is supported.
	/// (example: a security level accessible through a comms console *or* keycard auth)
	var/sec_level_flags = SEC_LEVEL_CAN_SWITCH_COMMS_CONSOLE
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
	if(lowering_to_configuration_key) // I'm not sure about you, but isn't there an easier way to do this?
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
	lowering_body = "All threats to the ship have passed."
	announcement_color = "green"
	sound = 'sound/misc/security_level/green.ogg' // Friendly beep
	number_level = SEC_LEVEL_GREEN

/**
 * BLUE
 *
 * Caution advised
 */
/datum/security_level/blue
	name = "blue"
	lowering_body = "The Code Red threat has passed. A possible threat may still be on the ship. All shipside personnel should remain vigilant and wear a helmet."
	elevating_body = "Code Blue directive issued. Possible threat on the ship. All shipside personnel should remain vigilant and wear a helmet."
	announcement_color = "blue"
	sound = 'sound/misc/security_level/blue.ogg' // Angry alarm
	number_level = SEC_LEVEL_BLUE

/**
 * RED
 *
 * Hostile threats on/about to be on ship
 */
/datum/security_level/red
	name = "red"
	lowering_body = "The destruction of the ship has been averted. A Code Red emergency will remain in place. Please prepare to evacuate or defend immediately. There is still an immediate and serious threat to the ship. All shipside personnel are strongly advised to carry a sidearm and wear a helmet."
	elevating_body = "Code Red emergency declared. Please prepare to evacuate or defend immediately. There is an immediate and serious threat to the ship. All shipside personnel are strongly advised to carry a weapon and wear a helmet."
	announcement_color = "red"
	sound = 'sound/misc/security_level/red.ogg' // More angry alarm
	number_level = SEC_LEVEL_RED
	sec_level_flags = SEC_LEVEL_CAN_SWITCH_WITH_AUTH

/**
 * DELTA
 *
 * Ship destruction is imminent
 */
/datum/security_level/delta
	name = "delta"
	announcement_color = "purple"
	sound = 'sound/misc/airraid.ogg' // Scary siren
	number_level = SEC_LEVEL_DELTA
	elevating_to_configuration_key = /datum/config_entry/string/alert_delta
	sec_level_flags = (SEC_LEVEL_CANNOT_SWITCH|SEC_LEVEL_IS_EMERGENCY)
