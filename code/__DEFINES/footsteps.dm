#define FOOTSTEP_WOOD "wood"
#define FOOTSTEP_FLOOR "floor"
#define FOOTSTEP_PLATING "plating"
#define FOOTSTEP_CARPET "carpet"
#define FOOTSTEP_SAND "sand"
#define FOOTSTEP_GRASS "grass"
#define FOOTSTEP_WATER "water"
#define FOOTSTEP_LAVA "lava"
#define FOOTSTEP_MUD "mud"
#define FOOTSTEP_STONE "stone"
#define FOOTSTEP_SHALLOW "shallow"

//barefoot sounds
#define FOOTSTEP_WOOD_BAREFOOT "woodbarefoot"
#define FOOTSTEP_WOOD_CLAW "woodclaw"
#define FOOTSTEP_HARD_BAREFOOT "hardbarefoot"
#define FOOTSTEP_SOFT_BAREFOOT "softbarefoot"
#define FOOTSTEP_HARD_CLAW "hardclaw"
#define FOOTSTEP_CARPET_BAREFOOT "carpetbarefoot"
//misc footstep sounds
#define FOOTSTEP_GENERIC_HEAVY "heavy"

//footstep mob defines
#define FOOTSTEP_MOB_CLAW 1
#define FOOTSTEP_MOB_BAREFOOT 2
#define FOOTSTEP_MOB_HEAVY 3
#define FOOTSTEP_MOB_SHOE 4
#define FOOTSTEP_MOB_HUMAN 5 //Warning: Only works on /mob/living/carbon/human
#define FOOTSTEP_MOB_SLIME 6

/*

id = list(
list(sounds),
base volume,
extra range addition
)


*/

GLOBAL_LIST_INIT(footstep, list(
	FOOTSTEP_WOOD = list(list(
		'sound/foley/footsteps/FTWOO_A1.ogg',
		'sound/foley/footsteps/FTWOO_A2.ogg',
		'sound/foley/footsteps/FTWOO_A3.ogg',
		'sound/foley/footsteps/FTWOO_A4.ogg'), 100, 0),
	FOOTSTEP_FLOOR = list(list(
		'sound/foley/footsteps/FTTIL_A1.ogg',
		'sound/foley/footsteps/FTTIL_A2.ogg',
		'sound/foley/footsteps/FTTIL_A3.ogg',
		'sound/foley/footsteps/FTTIL_A4.ogg'), 100, 0),
	FOOTSTEP_PLATING = list(list(
		'sound/foley/footsteps/FTMET_A1.ogg',
		'sound/foley/footsteps/FTMET_A2.ogg',
		'sound/foley/footsteps/FTMET_A3.ogg',
		'sound/foley/footsteps/FTMET_A4.ogg'), 100, 0),
	FOOTSTEP_CARPET = list(list(
		'sound/foley/footsteps/FTCAR_A1.ogg',
		'sound/foley/footsteps/FTCAR_A2.ogg',
		'sound/foley/footsteps/FTCAR_A3.ogg',
		'sound/foley/footsteps/FTCAR_A4.ogg'), 25, 0),
	FOOTSTEP_SAND = list(list(
		'sound/foley/footsteps/FTDIR_A1.ogg',
		'sound/foley/footsteps/FTDIR_A2.ogg',
		'sound/foley/footsteps/FTDIR_A3.ogg',
		'sound/foley/footsteps/FTDIR_A4.ogg'), 25, 0),
	FOOTSTEP_GRASS = list(list(
		'sound/foley/footsteps/FTGRA_A1.ogg',
		'sound/foley/footsteps/FTGRA_A2.ogg',
		'sound/foley/footsteps/FTGRA_A3.ogg',
		'sound/foley/footsteps/FTGRA_A4.ogg'), 25, 0),
	FOOTSTEP_WATER = list(list(
		'sound/foley/footsteps/FTWAT_1.ogg',
		'sound/foley/footsteps/FTWAT_2.ogg',
		'sound/foley/footsteps/FTWAT_3.ogg',
		'sound/foley/footsteps/FTWAT_4.ogg'), 100, 0),
	FOOTSTEP_SHALLOW = list(list(
		'sound/foley/footsteps/FTSHAL (1).ogg',
		'sound/foley/footsteps/FTSHAL (2).ogg',
		'sound/foley/footsteps/FTSHAL (3).ogg',
		'sound/foley/footsteps/FTSHAL (4).ogg',
		'sound/foley/footsteps/FTSHAL (5).ogg'), 100, 0),
	FOOTSTEP_LAVA = list(list(
		'sound/blank.ogg'), 100, 0),
	FOOTSTEP_STONE = list(list(
		'sound/foley/footsteps/FTROC_A1.ogg',
		'sound/foley/footsteps/FTROC_A2.ogg',
		'sound/foley/footsteps/FTROC_A3.ogg',
		'sound/foley/footsteps/FTROC_A4.ogg'), 100, 0),
	FOOTSTEP_MUD = list(list(
		'sound/foley/footsteps/FTMUD (1).ogg',
		'sound/foley/footsteps/FTMUD (2).ogg',
		'sound/foley/footsteps/FTMUD (3).ogg',
		'sound/foley/footsteps/FTMUD (4).ogg',
		'sound/foley/footsteps/FTMUD (5).ogg'), 100, 0),
))
//bare footsteps lists
GLOBAL_LIST_INIT(barefootstep, list(
	FOOTSTEP_HARD_BAREFOOT = list(list(
		'sound/foley/footsteps/hardbarefoot (1).ogg',
		'sound/foley/footsteps/hardbarefoot (2).ogg',
		'sound/foley/footsteps/hardbarefoot (3).ogg'), 25, 0),
	FOOTSTEP_SOFT_BAREFOOT = list(list(
		'sound/foley/footsteps/softbarefoot (1).ogg',
		'sound/foley/footsteps/softbarefoot (2).ogg',
		'sound/foley/footsteps/softbarefoot (3).ogg'), 25, 0),
	FOOTSTEP_WATER = list(list(
		'sound/foley/footsteps/FTWAT_1.ogg',
		'sound/foley/footsteps/FTWAT_2.ogg',
		'sound/foley/footsteps/FTWAT_3.ogg',
		'sound/foley/footsteps/FTWAT_4.ogg'), 100, 0),
	FOOTSTEP_SHALLOW = list(list(
		'sound/foley/footsteps/FTSHAL (1).ogg',
		'sound/foley/footsteps/FTSHAL (2).ogg',
		'sound/foley/footsteps/FTSHAL (3).ogg',
		'sound/foley/footsteps/FTSHAL (4).ogg',
		'sound/foley/footsteps/FTSHAL (5).ogg'), 100, 0),
	FOOTSTEP_LAVA = list(list(
		'sound/blank.ogg',
		'sound/blank.ogg',
		'sound/blank.ogg'), 100, 0),
	FOOTSTEP_MUD = list(list(
		'sound/foley/footsteps/FTMUD (1).ogg',
		'sound/foley/footsteps/FTMUD (2).ogg',
		'sound/foley/footsteps/FTMUD (3).ogg',
		'sound/foley/footsteps/FTMUD (4).ogg',
		'sound/foley/footsteps/FTMUD (5).ogg'), 100, 0),
))

//claw footsteps lists
GLOBAL_LIST_INIT(clawfootstep, list(
	FOOTSTEP_WOOD_CLAW = list(list(
		'sound/blank.ogg'), 90, 1),
	FOOTSTEP_HARD_CLAW = list(list(
		'sound/blank.ogg'), 90, 1),
	FOOTSTEP_CARPET_BAREFOOT = list(list(
		'sound/blank.ogg'), 25, -2),
	FOOTSTEP_SAND = list(list(
		'sound/blank.ogg'), 25, 0),
	FOOTSTEP_GRASS = list(list(
		'sound/blank.ogg'), 25, 0),
	FOOTSTEP_WATER = list(list(
		'sound/blank.ogg'), 50, 1),
	FOOTSTEP_LAVA = list(list(
		'sound/blank.ogg'), 50, 0),
))

//heavy footsteps list
GLOBAL_LIST_INIT(heavyfootstep, list(
	FOOTSTEP_GENERIC_HEAVY = list(list(
		'sound/foley/footsteps/bigwalk (1).ogg',
		'sound/foley/footsteps/bigwalk (2).ogg',
		'sound/foley/footsteps/bigwalk (3).ogg',
		'sound/foley/footsteps/bigwalk (4).ogg'), 100, 0),
	FOOTSTEP_WATER = list(list(
		'sound/foley/footsteps/FTWAT_1.ogg',
		'sound/foley/footsteps/FTWAT_2.ogg',
		'sound/foley/footsteps/FTWAT_3.ogg',
		'sound/foley/footsteps/FTWAT_4.ogg'), 100, 0),
	FOOTSTEP_SHALLOW = list(list(
		'sound/foley/footsteps/FTSHAL (1).ogg',
		'sound/foley/footsteps/FTSHAL (2).ogg',
		'sound/foley/footsteps/FTSHAL (3).ogg',
		'sound/foley/footsteps/FTSHAL (4).ogg',
		'sound/foley/footsteps/FTSHAL (5).ogg'), 100, 0),
	FOOTSTEP_LAVA = list(list(
		'sound/blank.ogg'), 100, 0),
	FOOTSTEP_MUD = list(list(
		'sound/foley/footsteps/FTMUD (1).ogg',
		'sound/foley/footsteps/FTMUD (2).ogg',
		'sound/foley/footsteps/FTMUD (3).ogg',
		'sound/foley/footsteps/FTMUD (4).ogg',
		'sound/foley/footsteps/FTMUD (5).ogg'), 100, 0),
))

