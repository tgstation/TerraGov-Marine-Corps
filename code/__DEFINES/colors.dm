// This is eventually for wjohn to add more color standardization stuff like I keep asking him >:(

#define COLOR_INPUT_DISABLED "#000000"
#define COLOR_INPUT_ENABLED "#231d1d"

#define COLOR_DARKMODE_BACKGROUND "#202020"
#define COLOR_DARKMODE_DARKBACKGROUND "#171717"
#define COLOR_DARKMODE_TEXT "#a4bad6"

#define COLOR_WHITE            "#EEEEEE"
#define COLOR_SILVER           "#C0C0C0"
#define COLOR_GRAY             "#808080"
#define COLOR_FLOORTILE_GRAY   "#8D8B8B"
#define COLOR_ALMOST_BLACK	   "#333333"
#define COLOR_BLACK            "#000000"
#define COLOR_RED              "#FF0000"
#define COLOR_RED_LIGHT        "#FF3333"
#define COLOR_MAROON           "#800000"
#define COLOR_YELLOW           "#FFFF00"
#define COLOR_OLIVE            "#808000"
#define COLOR_LIME             "#32CD32"
#define COLOR_GREEN            "#008000"
#define COLOR_CYAN             "#00FFFF"
#define COLOR_TEAL             "#008080"
#define COLOR_BLUE             "#0000FF"
#define COLOR_BLUE_LIGHT       "#33CCFF"
#define COLOR_NAVY             "#000080"
#define COLOR_PINK             "#FFC0CB"
#define COLOR_MAGENTA          "#FF00FF"
#define COLOR_PURPLE           "#800080"
#define COLOR_ORANGE           "#FF9900"
#define COLOR_BEIGE            "#CEB689"
#define COLOR_BLUE_GRAY        "#75A2BB"
#define COLOR_BROWN            "#BA9F6D"
#define COLOR_DARK_BROWN       "#997C4F"
#define COLOR_DARK_ORANGE      "#C3630C"
#define COLOR_GREEN_GRAY       "#99BB76"
#define COLOR_RED_GRAY         "#B4696A"
#define COLOR_PALE_BLUE_GRAY   "#98C5DF"
#define COLOR_PALE_GREEN_GRAY  "#B7D993"
#define COLOR_PALE_RED_GRAY    "#D59998"
#define COLOR_PALE_PURPLE_GRAY "#CBB1CA"
#define COLOR_PURPLE_GRAY      "#AE8CA8"

//Color defines used by the assembly detailer.
#define COLOR_ASSEMBLY_BLACK   "#545454"
#define COLOR_ASSEMBLY_BGRAY   "#9497AB"
#define COLOR_ASSEMBLY_WHITE   "#E2E2E2"
#define COLOR_ASSEMBLY_RED     "#CC4242"
#define COLOR_ASSEMBLY_ORANGE  "#E39751"
#define COLOR_ASSEMBLY_BEIGE   "#AF9366"
#define COLOR_ASSEMBLY_BROWN   "#97670E"
#define COLOR_ASSEMBLY_GOLD    "#AA9100"
#define COLOR_ASSEMBLY_YELLOW  "#CECA2B"
#define COLOR_ASSEMBLY_GURKHA  "#999875"
#define COLOR_ASSEMBLY_LGREEN  "#789876"
#define COLOR_ASSEMBLY_GREEN   "#44843C"
#define COLOR_ASSEMBLY_LBLUE   "#5D99BE"
#define COLOR_ASSEMBLY_BLUE    "#38559E"
#define COLOR_ASSEMBLY_PURPLE  "#6F6192"


//roguetown
#define CLOTHING_RED			"#a32121"
#define CLOTHING_PURPLE			"#8747b1"
#define CLOTHING_BLACK			"#414143"
#define CLOTHING_BROWN			"#685542"
#define CLOTHING_GREEN			"#428138"
#define CLOTHING_DARK_GREEN		"#264d26"
#define CLOTHING_BLUE			"#537bc6"
#define CLOTHING_YELLOW			"#b5b004"
#define CLOTHING_TEAL			"#249589"
#define CLOTHING_WHITE			"#ffffff"
#define CLOTHING_ORANGE			"#bd6606"
#define CLOTHING_MAJENTA		"#962e5c"

#define CLOTHING_WET			"#bbbbbb"

#define CLOTHING_COLOR_NAMES	list("Red","Purple","Black","Brown","Green","Blue","Yellow","Teal","White","Orange","Majenta")

/proc/clothing_color2hex(input)
	switch(input)
		if("Red")
			return CLOTHING_RED
		if("Purple")
			return CLOTHING_PURPLE
		if("Black")
			return CLOTHING_BLACK
		if("Brown")
			return CLOTHING_BROWN
		if("Green")
			return CLOTHING_GREEN
		if("Blue")
			return CLOTHING_BLUE
		if("Yellow")
			return CLOTHING_YELLOW
		if("Teal")
			return CLOTHING_TEAL
		if("White")
			return CLOTHING_WHITE
		if("Orange")
			return CLOTHING_ORANGE
		if("Majenta")
			return CLOTHING_MAJENTA
