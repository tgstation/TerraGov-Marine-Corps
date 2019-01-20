/client/proc/secrets()
	set name = "Secrets Panel"
	set category = "Admin"
	if (holder)
		holder.Secrets()
	feedback_add_details("admin_verb","S") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return


/datum/admins/proc/Secrets()
	if(!check_rights(0))	return

	var/dat = "<B>The first rule of adminbuse is: you don't talk about the adminbuse.</B><HR>"

	if(check_rights(R_ADMIN,0))
		dat += {"
			<B>Admin Secrets</B><BR>
			<BR>
			<A href='?src=\ref[src];secretsadmin=list_bombers'>Bombing List</A><BR>
			<A href='?src=\ref[src];secretsadmin=check_antagonist'>Check Antagonists</A><BR>
			<A href='?src=\ref[src];secretsadmin=list_signalers'>Show last [length(lastsignalers)] signalers</A><BR>
			<A href='?src=\ref[src];secretsadmin=list_lawchanges'>Show last [length(lawchanges)] law changes</A><BR>
			<A href='?src=\ref[src];secretsadmin=showailaws'>Show AI Laws</A><BR>
			<A href='?src=\ref[src];secretsadmin=showgm'>Show Game Mode</A><BR>
			<A href='?src=\ref[src];secretsadmin=manifest'>Show Crew Manifest</A><BR>
			<A href='?src=\ref[src];secretsadmin=DNA'>List DNA (Blood)</A><BR>
			<A href='?src=\ref[src];secretsadmin=fingerprints'>List Fingerprints</A><BR>
			<A href='?src=\ref[src];secretsfun=launchshuttle'>Launch a shuttle normally</A> (inop)<BR>
			<A href='?src=\ref[src];secretsfun=moveshuttle'>Move a shuttle instantly</A> (inop)<BR>
			<BR>
			"}

	if(check_rights(R_FUN,0))
		dat += {"
			<B>'Random' Events</B><BR>
			<BR>
			<A href='?src=\ref[src];secretsfun=gravity'>Toggle station artificial gravity</A> (inop)<BR> <!--Needs to not affect planets-->
			<A href='?src=\ref[src];secretsfun=wave'>Spawn a meteor shower</A> (inop)<BR> <!--Needs to not affect planets-->
			<A href='?src=\ref[src];secretsfun=spiders'>Trigger a Spider infestation</A> (inop)<BR> <!--Not working -->
			<A href='?src=\ref[src];secretsfun=radiation'>Irradiate the station</A> (inop)<BR> <!--Not working -->
			<A href='?src=\ref[src];secretsfun=prison_break'>Trigger a Prison Break</A><BR>
			<A href='?src=\ref[src];secretsfun=virus'>Trigger a Virus Outbreak</A> (inop)<BR> <!--Not working -->
			<A href='?src=\ref[src];secretsfun=lightsout'>Toggle a "lights out" event</A> (inop)<BR> <!--Not working -->
			<A href='?src=\ref[src];secretsfun=ionstorm'>Spawn an Ion Storm</A> (inop)<BR> <!--Not working -->
			<A href='?src=\ref[src];secretsfun=spacevines'>Spawn Space-Vines</A> (inop)<BR> <!--Not working -->
			<A href='?src=\ref[src];secretsfun=comms_blackout'>Trigger a Communication Blackout</A><BR>
			<BR>
			<B>Fun Secrets</B><BR>
			<BR>
			<A href='?src=\ref[src];secretsfun=striketeam'>Send in a strike team</A> (inop)<BR> <!--Not working. Maybe a 2nd Death Squad if needed in the future -->
			<A href='?src=\ref[src];secretsfun=unpower'>Unpower ship SMESs and APCs</A><BR>
			<A href='?src=\ref[src];secretsfun=power'>Power ship SMESs and APCs</A><BR>
			<A href='?src=\ref[src];secretsfun=quickpower'>Power ship SMESs</A><BR>
			<A href='?src=\ref[src];secretsfun=powereverything'>Power ALL SMESs and APCs everywhere</A><BR>
			<A href='?src=\ref[src];secretsfun=traitor_all'>Make everyone a traitor and give them one objective</A><BR>
			<A href='?src=\ref[src];secretsfun=onlyone'>There can only be one!</A> (inop)<BR> <!--Not working -->
			<A href='?src=\ref[src];secretsfun=blackout'>Break all lights</A><BR>
			<A href='?src=\ref[src];secretsfun=whiteout'>Fix all lights</A><BR>
			<BR>
			<B>Mass-Teleportation</B><BR>
			<BR>
			<A href='?src=\ref[src];secretsfun=gethumans'>Get ALL humans</A><BR>
			<A href='?src=\ref[src];secretsfun=getxenos'>Get ALL Xenos</A><BR>
			<A href='?src=\ref[src];secretsfun=getall'>Get ALL living, cliented mobs</A><BR>
			<BR>
			<B>Mass-Rejuvenate</B><BR>
			<BR>
			<A href='?src=\ref[src];secretsfun=rejuvall'>Rejuv ALL cliented mobs</A><BR>
			"}

	if(check_rights(R_DEBUG,0))
		dat += {"
			<BR>
			<A href='?src=\ref[src];secretscoder=spawn_objects'>Admin Log</A><BR>
			<BR>
			"}

	usr << browse(dat, "window=secrets")
	return