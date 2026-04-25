///The base healing number for a defibrillator.
#define DEFIBRILLATOR_BASE_HEALING_VALUE 8

///How often you can defib someone
#define DEFIBRILLATOR_COOLDOWN 1 SECONDS
/**
 * A macro for healing with a defibrillator.
 *
 * * `skill_input` - What to multiply `healing_value` by. If this is less than `SKILL_MEDICAL_PRACTICED`, will be 8.
 * * `healing_value` - The number to multiply. Should be `DEFIBRILLATOR_BASE_HEALING_VALUE` unless you want to change the base healing value
 */
#define DEFIBRILLATOR_HEALING_TIMES_SKILL(skill_input, healing_value) (skill_input < SKILL_MEDICAL_PRACTICED ? 8 : healing_value * skill_input * 0.5)

// Defibrillation outcomes, used in human_defines.dm
///Ready to defibrillate
#define DEFIB_POSSIBLE (1<<0)
///Missing a head
#define DEFIB_FAIL_DECAPITATED (1<<1)
///They have TRAIT_UNDEFIBBABLE
#define DEFIB_FAIL_BRAINDEAD (1<<2)
///Doesn't have the required organs to sustain life OR heart is broken
#define DEFIB_FAIL_BAD_ORGANS (1<<3)
///Too much damage
#define DEFIB_FAIL_TOO_MUCH_DAMAGE (1<<4)

///Revival states that strictly entail permadeath. These will prevent defibrillation
#define DEFIB_PREVENT_REVIVE_STATES (DEFIB_FAIL_DECAPITATED | DEFIB_FAIL_BRAINDEAD)
///All defibrillation outcomes that leave a revivable patient
#define DEFIB_REVIVABLE_STATES (DEFIB_FAIL_BAD_ORGANS | DEFIB_FAIL_TOO_MUCH_DAMAGE | DEFIB_POSSIBLE)
