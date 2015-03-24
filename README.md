# Shutterbug

[![Build Status](https://travis-ci.org/concord-consortium/shutterbug.png?branch=master)](https://travis-ci.org/concord-consortium/shutterbug)
[![Code Climate](https://codeclimate.com/github/concord-consortium/shutterbug.png)](https://codeclimate.com/github/concord-consortium/shutterbug)
[![Gem Version](https://badge.fury.io/rb/shutterbug.png)](http://badge.fury.io/rb/shutterbug)

## Overview ##

Shutterbug has two parts: a browser javascript library for taking html snapshots, and a server side utility for turning those html snapshots into images. This repository consists of JavaScript library.

### Server Side Utility

A rack utility using phantomjs that will create and save images (pngs) from parts of your html's documents current dom. These images become available as public png resources in the rack application. Currently shutterbug supports HTML, SVG and Canvas elements. Here is a sample config.ru file:


    use Shutterbug::Rackapp do |config|
      conf.resource_dir       = "/Users/npaessel/tmp"
      config.uri_prefix       = "http://shutterbug.herokuapp.com"
      config.path_prefix      = "/shutterbug"
      config.phantom_bin_path = "/app/vendor/phantomjs/bin/phantomjs"
    end

Configuration options default to reasonable defaults.

Shutterbug is distributed as a Ruby Gem. The rack service delivers a javascript library to the browser that can send HTML fragments back to the Rack service. The Rack service generates images from these fragments using PhantomJS.  In the following image “getDomSnapshot()” triggers a request to the Shutterbug service.  The response from the POST request contains an image tag, that points to a newly created image on the server.

  ![System Overview](images/shutterbug.jpg)

## Requirements & Dependencies

  * Ruby 1.9x or greater is required to run the Rack application.
  * [PhantomJS](http://phantomjs.org/) is requird to run the Rack application.

## Installation

Add this line to your application's Gemfile:

    gem 'shutterbug'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shutterbug

## License ##

Shutterbug is Copyright 2012 © by the Concord Consortium and is distributed under the [MIT License](LICENSE.md).


### Deploying on Heroku ###

To deploy on heroku, you are going to want to modify your stack following [these instructions](http://nerdery.crowdmob.com/post/33143120111/heroku-ruby-on-rails-and-phantomjs).

Your app should have a config.ru that looks something like this:


    require 'shutterbug'
    require 'rack/cors'

    use Rack::Cors do
      allow do
        origins '*'
        resource '/shutterbug/*'', :headers => :any, :methods => [:get, :post, :options]
      end
    end

    # Without a complete set of S3 credentials, Shutterbug
    # Places images in a temporary directory where
    # you will LOSE your images...
    use Shutterbug::Rackapp do |config|
      config.uri_prefix = "http://<your app name>.herokuapp.com/"
      config.path_prefix = "/shutterbug"
      config.phantom_bin_path = "/app/vendor/phantomjs/bin/phantomjs"
      # config.s3_key       = "your_S3_KEY"
      # config.s3_secret    = "your_S3_SECRET_DONT_COMMIT_IT"
      # config.s3_bin       = "your_S3_bucket_name"
    end

    app = proc do |env|
      [200, { 'Content-Type' => 'text/html' }, ['move along']]
    end

    run app

And a Procfile which looks like this:

    web: bundle exec rackup config.ru -p $PORT

## Changes ##

*  December 11, 2014 – v 0.5.0
    *  JS lib, JS handler and demos removed (as they are part of the new [shutterbug.js](https://github.com/concord-consortium/shutterbug.js) repo now).

*  December 4, 2014 – v 0.4.3
    *  Added support of various image formats and quality settings.

*  December 2, 2014 – v 0.3.0
    *  Improved canvas snapshot - data is uploaded directly to S3 from the browser (no PhantomJS rendering).

*  November 12, 2014 – v 0.2.5
    *  Added setFailureCallback to shutterbug.js for gracefully handling ajax failures in some custom way.
    *  Updated CORS configuration in config.ru to allow [:options] requests.


## TODO: ##

*  Configuration of the rack paths.
*  Fix web-font bugs in phantom js.
*  Better abstraction phantomjs command line invocation. Use phantomjs.rb ?
*  Use [sprockets](https://github.com/sstephenson/sprockets) for and coffee.erb for shutterbug.js
*  Write Tests.


## Contributing

2. Join the mailing list: [email](mailto:shutterbug-dev+subscribe@googlegroups.com) or [web](https://groups.google.com/forum/?hl=en#!forum/shutterbug-dev)
2. Fork this project.
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

© 2013 The Concord Consortium.
