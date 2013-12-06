Lab4
================

File transfering via UDP protocol.

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

You can use UDP protocol by typing <tt>-u</tt> flag on both server and client.

File from server_main application will be copied into file from client_main application.

Try <tt>-h</tt> argument for additional info.

  