//checks if a file exists and contains text
//returns text as a string if these conditions are met
/proc/return_file_text(filename)
	if(!fexists(filename))
		CRASH("File not found ([filename])")

	var/text = file2text(filename)
	if(!text)
		CRASH("File empty ([filename])")

	return text


//Sends resource files to client cache
/client/proc/getFiles()
	for(var/file in args)
		src << browse_rsc(file)