// the types of priority announcements
/// Regular gameplay, not too important
#define ANNOUNCEMENT_REGULAR 1
/// Probably round outcome changing, like OBs and Alamo fun
#define ANNOUNCEMENT_PRIORITY 2
/// Command alerts
#define ANNOUNCEMENT_COMMAND 3

/// Admin or OOC sources. Yellow
#define OOC_ALERT_ADMIN "ooc"
/// Game alerts, like roundend. Red
#define OOC_ALERT_GAME "game"

/// Colors for faction alert overrides, used for admin menus
#define FACTION_ALERT_COLORS list("default", "green", "blue", "pink", "yellow", "orange", "red", "purple", "grey")
