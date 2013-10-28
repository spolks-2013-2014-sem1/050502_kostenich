050502_kostenich
================

Lab1:
	To start the program type "ruby main.rb -n HOSTNAME -p PORTNUMBER" in your terminal, then connect to this port via telnet.
	You can use "ruby main.rb" w/o any arguments and it will create socket with "localhost: 2200".
	For additional info type "ruby main.rb -h" in your terminal.

Lab2:
	To start the program type "ruby server_main -n HOSTNAME -p PORTNUMBER -f FILEPATH" in your terminal.
	Then connect to this port with typing "ruby client_main -n HOSTNAME -p PORTNUMBER -s SERVERPORT -f FILEPATH" in your terminal.
	File from server_main application will be copied into file from client_main application.
	Although, you can use default arguments for applications, just type "ruby <server>/<client>_main -h" in your terminal.