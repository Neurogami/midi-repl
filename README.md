# midi-repl #

A command-line REPL for sending MIDI messages.

You need the `unimidi` and `midi-eye` gems for this, as well as Mr. Bones if you want to use the Rake tasks.



## Usage ##


`$ midi-repl <optional-path-to-config-file>`

If you omit the path then `midi-repl` looks for a file  `.midi-config.yaml` in the current directory.

A config file is required though in practice nothing in the config file is required.  (Might consider dropping the requirement to use a config file.)

A config file looks like this:


      ---
      :device: 1
      :initial_messages:
       - 1 55 100
       - 1 55
       - 1 46 127
       - 1 46 


If you specify a device number then `midi-repl` attempts to open the device with that index.

If you leave out a device number you will see list of available devices and be prompted to select one.

If you specify any initial messages these will be preloaded in the Readline history and you can use the arrow keys to move through history and select messages to send or edit.

Right now `midi-repl` only handles note on and note off.  

The format:

    <channel> <note value> <velocity>

If you omit the last value it is treated as a note-off message.


## License ##

Copyright 2014 [James Britt](http://jamesbritt.com) / [Neurogami](http://neurogami.com)

Code is released under the [MIT license](http://opensource.org/licenses/MIT)

---

Feed your head.

Hack your world.

Live curious.

