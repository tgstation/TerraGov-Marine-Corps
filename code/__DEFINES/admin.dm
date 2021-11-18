//A set of constants used to determine which type of mute an admin wishes to apply:
//Please read and understand the muting/automuting stuff before changing these. MUTE_IC_AUTO etc = (MUTE_IC << 1)
//Therefore there needs to be a gap between the flags for the automute flags
#define MUTE_IC (1<<0)
#define MUTE_OOC (1<<1)
#define MUTE_PRAY (1<<2)
#define MUTE_ADMINHELP (1<<3)
#define MUTE_DEADCHAT (1<<4)
#define MUTE_LOOC (1<<5)
#define MUTE_ALL (1<<6)-1

//Some constants for DB_Ban
#define BANTYPE_PERMA 1
#define BANTYPE_TEMP 2
#define BANTYPE_JOB_PERMA 3
#define BANTYPE_JOB_TEMP 4
#define BANTYPE_ANY_FULLBAN 5 //used to locate stuff to unban.

#define BANTYPE_ADMIN_PERMA 7
#define BANTYPE_ADMIN_TEMP 8
#define BANTYPE_ANY_JOB 9 //used to remove jobbans


//Ticket tiers
#define TICKET_MENTOR 1
#define TICKET_ADMIN 2

//Admin Permissions
#define R_ADMIN (1<<0)
#define R_MENTOR (1<<1)
#define R_BAN (1<<2)
#define R_ASAY (1<<3)
#define R_ADMINTICKET (1<<4)
#define R_FUN (1<<5)
#define R_SERVER (1<<6)
#define R_DEBUG (1<<7)
#define R_PERMISSIONS (1<<8)
#define R_COLOR (1<<9)
#define R_VAREDIT (1<<10)
#define R_SOUND (1<<11)
#define R_SPAWN (1<<12)
#define R_DBRANKS (1<<13)
#define R_RUNTIME (1<<14)
#define R_LOG (1<<15)

#define R_EVERYTHING (1<<16)-1 //the sum of all other rank permissions, used for +EVERYTHING

#define ADMIN_QUE(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];moreinfo=[REF(user)]'>?</a>)"
#define ADMIN_FLW(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];observefollow=[REF(user)]'>FLW</a>)"
#define ADMIN_JMP(src) "(<a href='?_src_=holder;[HrefToken(TRUE)];observecoordjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)"
#define ADMIN_JMP_USER(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];observecoordjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)"
#define ADMIN_PP(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];playerpanel=[REF(user)]'>PP</a>)"
#define ADMIN_VV(atom) "(<a href='?_src_=vars;[HrefToken(TRUE)];vars=[REF(atom)]'>VV</a>)"
#define ADMIN_SM(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];subtlemessage=[REF(user)]'>SM</a>)"
#define ADMIN_IF(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];imginaryfriend=[REF(user)]'>IF</a>)"
#define ADMIN_TP(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];traitorpanel=[REF(user)]'>TP</a>)"
#define ADMIN_KICK(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];kick=[REF(user)]'>KICK</a>)"
#define ADMIN_SC(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];spawncookie=[REF(user)]'>SC</a>)"
#define ADMIN_SFC(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];spawnfortunecookie=[REF(user)]'>SFC</a>)"
#define ADMIN_LOOKUP(user) "[key_name_admin(user)][ADMIN_QUE(user)]"
#define ADMIN_LOOKUPFLW(user) "[key_name_admin(user)][ADMIN_QUE(user)] [ADMIN_FLW(user)]"
#define ADMIN_FULLMONTY_NONAME(user) "[ADMIN_QUE(user)] [ADMIN_PP(user)] [ADMIN_VV(user)] [ADMIN_SM(user)] [ADMIN_JMP(user)] [ADMIN_FLW(user)]"
#define ADMIN_FULLMONTY(user) "[key_name_admin(user)] [ADMIN_FULLMONTY_NONAME(user)]"
#define ADMIN_TPMONTY_NONAME(user) "[ADMIN_QUE(user)] [ADMIN_JMP(user)] [ADMIN_FLW(user)]"
#define ADMIN_TPMONTY(user) "[key_name_admin(user)] [ADMIN_TPMONTY_NONAME(user)]"
#define COORD(src) "[src ? "([src.x],[src.y],[src.z])" : "nonexistent location"]"
#define AREACOORD(src) "[src ? "[get_area_name(src, TRUE)] ([src.x], [src.y], [src.z])" : "nonexistent location"]"
#define AREACOORD_NO_Z(src) "[src ? "[get_area_name(src, TRUE)] (X: [src.x], Y: [src.y])" : "nonexistent location"]"
#define ADMIN_COORDJMP(src) "[src ? "[COORD(src)] [ADMIN_JMP(src)]" : "nonexistent location"]"
#define ADMIN_VERBOSEJMP(src) "[src ? "[AREACOORD(src)] [ADMIN_JMP(src)]" : "nonexistent location"]"
#define ADMIN_INDIVIDUALLOG(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];individuallog=[REF(user)]'>LOGS</a>)"

#define AHELP_ACTIVE 1
#define AHELP_CLOSED 2
#define AHELP_RESOLVED 3

#define ROUNDSTART_LOGOUT_REPORT_TIME 10 MINUTES //Amount of time (in deciseconds) after the rounds starts, that the player disconnect report is issued.

#define SPAM_TRIGGER_TIME_PERIOD 10 SECONDS //The time period for checking spammy messages
#define SPAM_TRIGGER_WEIGHT_FORMULA(message) length_char(message) / 200
#define SPAM_TRIGGER_WARNING 7	//Number of messages required per the time period before the spam-prevention will warn you
#define SPAM_TRIGGER_AUTOMUTE 10	//Number of messages required per the time period before the spam-prevention will automute you
#define SPAM_TRIGGER_WEIGHT_WARNING 2.5 //The weight required per the time period before the spam-prevention will warn you
#define SPAM_TRIGGER_WEIGHT_AUTOMUTE 4 //The weight required per the time period before the spam-prevention will automute you

#define MAX_LENGTH_REQ_REASON 250

///Max length of a keypress command before it's considered to be a forged packet/bogus command
#define MAX_KEYPRESS_COMMANDLENGTH 16
///Maximum keys that can be bound to one button
#define MAX_COMMANDS_PER_KEY 5
///Max amount of keypress messages per second over two seconds before client is autokicked
#define MAX_KEYPRESS_AUTOKICK 50
///Length of held key buffer
#define HELD_KEY_BUFFER_LENGTH 15
///Maximum keys allowed per keybind
#define MAX_KEYS_PER_KEYBIND 3

/// Shown on top of policy verb window
#define POLICY_VERB_HEADER "policy_verb_header"

#define STICKYBAN_DB_CACHE_TIME 10 SECONDS
#define STICKYBAN_ROGUE_CHECK_TIME 5

#define EXTERNALREPLYCOUNT 2
#define IRC_STATUS_THROTTLE 5

#define IRC_AHELP_USAGE "Usage: ticket <close|resolve|icissue|reject|reopen \[ticket #\]|list>"


#define MAX_ADMINBANS_PER_ADMIN 1
#define MAX_ADMINBANS_PER_HEADMIN 10


#define POLLTYPE_OPTION "OPTION"
#define POLLTYPE_TEXT "TEXT"
#define POLLTYPE_RATING "NUMVAL"
#define POLLTYPE_MULTI "MULTICHOICE"
#define POLLTYPE_IRV "IRV"


#define APICKER_CLIENT "Key"
#define APICKER_MOB "Mob"
#define APICKER_LIVING "Living Mob"
#define APICKER_AREA "Area"
#define APICKER_TURF "Turf"
#define APICKER_COORDS "Coords"
#define APICKER_PLAYER "Cliented Mob"

#define ADMIN_SPAWN_CAP 100

// LOG BROWSE TYPES
#define BROWSE_ROOT_ALL_LOGS 1
#define BROWSE_ROOT_CURRENT_LOGS 2

/// for asay pings, this is the index in the return list for [/proc/check_admin_pings] that contains the message modified with underlines for the spotted names
#define ADMINSAY_PING_UNDERLINE_NAME_INDEX "!underlined_names"
