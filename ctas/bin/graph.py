#!/usr/bin/env python

import os, sys


#rrd_dir=sys.argv[1]
rrd_dir="/var/lib/ganglia/rrds/unspecified/cn2.massive.synchrotron.org.au/"
start=sys.argv[1]
end=sys.argv[2]

#start=""
#end=""

#########
#
# Colors for the CPU report graph
#
cpu_user_color="3333bb"
cpu_nice_color="ffea00"
cpu_system_color="dd0000"
cpu_wio_color="ff8a60"
cpu_idle_color="e2e2f2"

#
# Colors for the MEMORY report graph
#
mem_used_color="5555cc"
mem_shared_color="0000aa"
mem_cached_color="33cc33"
mem_buffered_color="99ff33"
mem_free_color="00ff00"
mem_swapped_color="9900CC";

#
# Colors for the LOAD report graph
#
load_one_color="CCCCCC"
proc_run_color="0000FF"
cpu_num_color="FF0000"
num_nodes_color="00FF00"

# Other colors
jobstart_color="ff3300"

#
# Default color for single metric graphs
#
default_metric_color="5555cc"

#########
#
# cpu graph
#
series=" \
DEF:cpu_user=" + rrd_dir + "/cpu_user.rrd:sum:AVERAGE " + \
"DEF:cpu_nice=" + rrd_dir + "/cpu_nice.rrd:sum:AVERAGE " + \
"DEF:cpu_system=" + rrd_dir + "/cpu_system.rrd:sum:AVERAGE " + \
"DEF:cpu_idle=" + rrd_dir + "/cpu_idle.rrd:sum:AVERAGE " + \
"DEF:cpu_wio=" + rrd_dir + "/cpu_wio.rrd:sum:AVERAGE " + \
"AREA:cpu_user#" + cpu_user_color + ":'User CPU' " + \
"STACK:cpu_nice#" + cpu_nice_color + ":'Nice CPU' " + \
"STACK:cpu_system#" + cpu_system_color + ":'System CPU' " + \
"STACK:cpu_wio#" + cpu_wio_color + ":'WAIT CPU' " + \
"STACK:cpu_idle#" + cpu_idle_color + ":'Idle CPU' " \

os.system("/usr/bin/rrdtool graph cpu.png --imgformat PNG --start " + start + " --end " + end + " --width 800 --height 200 \
--upper-limit 100 --rigid --lower-limit 0 --vertical-label Percent --title CPU " + str(series))

#########
#
# mem graph
#

series="\
DEF:mem_total=" + rrd_dir + "/mem_total.rrd:sum:AVERAGE CDEF:bmem_total=mem_total,1024,* " + \
"DEF:mem_shared=" + rrd_dir + "/mem_shared.rrd:sum:AVERAGE CDEF:bmem_shared=mem_shared,1024,* " + \
"DEF:mem_free=" + rrd_dir + "/mem_free.rrd:sum:AVERAGE CDEF:bmem_free=mem_free,1024,* " + \
"DEF:mem_cached=" + rrd_dir + "/mem_cached.rrd:sum:AVERAGE CDEF:bmem_cached=mem_cached,1024,* " + \
"DEF:mem_buffers=" + rrd_dir + "/mem_buffers.rrd:sum:AVERAGE CDEF:bmem_buffers=mem_buffers,1024,* " + \
"CDEF:bmem_used=bmem_total,bmem_shared,-,bmem_free,-,bmem_cached,-,bmem_buffers,- " + \
"AREA:bmem_used#" + mem_used_color + ":'Memory Used' STACK:bmem_shared#" + mem_shared_color + ":'Memory Shared' " + \
"STACK:bmem_cached#" + mem_cached_color + ":'Memory Cached' STACK:bmem_buffers#" + mem_buffered_color + ":'Memory Buffered' " + \
"DEF:swap_total=" + rrd_dir + "/swap_total.rrd:sum:AVERAGE DEF:swap_free=" + rrd_dir + "/swap_free.rrd:sum:AVERAGE " + \
"CDEF:bmem_swapped=swap_total,swap_free,-,1024,* STACK:bmem_swapped#" + mem_swapped_color +":'Memory Swapped' " +\
"LINE2:bmem_total#" + cpu_num_color + ":'Total In-Core Memory' "

os.system("/usr/bin/rrdtool graph mem.png --imgformat PNG --start " + start + " --end " + end + " --width 800 --height 200 \
--lower-limit 0 --rigid --base 1024 --vertical-label Bytes " + str(series))


#########
#
# load graphs
#
#  one minute load
series="DEF:load_one=" + rrd_dir + "/load_one.rrd:sum:AVERAGE " + \
"DEF:proc_run=" + rrd_dir + "/proc_run.rrd:sum:AVERAGE " + \
"DEF:cpu_num=" + rrd_dir + "/cpu_num.rrd:sum:AVERAGE " + \
"AREA:load_one#" + load_one_color + ":'1-min Load' " + \
"LINE2:cpu_num#" + cpu_num_color + ":'CPUs' " + \
"LINE2:proc_run#" + proc_run_color + ":'Running Processes' "

os.system("/usr/bin/rrdtool graph load1.png --imgformat PNG --start " + start + " --end " + end + " --width 800 --height 200 \
--lower-limit 0 --rigid --vertical-label Load/Procs " + str(series))

#  five minute load
series="DEF:load_five=" + rrd_dir + "/load_five.rrd:sum:AVERAGE " + \
"DEF:proc_run=" + rrd_dir + "/proc_run.rrd:sum:AVERAGE " + \
"DEF:cpu_num=" + rrd_dir + "/cpu_num.rrd:sum:AVERAGE " + \
"AREA:load_five#" + load_one_color + ":'5-min Load' " + \
"LINE2:cpu_num#" + cpu_num_color + ":'CPUs' " + \
"LINE2:proc_run#" + proc_run_color + ":'Running Processes' "

os.system("/usr/bin/rrdtool graph load5.png --imgformat PNG --start " + start + " --end " + end + " --width 800 --height 200 \
--lower-limit 0 --rigid --vertical-label Load/Procs " + str(series))

#  15 minute load
series="DEF:load_fifteen=" + rrd_dir + "/load_fifteen.rrd:sum:AVERAGE " + \
"DEF:proc_run=" + rrd_dir + "/proc_run.rrd:sum:AVERAGE " + \
"DEF:cpu_num=" + rrd_dir + "/cpu_num.rrd:sum:AVERAGE " + \
"AREA:load_fifteen#" + load_one_color + ":'15-min Load' " + \
"LINE2:cpu_num#" + cpu_num_color + ":'CPUs' " + \
"LINE2:proc_run#" + proc_run_color + ":'Running Processes' "

os.system("/usr/bin/rrdtool graph load15.png --imgformat PNG --start " + start + " --end " + end + " --width 800 --height 200 \
--lower-limit 0 --rigid --vertical-label Load/Procs " + str(series))

#########
#
# network graph
#
#
series="DEF:bytes_in=" + rrd_dir + "/bytes_in.rrd:sum:AVERAGE " + \
"DEF:bytes_out=" + rrd_dir + "/bytes_out.rrd:sum:AVERAGE " + \
"LINE2:bytes_in#" + mem_cached_color + ":'In' " + \
"LINE2:bytes_out#" + mem_used_color + ":'Out' "

os.system("/usr/bin/rrdtool graph net.png --imgformat PNG --start " + start + " --end " + end + " --width 800 --height 200 \
--lower-limit 0 --rigid --base 1024 --vertical-label Bytes/sec " + str(series))


#########
#
# single metric graphs
#
#

# memory buffers
#metricName="mem_buffers"
#series = "DEF:sum=" + rrd_dir + "/" + metricName + ".rrd:sum:AVERAGE AREA:sum#" + default_metric_color + ":'Memory Buffers' "
#os.system("/usr/bin/rrdtool graph " + metricName + ".png --imgformat PNG --start " + start + " --end " + end + " --width 800 --height 200 \
#--lower-limit 0 --rigid --base 1024 --vertical-label KB " + str(series))

# memory cached
#metricName="mem_cached"
#series = "DEF:sum=" + rrd_dir + "/" + metricName + ".rrd:sum:AVERAGE AREA:sum#" + default_metric_color + ":'Memory Cached' "
#os.system("/usr/bin/rrdtool graph " + metricName + ".png --imgformat PNG --start " + start + " --end " + end + " --width 800 --height 200 \
#--lower-limit 0 --rigid --base 1024 --vertical-label KB " + str(series))

# swap used
#series="\
#DEF:swap_total=" + rrd_dir + "/swap_total.rrd:sum:AVERAGE DEF:swap_free=" + rrd_dir + "/swap_free.rrd:sum:AVERAGE " + \
#"CDEF:bmem_swapped=swap_total,swap_free,-,1024,* AREA:bmem_swapped#" + mem_swapped_color +":'Memory Swapped' "
#os.system("/usr/bin/rrdtool graph swap-used.png --imgformat PNG --start " + start + " --end " + end + " --width 800 --height 200 \
#--lower-limit 0 --rigid --base 1024 --vertical-label " + str(series))


#

