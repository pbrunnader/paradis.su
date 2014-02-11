set terminal pdf
set output "ring_smp_enable.pdf"

# set title "512 number of processes (nodes)" 
# set title "512 times round the ring" 
set title "512 = number of processes * times round the ring" 

# set xlabel "number of times round the ring"
set xlabel "number of processes (nodes)"
set ylabel "wall clock time"

set logscale y
set logscale x

file_by_column(filename,column,limit)="<php select_by_column.php ".filename." ".column." ".limit
merge_and_select_by_column(filename1,filename2,match,column,limit)="<php merge_and_select_by_column.php ".filename1." ".filename2." ".match." ".column." ".limit

# plot file_by_column('ring_smp_enable','1','7000') using 2:($3/1000000) smooth unique with linespoints title '-smp=enable:4:4', \
# file_by_column('ring_smp_disable','1','7000') using 2:($3/1000000) smooth unique with linespoints title '-smp=disable'


plot merge_and_select_by_column('enable','disable','1','4','512') using 1:($3) smooth unique with linespoints title '-smp=enable (4 cores)', \
merge_and_select_by_column('enable','disable','1','4','512') using 1:($7) smooth unique with linespoints title '-smp=disable'


# file_by_column('ring_smp_disable','1','1000') using 1:($3/1000000) smooth unique with linespoints title '-smp=disable'




