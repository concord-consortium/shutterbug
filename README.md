# Shutterbug

[![Build Status](https://travis-ci.org/concord-consortium/shutterbug.png?branch=master)](https://travis-ci.org/concord-consortium/shutterbug)
[![Code Climate](https://codeclimate.com/github/concord-consortium/shutterbug.png)](https://codeclimate.com/github/concord-consortium/shutterbug)

A rack utility using phantomjs that will create and save images (pngs) from parts of your html's documents current dom. These images become available as public png resources in the rack application. Currently shutterbug supports HTML, SVG and Canvas elements. Here is a sampel config.ru file:


    use Shutterbug::Rackapp do |config|
      conf.resource_dir       = "/Users/npaessel/tmp"
      config.uri_prefix       = "http://shutterbug.herokuapp.com"
      config.path_prefix      = "/shutterbug"
      config.phantom_bin_path = "/app/vendor/phantomjs/bin/phantomjs"
    end

Configuration options default to reasonable defaults.


## Installation

Add this line to your application's Gemfile:

    gem 'shutterbug'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shutterbug

## License ##

* [Simplified BSD](http://www.opensource.org/licenses/BSD-2-Clause),
* [MIT](http://www.opensource.org/licenses/MIT), or
* [Apache 2.0](http://www.opensource.org/licenses/Apache-2.0).

See [LICENSE.md](license.md) for more information.

## Usage

After adding `use Shutterbug::Rackapp` to your config.ru file, you can convert pieces of your web-page into png images.  Just follow these steps:

include the following javascript in your pages:  
     
     <script src='http://<yourhost:port>/shutterbug/shutterbug.js' type='text/javascript'></script>

Elsewhere in your javascript, something like this:
    
      var shutterbug = new Shutterbug('#sourceselector', '#outselector',optCallbackFn, optIdentifier);
      $('#button').click(function() {
        shutterbug.getDomSnapshot();
      });

This will replace the contents of `$("#outselector")` with an `<img src="http://<yourhost:port>/gete_png/sha1hash>` tag which will magically spring into existance.  `optCallbackFn` is an optional callback function which will be invoked whith the `<img src=..>` tag. `optIdentifier` is useful when there are multiple snapshot buttons targetting multiple iframes, and you need to verify the destination for various snapshot window message events.

## Deploying on Heroku ##

To deploy on heroku, you are going to want to modify your stack following [these instructions](http://nerdery.crowdmob.com/post/33143120111/heroku-ruby-on-rails-and-phantomjs).

Your app should have a config.ru that looks something like this:


    require 'shutterbug'
    require 'rack/cors'
       
    use Rack::Cors do
      allow do
        origins '*'
        resource '/shutterbug/*', :headers => :any, :methods => :any
      end
    end
    
    use Shutterbug::Rackapp do |config|
      config.uri_prefix = "http://<your app name>.herokuapp.com/"
      config.path_prefix = "/shutterbug"
      config.phantom_bin_path = "/app/vendor/phantomjs/bin/phantomjs"
    end
       
    app = proc do |env|
      [200, { 'Content-Type' => 'text/html' }, ['move along']]
    end
     
    run app

And a Procfile which looks like this:

    web: bundle exec rackup config.ru -p $PORT



## TODO: ##

*  Configuration of the rack paths.
*  Fix web-font bugs in phantom js.
*  Better abstraction phantomjs command line invocation. Use phantomjs.rb ?
*  Use [sprockets](https://github.com/sstephenson/sprockets) for and coffee.erb for shutterbug.js 
*  Write Tests.
*  Write Documentation.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

© 2013 The concord Consortium.
