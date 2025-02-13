#
# makefile for the practical class AAD_P04
#

clean:
	rm -f a.out client server

server:		server_clients.c
	cc -Wall -O2 -DSERVER=1 server_clients.c -o server

client:		server_clients.c
	cc -Wall -O2 -DSERVER=0 server_clients.c -o client
