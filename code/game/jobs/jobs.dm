// Also see \code\modules\client\preferences.dm and change "limit" if any jobs become unselectable. Currently 16 max in each section (ENGSEC, MEDSCI, etc)


/*
var/const/CAPTAIN			=(1<<0)
var/const/HOS				=(1<<1)
var/const/WARDEN			=(1<<2)
var/const/DETECTIVE			=(1<<3)
var/const/OFFICER			=(1<<4)
var/const/CHIEF				=(1<<5)
var/const/ENGINEER			=(1<<6)
var/const/ATMOSTECH			=(1<<7)
var/const/AI				=(1<<8)
var/const/CYBORG			=(1<<9)
var/const/RD				=(1<<0)
var/const/SCIENTIST			=(1<<1)
var/const/CHEMIST			=(1<<2)
*/
//var/const/SQUADSP			=(1<<0)

/*
var/const/SULCMO			=(1<<10)
var/const/SULDOC			=(1<<11)
var/const/SULCHEM			=(1<<12)

var/const/CIVILIAN			=(1<<2)

var/const/HOP				=(1<<0)
var/const/BARTENDER			=(1<<1)
var/const/BOTANIST			=(1<<2)
var/const/CHEF				=(1<<3)
var/const/JANITOR			=(1<<4)
var/const/LIBRARIAN			=(1<<5)
var/const/QUARTERMASTER		=(1<<6)
var/const/CARGOTECH			=(1<<7)
var/const/MINER				=(1<<8)
var/const/LAWYER			=(1<<9)
var/const/CHAPLAIN			=(1<<10)
var/const/CLOWN				=(1<<11)
var/const/MIME				=(1<<12)
var/const/ASSISTANT			=(1<<13)

//Marines
//var/const/MARINE			=(1<<14)

var/const/MARINES		=(1<<3)

var/const/SQUADLE		=(1<<1)
var/const/SQUADME		=(1<<2)
var/const/SQUADEN		=(1<<3)
var/const/SQUADMA		=(1<<4)
*/

//Marines

var/const/COMMAND			=(1<<0)

var/const/COMMANDER			=(1<<0)
var/const/EXECUTIVE			=(1<<1)
var/const/BRIDGE			=(1<<2)
var/const/MPOLICE			=(1<<3)
var/const/LIASON			=(1<<4)
var/const/REQUI				=(1<<5)

var/const/ENGI				=(1<<1)

var/const/SULCE				=(1<<0)
var/const/SULENG			=(1<<1)
var/const/SULCARG			=(1<<2)

var/const/MEDSCI			=(1<<2)

var/const/SULCMO			=(1<<0)
var/const/SULDOC			=(1<<1)
var/const/SULRES			=(1<<2)
var/const/SULCHEM			=(1<<3)


var/const/MARINES			=(1<<3)

var/const/SQUADLE			=(1<<0)
var/const/SQUADME			=(1<<1)
var/const/SQUADEN			=(1<<2)
var/const/SQUADMA			=(1<<3)
var/const/SQUADSP			=(1<<4)


var/list/command_positions = list(
	"Commander",
	"Executive Officer",
	"Bridge Officer",
	"Military Police",
	"Corporate Liaison",
	"Requisitions Officer",
	"Chief Engineer",
	"Chief Medical Officer"
)

var/list/engineering_positions = list(
	"Chief Engineer",
	"Maintenance Tech"
)

var/list/cargo_positions = list(
	"Requisitions Officer",
	"Cargo Technician"
)

var/list/medical_positions = list(
	"Chief Medical Officer",
	"Doctor",
	"Researcher"
)

var/list/marine_squad_positions = list(
	"Squad Leader",
	"Squad Medic",
	"Squad Engineer",
	"Squad Marine",
	"Squad Specialist"
)

var/list/all_squad_positions = list(
	"Alpha",
	"Bravo",
	"Charlie",
	"Delta"
)

var/list/marine_unassigned_positions = list(
	"Squad Marine"
)

var/list/nonhuman_positions = list(
	"AI",
	"Cyborg",
	"pAI"
)


/*
var/list/science_positions = list(
	"Researcher",
	"Xenobiologist"
)



var/list/civilian_positions = list(
	"Assistant"
)

var/list/marine_alpha_positions = list(
	"Alpha Squad Leader",
	"Alpha Squad Standard",
	"Alpha Squad Engineer",
	"Alpha Squad Medic"
)


var/list/marine_bravo_positions = list(
	"Bravo Squad Leader",
	"Bravo Squad Standard",
	"Bravo Squad Engineer",
	"Bravo Squad Medic"
)


var/list/marine_charlie_positions = list(
	"Charlie Squad Leader",
	"Charlie Squad Standard",
	"Charlie Squad Engineer",
	"Charlie Squad Medic"
)


var/list/marine_delta_positions = list(
	"Delta Squad Leader",
	"Delta Squad Standard",
	"Delta Squad Engineer",
	"Delta Squad Medic"
)
*/

/proc/guest_jobbans(var/job)
	return ((job in command_positions) || (job in nonhuman_positions))

/proc/get_job_datums()
	var/list/occupations = list()
	var/list/all_jobs = typesof(/datum/job)

	for(var/A in all_jobs)
		var/datum/job/job = new A()
		if(!job)	continue
		occupations += job

	return occupations

/proc/get_alternate_titles(var/job)
	var/list/jobs = get_job_datums()
	var/list/titles = list()

	for(var/datum/job/J in jobs)
		if(J.title == job)
			titles = J.alt_titles

	return titles
