set terminal pdf
set output "ets_vs_dets.pdf"

# set title "512 number of processes (nodes)" 
# set title "512 times round the ring" 
# set title "512 = number of processes * times round the ring" 

# set xlabel "number of times round the ring"
set xlabel "number of records in the table"
set ylabel "wall clock time in seconds"


plot 'ets_vs_dets.txt' using 1:($2) smooth unique with linespoints title 'Erlang Built-in Term Storage', \
'ets_vs_dets.txt' using 1:($5) smooth unique with linespoints title 'Disk Based Term Storage'

set output "ets_vs_dets_speedup.pdf"

set format y "%g %%"
set yrange [-50:200]

set xlabel "number of records in the table"
set ylabel "better or worse runtime in %"

# set logscale y
set logscale x

plot 'ets_vs_dets.txt' using 1:($5/$2*100-100) smooth unique with linespoints title 'Disk Based Term Storage / Erlang Built-in Term Storage', \
'ets_vs_dets.txt' using 1:(0) smooth unique with lines title 'identical runtime'




