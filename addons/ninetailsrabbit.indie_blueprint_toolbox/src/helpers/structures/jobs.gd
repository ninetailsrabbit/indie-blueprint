## Wait for multiple callables to finish
## EXAMPLE:
## jobs.add(func(): ## do stuff):
## jobs.add(func(): ## do secondary stuff):
## await jobs.completed
class_name Jobs extends RefCounted

signal completed

var wait: bool = false
var started: int = 0
var finished: int = 0


func add(new_job: Callable):
	wait = true
	started += 1
	
	await new_job.call()
	finished += 1

	if started == finished:
		completed.emit()
