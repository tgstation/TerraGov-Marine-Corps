//attack visual effects
#define ATTACK_EFFECT_PUNCH		"punch"
#define ATTACK_EFFECT_KICK		"kick"
#define ATTACK_EFFECT_SMASH		"smash"
#define ATTACK_EFFECT_CLAW		"claw"
#define ATTACK_EFFECT_DISARM	"disarm"
#define ATTACK_EFFECT_BITE		"bite"
#define ATTACK_EFFECT_MECHFIRE	"mech_fire"
#define ATTACK_EFFECT_MECHTOXIN	"mech_toxin"
#define ATTACK_EFFECT_BOOP		"boop" //Honk

//Embedded objects
#define EMBEDDEED_DEL_ON_HOLDER_DEL	(1<<0)
#define EMBEDDEED_CAN_BE_YANKED_OUT	(1<<1)

#define EMBED_FLAGS								(EMBEDDEED_CAN_BE_YANKED_OUT)	//Default flags.
#define EMBED_CHANCE							3	//Percentage chance for an object to embed into somebody when thrown (if it's sharp).
#define EMBED_PROCESS_CHANCE					4	//Percentage chance to deal damage or whatever set behavior per victim's move.
#define EMBED_LIMB_DAMAGE						2	//Damage to deal to victim's limbs.
#define EMBED_BODY_DAMAGE						10	//Damage to deal to victims without limbs (xenos), to their body.
#define EMBEDDED_UNSAFE_REMOVAL_TIME			8 SECONDS	//Total removal time.
#define EMBEDDED_UNSAFE_REMOVAL_DMG_MULTIPLIER	8	//Coefficient of multiplication for the damage the item does when removed without a surgery (this*((embed_limb_damage or embed_body_damage)))
#define EMBEDDED_FALL_CHANCE					5	//Percentage chance for an embeddedd object fall out of the victim on its own, each process.
#define EMBEDDED_FALL_DMG_MULTIPLIER			3	//Coefficient of multiplication for the damage the item does when it falls out (this*(embed_limb_damage or embed_body_damage))
