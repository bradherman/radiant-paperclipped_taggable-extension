# Paperclipped Taggable

This might still work but it has been replaced with the [library extension](http://github.com/spanner/radiant-library-extension), which clarifies much that is confused below and includes much better faceted gallery/library retrieval tools.

...

On first encounter this is probably just a quick way to get reasonably shiny image galleries on your site, but its real job is to support a proper image, media and document library. The galleries are just a way of playing back the library, and you can also do things like putting related downloads on a page or retrieving documents by tag-overlap.

## How

This extension applies our taggable mechanism to paperclipped assets and extends the set of r:assets tags with various useful gallery shortcuts.

For compatibility with the way pages work, it defines a keywords accessor in Asset and puts a keywords field in the edit view.

## Status 

New but very simple. The work is done in the taggable extension: all we really do here is apply that to assets and add some radius tags for showing galleries.

## Requirements

* Radiant 0.7.x or 0.8.0.
* [paperclipped](https://github.com/spanner/paperclipped) (currently, requires our fork) and [taggable](https://github.com/spanner/radiant-taggable-extension) extensions

The galleries use mootools, which is included, because I like it better. 
It's all done unobtrusively - all we put on the page is lists - so you could easily replace it with a slimbox or some other library.

## Installation

As usual:

	git submodule add git://github.com/spanner/radiant-paperclipped_taggable-extension.git vendor/extensions/paperclipped_taggable
	rake radiant:extensions:paperclipped_taggable:update
	
## Configuration

You need to make sure that paperclipped and taggable load before this does. Multi_site too, if you're using that. This is the sequence I have:

	config.extensions = [ :share_layouts, :multi_site, :taggable, :reader, :reader_group, :paperclipped, :all ]
  
## Examples

There are galleries and tag clouds:

	<r:assets:gallery tags="ridiculous,special" match_all="true" />		#-> full-page gallery of all images having both tags
	<r:assets:minigallery />                   							#-> small rollover gallery of all images attached to current page.
	<r:assets:tag_cloud />
	
Selection and sub-selection tags for displaying various lists, usually but not necessarily on TagPage pages:

	<r:tagged_assets:each>...</r:tagged_assets:each>

and for each type of asset:

	<r:tagged_assets:images:each>...</r:tagged_assets:images:each>
	<r:tagged_assets:if_any_images>...</r:tagged_assets:if_any_images>
	<r:tagged_assets:unless_any_images>...</r:tagged_assets:unless_any_images>
	<r:tagged_assets:if_any_not_images>...</r:tagged_assets:if_any_not_images>
	<r:tagged_assets:unless_any_not_images>...</r:tagged_assets:unless_any_not_images>

General-purpose archive tags to match those for pages:

	<r:assets:tags:each><li><r:tag:title /></li></r:assets:tags:each>
	<r:assets:related><r:link /></r:assets:related>

For consistency the asset tags use the plural form. See the radius tag documentation for details. 

## Author and copyright

* William Ross, for spanner. will at spanner.org
* Copyright 2009 spanner ltd
* released under the same terms as Rails and/or Radiant