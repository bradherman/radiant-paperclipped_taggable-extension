module AssetGalleryTags
  include Radiant::Taggable
  
  class TagError < StandardError; end
    
  desc %{
    Prepares a collection of all the assets in the site. Useful to set context for a gallery or tag cloud.
    Supply a type parameter with one of image, audio, movie or other to limit the collection to that kind of asset.
  }    
  tag "assets:everything" do |tag|
    tag.locals.assets = Asset.find(:all)
    _subset_assets!(tag)
    tag.expand
  end

  desc %{
    Prepares a collection of all the assets attached to the page. Useful to set context for a gallery or tag cloud.
  }    
  tag "assets:all" do |tag|
    tag.locals.assets = tag.locals.page.assets
    tag.expand
  end

  %w(movie audio image other playable).each do |type|
    desc %{
      Prepares a collection of all the #{type} assets attached to the current page.  
    }    
    tag "assets:all_#{type.pluralize}" do |tag|
      tag.locals.assets ||= tag.locals.page.assets.send(type.pluralize.intern).find(:all)
      tag.expand
    end
  end
  
  desc %{
    Cycles through all tags attached to present asset.
    Takes the same sort and order parameters as children:each.
    Assets is plural for consistency with other paperclipped tags: 
    we're actually working with a single asset here.
    
    *Usage:* 
    <pre><code><r:assets:tags><r:tag:title /></r:assets:tags></code></pre>
  }    
  tag 'assets:tags' do |tag|
    raise TagError, "asset must be defined for asset:tags tag" unless tag.locals.asset
    tag.expand
  end
  tag 'assets:tags:each' do |tag|
    result = []
    tag.locals.asset.tags.each do |t|
      tag.locals.tag = t
      result << tag.expand
    end 
    result
  end

  
  desc %{
    Cycles through related assets of a tagged asset or page in descending order of relatedness.
    
    *Usage:* 
    <pre><code><r:assets:related:each>...</r:assets:related:each></code></pre>
  }    
  tag 'assets:related' do |tag|
    raise TagError, "page or asset must be defined for assets:related tag" unless tag.locals.page or tag.locals.asset
    tag.expand
  end
  tag 'assets:related:each' do |tag|
    result = []
    thing = tag.locals.asset || tag.locals.page
    thing.related_assets.each do |asset|
      tag.locals.asset = asset
      result << tag.expand
    end 
    result
  end

  
  desc %{
    Loops through the assets to which the present tag has been applied
    
    *Usage:* 
    <pre><code><r:tag:assets:each>...</r:tag:assets:each></code></pre>
  }    
  tag 'tag:assets' do |tag|
    raise TagError, "tag must be defined for tag:assets tag" unless tag.locals.tag
    tag.expand
  end
  tag 'tag:assets:each' do |tag|
    result = []
    tag.locals.tag.assets.each do |item|
      tag.locals.asset = item
      result << tag.expand
    end 
    result
  end


  desc %{
    Loops through all the assets with any of the specified tags,
    In descending order of overlap between asset tags and specified list
    
    *Usage:* 
    <pre><code><r:assets:tagged tags="tag1[, tag2, etc]">...</r:assets:tagged></code></pre>
  }    
  tag 'assets:tagged' do |tag|
    result = []
    _assets_for_tags(tag.attr['tags']).each do |asset|
      tag.locals.asset = asset
      result << tag.expand
    end 
    result
  end

  
  desc %{ 
    Presents a standard marginal gallery block suitable for turning unobtrusively into a rollover or lightbox gallery. 
    We need to be able to work out a collection of assets: that can be defined already (eg by assets:all) or come from a page or tag or from one or more tags.
    If no tags are found, nothing is displayed.
    Default preview size is 'large' and thumbnail size 'thumbnail' but you can specify any standard asset sizes.
    
    *Usage:*
    <pre><code>
      <r:assets:minigallery [size="..."] [thumbnail_size="..."] [tags="one,or,more,tags"] />
    </code></pre>

  }
  tag 'assets:minigallery' do |tag|
    raise TagError, "asset collection must be available for assets:minigallery tag" unless tag.locals.assets or tag.locals.page or tag.locals.tag or tag.attr['tags']
    assets = _current_assets(tag, :images)

    unless assets.empty?
      size = tag.attr['size'] || 'large'
      thumbsize = tag.attr['thumbnail_size'] || 'thumbnail'
      result = ""
      result << %{<div class="illustration">}
      tag.locals.asset = assets.shift
      result << tag.render('assets:image', {'size' => size})
      result << %{<p class="caption">#{tag.locals.asset.caption}</p>}
      assets.each do |a|
        tag.locals.asset = a
        result << %{<div class="thumbnail"><a href="#{tag.render('assets:link', 'size' => 'illustration')}">}
        result << tag.render('assets:image', {'size' => thumbsize, 'title' => a.caption, 'alt' => a.title})
        result << %{</a></div>}
      end
      result << %{</div>}
      result
    end
  end

  desc %{ 
    Presents a full-page gallery of the images in the current collection. If none is defined, we show a gallery of all the images available.
    
    The gallery is quite bare: it's designed to be smartened up and turned into a paginated pick-and-show player using either the supplied javascript or (for those who don't like mootools) something like it.

    Default preview size is 'large' and thumbnail size 'icon' but you can specify any standard asset sizes.

    *Usage:*
    <pre><code>
    <r:assets:gallery [size="..."] [thumbnail_size="..."] [download_size="..."] [no_download="false"] [tags="one,or,more,tags"] [thumbnails_per_page="33"] [help="something explananatory"] />
    </code></pre>
  }
  tag 'assets:gallery' do |tag|
    options = tag.attr.dup.symbolize_keys
    assets = _current_assets(tag, :images)

    unless assets.empty?
      size = options[:size] || 'large'
      thumbsize = options[:thumbnail_size] || 'icon'
      dlsize = options[:download_size] || 'original'
      per_slide = (options[:thumbnails_per_page] || 33).to_i
      help_text = options[:help] || "Click on a thumbnail to preview that image, and on a preview image to download the full-size version."
      tag.locals.asset = assets.first
      result << %{
<div class="gallery">
  <div class="gallery_shower gallery_waiting"></div>
	<div class="gallery_caption">#{tag.render('assets:caption')}</div>
	<a class="gallery_left" href="#">&lt;</a>
	<div class="gallery_wrapper">
	  <div class="gallery_slider">
		  <ul class="gallery_page">}
  		counter = 0
      assets.each do |asset|
        tag.locals.asset = asset
        result << %{
        <li class="gallery_item" id="asset_#{asset.id}">
          <a class="gallery_preview" href="#{tag.render('assets:url', 'size' => size)}">
            <img class="gallery_thumb" alt="#{tag.locals.asset.title} thumbnail" src="#{tag.render('assets:url', 'size' => thumbsize)}"/>
          </a>
          <a class="gallery_download" title="download" href="#{tag.render('assets:url', 'size' => dlsize)}">#{tag.locals.asset.caption}</a>
        </li>}
        counter += 1
        result << %{</ul><ul class="gallery_page">} if counter % per_slide == 0 && asset != assets.last
      end
      result << %{
		  </ul>
  	</div>
	</div>
	<a class="gallery_right" href="#">&gt;</a>
  <div class="gallery_foot"><p>#{help_text}</p></div>
</div>}
    else
      result << "<p>No images found</p>"
    end
    result
  end        

  desc %{ 
    Presents a tag cloud built from the current set of assets. If none is defined, we show a cloud for the whole asset set.
    
    Options and enclosed markup are passed through to r:tag_cloud.
    
    *Usage:*
    <pre><code>
    <r:assets:tag_cloud />
    </code></pre>
  }
  tag 'assets:tag_cloud' do |tag|
    assets = _current_assets(tag)
    limit = tag.attr['limit'] || 50
    if assets.any?
      tag.locals.tags = Tag.banded(Tag.attached_to(assets).most_popular(limit))
      tag.render('tag_cloud')
    end
  end
  
  
  
  
  
  




  private
    
    def _current_assets(tag)
      if tag.locals.assets
        tag.locals.assets
      elsif tag.attr['tags']
        _assets_for_tags(tag.attr['tags'])
      elsif tag.locals.tag
        tag.locals.tag.assets
      else
        Asset.find(:all)
      end
    end
  
    def _assets_for_tags(taglist, strict=false)
      tags = Tag.from_list(taglist)
      assets = Asset.from_tags(tags)
      assets.select!{ |a| a.match_count.to_i == tags.length} if strict and not assets.empty?
      assets
    end
    
    def _subset_assets!(tag)
      if tag.locals.assets
        asset_type = tag.attr['type']
        if asset_type && %w{image audio movie other}.include?(asset_type)
          tag.locals.assets = tag.locals.assets.send(asset_type.pluralize.intern)
        end
      end
    end
  
end