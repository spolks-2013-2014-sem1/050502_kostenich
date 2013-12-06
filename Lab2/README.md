Lab2
================

File transfering via TCP protocol

Requirments
-----------

###Ruby

* Ruby version >= 1.9.3

Manual
------

Start server with next operation:

    $ ruby server_main -n HOSTNAME -p PORTNUMBER -f FILEPATH

Then connect to this port with:

    $ ruby client_main -n HOSTNAME -p PORTNUMBER -s SERVERPORT -f FILEPATH

File from server_main application will be copied into file from client_main application.

Try <tt>-h</tt> argument for additional info.

  