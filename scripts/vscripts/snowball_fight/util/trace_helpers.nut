

::fire_trace <- function(tr_start, tr_end, tr_mask, tr_ignore, tr_filter, tr_debug = debug)
{
    local trace =
    {
        start = tr_start
        end = tr_end
        mask = tr_mask
        ignore = tr_ignore
        filter = tr_filter
    }

    if (tr_debug) print_pre_trace(trace)
    TraceLineFilter(trace)
    if (tr_debug) print_trace(trace)

    return trace
}

::fire_trace_hull <- function(tr_start, tr_end, tr_mask, tr_ignore, tr_hullmin, tr_hullmax, tr_filter, tr_debug = debug)
{
    local trace =
    {
        start = tr_start
        end = tr_end
        mask = tr_mask
        ignore = tr_ignore
        hullmin = tr_hullmin
        hullmax = tr_hullmax
        filter = tr_filter
    }

    if (tr_debug) print_pre_trace(trace)
    TraceHullFilter(trace)
    if (tr_debug) print_trace(trace)

    return trace
}