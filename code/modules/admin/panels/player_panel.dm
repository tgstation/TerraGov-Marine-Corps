/datum/admins/proc/player_panel()
	set category = "Admin"
	set name = "Player Panel"

	if(!check_rights(R_BAN))
		return

	var/dat = {"<html>

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
								var lsearch = td.getElementsByClassName("filter_data");
								var search = lsearch\[0\];
								if ( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									tr.innerHTML = "";
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

				function expand(id, job, name, real_name, old_names, key, ip, cid, ref){

					clearAll();

					var span = document.getElementById(id);
					var ckey = key.toLowerCase().replace(/\[^a-z@0-9\]+/g,"");

					body = "<table><tr><td>";

					body += "</td><td align='left'>";

					body += "<font size='2'>"+job+" - "+name+"<br>Real name: "+real_name+"<br>"+key+" ("+ip+", "+cid+")<br>Old names: "+old_names+"</font>";

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

						if(!id || !(id.indexOf("item")==0))
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
					notice_span.innerHTML = "<font color='#bc3c3c'>Locked</font> ";
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

		<table width='650' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
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
		<table width='650' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/i = 1
	for(var/mob/M in sortmobs())
		if(!M.ckey || !M.client)
			continue

		var/color = "#494949"
		if(i % 2 == 0)
			color = "#595959"

		var/M_job = ""

		if(isliving(M))
			if(iscarbon(M)) //Carbon stuff
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.job)
						M_job = H.job.title
				else if(ismonkey(M))
					M_job = "Monkey"
				else if(isxeno(M))
					if(M.client?.prefs?.xeno_name && M.client.prefs.xeno_name != "Undefined")
						M_job = "Xenomorph - [M.client.prefs.xeno_name]"
					else
						M_job = "Xenomorph"
				else
					M_job = "Carbon-based"

			else if(issilicon(M)) //silicon
				if(isAI(M))
					M_job = "AI"
				else
					M_job = "Silicon"

			else if(isanimal(M)) //simple animals
				if(iscorgi(M))
					M_job = "Corgi"
				else
					M_job = "Animal"

			else
				M_job = "Living"

		else if(istype(M,/mob/new_player))
			M_job = "New player"

		else if(isobserver(M))
			M_job = "Ghost"

		M_job = html_encode(M_job)
		var/M_name = html_encode(M.name)
		var/M_rname = html_encode(M.real_name)
		var/M_key = html_encode(M.key)
		var/M_cid = html_encode(M.computer_id)
		var/M_ip = html_encode(M.ip_address)

		var/previous_names = ""
		var/datum/player_details/P = GLOB.player_details[M.ckey]
		if(P)
			previous_names = P.played_names.Join(", ")
		previous_names = html_encode(previous_names)

		//output for each mob
		dat += {"

			<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
				<td align='center' bgcolor='[color]'>
					<span id='notice_span[i]'></span>
					<a id='link[i]'
					onmouseover='expand("item[i]","[M_job]","[M_name]","[M_rname]","[previous_names]","[M_key]","[M.ip_address]","[M.computer_id]","[REF(M)]")'
					>
					<b id='search[i]' style='font-weight:normal'>[M_name] - [M_rname] - [M_key] ([M_job])</b>
					<span hidden class='filter_data'>[M_name] [M_rname] [M_key] [M_job] [M_cid] [M_ip] [previous_names]</span>
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

	var/datum/browser/browser = new(usr, "players", "<div align='center'>Player Panel</div>", 700, 500)
	browser.set_content(dat)
	browser.open()



/datum/admins/proc/player_panel_extended()
	set category = "Admin"
	set name = "Player Panel Extended"

	if(!check_rights(R_BAN))
		return

	var/ref = "[REF(usr.client.holder)];[HrefToken()]"
	var/dat = "<table border=0 cellspacing=5><B><tr><th>Key</th><th>Name</th><th>Type</th><th>PP</th><th>CID</th><th>IP</th><th>JMP</th><th>FLW</th><th>Notes</th></tr></B>"

	for(var/mob/M in sortmobs())
		if(!M.ckey)
			continue

		dat += "<tr><td>[(M.key ? "[M.key]" : "No Key")]</td>"
		dat += "<td><a href='?priv_msg=[M.ckey]'>[M.name]</a></td>"
		if(isAI(M))
			dat += "<td>AI</td>"
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
		<td>[M.ip_address]</td>
		<td><a href='?src=[ref];observejump=[REF(M)]'>JMP</a></td>
		<td><a href='?src=[ref];observefollow=[REF(M)]'>FLW</a></td>
		<td><a href='?src=[ref];showmessageckey=[M.ckey]'>Notes</a></td>
		"}


	dat += "</table>"

	log_admin("[key_name(usr)] opened the extended player panel.")


	var/datum/browser/browser = new(usr, "players", "<div align='center'>Player Panel Extended</div>", 800, 600)
	browser.set_content(dat)
	browser.open()


/datum/admins/proc/show_player_panel(mob/M in GLOB.mob_list)
	set category = null
	set name = "Show Player Panel"

	if(!check_rights(R_ADMIN))
		return

	if(!istype(M))
		return

	var/ref = "[REF(usr.client.holder)];[HrefToken()]"
	var/body

	body += "<b>[M.name]</b>"

	if(M.client)
		body += " played by <b>[M.client]</b> "
		body += " <a href='?src=[ref];editrights=[(GLOB.admin_datums[M.client.ckey] || GLOB.deadmins[M.client.ckey]) ? "rank" : "add"];key=[M.key];close=1'>[M.client.holder ? M.client.holder.rank : "Player"]</a>"

	if(isnewplayer(M))
		body += " <b>Hasn't Entered Game</b> "
	else
		body += " | <a href='?src=[ref];revive=[REF(M)]'>Heal</a> | <a href='?src=[ref];sleep=[REF(M)]'>Sleep</a>"

	body += {"
		<br><br>
		<a href='?priv_msg=[M.ckey]'>PM</a> -
		<a href='?src=[ref];subtlemessage=[REF(M)]'>SM</a> -
		<a href='?_src_=vars;[HrefToken()];vars=[REF(M)]'>VV</a> -
		<a href='?src=[ref];spawncookie=[REF(M)]'>SC</a> -
		<a href='?src=[ref];spawnfortunecookie=[REF(M)]'>SFC</a> -
		<a href='?src=[ref];observejump=[REF(M)]'>JMP</a> -
		<a href='?src=[ref];observefollow=[REF(M)]'>FLW</a> -
		<a href='?src=[ref];individuallog=[REF(M)]'>LOGS</a></b><br>
		<b>Mob Type:</b> [M.type]<br>
		<b>Mob Location:</b> [AREACOORD(M.loc)]<br>"}

	if(isliving(M))
		var/mob/living/L = M
		body += "<b>Mob Faction:</b> [L.faction]<br>"
		if(L.job)
			body += "<b>Mob Role:</b> [L.job.title]<br>"

	body += "<b>CID:</b> [M.computer_id] | <b>IP:</b> [M.ip_address]<br>"
	if(M.client)
		body += "<br>\[<b>First Seen:</b> [M.client.player_join_date]\]\[<b>Byond account registered on:</b> [M.client.account_join_date]\]"
		if(M.client.related_accounts_cid || M.client.related_accounts_ip)
			//if(M.client.related_accounts_cid != "Requires database" && M.client.related_accounts_ip != "Requires database")
			body += "<br><b><font color=red>Player has related accounts</font></b> "
		body += "\[ <a href='?_src_=holder;[HrefToken()];showrelatedacc=cid;client=[REF(M.client)]'>CID related accounts</a> | "
		body += "<a href='?_src_=holder;[HrefToken()];showrelatedacc=ip;client=[REF(M.client)]'>IP related accounts</a> \]<br>"

	body += "<b>CentCom Galactic Ban DB: </b> "
	if(CONFIG_GET(string/centcom_ban_db))
		body += "<a href='?_src_=holder;[HrefToken()];centcomlookup=[M?.ckey]'>Search for ([M?.ckey])</a>"
	else
		body += "<i>Disabled</i>"

	body += "<br><br>"
	if(M.client)
		body += "<a href='?src=[ref];playtime=[REF(M)]'>Playtime</a> | "
		body += "<a href='?src=[ref];kick=[REF(M)]'>Kick</a> | "
		body += "<a href='?src=[ref];newbankey=[M.key];newbanip=[M.client.address];newbancid=[M.client.computer_id]'>Ban</a> | "
	else
		body += "<a href='?src=[ref];newbankey=[M.key]'>Ban</a> | "

	body += "<a href='?src=[ref];showmessageckey=[M.ckey]'>Notes</a> | "
	body += "<a href='?src=[ref];cryo=[REF(M)]'>Cryo</a>"

	if(M.client)
		body += "| <a href='?src=[ref];lobby=[REF(M)]'> Send back to Lobby</a>"

	body += "<br>"

	if(M.client?.prefs)
		var/muted = M.client.prefs.muted
		body += {"<br><b>Mute: </b>
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_IC]'><font color='[(muted & MUTE_IC) ? "#ff5e5e" : "white"]'>IC</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_OOC]'><font color='[(muted & MUTE_OOC) ? "#ff5e5e" : "white"]'>OOC</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_LOOC]'><font color='[(muted & MUTE_LOOC) ? "#ff5e5e" : "white"]'>LOOC</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_PRAY]'><font color='[(muted & MUTE_PRAY) ? "#ff5e5e" : "white"]'>PRAY</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_ADMINHELP]'><font color='[(muted & MUTE_ADMINHELP) ? "#ff5e5e" : "white"]'>ADMINHELP</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_DEADCHAT]'><font color='[(muted & MUTE_DEADCHAT) ? "#ff5e5e" : "white"]'>DEADCHAT</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_TTS]'><font color='[(muted & MUTE_TTS) ? "#ff5e5e" : "white"]'>TEXT TO SPEECH</font></a>
			(<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_ALL]'><font color='[(muted & MUTE_ALL) ? "#ff5e5e" : "white"]'>ALL</font></a>)
		"}

	body += {"
		<br><br>
		<a href='?src=[ref];jumpto=[REF(M)]'>Jump To</a> |
		<a href='?src=[ref];getmob=[REF(M)]'>Get Mob</a> |
		<a href='?src=[ref];sendmob=[REF(M)]'>Send Mob</a>
		<br>
	"}


	body += {"<br>
		<b>Transformation:</b>
		<br> Special:
		<a href='?src=[ref];transform=observer;mob=[REF(M)]'>Observer</a> |
		<a href='?src=[ref];transform=ai;mob=[REF(M)]'>AI</a>
		<a href='?src=[ref];transform=sectoid;mob=[REF(M)]'>Sectoid</a> |
		<a href='?src=[ref];transform=SKELETON;mob=[REF(M)]'>SKELETON</a>
		<br> Humanoid:
		<a href='?src=[ref];transform=human;mob=[REF(M)]'>Human</a> |
		<a href='?src=[ref];transform=synthetic;mob=[REF(M)]'>Synthetic</a> |
		<a href='?src=[ref];transform=early_synth;mob=[REF(M)]'>Early_Synth</a> |
		<a href='?src=[ref];transform=vatborn;mob=[REF(M)]'>Vatborn</a> |
		<a href='?src=[ref];transform=vatgrown;mob=[REF(M)]'>Vatgrown</a> |
		<a href='?src=[ref];transform=combat_robot;mob=[REF(M)]'>Combat_Robot</a> |
		<a href='?src=[ref];transform=monkey;mob=[REF(M)]'>Monkey</a> |
		<a href='?src=[ref];transform=moth;mob=[REF(M)]'>Moth</a> |
		<a href='?src=[ref];transform=zombie;mob=[REF(M)]'>Zombie</a> |
		<br> Alien Tier 0:
		<a href='?src=[ref];transform=larva;mob=[REF(M)]'>Larva</a> |
		<br> Alien Tier 1:
		<a href='?src=[ref];transform=runner;mob=[REF(M)]'>Runner</a> |
		<a href='?src=[ref];transform=drone;mob=[REF(M)]'>Drone</a> |
		<a href='?src=[ref];transform=sentinel;mob=[REF(M)]'>Sentinel</a> |
		<a href='?src=[ref];transform=defender;mob=[REF(M)]'>Defender</a> |
		<br> Alien Tier 2:
		<a href='?src=[ref];transform=hunter;mob=[REF(M)]'>Hunter</a> |
		<a href='?src=[ref];transform=bull;mob=[REF(M)]'>Bull</a> |
		<a href='?src=[ref];transform=warrior;mob=[REF(M)]'>Warrior</a> |
		<a href='?src=[ref];transform=spitter;mob=[REF(M)]'>Spitter</a> |
		<a href='?src=[ref];transform=hivelord;mob=[REF(M)]'>Hivelord</a> |
		<a href='?src=[ref];transform=carrier;mob=[REF(M)]'>Carrier</a> |
		<a href='?src=[ref];transform=wraith;mob=[REF(M)]'>Wraith</a> |
		<a href='?src=[ref];transform=puppeteer;mob=[REF(M)]'>Puppeteer</a> |
		<br> Alien Tier 3:
		<a href='?src=[ref];transform=ravager;mob=[REF(M)]'>Ravager</a> |
		<a href='?src=[ref];transform=widow;mob=[REF(M)]'>Widow</a> |
		<a href='?src=[ref];transform=praetorian;mob=[REF(M)]'>Praetorian</a> |
		<a href='?src=[ref];transform=boiler;mob=[REF(M)]'>Boiler</a> |
		<a href='?src=[ref];transform=defiler;mob=[REF(M)]'>Defiler</a> |
		<a href='?src=[ref];transform=crusher;mob=[REF(M)]'>Crusher</a>
		<a href='?src=[ref];transform=gorger;mob=[REF(M)]'>Gorger</a>
		<a href='?src=[ref];transform=warlock;mob=[REF(M)]'>Warlock</a>
		<a href='?src=[ref];transform=behemoth;mob=[REF(M)]'>Behemoth</a>
		<br> Alien Tier 4:
		<a href='?src=[ref];transform=queen;mob=[REF(M)]'>Queen</a> |
		<a href='?src=[ref];transform=shrike;mob=[REF(M)]'>Shrike</a> |
		<a href='?src=[ref];transform=hivemind;mob=[REF(M)]'>Hivemind</a> |
		<a href='?src=[ref];transform=king;mob=[REF(M)]'>King</a> |
		<br>
	"}


	if(!isnewplayer(M))
		body += "<br><br>"
		body += "<b>Other actions:</b>"
		body += "<br>"
		body += "<a href='?src=[ref];thunderdome=[REF(M)]'>Thunderdome</a> | "
		body += "<a href='?src=[ref];gib=[REF(M)]'>Gib</a>"

		if(isliving(M))
			body += "<br>"
			body += "<a href='?src=[ref];checkcontents=[REF(M)]'>Check Contents</a> | "
			body += "<a href='?src=[ref];offer=[REF(M)]'>Offer Mob</a> | "
			body += "<a href='?src=[ref];give=[REF(M)]'>Give Mob</a>"

			if(ishuman(M))
				body += "<br>"
				body += "<a href='?src=[ref];rankequip=[REF(M)]'>Rank and Equipment</a> | "
				body += "<a href='?src=[ref];editappearance=[REF(M)]'>Edit Appearance</a> | "
				body += "<a href='?src=[ref];randomname=[REF(M)]'>Randomize Name</a>"

	log_admin("[key_name(usr)] opened the player panel of [key_name(M)].")

	var/datum/browser/browser = new(usr, "player_panel_[key_name(M)]", "<div align='center'>Player Panel [key_name(M)]</div>", 575, 555)
	browser.set_content(body)
	browser.open()
