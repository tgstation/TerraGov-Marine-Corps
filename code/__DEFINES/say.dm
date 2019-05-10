//Message modes. Each one defines a radio channel, more or less.
#define MODE_HEADSET "headset"
#define MODE_ROBOT "robot"

#define MODE_R_HAND "right hand"
#define MODE_KEY_R_HAND "r"

#define MODE_L_HAND "left hand"
#define MODE_KEY_L_HAND "l"

#define MODE_INTERCOM "intercom"
#define MODE_KEY_INTERCOM "i"

#define MODE_WHISPER "whisper"
#define MODE_WHISPER_CRIT "whispercrit"

#define MODE_DEPARTMENT "department"
#define MODE_KEY_DEPARTMENT "h"
#define MODE_TOKEN_DEPARTMENT ":h"

#define MODE_ALIEN "alientalk"
#define MODE_HOLOPAD "holopad"
#define MODE_BINARY "binary"

//Spans. Robot speech, italics, etc. Applied in compose_message().
#define SPAN_YELL "yell"
#define SPAN_ITALICS "italics"
#define SPAN_COMMAND "command_headset"

//Eavesdropping
#define EAVESDROP_EXTRA_RANGE 1 //how much past the specified message_range does the message get starred, whispering only

//bitflag #defines for return value of the radio() proc.
#define ITALICS 		(1<<0)
#define REDUCE_RANGE 	(1<<1)
#define NOPASS 			(1<<2)


#define FOLLOW_LINK(observer, target) "<a href=?src=[REF(observer)];track=[REF(target)]>(F)</a>"
#define TURF_LINK(observer, turfy) "<a href=?src=[REF(observer)];x=[turfy.x];y=[turfy.y];z=[turfy.z]>(T)</a>"
#define FOLLOW_OR_TURF_LINK(observer, target, turfy) "<a href=?src=[REF(observer)];track=[REF(target)];x=[turfy.x];y=[turfy.y];z=[turfy.z]>(F)</a>"