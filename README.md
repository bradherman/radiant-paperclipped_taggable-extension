# Paperclipped Taggable

In most cases this is just a quick and clean way to get reasonably shiny image galleries on your site, but its real job is to support proper image, media and document archiving and retrieval. The galleries are just a way of playing back the archive, and you can drop any set of assets into a gallery format using the supplied tags:


## How

This extension applies our taggable mechanism to paperclipped assets and extends the set of r:assets tags with various useful gallery shortcuts.

For compatibility with the way pages work, it defines a keywords accessor in Asset and puts a keywords field in the edit view.

There's only a line of code and a couple of partials here: for the mechanism, see `taggable/lib/taggable_model.rb`.

## Status 

Brand new but most of the code is well broken-in and has survived in production for a couple of years.

## Requirements

* Radiant 0.7.x.
* paperclipped and taggable extensions

## Installation

As usual:

	git submodule add git://github.com/spanner/radiant-paperclipped_taggable-extension.git vendor/extensions/taggable
	rake radiant:extensions:paperclipped_taggable:update
	
## Configuration

You probably want to make sure that paperclipped and taggable load before this does. Multi_site too, if you're using that.
	
## Usage

...

## Author and copyright

* William Ross, for spanner. will at spanner.org
* Copyright 2009 spanner ltd
* released under the same terms as Rails and/or Radiant