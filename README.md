# Planes of Imperial Japan

A fast and simple skin for a database of planes used by the IJA and IJN, using some nokogiri magic.
Currently available to [browse online here](https://planes-of-imperial-japan.tardate.com/).

![workflow-status](https://github.com/tardate/planes_of_imperial_japan/actions/workflows/rspec.yml/badge.svg)

## Notes

This is a little project made while waiting for a plane at Haneda Airport;-)

It is a simple parsing, re-organisation and presentation of information from the
[List of aircraft of Japan during World War II](https://en.wikipedia.org/wiki/List_of_aircraft_of_Japan_during_World_War_II)
wikipedia page, available under the
[Creative Commons Attribution-ShareAlike License](https://creativecommons.org/licenses/by-sa/4.0/deed.en).

## Setup

The catalog runs locally and needs a working ruby installation - I'm currently using Ruby 2.7.2 but the code is not version-sensitive.
Dependencies can be installed with bundler in the usual way, then you are good to go:

    bundle install

## Building the Plane Database

The `bin/update.rb` script builds a local cache of the plane database.
NB: this is sensitive to major changes in the wikipedia pages, but for now works fine.

Options:

    $ bin/update.rb
            Usage:
              bin/update.rb all                      # reload plane data and ensures the image cache is complete
              bin/update.rb cache                    # ensures the data and image cache is complete
              bin/update.rb show_categories          # show all categories used by current records in the database
              bin/update.rb (help)                   # this help

            Environment settings:
              BACKOFF_SECONDS # override the default backoff delay 0.3 seconds

## Testing the Loader Code

The code has rspec coverage:

    bundle exec rspec

Or with rake

    bundle exec rake spec

Or with guard

    bundle exec guard

## Running the Site

After updating the cache, the `index.html` presents a very snappy searchable and filterable listing of the plane database.
It's a simple web page using some basic Bootstrap and Datatables features with a little custom javascript.

Here's an example, with a simple search applied.
Each entry has links to the main Wikipedia page as well as search links for the plane on Scalemates and Google.

![file_example](./assets/file_example.jpg?raw=true)

Note: the catalog is loaded from JSON file, which presents a security issue if the `index.html` is loaded
locally as a file in a browser.

In Firefox, the security issue can be overcome by disabling the `security.fileuri.strict_origin_policy` preference in `about:config`

## Running with Sinatra

I've defined a simple Sinatra app in `app.rb` that can be used to serve the catalog
[locally over HTTP](http://localhost:4567/),
avoiding the browser limitations with loading the JSON data file. Run it with:

    $ ruby app.rb
    == Sinatra (v3.0.1) has taken the stage on 4567 for development with backup from Thin
    2023-09-27 19:30:43 +0900 Thin web server (v1.8.1 codename Infinite Smoothie)
    2023-09-27 19:30:43 +0900 Maximum connections set to 1024
    2023-09-27 19:30:43 +0900 Listening on localhost:4567, CTRL+C to stop
    ::1 - - [27/Sep/2023:19:30:57 +0900] "GET / HTTP/1.1" 302 - 0.0023
    ::1 - - [27/Sep/2023:19:30:57 +0900] "GET /index.html HTTP/1.1" 200 4986 0.0068
    ::1 - - [27/Sep/2023:19:30:58 +0900] "GET /assets/skin.css HTTP/1.1" 200 436 0.0014
    ::1 - - [27/Sep/2023:19:30:58 +0900] "GET /assets/flag.png HTTP/1.1" 200 9226 0.0006
    ::1 - - [27/Sep/2023:19:30:58 +0900] "GET /assets/skin.js HTTP/1.1" 200 4609 0.0016
    ::1 - - [27/Sep/2023:19:30:58 +0900] "GET /cache/data.json?_=1695810658264 HTTP/1.1" 200 121954 0.0030
    ::1 - - [27/Sep/2023:19:30:58 +0900] "GET /cache/images/7c698e1440838dc1b20c18ad1b61d217.jpg HTTP/1.1" 200 9916 0.0019
    ::1 - - [27/Sep/2023:19:30:58 +0900] "GET /cache/images/700b7a3089c2fcfe092ebba221d7c9c9.jpg HTTP/1.1" 200 9422 0.0016
    ...

![sinatra_example](./assets/sinatra_example.jpg?raw=true)

## Credits and References

* [List of aircraft of Japan during World War II](https://en.wikipedia.org/wiki/List_of_aircraft_of_Japan_during_World_War_II)
* [World War II Allied names for Japanese aircraft](https://en.wikipedia.org/wiki/World_War_II_Allied_names_for_Japanese_aircraft)
* [Datatables](https://datatables.net/)
* [Bootstrap](https://getbootstrap.com/docs/3.4/)
* [Sinatra Docs](http://sinatrarb.com/)
* [favicon.io](https://favicon.io/favicon-converter/) - used to generate the favicons
