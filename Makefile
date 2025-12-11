# Makefile Maestro: Serial vs OpenMP
FC = gfortran

# Directorios
DIR_SERIAL = src/serial
DIR_OMP = src/openmp

# Flags
FLAGS_SERIAL = -O3 -Wall
FLAGS_OMP = -O3 -Wall -fopenmp

# Targets (Ejecutables)
EXEC_SERIAL = onda_serial
EXEC_OMP = onda_omp

# --- REGLAS ---

all: info

info:
	@echo "Usa: make serial   -> Para compilar la version normal"
	@echo "Usa: make openmp   -> Para compilar la version paralela"
	@echo "Usa: make clean    -> Para limpiar"

# Compilar Serial
serial: $(DIR_SERIAL)/onda_serial.f90
	$(FC) $(FLAGS_SERIAL) $(DIR_SERIAL)/onda_serial.f90 -o $(EXEC_SERIAL)
	@echo ">>> Compilado version SERIAL: ./$(EXEC_SERIAL)"

# Compilar OpenMP
openmp: $(DIR_OMP)/onda_omp.f90
	$(FC) $(FLAGS_OMP) $(DIR_OMP)/onda_omp.f90 -o $(EXEC_OMP)
	@echo ">>> Compilado version OPENMP: ./$(EXEC_OMP)"

# Ejecutar pruebas rápidas
run_serial: serial
	./$(EXEC_SERIAL)

run_omp: openmp
	./$(EXEC_OMP)

clean:
	rm -f $(EXEC_SERIAL) $(EXEC_OMP) *.mod *.o *.dat

.PHONY: all serial openmp clean run_serial run_omp
