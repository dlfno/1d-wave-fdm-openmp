program ecuacion_onda
    implicit none
    
    ! Declaración de variables
    integer, parameter :: dp = kind(0.d0)
    integer :: nx, nt, i, n
    real(dp) :: c, L, T_max, dx, dt, cfl, pi
    real(dp), allocatable :: u_prev(:), u_curr(:), u_next(:), x(:)
    real(dp) :: time
    
    ! --- PARÁMETROS ---
    c = 2.0_dp          ! Velocidad
    L = 1.0_dp          ! Longitud del dominio
    dx = 0.1_dp         ! Paso espacial (h)
    dt = 0.05_dp        ! Paso temporal (tau)
    T_max = 20.0_dp     ! Tiempo final de simulación
    
    ! Constantes
    pi = 4.0_dp * atan(1.0_dp)
    
    ! Cálculo de puntos de malla
    nx = nint(L / dx) + 1
    nt = nint(T_max / dt)
    
    ! Asignación de memoria
    allocate(u_prev(nx), u_curr(nx), u_next(nx), x(nx))
    
    ! Cálculo del CFL
    cfl = (c * dt) / dx
    print *, "Analisis CFL:"
    print *, "Velocidad (c): ", c
    print *, "dx: ", dx, " dt: ", dt
    print *, "Numero CFL: ", cfl
    if (cfl > 1.0_dp) then
        print *, "ADVERTENCIA: Solucion inestable (CFL > 1)"
    else
        print *, "Esquema estable (CFL <= 1)"
    end if
    print *, "----------------------------------------"
    
    ! Inicialización de la malla espacial y condición inicial u(x,0)
    ! f(x) = sin(pi*x)
    open(unit=10, file='datos_onda.dat', status='replace')
    
    do i = 1, nx
        x(i) = (i-1) * dx
        u_curr(i) = sin(pi * x(i))  ! u en t=0
        u_prev(i) = 0.0_dp          ! Temporal
    end do
    
    ! Aplicar Condiciones de Frontera (Dirichlet u=0 en extremos)
    u_curr(1) = 0.0_dp
    u_curr(nx) = 0.0_dp
    
    ! --- PRIMER PASO DE TIEMPO (t=1) ---
    ! Usamos la condición g(x) = du/dt = 0 en t=0
    ! Formula: u_i^1 = u_i^0 + 0.5 * CFL^2 * (u_{i+1}^0 - 2u_i^0 + u_{i-1}^0)
    
    time = dt
    do i = 2, nx-1
        u_next(i) = u_curr(i) + 0.5_dp * cfl**2 * (u_curr(i+1) - 2.0_dp*u_curr(i) + u_curr(i-1))
    end do
    
    ! Fronteras
    u_next(1) = 0.0_dp
    u_next(nx) = 0.0_dp
    
    ! Actualizar arreglos para el bucle principal
    u_prev = u_curr
    u_curr = u_next
    
    ! --- BUCLE PRINCIPAL DE TIEMPO ---
    do n = 2, nt
        time = n * dt
        
        do i = 2, nx-1
            u_next(i) = 2.0_dp*(1.0_dp - cfl**2)*u_curr(i) &
                      + cfl**2 * (u_curr(i+1) + u_curr(i-1)) &
                      - u_prev(i)
        end do
        
        ! Fronteras
        u_next(1) = 0.0_dp
        u_next(nx) = 0.0_dp
        
        ! Guardar resultados solo si t >= 1.0
        if (time >= 1.0_dp) then
            ! Escribir formato: Tiempo  X  Amplitud
            do i = 1, nx
                write(10, *) time, x(i), u_next(i)
            end do
            write(10, *) "" ! Línea en blanco para separar bloques en Gnuplot
        end if
        
        ! Actualizar arreglos
        u_prev = u_curr
        u_curr = u_next
        
    end do
    
    close(10)
    print *, "Calculo finalizado. Datos guardados en 'datos_onda.dat'"
    
end program ecuacion_onda
