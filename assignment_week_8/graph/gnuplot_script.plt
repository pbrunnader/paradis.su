set terminal pdf
set output "ets_vs_dets.pdf"


# set title "512 number of processes (nodes)" 


set xlabel "number of records in the table"
set ylabel "wall clock time in seconds"

plot 'ets_dets_avg_min_max.log' using 1:($3):($4) smooth unique with filledcu linecolor rgb '#FFCCCC' title 'runtime range (min, max) using ETS', \
'ets_dets_avg_min_max.log' using 1:($2) smooth unique with lines linecolor rgb '#CC0000' title 'average runtime using ETS', \
'ets_dets_avg_min_max.log' using 1:($7):($8) smooth unique with filledcu linecolor rgb '#CCFFCC' title 'runtime range (min, max) using DETS', \
'ets_dets_avg_min_max.log' using 1:($6) smooth unique with lines linecolor rgb '#00CC00' title 'average runtime using DETS'



set output "ets_vs_dets_speedup.pdf"

set format y "%g %%"
set yrange [0:100]

set xlabel "number of records in the table"
set ylabel "speedup runtime in %"

plot 'ets_dets_all.log' using 1:($5/$2*100-100) smooth unique with lines linecolor rgb '#FF0000' title 'DETS / ETS'



