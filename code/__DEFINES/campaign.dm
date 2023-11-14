///Number of victory points before a faction wins a campaign
#define CAMPAIGN_MAX_VICTORY_POINTS 12

///Respawn time in campaign mode
#define CAMPAIGN_RESPAWN_TIME 2 MINUTES

///stats/points/etc recorded by faction
#define MISSION_SELECTION_ALLOWED  (1<<0)
///How long after a mission ends players are returned to base
#define AFTER_MISSION_TELEPORT_DELAY 10 SECONDS
///How long after a mission ends a new leader is picked
#define AFTER_MISSION_LEADER_DELAY 1 MINUTES
///Standard amount of missions for a faction to have
#define CAMPAIGN_STANDARD_MISSION_QUANTITY 3
///Attrition bonus for losing
#define CAMPAIGN_LOSS_BONUS 0.15
///Max losing bonus
#define CAMPAIGN_MAX_LOSS_BONUS 0.45

//mission defines
///Mission has not been loaded
#define MISSION_STATE_NEW "mission state new"
///Mission loaded but not yet active
#define MISSION_STATE_LOADED "mission state loaded"
///Mission actively running
#define MISSION_STATE_ACTIVE "mission state active"
///Mission ended
#define MISSION_STATE_FINISHED "mission state finished"

#define MISSION_OUTCOME_MAJOR_VICTORY "major victory"
#define MISSION_OUTCOME_MINOR_VICTORY "minor victory"
#define MISSION_OUTCOME_DRAW "draw"
#define MISSION_OUTCOME_MINOR_LOSS "minor loss"
#define MISSION_OUTCOME_MAJOR_LOSS "major loss"

#define MISSION_STARTING_FACTION "mission_starting_faction"
#define MISSION_HOSTILE_FACTION "mission_hostile_faction"
//Attackers are usually the starting faction, but not always
#define MISSION_ATTACKING_FACTION "mission_attacking_faction"
#define MISSION_DEFENDING_FACTION "mission_defending_faction"

#define MISSION_DISALLOW_DROPPODS (1<<0)
#define MISSION_DISALLOW_FIRESUPPORT (1<<1)
#define MISSION_CRITICAL (1<<2)
#define MISSION_DISALLOW_TELEPORT (1<<3)

#define MISSION_CODE_BLUE "blue"
#define MISSION_CODE_RED "red"
#define MISSION_CODE_GREEN "green"
