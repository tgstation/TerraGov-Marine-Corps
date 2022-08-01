/atom/movable/effect/spawner/vaultspawner
	var/maxX = 6
	var/maxY = 6
	var/minX = 2
	var/minY = 2

/atom/movable/effect/spawner/vaultspawner/Initialize(mapload, lX = minX, uX = maxX, lY = minY, uY = maxY,type = null)
	. = ..()
	if(!type)
		type = pick("sandstone","rock","alien")

	var/lowBoundX = loc.x
	var/lowBoundY = loc.y

	var/hiBoundX = loc.x + rand(lX,uX)
	var/hiBoundY = loc.y + rand(lY,uY)

	var/z = loc.z

	for(var/i = lowBoundX,i<=hiBoundX,i++)
		for(var/j = lowBoundY,j<=hiBoundY,j++)
			if(i == lowBoundX || i == hiBoundX || j == lowBoundY || j == hiBoundY)
				new /turf/closed/wall/vault(locate(i,j,z),type)
			else
				new /turf/open/floor/vault(locate(i,j,z),type)

	return INITIALIZE_HINT_QDEL
