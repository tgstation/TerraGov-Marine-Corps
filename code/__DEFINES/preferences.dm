//Do not decrease this unles you know what you're doing.
#define MAX_SAVE_SLOTS 10

#define AGE_MIN 18
#define AGE_MAX 85

#define BACK_NOTHING 1
#define BACK_BACKPACK 2
#define BACK_SATCHEL 3

#define GET_RANDOM_JOB 0
#define BE_OVERFLOW 1
#define RETURN_TO_LOBBY 2

//Do not decrease this unless you know what you are doing. It can be safely increased
#define CUSTOM_EMOTE_SLOTS 10

#define JOBS_PRIORITY_HIGH 3
#define JOBS_PRIORITY_MEDIUM 2
#define JOBS_PRIORITY_LOW 1
#define JOBS_PRIORITY_NEVER 0

#define MAX_GEAR_COST 5 //Custom loadout point limit.

#define BE_ALIEN (1<<0)
#define BE_QUEEN (1<<1) //Unused
#define BE_SURVIVOR (1<<2) //Unused
#define BE_DEATHMATCH (1<<3)
#define BE_SQUAD_STRICT (1<<4)
#define BE_ALIEN_UNREVIVABLE (1<<5)

#define BE_SPECIAL_DEFAULT (BE_DEATHMATCH)


#define GHOST_HUD_MED (1<<0)
#define GHOST_HUD_SEC (1<<1)
#define GHOST_HUD_SQUAD (1<<2)
#define GHOST_HUD_XENO (1<<3)
#define GHOST_HUD_ORDER (1<<4)

#define TOGGLES_GHOSTHUD_DEFAULT (GHOST_HUD_MED|GHOST_HUD_SQUAD|GHOST_HUD_XENO|GHOST_HUD_ORDER)


#define SOUND_ADMINHELP (1<<0)
#define SOUND_MIDI (1<<1)
#define SOUND_AMBIENCE (1<<2)
#define SOUND_LOBBY (1<<3)
#define SOUND_INSTRUMENTS_OFF (1<<4)
#define SOUND_GAS_MASK (1<<5)
#define SOUND_WEATHER (1<<6)
#define SOUND_NOENDOFROUND (1<<7)

#define TOGGLES_SOUND_DEFAULT (SOUND_ADMINHELP|SOUND_MIDI|SOUND_AMBIENCE|SOUND_LOBBY|SOUND_WEATHER)


#define CHAT_OOC (1<<0)
#define CHAT_DEAD (1<<1)
#define CHAT_GHOSTEARS (1<<2)
#define CHAT_GHOSTSIGHT (1<<3)
#define CHAT_PRAYER (1<<4)
#define CHAT_RADIO (1<<5)
#define CHAT_ATTACKLOGS (1<<6) //Unused
#define CHAT_DEBUGLOGS (1<<7)
#define CHAT_GHOSTRADIO (1<<8)
#define CHAT_FFATTACKLOGS (1<<9)
#define CHAT_ENDROUNDLOGS (1<<10)
#define CHAT_GHOSTHIVEMIND (1<<11)
#define CHAT_STATISTICS (1<<12)
#define CHAT_LOOC (1<<13)

#define TOGGLES_CHAT_DEFAULT (CHAT_OOC|CHAT_DEAD|CHAT_GHOSTEARS|CHAT_GHOSTSIGHT|CHAT_PRAYER|CHAT_RADIO|CHAT_ATTACKLOGS|CHAT_DEBUGLOGS|CHAT_GHOSTRADIO|CHAT_FFATTACKLOGS|CHAT_ENDROUNDLOGS|CHAT_GHOSTHIVEMIND|CHAT_STATISTICS|CHAT_LOOC)

#define DISABLE_DEATHRATTLE (1<<0)
#define DISABLE_ARRIVALRATTLE (1<<1)

#define TOGGLES_DEADCHAT_DEFAULT (NONE)

#define RADIAL_MEDICAL (1<<0)
#define MIDDLESHIFTCLICKING (1<<1)
#define RADIAL_STACKS (1<<2)
#define AUTO_INTERACT_DEPLOYABLES (1<<3)
#define RADIAL_LASERGUNS (1<<4)

#define PARALLAX_INSANE -1 //for show offs
#define PARALLAX_HIGH    0 //default.
#define PARALLAX_MED     1
#define PARALLAX_LOW     2
#define PARALLAX_DISABLE 3 //this option must be the highest number

#define PARALLAX_DELAY_DEFAULT world.tick_lag
#define PARALLAX_DELAY_MED     1
#define PARALLAX_DELAY_LOW     2

#define PIXEL_SCALING_AUTO 0
#define PIXEL_SCALING_1X 1
#define PIXEL_SCALING_1_2X 1.5
#define PIXEL_SCALING_2X 2
#define PIXEL_SCALING_3X 3

#define SCALING_METHOD_NORMAL "normal"
#define SCALING_METHOD_DISTORT "distort"
#define SCALING_METHOD_BLUR "blur"

#define TOGGLES_GAMEPLAY_DEFAULT (RADIAL_MEDICAL|MIDDLESHIFTCLICKING|RADIAL_STACKS|AUTO_INTERACT_DEPLOYABLES|RADIAL_LASERGUNS)

#define CHARACTER_CUSTOMIZATION 1
#define BACKGROUND_INFORMATION 2
#define GEAR_CUSTOMIZATION 3
#define JOB_PREFERENCES 4
#define GAME_SETTINGS 5
#define KEYBIND_SETTINGS 6
#define DRAW_ORDER 7

#define CITIZENSHIP_CHOICES list(\
	"Earth Born",\
	"Sol Born",\
	"Colony Born"\
	)


#define RELIGION_CHOICES list(\
	"Christianity (Catholic)",\
	"Christianity (Protestant, Anglicanism)",\
	"Christianity (Protestant, Baptist)",\
	"Christianity (Protestant, Lutheranism)",\
	"Christianity (Protestant, Calvinism)",\
	"Christianity (Protestant, Methodism)",\
	"Christianity (Protestant, Adventism)",\
	"Christianity (Protestant, Pentecostalism)",\
	"Christianity (Protestant, Other)",\
	"Christianity (Eastern Orthodoxy)",\
	"Christianity (Oriental Orthodoxy)",\
	"Christianity (Non-trinitarian Restorationism, Mormonism)",\
	"Christianity (Non-trinitarian Restorationism, Jehovah's Witnesses)",\
	"Christianity (Non-trinitarian Restorationism, Oneness Pentecostalism)",\
	"Christianity (Other)",\
	"Judaism",\
	"Islam (Shia)",\
	"Islam (Sunni)",\
	"Buddhism",\
	"Hinduism",\
	"Sikhism",\
	"Shintoism",\
	"Adherents of the Machine God",\
	"Paganism",\
	"Other Religion",\
	"Atheism",\
	"None"\
	)


#define SELECTABLE_SQUADS list(\
	"Alpha",\
	"Bravo",\
	"Charlie",\
	"Delta",\
	"None"\
	)

#define SELECTABLE_SQUADS_SOM list(\
	"Zulu",\
	"Yankee",\
	"Xray",\
	"Whiskey",\
	"None"\
	)


#define UI_STYLES list(\
	"Midnight",\
	"Plasmafire",\
	"Retro",\
	"White",\
	"Slimecore",\
	"Operative",\
	"Clockwork",\
	"Glass",\
	"Minimalist",\
	"Holo"\
	)

///The amount of quick equip slots there should have. If someone doesn't have this many slots, their prefs will reset to get the new ones.
///This adds only the buttons, to make the hotkeys usable in-game you need to make a keybind for it.
#define MAX_QUICK_EQUIP_SLOTS 5

///The default Quick equip order list, adding/removing slots from this list will increase the amount of quick equip slots. Update the define above when
#define QUICK_EQUIP_ORDER list(\
	SLOT_S_STORE,\
	SLOT_BELT,\
	SLOT_IN_BOOT,\
	SLOT_L_STORE,\
	SLOT_R_STORE\
	)

#define BE_SPECIAL_FLAGS list(\
	"Latejoin Xenomorph" = BE_ALIEN,\
	"Xenomorph when unrevivable" = BE_ALIEN_UNREVIVABLE,\
	"End of Round Deathmatch" = BE_DEATHMATCH,\
	"Prefer Squad over Role" = BE_SQUAD_STRICT\
	)
