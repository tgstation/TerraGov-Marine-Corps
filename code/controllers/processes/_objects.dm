datum/controller/process/objects

datum/controller/process/objects/setup()
	name = "Objects"
	schedule_interval = 23 //2.3 seconds

	to_chat(world, "<span class='danger'>Initializing objects</span>")
	sleep(-1)
	for(var/atom/movable/object in world)
		object.initialize()

datum/controller/process/objects/doWork()

	var/i = 1
	while(i<=SSobj.len)
		var/obj/Object = SSobj[i]
		if(Object)
			Object.process()
			i++
			continue
		SSobj.Cut(i,i+1)