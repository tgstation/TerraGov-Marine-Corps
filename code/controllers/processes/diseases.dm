datum/controller/process/diseases

datum/controller/process/diseases/setup()
	name = "Diseases"
	schedule_interval = 23 //2.3 seconds

datum/controller/process/diseases/doWork()

	var/i = 1
	while(i<=active_diseases.len)
		var/datum/disease/Disease = active_diseases[i]
		if(Disease)
			Disease.process()
			i++
			continue
		active_diseases.Cut(i,i+1)