class_name IndieBlueprintNetworkHelper


static func get_local_ip(ip_type: IP.Type = IP.Type.TYPE_IPV4) -> String:
	if IndieBlueprintHardwareDetector.is_windows() and OS.has_environment("COMPUTERNAME"):
		return IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")), ip_type)
		
	elif (IndieBlueprintHardwareDetector.is_linux() or IndieBlueprintHardwareDetector.is_mac()) and OS.has_environment("HOSTNAME"):
		return IP.resolve_hostname(str(OS.get_environment("HOSTNAME")), ip_type)
		
	elif IndieBlueprintHardwareDetector.is_mac() and OS.has_environment("HOSTNAME"):
		return IP.resolve_hostname(str(OS.get_environment("HOSTNAME")), ip_type)
			
	return ""


static func is_valid_url(url: String) -> bool:
	var regex = RegEx.new()
	var url_pattern = "/(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?\\/[a-zA-Z0-9]{2,}|((https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?)|(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}(\\.[a-zA-Z0-9]{2,})?/g"
	regex.compile(url_pattern)
	
	return regex.search(url) != null


static func open_external_link(url: String) -> void:
	if is_valid_url(url) and OS.has_method("shell_open"):
		if OS.get_name() == "Web":
			url = url.uri_encode()
			
		OS.shell_open(url)


static func clear_signal_connections(selected_signal: Signal):
	for connection: Dictionary in selected_signal.get_connections():
		selected_signal.disconnect(connection.callable)
