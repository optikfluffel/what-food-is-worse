# What food is worse?

[Hackzurich 2014](http://hackzurich.com) project using Migros API preview.

Currently online at [what-food-is-worse.fluffel.io](http://what-food-is-worse.fluffel.io)


## Screenshot

![Screenshot of what-food-is-worse.fluffel.io](http://cl.ly/image/1P2z0d0d2e0B/Screen%20Shot%202014-10-12%20at%2005.44.43.png "Screenshot of what-food-is-worse.fluffel.io")


## Setup for development

### Dependencies

_Make sure you have [rvm](https://rvm.io) installed
(or anything other that can handle `.ruby-version` and `.ruby-gemset`)_

* If you haven't already install bundler using `gem install bundler`
* Run `bundle install`
* Make sure you have [mongoDB](http://www.mongodb.org) installed, up and running
* If you make changes be sure you have [EditorConfig](http://editorconfig.org) setup in your editor
or at least try to follow the rules at `.editorconfig`


### Initial Data Import

* Go and get the [MScraper](https://github.com/fliiiix/MScraper)
* Simply run it with `ruby scraper_take2.rb` to get the Data from the temporarily opened Preview of
an API from Migros
* Wait a minute or two


### Start server

* Just run `rackup`
* Visit [localhost:9292](http://localhost:9292) in your browser
