
//These are all the different status effects. Use the paths for each effect in the defines.

#define STATUS_EFFECT_MULTIPLE 0 //if it allows multiple instances of the effect

#define STATUS_EFFECT_UNIQUE 1 //if it allows only one, preventing new instances

#define STATUS_EFFECT_REPLACE 2 //if it allows only one, but new instances replace

#define STATUS_EFFECT_REFRESH 3 // if it only allows one, and new instances just instead refresh the timer

///////////
// BUFFS //
///////////

#define STATUS_EFFECT_GUN_SKILL_ACCURACY_BUFF /datum/status_effect/stacking/gun_skill/accuracy/buff // Increases the accuracy of the mob

#define STATUS_EFFECT_GUN_SKILL_SCATTER_BUFF /datum/status_effect/stacking/gun_skill/scatter/buff // Increases the scatter of the mob

#define STATUS_EFFECT_XENO_ESSENCE_LINK /datum/status_effect/stacking/essence_link

#define STATUS_EFFECT_XENO_SALVE_REGEN /datum/status_effect/salve_regen

#define STATUS_EFFECT_XENO_ENHANCEMENT /datum/status_effect/drone_enhancement

#define STATUS_EFFECT_XENO_REJUVENATE /datum/status_effect/xeno_rejuvenate

#define STATUS_EFFECT_XENO_PSYCHIC_LINK /datum/status_effect/xeno_psychic_link

#define STATUS_EFFECT_XENO_CARNAGE /datum/status_effect/xeno_carnage

#define STATUS_EFFECT_XENO_FEAST /datum/status_effect/xeno_feast

#define STATUS_EFFECT_RESIN_JELLY_COATING /datum/status_effect/resin_jelly_coating

#define STATUS_EFFECT_PLASMA_SURGE /datum/status_effect/plasma_surge

#define STATUS_EFFECT_HEALING_INFUSION /datum/status_effect/healing_infusion

#define STATUS_EFFECT_DRAIN_SURGE /datum/status_effect/drain_surge

#define STATUS_EFFECT_MINDMEND /datum/status_effect/mindmeld

#define STATUS_EFFECT_REKNIT_FORM /datum/status_effect/reknit_form
/////////////
// DEBUFFS //
/////////////

#define STATUS_EFFECT_STAGGER /datum/status_effect/incapacitating/stagger //reduces human gun damage or impairs xeno ability use

#define STATUS_EFFECT_STUN /datum/status_effect/incapacitating/stun //the affected is unable to move or use items

#define STATUS_EFFECT_KNOCKDOWN /datum/status_effect/incapacitating/knockdown //the affected is unable to stand up

#define STATUS_EFFECT_IMMOBILIZED /datum/status_effect/incapacitating/immobilized //the affected is unable to move

#define STATUS_EFFECT_PARALYZED /datum/status_effect/incapacitating/paralyzed //the affected is unable to move, use items, or stand up.

#define STATUS_EFFECT_UNCONSCIOUS /datum/status_effect/incapacitating/unconscious //the affected is unconscious

#define STATUS_EFFECT_SLEEPING /datum/status_effect/incapacitating/sleeping //the affected is asleep

#define STATUS_EFFECT_ADMINSLEEP /datum/status_effect/incapacitating/adminsleep //the affected is admin slept

#define STATUS_EFFECT_CONFUSED /datum/status_effect/incapacitating/confused // random direction chosen when trying to move

#define STATUS_EFFECT_GUN_SKILL_ACCURACY_DEBUFF /datum/status_effect/gun_skill/accuracy/debuff // Decreases the accuracy of the mob

#define STATUS_EFFECT_GUN_SKILL_SCATTER_DEBUFF /datum/status_effect/gun_skill/scatter/debuff // Decreases the scatter of the mob

#define STATUS_EFFECT_MUTED /datum/status_effect/mute //Mutes the affected mob

#define STATUS_EFFECT_IRRADIATED /datum/status_effect/incapacitating/irradiated //the affected has been irradiated, harming them over time

#define STATUS_EFFECT_INTOXICATED /datum/status_effect/stacking/intoxicated //Damage over time

#define STATUS_EFFECT_REPAIR_MODE /datum/status_effect/incapacitating/repair_mode //affected is blinded and stunned, but heals over time
///damage and sunder over time
#define STATUS_EFFECT_MELTING /datum/status_effect/stacking/melting
///damage over time
#define STATUS_EFFECT_MICROWAVE /datum/status_effect/stacking/microwave
///armor reduction
#define STATUS_EFFECT_SHATTER /datum/status_effect/shatter

/////////////
// NEUTRAL //
/////////////

// none for now

// Stasis helpers

#define IS_IN_STASIS(mob) (mob.has_status_effect(STATUS_EFFECT_STASIS))
