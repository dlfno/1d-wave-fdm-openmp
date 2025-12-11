set term pngcairo size 1200,800 enhanced font 'Verdana,10'
set output 'grafica_onda.png'
set title "Ecuación de Onda 1D (Alta Resolución)"
set xlabel "Posición (x)"
set ylabel "Tiempo (t)"
set zlabel "Amplitud u(x,t)"

# BORRAMOS dgrid3d para usar los datos reales
# set dgrid3d 30,30

set hidden3d
set pm3d
set view 60, 30

# Ajustamos el rango de Z para que se vea bien la amplitud
set zrange [-1.1:1.1]

splot "datos_onda.dat" using 2:1:3 with lines palette linewidth 0.5 title "u(x,t)"
