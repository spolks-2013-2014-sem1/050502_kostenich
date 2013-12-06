Lab1
================

Telnet-based chat

Requirments
-----------

###Ruby

* Ruby version >= 1.9.3

Manual
------

Start chat "server" with next operation:

    $ ruby main.rb -n HOSTNAME -p PORTNUMBER

Then connect to this port via telnet.

You can use "ruby main.rb" w/o any arguments and it will create socket with "localhost: 2200".
Try <tt>-h</tt> argument for additional info.

	