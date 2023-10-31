debug <- true

::print_trace <- function(tr)
{
	if (!debug) return

	if ("hit" in tr)        printl("hit           " + tr.hit)
	if ("enthit" in tr)     printl("enthit        " + tr.enthit)
	if ("allsolid" in tr)   printl("allsolid      " + tr.allsolid)
	                        printl("startpos      " + tr.startpos)
	                        printl("endpos        " + tr.endpos)
	if ("startsolid" in tr) printl("startsolid    " + tr.startsolid)
	                        printl("plane_normal  " + tr.plane_normal)
	                        printl("plane_dist    " + tr.plane_dist)
	                        printl("surface_name  " + tr.surface_name)
	                        printl("surface_flags " + tr.surface_flags)
	                        printl("surface_props " + tr.surface_props)
}

::print_pre_trace <- function(tr)
{
	if (!debug) return

	local start = null
	local end = null
	if (start = "start" in tr)  printl("start   " + tr.start)
	if (end = "end" in tr)      printl("end     " + tr.end)
	if ("ignore" in tr)         printl("ignore  " + tr.ignore)
	if ("mask" in tr)           printl("mask    " + tr.mask)
	if ("hullmin" in tr)        printl("hullmin " + tr.hullmin)
	if ("hullmax" in tr)        printl("hullmax " + tr.hullmax)

	if ("start" in tr && "end" in tr)       DebugDrawLine(tr.start, tr.end, 255, 0, 0, false, 5)
	if ("hullmin" in tr && "hullmax" in tr) DebugDrawBox(tr.start, tr.hullmin, tr.hullmax, 255, 0, 0, 0, 5.0)
}