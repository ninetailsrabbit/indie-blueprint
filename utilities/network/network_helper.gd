class_name NetworkHelper


static func get_local_ip(ip_type: IP.Type = IP.Type.TYPE_IPV4) -> String:
	if HardwareDetector.is_windows() and OS.has_environment("COMPUTERNAME"):
		return IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")), ip_type)
		
	elif (HardwareDetector.is_linux() or HardwareDetector.is_mac()) and OS.has_environment("HOSTNAME"):
		return IP.resolve_hostname(str(OS.get_environment("HOSTNAME")), ip_type)
		
	elif HardwareDetector.is_mac() and OS.has_environment("HOSTNAME"):
		return IP.resolve_hostname(str(OS.get_environment("HOSTNAME")), ip_type)
			
	return ""


static func is_valid_url(url: String) -> bool:
	var regex = RegEx.new()
	var url_pattern = "/(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?\\/[a-zA-Z0-9]{2,}|((https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?)|(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}(\\.[a-zA-Z0-9]{2,})?/g"
	regex.compile(url_pattern)
	
	return regex.search(url) != null


func open_external_link(url: String) -> void:
	if is_valid_url(url) and OS.has_method("shell_open"):
		if OS.get_name() == "Web":
			url = url.uri_encode()
			
		OS.shell_open(url)
