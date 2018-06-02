
/*Access levels. Changed into defines, since that's what they should be.
It's best not to mess with the numbers of the regular access levels because
most of them are tied into map-placed objects. This should be reworked in the future.*/
//WE NEED TO REWORK THIS ONE DAY.  Access levels make me cry - Apophis
#define ACCESS_MARINE_COMMANDER 	1
#define ACCESS_MARINE_LOGISTICS 	2
#define ACCESS_MARINE_BRIG 			3
#define ACCESS_MARINE_ARMORY 		4
#define ACCESS_MARINE_CMO 			5
#define ACCESS_MARINE_CE 			6
#define ACCESS_MARINE_ENGINEERING 	7
#define ACCESS_MARINE_MEDBAY 		8
#define ACCESS_MARINE_PREP 			9
#define ACCESS_MARINE_MEDPREP 		10
#define ACCESS_MARINE_ENGPREP 		11
#define ACCESS_MARINE_LEADER 		12
#define ACCESS_MARINE_SPECPREP 		13
#define ACCESS_MARINE_RESEARCH 		14
#define ACCESS_MARINE_SMARTPREP		25

#define ACCESS_MARINE_ALPHA 		15
#define ACCESS_MARINE_BRAVO 		16
#define ACCESS_MARINE_CHARLIE 		17
#define ACCESS_MARINE_DELTA 		18

#define ACCESS_MARINE_BRIDGE 		19
#define ACCESS_MARINE_CHEMISTRY 	20
#define ACCESS_MARINE_CARGO 		21
#define ACCESS_MARINE_DROPSHIP 		22
#define ACCESS_MARINE_PILOT 		23
#define ACCESS_MARINE_WO			24
#define ACCESS_MARINE_RO			26

//Surface access levels
#define ACCESS_CIVILIAN_PUBLIC 		100
#define ACCESS_CIVILIAN_LOGISTICS 	101
#define ACCESS_CIVILIAN_ENGINEERING 102
#define ACCESS_CIVILIAN_RESEARCH	103

//Special access levels. Should be alright to modify these.
#define ACCESS_WY_PMC_GREEN 		180
#define ACCESS_WY_PMC_ORANGE	 	181
#define ACCESS_WY_PMC_RED			182
#define ACCESS_WY_PMC_BLACK			183
#define ACCESS_WY_PMC_WHITE			184
#define ACCESS_WY_CORPORATE 		200
#define ACCESS_ILLEGAL_PIRATE 		201

//Temporary until I turn these into defines/bitflags and develop proper IF tagging.
#define ACCESS_IFF_MARINE 			998
#define ACCESS_IFF_PMC 				999
//=================================================