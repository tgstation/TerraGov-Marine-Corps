/*
	Rendering system hacks
*/

/** This is for straight chat messages data */
function recieveMessage(data) {
	return putmessage(data);
}

/** This is for generic data */
function receiveData(data) {
	return get_event(data);
}
