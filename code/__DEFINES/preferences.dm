//Do not decrease this unles you know what you're doing.
#define MAX_SAVE_SLOTS 10

#define AGE_MIN 17
#define AGE_MAX 85

#define GET_RANDOM_JOB 0
#define BE_MARINE 1
#define RETURN_TO_LOBBY 2

#define MAX_GEAR_COST 5 //Custom loadout point limit.

#define BE_ALIEN		(1<<0)
#define BE_QUEEN		(1<<1)
#define BE_SURVIVOR		(1<<2)
#define BE_DEATHMATCH	(1<<3)
#define BE_SQUAD_STRICT (1<<4)

#define BE_SPECIAL_DEFAULT (BE_ALIEN|BE_DEATHMATCH)


#define GHOST_HUD_MED 	(1<<0)
#define GHOST_HUD_SEC 	(1<<1)
#define GHOST_HUD_SQUAD	(1<<2)
#define GHOST_HUD_XENO	(1<<3)
#define GHOST_HUD_ORDER	(1<<4)

#define TOGGLES_GHOSTHUD_DEFAULT (GHOST_HUD_MED|GHOST_HUD_SQUAD|GHOST_HUD_XENO|GHOST_HUD_ORDER)


#define SOUND_ADMINHELP	(1<<0)
#define SOUND_MIDI		(1<<1)
#define SOUND_AMBIENCE	(1<<2)
#define SOUND_LOBBY		(1<<3)

#define TOGGLES_SOUND_DEFAULT (SOUND_ADMINHELP|SOUND_MIDI|SOUND_AMBIENCE|SOUND_LOBBY)


#define CHAT_OOC			(1<<0)
#define CHAT_DEAD			(1<<1)
#define CHAT_GHOSTEARS		(1<<2)
#define CHAT_GHOSTSIGHT		(1<<3)
#define CHAT_PRAYER			(1<<4)
#define CHAT_RADIO			(1<<5)
#define CHAT_ATTACKLOGS		(1<<6)
#define CHAT_DEBUGLOGS		(1<<7)
#define CHAT_GHOSTRADIO 	(1<<8)
#define CHAT_FFATTACKLOGS 	(1<<9)
#define CHAT_ENDROUNDLOGS	(1<<10)
#define CHAT_GHOSTHIVEMIND	(1<<11)
#define CHAT_STATISTICS		(1<<12)
#define CHAT_LOOC			(1<<13)

#define TOGGLES_CHAT_DEFAULT (CHAT_OOC|CHAT_DEAD|CHAT_GHOSTEARS|CHAT_GHOSTSIGHT|CHAT_PRAYER|CHAT_RADIO|CHAT_DEBUGLOGS|CHAT_GHOSTRADIO|CHAT_FFATTACKLOGS|CHAT_GHOSTHIVEMIND|CHAT_STATISTICS|CHAT_LOOC)


#define CITIZENSHIP_CHOICES list(\
	"TerraGov",\
	"Limited Service (Colony)",\
	"Green Card (Foreign)"\
	)


#define CORP_RELATIONS list(\
	"Loyal",\
	"Supportive",\
	"Neutral",\
	"Skeptical",\
	"Opposed"\
	)


#define RELIGION_CHOICES list(\
    "Christianity (Protestant)",\
    "Christianity (Catholic)",\
    "Christianity (Orthodox)",\
    "Christianity (Mormonism)",\
    "Christianity (Other)",\
    "Judaism",\
    "Islam (Shia)",\
    "Islam (Sunni)",\
    "Buddhism",\
    "Hinduism",\
    "Sikhism",\
    "Shintoism",\
    "Wiccanism",\
    "Paganism (Wicca)",\
    "Minor Religion",\
    "Atheism",\
    "None",\
    "Other"\
	)


#define SELECTABLE_SQUADS list(\
	"Alpha",\
	"Bravo",\
	"Charlie",\
	"Delta",\
	"None"\
	)


#define UI_STYLES list(\
	"Midnight",\
	"Orange",\
	"old",\
	"White",\
	"Slimecore",\
	"Operative",\
	"Clockwork"\
	)

#define BE_SPECIAL_FLAGS list(\
	"Xenomorph" = BE_ALIEN,\
	"Xeno Queen" = BE_QUEEN,\
	"Survivor" = BE_SURVIVOR,\
	"End of Round Deathmatch" = BE_DEATHMATCH,\
	"Prefer Squad over Role" = BE_SQUAD_STRICT\
	)