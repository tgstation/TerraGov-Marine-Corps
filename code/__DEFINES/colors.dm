//different types of atom colorations
/// Only used by rare effects like greentext coloring mobs and when admins varedit color
#define ADMIN_COLOUR_PRIORITY 1
/// e.g. purple effect of the revenant on a mob, black effect when mob electrocuted
#define TEMPORARY_COLOUR_PRIORITY 2
/// Color splashed onto an atom (e.g. paint on turf)
#define WASHABLE_COLOUR_PRIORITY 3
/// Color inherent to the atom (e.g. blob color)
#define FIXED_COLOUR_PRIORITY 4
///how many colour priority levels there are.
#define COLOUR_PRIORITY_AMOUNT 4

#define COLOR_INPUT_DISABLED "#F0F0F0"
#define COLOR_INPUT_ENABLED "#D3B5B5"

#define LIGHTMODE_BACKGROUND "none"
#define LIGHTMODE_TEXT "#000000"

#define DARKMODE_DARKBACKGROUND "#111111"
#define DARKMODE_BACKGROUND "#202020"
#define DARKMODE_TEXT "#EEEEEE"
#define DARKMODE_GRAYBUTTON "#333333"
#define DARKMODE_DARKGRAYBUTTON "#2c2c2c"

#define COLOR_DARKMODE_BACKGROUND "#202020"
#define COLOR_DARKMODE_DARKBACKGROUND "#111111"
#define COLOR_DARKMODE_TEXT "#EEEEEE"

#define COLOR_WHITE "#FFFFFF"
#define COLOR_VERY_LIGHT_GRAY "#EEEEEE"
#define COLOR_SILVER "#C0C0C0"
#define COLOR_GRAY "#808080"
#define COLOR_FLOORTILE_GRAY "#8D8B8B"
#define COLOR_ALMOST_BLACK "#333333"
#define COLOR_NEARLY_ALL_BLACK "#111111"
#define COLOR_BLACK "#000000"
#define COLOR_HALF_TRANSPARENT_BLACK "#0000007A"
#define COLOR_TRANSPARENT_SHADOW "#03020781"

#define COLOR_RED "#FF0000"
#define COLOR_MOSTLY_PURE_RED "#FF3300"
#define COLOR_SOMEWHAT_LIGHTER_RED "#da4635"
#define COLOR_DARK_RED "#A50824"
#define COLOR_RED_LIGHT "#FF3333"
#define COLOR_MAROON "#800000"
#define COLOR_VIVID_RED "#FF3232"
#define COLOR_LIGHT_GRAYISH_RED "#E4C7C5"

/// Warm but extremely diluted red. rgb(250, 130, 130)
#define COLOR_SOFT_RED "#FA8282"
#define COLOR_LASER_RED "#FF8D8D"
#define COLOR_LASER_BLUE "#0000FF"

#define COLOR_YELLOW "#FFFF00"
#define COLOR_VIVID_YELLOW "#FBFF23"
#define COLOR_VERY_SOFT_YELLOW "#FAE48E"

#define COLOR_OLIVE "#808000"
#define COLOR_VIBRANT_LIME "#00FF00"
#define COLOR_LIME "#32CD32"
#define COLOR_VERY_PALE_LIME_GREEN "#DDFFD3"
#define COLOR_VERY_DARK_LIME_GREEN "#003300"
#define COLOR_GREEN "#008000"
#define COLOR_DARK_MODERATE_LIME_GREEN "#44964A"

#define COLOR_CYAN "#00FFFF"
#define COLOR_DARK_CYAN "#00A2FF"
#define COLOR_TEAL "#008080"
#define COLOR_BLUE "#0000FF"
#define COLOR_BRIGHT_BLUE "#2CB2E8"
#define COLOR_MODERATE_BLUE "#555CC2"
#define COLOR_BLUE_LIGHT "#33CCFF"
#define COLOR_NAVY "#000080"
#define COLOR_BLUE_GRAY "#75A2BB"
#define COLOR_DISABLER_BLUE "#7E89FF"
#define COLOR_PULSE_BLUE "#BEFFFF"
#define COLOR_TESLA_BLUE "#DAD9FF"

#define COLOR_PINK "#FFC0CB"
#define COLOR_MOSTLY_PURE_PINK "#E4005B"
#define COLOR_MAGENTA "#FF00FF"
#define COLOR_STRONG_MAGENTA "#B800B8"
#define COLOR_PURPLE "#800080"
#define COLOR_VIOLET "#B900F7"
#define COLOR_STRONG_VIOLET "#6927c5"

#define COLOR_ORANGE "#FF9900"
#define COLOR_TAN_ORANGE "#FF7B00"
#define COLOR_BRIGHT_ORANGE "#E2853D"
#define COLOR_LIGHT_ORANGE "#ffc44d"
#define COLOR_PALE_ORANGE "#FFBE9D"
#define COLOR_BEIGE "#CEB689"
#define COLOR_DARK_ORANGE "#C3630C"
#define COLOR_DARK_MODERATE_ORANGE "#8B633B"

#define COLOR_BROWN "#BA9F6D"
#define COLOR_DARK_BROWN "#997C4F"

#define COLOR_GREEN_GRAY "#99BB76"
#define COLOR_RED_GRAY "#B4696A"
#define COLOR_PALE_BLUE_GRAY "#98C5DF"
#define COLOR_PALE_GREEN_GRAY "#B7D993"
#define COLOR_PALE_RED_GRAY "#D59998"
#define COLOR_PALE_PURPLE_GRAY "#CBB1CA"
#define COLOR_PURPLE_GRAY "#AE8CA8"

//Color defines used by the assembly detailer.
#define COLOR_ASSEMBLY_BLACK "#545454"
#define COLOR_ASSEMBLY_BGRAY "#9497AB"
#define COLOR_ASSEMBLY_WHITE "#E2E2E2"
#define COLOR_ASSEMBLY_RED "#CC4242"
#define COLOR_ASSEMBLY_ORANGE "#E39751"
#define COLOR_ASSEMBLY_BEIGE "#AF9366"
#define COLOR_ASSEMBLY_BROWN "#97670E"
#define COLOR_ASSEMBLY_GOLD "#AA9100"
#define COLOR_ASSEMBLY_YELLOW "#CECA2B"
#define COLOR_ASSEMBLY_GURKHA "#999875"
#define COLOR_ASSEMBLY_LGREEN "#789876"
#define COLOR_ASSEMBLY_GREEN "#44843C"
#define COLOR_ASSEMBLY_LBLUE "#5D99BE"
#define COLOR_ASSEMBLY_BLUE "#38559E"
#define COLOR_ASSEMBLY_PURPLE "#6F6192"

//Color dedfines used by pill packets
#define COLOR_PACKET_BICARIDINE "#FF0000"
#define COLOR_PACKET_KELOTANE "#FFFF00"
#define COLOR_PACKET_TRAMADOL "#675772"
#define COLOR_PACKET_TRICORDRAZINE "#FFFFFF"
#define COLOR_PACKET_DYLOVENE "#00FF00"
#define COLOR_PACKET_PARACETAMOL "#65B4B1"
#define COLOR_PACKET_ISOTONIC "#5c0e0e"
#define COLOR_PACKET_LEPORAZINE "#0066FF"
#define COLOR_PACKET_RUSSIAN_RED "#3d0000"
#define COLOR_PACKET_RYETALYN "#AC6D32"

//Color defines used by medicine
#define COLOR_REAGENT_INAPROVALINE "#9966CC" // rgb: 200, 165, 220
#define COLOR_REAGENT_RYETALYN "#C8A5DC" // rgb: 200, 165, 220
#define COLOR_REAGENT_PARACETAMOL "#cac5c5"
#define COLOR_REAGENT_TRAMADOL "#8a8686"
#define COLOR_REAGENT_OXYCODONE "#4b4848"
#define COLOR_REAGENT_HYDROCODONE "#C805DC"
#define COLOR_REAGENT_LEPORAZINE "#C8A5DC" // rgb: 200, 165, 220
#define COLOR_REAGENT_KELOTANE "#CC9900"
#define COLOR_REAGENT_DERMALINE "#ffef00"
#define COLOR_REAGENT_SALINE_GLUCOSE "#d4f1f9"
#define COLOR_REAGENT_DEXALIN "#5972FD"
#define COLOR_REAGENT_DEXALINPLUS "#2445ff"
#define COLOR_REAGENT_TRICORDRAZINE "#f8f8f8"
#define COLOR_REAGENT_DYLOVENE "#669900"
#define COLOR_REAGENT_ADMINORDRAZINE "#C8A5DC" // rgb: 200, 165, 220
#define COLOR_REAGENT_SYNAPTIZINE "#C8A5DC" // rgb: 200, 165, 220
#define COLOR_REAGENT_NEURALINE "#C8A5DC" // rgb: 200, 165, 220
#define COLOR_REAGENT_HYRONALIN "#426300" // rgb: 200, 165, 220
#define COLOR_REAGENT_ARITHRAZINE "#C8A5DC" // rgb: 200, 165, 220
#define COLOR_REAGENT_RUSSIAN_RED "#3d0000" // rgb: 200, 165, 220
#define COLOR_REAGENT_ALKYSINE "#0292AC"
#define COLOR_REAGENT_IMIDAZOLINE "#F7A151" // rgb: 200, 165, 220
#define COLOR_REAGENT_PERIDAXON_PLUS "#FFC896"
#define COLOR_REAGENT_BICARIDINE "#DA0000"
#define COLOR_REAGENT_MERALYNE "#FD5964"
#define COLOR_REAGENT_QUICKCLOT "#E07BAD"
#define COLOR_REAGENT_QUICKCLOTPLUS "#f1accf"
#define COLOR_REAGENT_NANOBLOOD "#A10808"
#define COLOR_REAGENT_ULTRAZINE "#C8A5DC" // rgb: 200, 165, 220
#define COLOR_REAGENT_CRYOXADONE "#C8A5DC" // rgb: 200, 165, 220
#define COLOR_REAGENT_CLONEXADONE "#C8A5DC" // rgb: 200, 165, 220
#define COLOR_REAGENT_REZADONE "#669900" // rgb: 102, 153, 0
#define COLOR_REAGENT_SPACEACILLIN "#90F7F5" // rgb: 200, 165, 220
#define COLOR_REAGENT_POLYHEXANIDE "#C8A5DC" // rgb: 200, 165, 220
#define COLOR_REAGENT_LARVAWAY "#C8A5DC" // rgb: 200, 165, 220
#define COLOR_REAGENT_ETHYLREDOXRAZINE "#605048" // rgb: 96, 80, 72
#define COLOR_REAGENT_HYPERVENE "#AC6D32"
#define COLOR_REAGENT_ROULETTIUM "#19C832"
#define COLOR_REAGENT_LEMOLINE "#66801e"
#define COLOR_REAGENT_BIHEXAJULINE "#DFDFDF"
#define COLOR_REAGENT_QUIETUS "#19C832"
#define COLOR_REAGENT_SOMOLENT "#19C832"
#define COLOR_REAGENT_MEDICALNANITES "#19C832"
#define COLOR_REAGENT_STIMULON "#19C832"

//Color defines used by toxin
#define COLOR_TOXIN_TOXIN "#CF3600" // rgb: 207, 54, 0
#define COLOR_TOXIN_AMATOXIN "#792300" // rgb: 121, 35, 0
#define COLOR_TOXIN_MUTAGEN "#13BC5E" // rgb: 19, 188, 94
#define COLOR_TOXIN_PHORON "#E71B00" // rgb: 231, 27, 0
#define COLOR_TOXIN_LEXORIN "#C8A5DC" // rgb: 200, 165, 220
#define COLOR_TOXIN_CYANIDE "#CF3600" // rgb: 207, 54, 0
#define COLOR_TOXIN_MINTTOXIN "#CF3600" // rgb: 207, 54, 0
#define COLOR_TOXIN_CARPOTOXIN "#003333" // rgb: 0, 51, 51
#define COLOR_TOXIN_HUSKPOWDER "#669900" // rgb: 102, 153, 0
#define COLOR_TOXIN_MINDBREAKER "#B31008" // rgb: 139, 166, 233
#define COLOR_TOXIN_FERTILIZER "#664330" // rgb: 102, 67, 48
#define COLOR_TOXIN_PLANTBGONE "#49002E" // rgb: 73, 0, 46
#define COLOR_TOXIN_SLEEPTOXIN "#E895CC" // rgb: 232, 149, 204
#define COLOR_TOXIN_CHLORALHYDRATE "#000067" // rgb: 0, 0, 103
#define COLOR_TOXIN_POTASSIUM_CHLORIDE "#FFFFFF" // rgb: 255,255,255
#define COLOR_TOXIN_PLASTICIDE "#CF3600" // rgb: 207, 54, 0
#define COLOR_TOXIN_ACID "#DB5008" // rgb: 219, 80, 8
#define COLOR_TOXIN_POLYACID "#8E18A9" // rgb: 142, 24, 169
#define COLOR_TOXIN_NANITES "#535E66" // rgb: 83, 94, 102
#define COLOR_TOXIN_XENO_NEUROTOXIN "#CF3600" // rgb: 207, 54, 0
#define COLOR_TOXIN_XENO_HEMODILE "#602CFF"
#define COLOR_TOXIN_XENO_TRANSVITOX "#94FF00"
#define COLOR_TOXIN_XENO_SANGUINAL "#bb0a1e"
#define COLOR_TOXIN_XENO_OZELOMELYN "#f1ddcf"
#define COLOR_TOXIN_ZOMBIUM "#ac0abb"
#define COLOR_TOXIN_SATRAPINE "#cfb000"

/*
Some defines to generalise colours used in lighting.

Important note: colors can end up significantly different from the basic html picture, especially when saturated
*/

/// Full white. rgb(255, 255, 255)
#define LIGHT_COLOR_WHITE "#FFFFFF"
/// Bright but quickly dissipating neon green. rgb(100, 200, 100)
#define LIGHT_COLOR_GREEN "#64C864"
/// Warm red color rgb(250, 66, 66)
#define LIGHT_COLOR_RED "#ff3b3b"
/// Electric green. rgb(0, 255, 0)
#define LIGHT_COLOR_ELECTRIC_GREEN "#00FF00"
/// Cold, diluted blue. rgb(100, 150, 250)
#define LIGHT_COLOR_BLUE "#6496FA"
/// Light blueish green. rgb(125, 225, 175)
#define LIGHT_COLOR_BLUEGREEN "#7DE1AF"
/// Diluted cyan. rgb(125, 225, 225)
#define LIGHT_COLOR_CYAN "#7DE1E1"
/// Electric cyan rgb(0, 255, 255)
#define LIGHT_COLOR_ELECTRIC_CYAN "#00FFFF"
/// More-saturated cyan. rgb(16, 21, 22)
#define LIGHT_COLOR_LIGHT_CYAN "#40CEFF"
/// Saturated blue. rgb(51, 117, 248)
#define LIGHT_COLOR_DARK_BLUE "#6496FA"
/// Diluted, mid-warmth pink. rgb(225, 125, 225)
#define LIGHT_COLOR_PINK "#E17DE1"
/// Dimmed yellow, leaning kaki. rgb(225, 225, 125)
#define LIGHT_COLOR_YELLOW "#E1E17D"
/// Clear brown, mostly dim. rgb(150, 100, 50)
#define LIGHT_COLOR_BROWN "#966432"
/// Mostly pure orange. rgb(250, 150, 50)
#define LIGHT_COLOR_ORANGE "#FA9632"
/// Light Purple. rgb(149, 44, 244)
#define LIGHT_COLOR_PURPLE "#952CF4"
/// Less-saturated light purple. rgb(155, 81, 255)
#define LIGHT_COLOR_LAVENDER "#9B51FF"
///slightly desaturated bright yellow.
#define LIGHT_COLOR_HOLY_MAGIC "#FFF743"
/// deep crimson
#define LIGHT_COLOR_BLOOD_MAGIC "#D00000"

/* These ones aren't a direct colour like the ones above, because nothing would fit */
/// Warm orange color, leaning strongly towards yellow. rgb(250, 160, 25)
#define LIGHT_COLOR_FIRE "#FAA019"
/// Very warm yellow, leaning slightly towards orange. rgb(196, 138, 24)
#define LIGHT_COLOR_LAVA "#C48A18"
/// Bright, non-saturated red. Leaning slightly towards pink for visibility. rgb(250, 100, 75)
#define LIGHT_COLOR_FLARE "#FA644B"
/// Weird color, between yellow and green, very slimy. rgb(175, 200, 75)
#define LIGHT_COLOR_SLIME_LAMP "#AFC84B"
/// Extremely diluted yellow, close to skin color (for some reason). rgb(250, 225, 175)
#define LIGHT_COLOR_TUNGSTEN "#FAE1AF"
/// Barely visible cyan-ish hue, as the doctor prescribed. rgb(240, 250, 250)
#define LIGHT_COLOR_HALOGEN "#F0FAFA"
/// More bright and rich in color compared to lava. rgb(248, 136, 24)
#define LIGHT_COLOR_FLAME "#F88818"
/// Rich and bright blue. rgb(0, 183, 255)
#define LIGHT_COLOR_BLUE_FLAME "#00b8ff"
///Strong red orange
#define LIGHT_COLOR_RED_ORANGE "#ff2802"

//Ammo and grenade colors
#define COLOR_AMMO_AIRBURST "#2272eb"
#define COLOR_AMMO_INCENDIARY "#fa7923"
#define COLOR_AMMO_TACTICAL_SMOKE "#2F7B00"
#define COLOR_AMMO_SMOKE "#0F98BD"
#define COLOR_AMMO_TANGLEFOOT "#AA1FDC"
#define COLOR_AMMO_ACID "#25dc1f"
#define COLOR_AMMO_RAZORBURN "#FBF236"
#define COLOR_AMMO_HIGH_EXPLOSIVE "#b02323"

//Campaign map lighting
#define LIGHT_COLOR_PALE_GREEN "#ebffc6"
#define COLOR_MISSION_RED "#ffdfd6"
#define COLOR_MISSION_YELLOW "#fffbd6"
#define COLOR_MISSION_BLUE "#d6f2ff"

//less saturated colours intended for lighting effects
#define LIGHT_COLOR_EMISSIVE_GREEN "#69fa64"
#define LIGHT_COLOR_EMISSIVE_RED "#fa6464"
#define LIGHT_COLOR_EMISSIVE_YELLOW "#f0fa64"
#define LIGHT_COLOR_EMISSIVE_ORANGE "#faac64"

//Colors used by special resin walls.
#define COLLOR_WALL_BULLETPROOF "#ed99f6"
#define COLOR_WALL_FIREPROOF "#ff696e"
#define COLOR_WALL_HARDY "#6699ff"
