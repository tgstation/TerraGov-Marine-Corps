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
#define MODE_RELAYED "relayed"

#define MODE_BINARY "binary"
#define MODE_KEY_BINARY "n"
#define MODE_TOKEN_BINARY ":n"

#define MODE_SING "%"

//Spans. Robot speech, italics, etc. Applied in compose_message().
#define SPAN_YELL "yell"
#define SPAN_ITALICS "italics"
#define SPAN_COMMAND "command_headset"
#define SPAN_ROBOT "robot"
#define SPAN_SINGING "singing"

//Eavesdropping
#define EAVESDROP_EXTRA_RANGE 1 //how much past the specified message_range does the message get starred, whispering only

//bitflag #defines for return value of the radio() proc.
#define ITALICS (1<<0)
#define REDUCE_RANGE (1<<1)
#define NOPASS (1<<2)


#define FOLLOW_LINK(observer, target) "<a href=byond://?src=[REF(observer)];track=[REF(target)]>(F)</a>"
#define TURF_LINK(observer, turfy) "<a href=byond://?src=[REF(observer)];jump=1;x=[turfy.x];y=[turfy.y];z=[turfy.z]>(T)</a>"
#define FOLLOW_OR_TURF_LINK(observer, target, turfy) "<a href=byond://?src=[REF(observer)];track=[REF(target)];jump=1;x=[turfy.x];y=[turfy.y];z=[turfy.z]>(F)</a>"


//Used in visible_message_flags, audible_message_flags and runechat_flags
#define COMBAT_MESSAGE (1<<0)
#define EMOTE_MESSAGE (1<<1)
#define OOC_MESSAGE (1<<2)

///the area channel of the important_recursive_contents list, everything in here will be sent a signal when their last holding object changes areas
#define RECURSIVE_CONTENTS_AREA_SENSITIVE "recursive_contents_area_sensitive"
///the hearing channel of the important_recursive_contents list, everything in here will count as a hearing atom
#define RECURSIVE_CONTENTS_HEARING_SENSITIVE "recursive_contents_hearing_sensitive"

///the client mobs channel of the important_recursive_contents list, everything in here will be a mob with an attached client
///this is given to both a clients mob, and a clients eye, both point to the clients mob
#define RECURSIVE_CONTENTS_CLIENT_MOBS "recursive_contents_client_mobs"
