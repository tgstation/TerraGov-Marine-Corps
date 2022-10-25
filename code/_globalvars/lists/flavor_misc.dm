//Preferences stuff
GLOBAL_LIST_EMPTY(ethnicities_list)
	//Hairstyles
GLOBAL_LIST_EMPTY(hair_styles_list)			//stores /datum/sprite_accessory/hair indexed by name
GLOBAL_LIST_EMPTY(hair_gradients_list)			//stores /datum/sprite_accessory/hair_gradient indexed by name
GLOBAL_LIST_EMPTY(facial_hair_styles_list)	//stores /datum/sprite_accessory/facial_hair indexed by name
	//Underwear
GLOBAL_LIST_EMPTY(underwear_list)		//stores /datum/sprite_accessory/underwear indexed by name
GLOBAL_LIST_INIT(underwear_m, list("Briefs")) //Curse whoever made male/female underwear diffrent colours
GLOBAL_LIST_INIT(underwear_f, list("Briefs", "Panties"))
	//Undershirts
GLOBAL_LIST_INIT(undershirt_t, list("None","Undershirt(Sleeveless)", "Undershirt(Sleeved)", "Rolled Undershirt(Sleeveless)", "Rolled Undershirt(Sleeved)"))
	//Mutant Human bits
GLOBAL_LIST_EMPTY(moth_wings_list)
GLOBAL_LIST_EMPTY(tails_list_monkey)


GLOBAL_LIST_INIT(ghost_forms_with_directions_list, list("ghost")) //stores the ghost forms that support directional sprites
GLOBAL_LIST_INIT(ghost_forms_with_accessories_list, list("ghost")) //stores the ghost forms that support hair and other such things

GLOBAL_LIST_INIT(ai_core_display_screens, list(
	":thinking:",
	"Alien",
	"Angel",
	"Banned",
	"Bliss",
	"Blue",
	"Clown",
	"Database",
	"Dorf",
	"Firewall",
	"Fuzzy",
	"Gentoo",
	"Glitchman",
	"Gondola",
	"Goon",
	"Hades",
	"Heartline",
	"Helios",
	"House",
	"Inverted",
	"Matrix",
	"Monochrome",
	"Murica",
	"Nanotrasen",
	"Not Malf",
	"President",
	"Random",
	"Rainbow",
	"Red",
	"Red October",
	"Static",
	"Syndicat Meow",
	"Text",
	"Too Deep",
	"Triumvirate",
	"Triumvirate-M",
	"Weird",
	"shodan",
	"shodan_chill",
	"shodan_data",
	"shodan_pulse"))

/proc/resolve_ai_icon(input)
	if(!input || !(input in GLOB.ai_core_display_screens))
		return "ai"
	else
		if(input == "Random")
			input = pick(GLOB.ai_core_display_screens - "Random")
		return "ai-[lowertext(input)]"

	//Backpacks
GLOBAL_LIST_INIT(backpacklist, list("Nothing", "Backpack", "Satchel"))


GLOBAL_LIST_INIT(genders, list(MALE, FEMALE, NEUTER))

GLOBAL_LIST_EMPTY(minimap_icons)
GLOBAL_LIST_INIT(playable_icons, list(
	"alpha_engi",
	"alpha_leader",
	"alpha_medic",
	"alpha_private",
	"alpha_smartgunner",
	"boiler",
	"bravo_engi",
	"bravo_leader",
	"bravo_medic",
	"bravo_private",
	"bravo_smartgunner",
	"bull",
	"captain",
	"carrier",
	"charlie_engi",
	"charlie_leader",
	"charlie_medic",
	"charlie_private",
	"charlie_smartgunner",
	"chief_medical",
	"cl",
	"crusher",
	"cse",
	"defender",
	"defiler",
	"delta_engi",
	"delta_leader",
	"delta_medic",
	"delta_private",
	"delta_smartgunner",
	"drone",
	"fieldcommander",
	"gorger",
	"hivelord",
	"hivemind",
	"hunter",
	"larva",
	"mech_pilot",
	"medical",
	"pilot",
	"praetorian",
	"private",
	"ravager",
	"requisition",
	"researcher",
	"runner",
	"sentinel",
	"spiderling",
	"spitter",
	"st",
	"staffofficer",
	"synth",
	"warrior",
	"whiskey_engi",
	"whiskey_leader",
	"whiskey_medic",
	"whiskey_private",
	"whiskey_smartgunner",
	"widow",
	"wraith",
	"xenoking",
	"xenoqueen",
	"xenoshrike",
	"xray_engi",
	"xray_leader",
	"xray_medic",
	"xray_private",
	"xray_smartgunner",
	"yankee_engi",
	"yankee_leader",
	"yankee_medic",
	"yankee_private",
	"yankee_smartgunner",
	"zulu_engi",
	"zulu_leader",
	"zulu_medic",
	"zulu_private",
	"zulu_smartgunner",
))
