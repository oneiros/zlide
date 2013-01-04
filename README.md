# zlide

zlide is a tool to build web-based presentations from markdown files.

It currently uses deck.js for handling of slides in the browser.

## Alternatives

zlide is currently a work in progress and you are probably better served by one of the many alternatives.

If all you want is to generate and dynamically serve up deck.js presentations from markdown files, have a look at deck.rb (https://github.com/alexch/deck.rb).

If you want a maximum of flexibility check out the excellent slideshow gem: http://slideshow.rubyforge.org/

## Installation

Install via rubygems:

    $ gem install zlide

## Usage

Create a new slide deck:

    $ zlide new <deck_name>

This will scaffold a directory called 'deck_name' with a few files and directories to get you started.

Change to the newly created directory, put one or more markdown files in the slides/ folder and you are good to go.

Serve up your presentation:

    $ zlide serve

This will start a web server on port 4567. Just navigate to http://localhost:4567 in your web browser.

Compile a pdf handout:

    $ zlide pdf

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
