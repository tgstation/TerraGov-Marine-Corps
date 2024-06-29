///The base healing number for a defibrillator.
#define DEFIBRILLATOR_BASE_HEALING_VALUE 8
///The formula for healing with a defibrillator. If `skill_input` in this macro is less than `SKILL_MEDICAL_PRACTICED`, this will be 8.
#define DEFIBRILLATOR_HEALING_TIMES_SKILL(skill_input) (skill_input < SKILL_MEDICAL_PRACTICED ? 8 : DEFIBRILLATOR_BASE_HEALING_VALUE * skill_input * 0.5)
