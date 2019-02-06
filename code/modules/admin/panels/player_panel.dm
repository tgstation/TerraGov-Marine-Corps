/datum/admins/proc/player_panel()
	set category = "Admin"
	set name = "Player Panel"

	if(!check_rights(R_ADMIN))
		return

	var/dat = "<html><head><title>Player Panel</title></head>"

	dat += {"

		<head>
			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch(){


					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != ""){
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == ""){
						return;
					}else{

						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for ( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0){
									continue;
								}
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByTagName("b");
								var search = lsearch\[0\];
								//var inner_span = li.getElementsByTagName("span")\[1\] //Should only ever contain one element.
								//document.write("<p>"+search.innerText+"<br>"+filter+"<br>"+search.innerText.indexOf(filter))
								if ( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									//document.write("a");
									//ltr.removeChild(tr);
									td.innerHTML = "";
									i--;
								}
							}catch(err) {   }
						}
					}

					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");

					locked_tabs = new Array();

				}

				function expand(id,job,name,real_name,image,key,ip,antagonist,ref){

					clearAll();

					var span = document.getElementById(id);
					var ckey = key.toLowerCase().replace(/\[^a-z@0-9\]+/g,"");

					body = "<table><tr><td>";

					body += "</td><td align='center'>";

					body += "<font size='2'><b>"+job+" "+name+"</b><br><b>Real name "+real_name+"</b><br><b>Played by "+key+" ("+ip+")</b></font>"

					body += "</td><td align='center'>";

					body += "<a href='?_src_=holder;[HrefToken()];playerpanel="+ref+"'>PP</a> - "
					body += "<a href='?_src_=vars;[HrefToken()];vars="+ref+"'>VV</a> - "
					body += "<a href='?priv_msg="+ckey+"'>PM</a> - "
					body += "<a href='?_src_=holder;[HrefToken()];subtlemessage="+ref+"'>SM</a> - "
					body += "<a href='?_src_=holder;[HrefToken()];observejump="+ref+"'>JMP</a> - "
					body += "<a href='?_src_=holder;[HrefToken()];observefollow="+ref+"'>FLW</a> - "
					body += "<a href='?_src_=holder;[HrefToken()];individuallog="+ref+"'>LOGS</a><br>"
					body += "</td></tr></table>";


					span.innerHTML = body
				}

				function clearAll(){
					var spans = document.getElementsByTagName('span');
					for(var i = 0; i < spans.length; i++){
						var span = spans\[i\];

						var id = span.getAttribute("id");

						if(!(id.indexOf("item")==0))
							continue;

						var pass = 1;

						for(var j = 0; j < locked_tabs.length; j++){
							if(locked_tabs\[j\]==id){
								pass = 0;
								break;
							}
						}

						if(pass != 1)
							continue;




						span.innerHTML = "";
					}
				}

				function addToLocked(id,link_id,notice_span_id){
					var link = document.getElementById(link_id);
					var decision = link.getAttribute("name");
					if(decision == "1"){
						link.setAttribute("name","2");
					}else{
						link.setAttribute("name","1");
						removeFromLocked(id,link_id,notice_span_id);
						return;
					}

					var pass = 1;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 0;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs.push(id);
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "<font color='red'>Locked</font> ";
					//link.setAttribute("onClick","attempt('"+id+"','"+link_id+"','"+notice_span_id+"');");
					//document.write("removeFromLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
					//document.write("aa - "+link.getAttribute("onClick"));
				}

				function attempt(ab){
					return ab;
				}

				function removeFromLocked(id,link_id,notice_span_id){
					//document.write("a");
					var index = 0;
					var pass = 0;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 1;
							index = j;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs\[index\] = "";
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "";
					//var link = document.getElementById(link_id);
					//link.setAttribute("onClick","addToLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
				}

				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}

			</script>
		</head>


	"}

	//body tag start + onload and onkeypress (onkeyup) javascript event calls
	dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

	//title + search bar
	dat += {"

		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
					<font size='5'><b>Player panel</b></font><br>
					Hover over a line to see more information.
					<p>
				</td>
			</tr>
			<tr id='search_tr'>
				<td align='center'>
					<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
				</td>
			</tr>
	</table>

	"}

	//player table header
	dat += {"
		<span id='maintable_data_archive'>
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/list/mobs = sortmobs()
	var/i = 1
	for(var/mob/M in mobs)
		if(M.ckey && M.client)

			var/color = "#e6e6e6"
			if(i % 2 == 0)
				color = "#f2f2f2"
			var/is_antagonist = is_special_character(M)

			var/M_job = ""

			if(isliving(M))

				if(iscarbon(M)) //Carbon stuff
					if(ishuman(M))
						M_job = M.job
					else if(ismonkey(M))
						M_job = "Monkey"
					else if(isxeno(M))
						if(M.client?.prefs?.xeno_name && M.client.prefs.xeno_name != "Undefined")
							M_job = "alien - [M.client.prefs.xeno_name]"
						else
							M_job = "alien"
					else
						M_job = "Carbon-based"

				else if(issilicon(M)) //silicon
					if(isAI(M))
						M_job = "aI"
					else if(iscyborg(M))
						M_job = "Cyborg"
					else
						M_job = "Silicon-based"

				else if(isanimal(M)) //simple animals
					if(iscorgi(M))
						M_job = "Corgi"
					else
						M_job = "animal"

				else
					M_job = "Living"

			else if(istype(M,/mob/new_player))
				M_job = "New player"

			else if(isobserver(M))
				M_job = "Ghost"

			M_job = oldreplacetext(M_job, "'", "")
			M_job = oldreplacetext(M_job, "\"", "")
			M_job = oldreplacetext(M_job, "\\", "")

			var/M_name = M.name
			M_name = oldreplacetext(M_name, "'", "")
			M_name = oldreplacetext(M_name, "\"", "")
			M_name = oldreplacetext(M_name, "\\", "")
			var/M_rname = M.real_name
			M_rname = oldreplacetext(M_rname, "'", "")
			M_rname = oldreplacetext(M_rname, "\"", "")
			M_rname = oldreplacetext(M_rname, "\\", "")

			var/M_key = M.key
			M_key = oldreplacetext(M_key, "'", "")
			M_key = oldreplacetext(M_key, "\"", "")
			M_key = oldreplacetext(M_key, "\\", "")

			//output for each mob
			dat += {"

				<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
					<td align='center' bgcolor='[color]'>
						<span id='notice_span[i]'></span>
						<a id='link[i]'
						onmouseover='expand("item[i]","[M_job]","[M_name]","[M_rname]","--unused--","[M_key]","[M.lastKnownIP]",[is_antagonist],"\ref[M]")'
						>
						<b id='search[i]'>[M_name] - [M_rname] - [M_key] ([M_job])</b>
						</a>
						<br><span id='item[i]'></span>
					</td>
				</tr>

			"}

			i++


	//player table ending
	dat += {"
		</table>
		</span>

		<script type='text/javascript'>
			var maintable = document.getElementById("maintable_data_archive");
			var complete_list = maintable.innerHTML;
		</script>
	</body></html>
	"}

	log_admin("[key_name(usr)] opened the player panel.")

	usr << browse(dat, "window=players;size=600x480")



/datum/admins/proc/player_panel_extended()
	set category = "Admin"
	set name = "Player Panel Extended"

	if(!check_rights(R_ADMIN))
		return

	var/ref = "[REF(usr.client.holder)];[HrefToken()]"
	var/dat = "<html><head><title>Player Menu</title></head>"
	dat += "<body><table border=1 cellspacing=5><B><tr><th>Key</th><th>Name</th><th>Type</th><th>PP</th><th>CID</th><th>IP</th><th>JMP</th><th>FLW</th><th>Notes</th></tr></B>"
	var/list/mobs = sortmobs()

	for(var/mob/M in mobs)
		if(!M.ckey)
			continue

		dat += "<tr><td>[(M.client ? "[M.client]" : "No client")]</td>"
		dat += "<td><a href='?priv_msg=[M.ckey]'>[M.name]</a></td>"
		if(isAI(M))
			dat += "<td>aI</td>"
		else if(iscyborg(M))
			dat += "<td>Cyborg</td>"
		else if(ishuman(M))
			dat += "<td>[M.real_name]</td>"
		else if(istype(M, /mob/new_player))
			dat += "<td>New Player</td>"
		else if(isobserver(M))
			dat += "<td>Ghost</td>"
		else if(ismonkey(M))
			dat += "<td>Monkey</td>"
		else if(isxeno(M))
			if(M.client?.prefs?.xeno_name && M.client.prefs.xeno_name != "Undefined")
				dat += "<td>alien - [M.client.prefs.xeno_name]</td>"
			else
				dat += "<td>alien</td>"
		else
			dat += "<td>Unknown</td>"


		dat += {"<td align=center><a href='?src=[ref];playerpanel=[REF(M)]'>PP</a></td>
		<td>[M.computer_id]</td>
		<td>[M.lastKnownIP]</td>
		<td><a href='?src=[ref];observejump=[REF(M)]'>JMP</a></td>
		<td><a href='?src=[ref];observefollow=[REF(M)]'>FLW</a></td>
		<td><a href='?src=[ref];notes=show;mob=[REF(M)]'>Notes</a></td>
		"}


	dat += "</table></body></html>"

	log_admin("[key_name(usr)] opened the extended player panel.")

	usr << browse(dat, "window=players;size=640x480")


/datum/admins/proc/show_player_panel(var/mob/M in GLOB.mob_list)
	set category = null
	set name = "Show Player Panel"

	if(!check_rights(R_ADMIN))
		return

	var/ref = "[REF(usr.client.holder)];[HrefToken()]"
	var/body = "<html><head><title>Player Panel: [key_name(M)]</title></head>"

	body += "[M.name]"

	if(M.client)
		body += " played by <b>[M.client]</b> "
		body += "\[<a href='?src=[ref];editrights=[(GLOB.admin_datums[M.client.ckey] || GLOB.deadmins[M.client.ckey]) ? "rank" : "add"];key=[M.key]'>[M.client.holder ? M.client.holder.rank : "Player"]</A>\]"

	if(istype(M, /mob/new_player))
		body += " <B>Hasn't Entered Game</B> "
	else
		body += " \[<a href='?src=[ref];revive=[REF(M)]'>Heal</a>\] "

	body += {"
		<br><br>\[
		<a href='?priv_msg=[M.ckey]'>PM</a> -
		<a href='?src=[ref];subtlemessage=[REF(M)]'>SM</a> -
		<a href='?_src_=vars;[HrefToken()];vars=[REF(M)]'>VV</a> -
		<a href='?src=[ref];spawncookie=[REF(M)]'>SC</a> -
		<a href='?src=[ref];spawnfortunecookie=[REF(M)]'>SFC</a> -
		<a href='?src=[ref];observejump=[REF(M)]'>JMP</a> -
		<a href='?src=[ref];observefollow=[REF(M)]'>FLW</a> -
		<a href='?src=[ref];individuallog=[REF(M)]'>LOGS</a> \]</b><br>
		<b>Mob type</b> = [M.type]<br><br>
		<a href='?src=[ref];kick=[REF(M)]'>Kick</a> |
		<a href='?src=[ref];ban=[REF(M)]'>Ban</a> |
		<a href='?src=[ref];jobbanpanel=[REF(M)]'>Jobban</a> |
		<a href='?src=[ref];notes=show;mob=[REF(M)]'>Notes</a> |
	"}

	if(M.client?.prefs)
		body += "\ <a href='?src=[ref];lobby=[REF(M)]'> Send back to Lobby</a>"
		var/muted = M.client.prefs.muted
		body += {"<br><b>Mute: </b>
			\[<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_IC]'><font color='[(muted & MUTE_IC)?"red":"blue"]'>IC</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_OOC]'><font color='[(muted & MUTE_OOC)?"red":"blue"]'>OOC</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_PRAY]'><font color='[(muted & MUTE_PRAY)?"red":"blue"]'>PRAY</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_ADMINHELP]'><font color='[(muted & MUTE_ADMINHELP)?"red":"blue"]'>ADMINHELP</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_DEADCHAT]'><font color='[(muted & MUTE_DEADCHAT)?"red":"blue"]'>DEADCHAT</font></a>\]
			(<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_ALL]'><font color='[(muted & MUTE_ALL)?"red":"blue"]'>toggle all</font></a>)
		"}

	body += {"
		<br><br>
		<a href='?src=[ref];jumpto=[REF(M)]'>Jump To</a> |
		<a href='?src=[ref];getmob=[REF(M)]'>Get Mob</a> |
		<a href='?src=[ref];sendmob=[REF(M)]'>Send Mob</a>
		<br>
	"}

	if(!istype(M, /mob/new_player))
		body += {"<br>
			<b>Transformation:</b><br>
			\[ Observer: <a href='?src=[ref];transform=observer;mob=[REF(M)]'>Observer</a> \]
			<br>\[ Humanoid: <a href='?src=[ref];transform=human;mob=[REF(M)]'>Human</a> |
			<a href='?src=[ref];transform=monkey;mob=[REF(M)]'>Monkey</a> |
			<a href='?src=[ref];transform=moth;mob=[REF(M)]'>Moth</a> |
			<a href='?src=[ref];transform=yautja;mob=[REF(M)]'>Yautja</a> \]
			<br>\[ Alien Tier 0:
			<a href='?src=[ref];transform=larva;mob=[REF(M)]'>Larva</a> \]
			<br>\[ Alien Tier 1:
			<a href='?src=[ref];transform=runner;mob=[REF(M)]'>Runner</a> |
			<a href='?src=[ref];transform=drone;mob=[REF(M)]'>Drone</a> |
			<a href='?src=[ref];transform=sentinel;mob=[REF(M)]'>Sentinel</a> |
			<a href='?src=[ref];transform=defender;mob=[REF(M)]'>Defender</a> \]
			<br>\[ Alien Tier 2:
			<a href='?src=[ref];transform=hunter;mob=[REF(M)]'>Hunter</a> |
			<a href='?src=[ref];transform=warrior;mob=[REF(M)]'>Warrior</a> |
			<a href='?src=[ref];transform=spitter;mob=[REF(M)]'>Spitter</a> |
			<a href='?src=[ref];transform=hivelord;mob=[REF(M)]'>Hivelord</a> |
			<a href='?src=[ref];transform=carrier;mob=[REF(M)]'>Carrier</a> \]
			<br>\[ Alien Tier 3:
			<a href='?src=[ref];transform=ravager;mob=[REF(M)]'>Ravager</a> |
			<a href='?src=[ref];transform=praetorian;mob=[REF(M)]'>Praetorian</a> |
			<a href='?src=[ref];transform=boiler;mob=[REF(M)]'>Boiler</a> |
			<a href='?src=[ref];transform=defiler;mob=[REF(M)]'>Defiler</a> |
			<a href='?src=[ref];transform=crusher;mob=[REF(M)]'>Crusher</a> \]
			<br>\[ Alien Tier 4:
			<a href='?src=[ref];transform=queen;mob=[REF(M)]'>Queen</a> \]
			<br>
		"}


		body += {"<br><br>
			<b>Other actions:</b>
			<br>
			<a href='?src=[ref];forcesay=[REF(M)]'>Forcesay</a> |
			<a href='?src=[ref];thunderdome=[REF(M)]'>Thunderdome</a> |
			<a href='?src=[ref];gib=[REF(M)]'>Gib</a>
		"}

	body += {"
	<br>
	</body></html>
	"}

	log_admin("[key_name(usr)] opened the player panel of [key_name(M)].")

	usr << browse(body, "window=adminplayeropts;size=550x515")