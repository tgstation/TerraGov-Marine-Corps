//attack visual effects
#define ATTACK_EFFECT_PUNCH "punch"
#define ATTACK_EFFECT_KICK "kick"
#define ATTACK_EFFECT_SMASH "smash"
#define ATTACK_EFFECT_CLAW pick("claw","claw2")
#define ATTACK_EFFECT_DISARM "disarm"
#define ATTACK_EFFECT_DISARM2 "disarm_2"
#define ATTACK_EFFECT_BITE "bite"
#define ATTACK_EFFECT_MECHFIRE "mech_fire"
#define ATTACK_EFFECT_MECHTOXIN "mech_toxin"
#define ATTACK_EFFECT_BOOP "boop" //Honk
#define ATTACK_EFFECT_GRAB "grab"
#define ATTACK_EFFECT_REDSLASH list("redslash","redslash2")
#define ATTACK_EFFECT_REDSTAB "redstab"
#define ATTACK_EFFECT_DRAIN_STING "drain_sting"
#define ATTACK_EFFECT_YELLOWPUNCH "yellowpunch"
#define ATTACK_EFFECT_WEAK_PUNCH "weak_punch"
#define ATTACK_EFFECT_LASERSWORD pick("laser_slash","laser_slash2")

//Damage flag defines //
/// Involves a melee attack or a thrown object.
#define MELEE "melee"
/// Involves a solid projectile.
#define BULLET "bullet"
/// Involves a laser.
#define LASER "laser"
/// Involves an EMP or energy-based projectile.
#define ENERGY "energy"
/// Involves a shockwave, usually from an explosion.
#define BOMB "bomb"
/// Involved in checking whether a disease can infect or spread. Also involved in xeno neurotoxin.
#define BIO "bio"
/// Involves fire or temperature extremes.
#define FIRE "fire"
/// Involves corrosive substances.
#define ACID "acid"

//the define for visible message range in combat
#define COMBAT_MESSAGE_RANGE 3
#define DEFAULT_MESSAGE_RANGE 7

//Embedded objects
#define EMBEDDED_DEL_ON_HOLDER_DEL (1<<0)
#define EMBEDDED_CAN_BE_YANKED_OUT (1<<1)

#define EMBED_FLAGS (EMBEDDED_CAN_BE_YANKED_OUT)	//Default flags.
#define EMBED_CHANCE 3	//Percentage chance for an object to embed into somebody when thrown (if it's sharp).
#define EMBED_PROCESS_CHANCE 4	//Percentage chance to deal damage or whatever set behavior per victim's move.
#define EMBED_LIMB_DAMAGE 2	//Damage to deal to victim's limbs.
#define EMBED_BODY_DAMAGE 10	//Damage to deal to victims without limbs (xenos), to their body.
#define EMBEDDED_UNSAFE_REMOVAL_TIME 8 SECONDS	//Total removal time.
#define EMBEDDED_UNSAFE_REMOVAL_DMG_MULTIPLIER 8	//Coefficient of multiplication for the damage the item does when removed without a surgery (this*((embed_limb_damage or embed_body_damage)))
#define EMBEDDED_FALL_CHANCE 5	//Percentage chance for an embeddedd object fall out of the victim on its own, each process.
#define EMBEDDED_FALL_DMG_MULTIPLIER 3	//Coefficient of multiplication for the damage the item does when it falls out (this*(embed_limb_damage or embed_body_damage))

///Melee damage
#define COMBAT_MELEE_ATTACK "melee_attack"
///Projectile damage
#define COMBAT_PROJ_ATTACK "proj_attack"
///Potentially hostile interactions that aren't actually damage, such as disarms or grabs
#define COMBAT_TOUCH_ATTACK "touch_attack"

///Can be toggled on and off
#define SHIELD_TOGGLE (1<<0)
///Shield works by % chance to simply block the attack entirely, instead of normal reductive calc
#define SHIELD_PURE_BLOCKING (1<<1)
///Transfers damage to parent's integrity
#define SHIELD_PARENT_INTEGRITY (1<<2)

#define EXPLODE_NONE 0
#define EXPLODE_DEVASTATE 1
#define EXPLODE_HEAVY 2
#define EXPLODE_LIGHT 3
#define EXPLODE_WEAK 4

#define EMP_NONE 0
#define EMP_DEVASTATE 1
#define EMP_HEAVY 2
#define EMP_LIGHT 3
#define EMP_WEAK 4

///Xenomorph accuracy
#define XENO_DEFAULT_ACCURACY 70
