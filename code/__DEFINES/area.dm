//Alarm levels.
#define ALARM_WARNING_FIRE (1<<0)
#define ALARM_WARNING_ATMOS (1<<1)
#define ALARM_WARNING_EVAC (1<<2)
#define ALARM_WARNING_READY (1<<3)
#define ALARM_WARNING_DOWN (1<<4)

//flags_area
///When present prevents xenos from weeding this area
#define DISALLOW_WEEDING (1<<0)
///When present, monitor will consider marines inside it to be at FOB
#define NEAR_FOB (1<<1)
///When present, this will prevent the drop pod to land there (usually kill zones)
#define NO_DROPPOD (1<<2)
