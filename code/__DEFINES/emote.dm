/// Emote can be received by the non-blind
#define EMOTE_TYPE_VISIBLE 1
/// Emote can be received by the non-deaf
#define EMOTE_TYPE_AUDIBLE 2
/// Emote will be received by everyone who can technically see the emotee
#define EMOTE_TYPE_IMPORTANT 3

/// For emotes with sound, this emote will vary the pitch of its sound
#define EMOTE_VARY (1<<0)
/// This emote can't be performed intentionally
#define EMOTE_FORCED_AUDIO (1<<1)
/// This emote will bypass muzzles if it's [EMOTE_TYPE_AUDIBLE]
#define EMOTE_MUZZLE_IGNORE (1<<2)
/// This emote can't be performed while restrained
#define EMOTE_RESTRAINT_CHECK (1<<3)
/// This emote can't be performed by a keybind
#define NO_KEYBIND (1<<4)
/// This emote requires a user to have arms
#define EMOTE_ARMS_CHECK (1<<5)
/// This emote requires an item held in a user's active hand
#define EMOTE_ACTIVE_ITEM (1<<6)
