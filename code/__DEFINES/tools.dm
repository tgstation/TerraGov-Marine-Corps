// Tool types
#define TOOL_CROWBAR "crowbar"
#define TOOL_MULTITOOL "multitool"
#define TOOL_SCREWDRIVER "screwdriver"
#define TOOL_WIRECUTTER "wirecutter"
#define TOOL_WRENCH "wrench"
#define TOOL_WELDER "welder"
#define TOOL_WELD_CUTTER "weld_cutter"
#define TOOL_ANALYZER "analyzer"
#define TOOL_MINING "mining"
#define TOOL_SHOVEL "shovel"
#define TOOL_FULTON "fulton"


// If delay between the start and the end of tool operation is less than MIN_TOOL_SOUND_DELAY,
// tool sound is only played when op is started. If not, it's played twice.
#define MIN_TOOL_SOUND_DELAY 20


///Translate the tool type to the action that might be taken
/proc/tool_define_to_tool_action(tool_type)
	switch(tool_type)
		if(TOOL_SCREWDRIVER)
			return "screw"
		if(TOOL_CROWBAR)
			return "crowbar"
		if(TOOL_WRENCH)
			return "wrench"
		if(TOOL_WIRECUTTER)
			return "cut"
		if(TOOL_WELDER)
			return "weld"
		if(TOOL_WELD_CUTTER)
			return "melt"	//I don't know what else to call it
		if(TOOL_MULTITOOL)
			return "pulse"
		if(TOOL_ANALYZER)
			return "scan"
		if(TOOL_MINING)
			return "mine"
		if(TOOL_SHOVEL)
			return "dig"
		if(TOOL_FULTON)
			return "strap"	//I guess?
	return "[tool_type] does not exist!!!"
