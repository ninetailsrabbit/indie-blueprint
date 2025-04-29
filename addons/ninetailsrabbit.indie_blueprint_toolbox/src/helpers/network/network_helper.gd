class_name IndieBlueprintNetworkHelper


static func validate_ipv4(ip: String) -> bool:
	var ipv4_regex: RegEx = RegEx.new()
	
	return ipv4_regex.compile(r"^(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)){3}$")


static func validate_ipv6(ip: String) -> bool:
	var ipv6_regex: RegEx = RegEx.new()
	
	return ipv6_regex.compile(r"(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))")
	
	
static func port_in_valid_range(port: int) -> bool:
	return IndieBlueprintMathHelper.value_is_between(port, 1, pow(2, 16) - 1) ## 65536 - 1


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
