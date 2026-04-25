//! Defines for security level subsystem + datum behavior.

/// GREEN - Absolutely nothing of note!
#define SEC_LEVEL_GREEN 1
/// BLUE - Possible threats.
#define SEC_LEVEL_BLUE 2
/// RED - Severe threats. Boarding imminent or actively happening.
/// This is the level that will be set when evac and SD are both called off.
#define SEC_LEVEL_RED 3
/// DELTA - Destruction of the ship is imminent.
#define SEC_LEVEL_DELTA 4

/// Players can change to this through comms consoles
#define SEC_LEVEL_FLAG_CAN_SWITCH_COMMS_CONSOLE (1<<0)
/// Players can change to this but only through keycard authentication, which requires someone else
#define SEC_LEVEL_FLAG_CAN_SWITCH_WITH_AUTH (1<<1)
/// Players can't change to this level manually.
#define SEC_LEVEL_FLAG_CANNOT_SWITCH (1<<2)
/// Turns shipside lights red.
#define SEC_LEVEL_FLAG_RED_LIGHTS (1<<3)
/// Opens SD shutters, shows evacuation and related information in comms console.
/// Also causes delta alarms to start playing.
#define SEC_LEVEL_FLAG_STATE_OF_EMERGENCY (1<<4)
