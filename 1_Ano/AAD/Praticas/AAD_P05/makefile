#
# makefile for the practical class AAD_P05
#

clean:
	rm -f a.out hello one_to_one one_to_all

hello:		hello_world_mpi.c
	mpicc -Wall -O2 hello_world_mpi.c -o hello

.PHONY:		run_hello
run_hello:	hello
	mpirun -np 4 ./hello

one_to_one:	one_to_one_communication_mpi.c
	mpicc -Wall -O2 one_to_one_communication_mpi.c -o one_to_one

one_to_all:	one_to_all_communication_mpi.c
	mpicc -Wall -O2 one_to_all_communication_mpi.c -o one_to_all

.PHONY: run_to_one
run_to_one:	one_to_one
	mpirun -np 2 ./one_to_one

.PHONY: run_to_all
run_to_all:	one_to_all
	mpirun -np 4 ./one_to_all

