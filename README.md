# Paperclipped Taggable

In most cases this is just a quick and clean way to get reasonably shiny image galleries on your site, but its real job is to support proper image, media and document archiving and retrieval. The galleries are just a way of playing back the archive, and you can drop any set of assets into a gallery format using the supplied tags.

## How

This extension applies our taggable mechanism to paperclipped assets and extends the set of r:assets tags with various useful gallery shortcuts.

For compatibility with the way pages work, it defines a keywords accessor in Asset and puts a keywords field in the edit view.

There's only a line of code and a couple of partials here: for the mechanism, see `lib/taggable_model.rb` in the [taggable](https://github.com/spanner/radiant-taggable-extension/tree) extension.

## Status 

Brand new but most of the code is well broken-in and has survived in production for a couple of years.

## Requirements

* Radiant 0.7.x.
* [paperclipped](https://github.com/spanner/paperclipped) (currently you need our fork) and [taggable](https://github.com/spanner/radiant-taggable-extension) extensions

## Installation

As usual:

	git submodule add git://github.com/spanner/radiant-paperclipped_taggable-extension.git vendor/extensions/taggable
	rake radiant:extensions:paperclipped_taggable:update
	
## Configuration

You probably want to make sure that paperclipped and taggable load before this does. Multi_site too, if you're using that. This is the sequence I have to use:

	config.extensions = [ :share_layouts, :multi_site, :taggable, :reader, :reader_group, :paperclipped, :all ]
  
## Examples

There are galleries (with sample css and javascript):

	<r:gallery tags="2009,special" match_all="true" />		#-> large gallery of all images having both tags

	<r:minigallery />                   					#-> small rollover gallery of all images attached to current page.
	
And general-purpose archive tags to match those for pages:

	<r:assets:tags:each><li><r:tag:title /></li></r:assets:tags:each>
	<r:assets:related><r:thumbnail /></r:assets:related>

See the tag documentation for details. 

## Author and copyright

* William Ross, for spanner. will at spanner.org
* Copyright 2009 spanner ltd
* released under the same terms as Rails and/or Radiant