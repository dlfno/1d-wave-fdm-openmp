program ecuacion_onda_omp
    use iso_fortran_env
    use omp_lib  ! Necesario para funciones de OpenMP
    implicit none
    
    ! Declaración de variables
    integer, parameter :: dp = kind(0.d0)
    integer :: nx, nt, i, n
    real(dp) :: c, L, T_max, dx, dt, cfl, pi_val
    real(dp), allocatable :: u_prev(:), u_curr(:), u_next(:), x(:)
    real(dp) :: time
    real(dp) :: start_time, end_time ! Para medir rendimiento
    
    ! --- PARÁMETROS ---
    c = 2.0_dp
    L = 1.0_dp
    dx = 0.1_dp        
    dt = 0.05_dp       
    T_max = 20.0_dp    
    
    pi_val = 4.0_dp * atan(1.0_dp)
    
    ! Cálculo de puntos de malla
    nx = nint(L / dx) + 1
    nt = nint(T_max / dt)
    
    allocate(u_prev(nx), u_curr(nx), u_next(nx), x(nx))
    
    ! --- INICIO MEDICIÓN DE TIEMPO ---
    start_time = omp_get_wtime()
    
    ! Inicialización (Paralelizable)
    !$omp parallel do private(i)
    do i = 1, nx
        x(i) = (i-1) * dx
        u_curr(i) = sin(pi_val * x(i))
        u_prev(i) = 0.0_dp
    end do
    !$omp end parallel do
    
    u_curr(1) = 0.0_dp; u_curr(nx) = 0.0_dp
    cfl = (c * dt) / dx
    
    ! --- PRIMER PASO (t=1) ---
    !$omp parallel do private(i)
    do i = 2, nx-1
        u_next(i) = u_curr(i) + 0.5_dp * cfl**2 * (u_curr(i+1) - 2.0_dp*u_curr(i) + u_curr(i-1))
    end do
    !$omp end parallel do
    
    u_next(1) = 0.0_dp; u_next(nx) = 0.0_dp
    u_prev = u_curr
    u_curr = u_next
    
    ! --- BUCLE PRINCIPAL (Time-Stepping) ---
    ! Nota: El bucle de tiempo 'n' NO se puede paralelizar (dependencia de datos)
    ! Pero el bucle espacial 'i' SÍ se paraleliza en cada paso.
    
    do n = 2, nt
        time = n * dt
        
        ! Región Paralela OpenMP
        !$omp parallel do private(i) shared(u_next, u_curr, u_prev, cfl) schedule(static)
        do i = 2, nx-1
            u_next(i) = 2.0_dp*(1.0_dp - cfl**2)*u_curr(i) &
                      + cfl**2 * (u_curr(i+1) + u_curr(i-1)) &
                      - u_prev(i)
        end do
        !$omp end parallel do
        
        u_next(1) = 0.0_dp
        u_next(nx) = 0.0_dp
        
        ! Escritura de datos (solo en el hilo maestro y cada cierto tiempo para no afectar performance)
        ! Para benchmark puro, a veces se comenta la escritura.
        if (mod(n, 20) == 0) then
             ! Aquí iría la escritura, omitida para no ensuciar el código de ejemplo
        end if
        
        u_prev = u_curr
        u_curr = u_next
        
    end do

    ! --- FIN MEDICIÓN DE TIEMPO ---
    end_time = omp_get_wtime()
    
    print *, "Simulacion OpenMP finalizada."
    print *, "Hilos usados: ", omp_get_max_threads()
    print *, "Tiempo de ejecucion (s): ", end_time - start_time
    
end program ecuacion_onda_omp
