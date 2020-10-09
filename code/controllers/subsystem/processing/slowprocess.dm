//Fires once every five seconds, used for uniportant processing systems

PROCESSING_SUBSYSTEM_DEF(slowprocess)
	name = "Slow Processing"
	wait = 5 SECONDS
	stat_tag = "SP"
	flags = SS_BACKGROUND
