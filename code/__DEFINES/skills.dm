
// Skills
#define SKILL_LEVEL_NONE 0
#define SKILL_LEVEL_NOVICE 1 //basic
#define SKILL_LEVEL_APPRENTICE 2 //novice
#define SKILL_LEVEL_JOURNEYMAN 3 //skilled
#define SKILL_LEVEL_EXPERT 4 //expert
#define SKILL_LEVEL_MASTER 5 //master
#define SKILL_LEVEL_LEGENDARY 6 //legendary

#define SKILL_EXP_NOVICE 100
#define SKILL_EXP_APPRENTICE 250
#define SKILL_EXP_JOURNEYMAN 500
#define SKILL_EXP_EXPERT 900
#define SKILL_EXP_MASTER 1500
#define SKILL_EXP_LEGENDARY 2500

// Gets the reference for the skill type that was given
#define GetSkillRef(A) (SSskills.all_skills[A])
