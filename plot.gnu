set term pngcairo size 800,600 enhanced font 'Verdana,10'
set output 'grafica_onda.png'
set title "Ecuación de Onda 1D (t=1 a 20)"
set xlabel "Posición (x)"
set ylabel "Tiempo (t)"
set zlabel "Amplitud u(x,t)"
set dgrid3d 30,30
set hidden3d
set pm3d
set view 60, 30
splot "datos_onda.dat" using 2:1:3 with lines title "u(x,t)"
