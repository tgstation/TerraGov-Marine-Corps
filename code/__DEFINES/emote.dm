#define EMOTE_VISIBLE 1
#define EMOTE_AUDIBLE 2

#define EMOTE_VARY (1<<0) //vary the pitch
#define EMOTE_FORCED_AUDIO (1<<1) //can only code call this event instead of the player.
#define EMOTE_MUZZLE_IGNORE (1<<2) //Will only work if the emote is EMOTE_AUDIBLE
#define EMOTE_RESTRAINT_CHECK (1<<3) //Checks if the mob is restrained before performing the emote
#define NO_KEYBIND (1<<4) //This emote has no keybind
#define EMOTE_ARMS_CHECK (1<<5) //Checks if the mob has arms
