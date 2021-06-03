//When do we start calculating the states
#define START_STATE_CALCULATION 30 MINUTES

//The different states possible
#define STATE_BALANCED "state balanced"
#define XENOS_LOSING "xenos losing"
#define MARINES_LOSING "marines losing"
#define MARINES_DELAYING "marines delaying"
#define XENOS_DELAYING "xenos delaying"

//The threshold to get to those state, after correction from number of players
#define XENOS_DELAYING_THRESHOLD 40
#define XENOS_LOSING_THRESHOLD 20
#define MARINES_LOSING_THRESHOLD -20
#define MARINES_DELAYING_THRESHOLD -40

//How many times we must see the same state to consider the situation a stalemate
#define STALEMATE_THRESHOLD 5

//We consider that marines are FOB hugging if 80% of them are in LZ for 3 consecutive state checks
#define PROPORTION_MARINE_FOB_HUGGING_THRESHOLD 0.8
#define CONSECUTIVE_FOb_HUGGING 3

//The differente gamestate
#define SHUTTERS_CLOSED "shutters closed"
#define GROUNDSIDE "GROUNDSIDE"
#define SHIPSIDE "shipside"

//The weight of each statistics in the state calculator when GROUNDSIDE
#define XENOS_LIFE_WEIGHT -50
#define HUMAN_LIFE_ON_GROUND_WEIGHT 100
#define HUMAN_LIFE_ON_SHIP_WEIGHT 70
#define BURROWED_LARVA_WEIGHT -20
#define REQ_POINTS_WEIGHT 2
#define ELDER_T2_WEIGHT -20
#define ANCIENT_T2_WEIGHT -40
#define ELDER_T3_WEIGHT -40
#define ANCIENT_T3_WEIGHT -80
#define ELDER_QUEEN_WEIGHT -60
#define ANCIENT_QUEEN_WEIGHT -100
#define OB_AVAILABLE_WEIGHT 20
#define SPAWNING_POOL_WEIGHT -600

//The weight of each statistics in the state calculator before shutters drop
#define XENOS_LIFE_WEIGHT_PREGAME -300
#define HUMAN_LIFE_WEIGHT_PREGAME 100

//The weight of each statistics in the state calculator when shipside
#define XENOS_LIFE_WEIGHT_SHIPSIDE -200
#define HUMAN_LIFE_WEIGHT_SHIPSIDE 100

//Minimum proportion of burrowed larvas compared to live xenos for the unbalance join detector to show up
#define TOO_MUCH_BURROWED_PROPORTION 0.2
