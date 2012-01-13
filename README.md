# README

PhantomRb is a simple interface with phantomjs for Ruby


## Dependices

PhantomJS must be installed and the executable must exist in your PATH, install instructions can be found [here](http://www.phantomjs.org).


## Usage

PhantomRb is split into two parts the ruby bit and javascript bit


### Ruby

PhantomRb is simple, the ruby part simply calls javascript files on disk. PhantomRb simply provides an interface between the two.

The constructor simply accepts the path to the script to run

    script = Phantom.new("scripts/hello_world.coffee")

To run the script simple call `run` passing the args as a hash, the hash will be passed as a json object to the script.

    ret = script.run({
        :message => "Hello JavaScript"
    })

`run` will return an object of anything returned by the script, you can access the values via the hash accessor or the dot notation

    ret.data.message    # => "Hello Ruby"
    ret.data['message'] # => "Hello Ruby"

`status` is the exit status of the script run

    ret.status #=> unix exit status


### Javascript

The scripts run using PhantomRb don't need to be anything special, for example

    console.log("Hello badger")

However if you want to retrieve the arguments returned by the ruby, you can use the `PhantomRb.arg` object

    PhantomRb.arg("message") # => "Hello JavaScript"

And finally to return json from the script, the below also in turn calls `phantom.exit()` so it will be the last call in the script

    PhantomRb.exit({'message': "Hello Ruby"})

To specify a different exit code use the following syntax

    exit_status = 255
    PhantomRb.exit(exit_status, {'message': "Hello Ruby"})


### Complete example

The below example can be found in [./examples/](https://github.com/completelynovel/phantomrb/tree/master/examples)

**./examples/hello_world.coffee**

    message = PhantomRb.arg('message')
    console.log message
    PhantomRb.exit({
      'message': "Hello Ruby"
    })


**./examples/hello_world.rb**

    require 'phantomrb'

    script = PhantomRb.new("hello_world.coffee")
    ret = script.run({
      :message => "Hello Javascript"
    })
    puts ret.data.message

The output returned is

    Hello Javascript
    Hello Ruby



## Headless

If you on a server (something without a display) you'll need to run a fake x-server, to install this run the following

    apt-get install xvfb x11-xkb-utils xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic

Add the [/etc/init.d/Xvfb](https://github.com/completelynovel/phantomrb/blob/master/config/Xvfb) script

If `DISPLAY` is not set in the environment you'll also need to tell the PhantomRb which display to use, you can do this by giving an additional parameter to the `Phantom#new`

    display_num = 1
    Phantom.new("scripts/hello_world.coffee", display_num)


## Todo

 * stdout/stderr doesn't log out sequence
