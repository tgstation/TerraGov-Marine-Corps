///The base healing number for a defibrillator.
#define DEFIBRILLATOR_BASE_HEALING_VALUE 8
///The formula for healing with a defibrillator. If `skill_input` in this macro is less than `SKILL_MEDICAL_PRACTICED`, this will be 8.
#define DEFIBRILLATOR_HEALING_TIMES_SKILL(skill_input) (skill_input < SKILL_MEDICAL_PRACTICED ? 8 : DEFIBRILLATOR_BASE_HEALING_VALUE * skill_input * 0.5)

// Defibrillation outcomes, used in human_defines.dm
///Ready to defibrillate
#define DEFIB_POSSIBLE (1<<0)
///Missing a head
#define DEFIB_FAIL_DECAPITATED (1<<1)
///They have TRAIT_UNDEFIBBABLE
#define DEFIB_FAIL_BRAINDEAD (1<<2)
///Catatonic/NPC, a colonist or something
#define DEFIB_FAIL_NPC (1<<3)
///Doesn't have the required organs to sustain life OR heart is broken
#define DEFIB_FAIL_BAD_ORGANS (1<<4)
///Too much damage
#define DEFIB_FAIL_TOO_MUCH_DAMAGE (1<<5)
///No client, typically just a human who moved out of their body mid defib
#define DEFIB_FAIL_CLIENT_MISSING (1<<6)

///Revival states that strictly entail permadeath. These will prevent defibrillation
#define DEFIB_PERMADEATH_STATES (DEFIB_FAIL_DECAPITATED | DEFIB_FAIL_BRAINDEAD | DEFIB_FAIL_NPC)
///Revival states that don't necessarily mean permadeath, but prevent revival temporarily
#define DEFIB_RELAXED_REVIVABLE_STATES (DEFIB_FAIL_BAD_ORGANS | DEFIB_FAIL_TOO_MUCH_DAMAGE | DEFIB_FAIL_CLIENT_MISSING | DEFIB_POSSIBLE)
///Revival states that strictly don't prevent revival
#define DEFIB_STRICT_REVIVABLE_STATES (DEFIB_FAIL_CLIENT_MISSING | DEFIB_POSSIBLE)
