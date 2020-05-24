#define COOLDOWN_CHEW 		"chew"
#define COOLDOWN_PUKE 		"puke"
#define COOLDOWN_POINT 		"point"
#define COOLDOWN_EMOTE		"emote"
#define COOLDOWN_VENTCRAWL	"ventcrawl"
#define COOLDOWN_BUCKLE		"buckle"
#define COOLDOWN_RESIST		"resist"
#define COOLDOWN_ORDER		"order"
#define COOLDOWN_DISPOSAL	"disposal"
#define COOLDOWN_ACID		"acid"
#define COOLDOWN_GUT		"gut"
#define COOLDOWN_ZOOM		"zoom"
#define COOLDOWN_BUMP		"bump"
#define COOLDOWN_ENTANGLE	"entangle"
#define COOLDOWN_NEST		"nest"
#define COOLDOWN_BUMP_ATTACK "bump_attack"
#define COOLDOWN_TASTE		"taste"
#define COOLDOWN_VENTSOUND	"vendsound"

#define COOLDOWN_START(cd_source, cd_index, cd_time) LAZYSET(cd_source.cooldowns, cd_index, addtimer(CALLBACK(GLOBAL_PROC, /proc/end_cooldown, cd_source, cd_index), cd_time))

#define COOLDOWN_CHECK(cd_source, cd_index) LAZYACCESS(cd_source.cooldowns, cd_index)

#define COOLDOWN_END(cd_source, cd_index) LAZYREMOVE(cd_source.cooldowns, cd_index)
