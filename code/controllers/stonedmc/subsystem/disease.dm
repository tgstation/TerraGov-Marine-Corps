SUBSYSTEM_DEF(disease)
	name = "Disease"

	//var/list/active_diseases = list() //List of Active disease in all mobs; purely for quick referencing.
	var/list/diseases
	var/list/archive_diseases = list()

	var/static/list/list_symptoms = subtypesof(/datum/symptom)

/datum/controller/subsystem/disease/PreInit()
	if(!diseases)
		diseases = subtypesof(/datum/disease)

/datum/controller/subsystem/disease/stat_entry(msg)
	..("P:[active_diseases.len]")

/datum/controller/subsystem/disease/fire(resumed = 0)
	var/i = 1
	while(i<=active_diseases.len)
		var/datum/disease/Disease = active_diseases[i]
		if(Disease)
			Disease.process()
			i++
			continue
		active_diseases.Cut(i,i+1)

/datum/controller/subsystem/disease/proc/get_disease_name(id)
	var/datum/disease/advance/A = archive_diseases[id]
	if(A.name)
		return A.name
	else
		return "Unknown"
