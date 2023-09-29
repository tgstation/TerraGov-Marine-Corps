//Base Instance

/area/outpost
	name = "Research outpost"


//	ceiling = CEILING_GLASS
//	ceiling = CEILING_METAL



// LZ Areas

/area/outpost/lz1
	name = "Landing Zone 1"
	ceiling = CEILING_NONE
	icon_state="red"
	outside = FALSE
	minimap_color = MINIMAP_AREA_LZ

/area/outpost/lz2
	name = "Landing Zone 2"
	ceiling = CEILING_NONE
	icon_state="red"
	outside = FALSE
	minimap_color = MINIMAP_AREA_LZ



// Cargo Areas

/area/outpost/cargo
	name = "Cargo Bay"
	icon_state="orange"
	ceiling = CEILING_GLASS
	outside = FALSE
	minimap_color = MINIMAP_AREA_REQ

/area/outpost/cargo/office
	name = "Cargo Office"
	icon_state="orange"
	ceiling = CEILING_GLASS

/area/outpost/cargo/security
	name = "Cargo Security Outpost"
	icon_state="brig"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_SEC

/area/outpost/cargo/engineering
	name = "Cargo Engineering"
	icon_state="orange"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_REQ

// Cave Areas, cave.

/area/outpost/caves
	name = "Caves"
	icon_state="cave"
	ceiling = CEILING_NONE
	outside = FALSE
	always_unpowered = TRUE

/area/outpost/caves/central
	name = "Central Caves"
	icon_state="cave"
	ceiling = CEILING_NONE

/area/outpost/caves/north
	name = "Northern Caves"
	icon_state="cave"
	ceiling = CEILING_DEEP_UNDERGROUND
	minimap_color = MINIMAP_AREA_CAVES

/area/outpost/caves/north_east
	// Note: This is where the hive is
	name = "North Eastern Caves"
	icon_state="cave"
	ceiling = CEILING_DEEP_UNDERGROUND
	minimap_color = MINIMAP_AREA_CAVES

/area/outpost/caves/east
	name = "Eastern Caves"
	icon_state="cave"
	ceiling = CEILING_NONE

/area/outpost/caves/south_east
	name = "South Eastern Caves"
	icon_state="cave"
	ceiling = CEILING_NONE

/area/outpost/caves/south
	name = "Southern Caves"
	icon_state="cave"
	ceiling = CEILING_NONE

/area/outpost/caves/south_west
	name = "South Western Caves"
	icon_state="cave"
	ceiling = CEILING_NONE

/area/outpost/caves/west
	name = "Western Caves"
	icon_state="cave"
	ceiling = CEILING_NONE

/area/outpost/caves/north_west
	name = "North Western Caves"
	icon_state="cave"
	ceiling = CEILING_DEEP_UNDERGROUND
	minimap_color = MINIMAP_AREA_CAVES



// Yard Areas, there are a lot of these because there are a lot of open /areas.

/area/outpost/yard
	name = "Yard"
	icon_state="thunder"
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_AREA_COLONY
	always_unpowered = TRUE

/area/outpost/yard/central
	name = "Central Yard"
	icon_state="thunder"
	ceiling = CEILING_NONE

/area/outpost/yard/north
	name = "Northern Yard"
	icon_state="thunder"
	ceiling = CEILING_NONE

/area/outpost/yard/north_east
	name = "North Eastern Yard"
	icon_state="thunder"
	ceiling = CEILING_NONE

/area/outpost/yard/east
	name = "Eastern Yard"
	icon_state="thunder"
	ceiling = CEILING_NONE

/area/outpost/yard/south_east
	name = "South Eastern Yard"
	icon_state="thunder"
	ceiling = CEILING_NONE

/area/outpost/yard/south
	name = "Southern Yard"
	icon_state="thunder"
	ceiling = CEILING_NONE

/area/outpost/yard/south_west
	name = "South West Yard"
	icon_state="thunder"
	ceiling = CEILING_NONE

/area/outpost/yard/west
	name = "Western Yard"
	icon_state="thunder"
	ceiling = CEILING_NONE

/area/outpost/yard/north_west
	name = "North Western Yard"
	icon_state="thunder"
	ceiling = CEILING_NONE



// Arrivals Areas, where you arrive

/area/outpost/arrivals
	name = "Arrivals"
	icon_state="entry"
	ceiling = CEILING_GLASS
	outside = FALSE

/area/outpost/arrivals/securitylz1
	name = "LZ1 Security Outpost"
	icon_state="brig"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_SEC

/area/outpost/arrivals/securitylz2
	name = "LZ2 Security Outpost"
	icon_state="brig"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_SEC

// Hallway Areas, a few of these, somewhat annoying as the south hallway branches out more than the others.

/area/outpost/hallway
	name = "Hallway"
	icon_state="green"
	ceiling = CEILING_GLASS
	outside = FALSE

/area/outpost/hallway/northern
	name = "Northern Hallway"
	icon_state="green"
	ceiling = CEILING_GLASS

/area/outpost/hallway/central
	name = "Central Hallway"
	icon_state="green"
	ceiling = CEILING_GLASS

/area/outpost/hallway/west
	name = "Western Hallway"
	icon_state="green"
	ceiling = CEILING_GLASS

/area/outpost/hallway/south_cent
	name = "South Central Hallway"
	icon_state="green"
	ceiling = CEILING_GLASS

/area/outpost/hallway/south_east
	name = "South Eastern Hallway"
	icon_state="green"
	ceiling = CEILING_GLASS

/area/outpost/hallway/south_west
	name = "South Western Hallway"
	icon_state="green"
	ceiling = CEILING_GLASS

/area/outpost/hallway/east
	name = "South Western Hallway"
	icon_state="green"
	ceiling = CEILING_GLASS



// Medbay

/area/outpost/medbay
	name="Medbay"
	icon_state="blue"
	ceiling = CEILING_GLASS
	outside = FALSE
	minimap_color = MINIMAP_AREA_MEDBAY

/area/outpost/medbay/security
	name="Medbay Security Outpost"
	icon_state="blue"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_SEC

/area/outpost/medbay/storage
	name="Medbay Storage"
	icon_state="blue"
	ceiling = CEILING_GLASS

/area/outpost/medbay/surgery
	name="Surgery"
	icon_state="blue"
	ceiling = CEILING_GLASS

/area/outpost/medbay/chemistry
	name="Chemistry"
	icon_state="blue"
	ceiling = CEILING_GLASS



// Dorms, it feels like a waste of space to put in a comment for a single /area.

/area/outpost/dormitories
	name = "Dormitiories"
	icon_state="Sleep"
	ceiling = CEILING_GLASS
	outside = FALSE
	minimap_color = MINIMAP_AREA_LIVING


// Brig

/area/outpost/brig
	name = "Brig"
	icon_state="brig"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_SEC

/area/outpost/brig/gear_room
	name = "Brig Gear Room"
	icon_state="brig"
	ceiling = CEILING_METAL

/area/outpost/brig/wardens_office
	name = "Brig Gear Room"
	icon_state="brig"
	ceiling = CEILING_METAL

/area/outpost/brig/armoury
	name = "Armoury"
	icon_state="brig"
	ceiling = CEILING_METAL



// Science, man turns himself into a pickle, this is somehow a funny joke and you should laugh. //ha ha very funny

/area/outpost/science
	name = "Science Department"
	icon_state="purple"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_RESEARCH

/area/outpost/science/research
	name = "Research and Development"
	icon_state="purple"
	ceiling = CEILING_METAL

/area/outpost/science/security
	name = "Science Security Outpost"
	icon_state="brig"
	ceiling = CEILING_METAL
	minimap_color = MINIMAP_AREA_SEC

/area/outpost/science/hydponics
	// LOCAL DEGENERATE BOTANIST STOLE THE CHEM DISPENSER AGAIN
	name = "Plant Sciences"
	icon_state="purple"
	ceiling = CEILING_METAL

/area/outpost/science/rd_office
	name = "Research Directors Office"
	icon_state="purple"
	ceiling = CEILING_METAL

/area/outpost/science/xenobiology
	/*
	One day there was a lonely, overworked scientist.
	The company he worked for did not care at all about their employees.
	His boss refused his requests for vacation time and took credit for all of his work.
	One day he got an idea.
	He just stopped working.
	His boss quickly entered, having been watching the cameras to ensure he was working.
	"HEY, GET BACK TO WORK, YOU DONT GET BREAKS!"
	"Hey, Boss, what do you get when you cross a pissed of scientist with xenomorph specimines?
	"DO I NEED TO CALL SECURITY TO GET YOUR ASS BACK TO WORK!?"
	"YOU GET WHAT YOU FUCKING DESERVE!"
	*SMASH*
	*WARNING, CONTAINMENT BREACH DETECTED IN XENOBIOLOGY LAB*
	*/
	name = "Xenobiology"
	icon_state="purple"
	ceiling = CEILING_METAL
	outside = FALSE



// Engineering

/area/outpost/engineering
	name = "Engineering Hallway"
	icon_state="engine"
	ceiling = CEILING_GLASS
	outside = FALSE
	minimap_color = MINIMAP_AREA_ENGI

/area/outpost/engineering/hallway
	name = "Engineering Hallway"
	icon_state="engine"
	ceiling = CEILING_GLASS

/area/outpost/engineering/security
	name = "Engineering Security Outpost"
	icon_state="engine"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_SEC

/area/outpost/engineering/engine
	name = "Engine Room"
	icon_state="engine"
	ceiling = CEILING_UNDERGROUND
	minimap_color = MINIMAP_AREA_ENGI_CAVE
