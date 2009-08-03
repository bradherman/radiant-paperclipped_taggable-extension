module AssetGalleryTags
  include Radiant::Taggable
  
  class TagError < StandardError; end
    
  # single-asset radius tags: listing attached tags and related assets
    
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


  # single-tag radius tags: listing assets associated with a particular tag

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


  # multiple tags: given tags, get lists of tagged assets and subset the lists in useful ways

  desc %{
    Lists all the assets associated with a set of tags, in descending order of relatedness.
    If no tags are in context, we get all the assets (a useful default for galleries)
    
    *Usage:* 
    <pre><code><r:tagged_assets:each>...</r:tagged_assets:each></code></pre>
  }
  tag 'tagged_assets' do |tag|
    tag.locals.assets = Asset.from_tags(tag.locals.tags) if tag.locals.tags
    tag.expand
  end
  tag 'tagged_assets:each' do |tag|
    result = []
    tag.locals.assets.each do |asset|
      tag.locals.asset = asset
      result << tag.expand
    end 
    result
  end
  
  
  Asset.known_types.each do |type|
    desc %{
      Loops through all assets of the specified type.

      *Usage:* 
      <pre><code><r:assets:#{type.to_s.pluralize}>...</r:assets:#{type.to_s.pluralize}></code></pre>
    }
    tag "assets:#{type.to_s.pluralize}" do |tag|
      tag.locals.assets = Asset.send("#{type.to_s.pluralize}".intern)
      tag.expand
    end
    tag "assets:#{type.to_s.pluralize}:each" do |tag|
      result = []
      tag.locals.assets.each do |asset|
        tag.locals.asset = asset
        result << tag.expand
      end 
      result
    end

    desc %{
      Renders the contained elements only if there are any assets of the specified type in the current set.

      *Usage:* 
      <pre><code><r:tagged_assets:if_any_#{type.to_s.pluralize}>...</r:tagged_assets:if_any_#{type.to_s.pluralize}></code></pre>
    }
    tag "tagged_assets:if_any_#{type.to_s.pluralize}" do |tag|
      assets = tag.locals.assets.send("#{type.to_s.pluralize}".intern).to_a
      STDERR.puts ">> tagged_assets:if_any_#{type.to_s.pluralize}: assets are #{assets.map(&:title)}"
      tag.expand if assets.any?
    end

    desc %{
      Renders the contained elements only if there are no assets of the specified type in the current set.

      *Usage:* 
      <pre><code><r:tagged_assets:unless_any_#{type.to_s.pluralize}>...</r:tagged_assets:unless_any_#{type.to_s.pluralize}></code></pre>
    }
    tag "tagged_assets:unless_any_#{type.to_s.pluralize}" do |tag|
      assets = tag.locals.assets.send("#{type.to_s.pluralize}".intern).to_a
      STDERR.puts ">> tagged_assets:if_any_#{type.to_s.pluralize}: assets are #{assets.map(&:title)}"
      tag.expand unless assets.any?
    end
    
    desc %{
      Renders the contained elements only if there are assets not of the specified type in the current set.

      *Usage:* 
      <pre><code><r:tagged_assets:if_any_not_#{type.to_s.pluralize}>...</r:tagged_assets:if_any_not_#{type.to_s.pluralize}></code></pre>
    }
    tag "tagged_assets:if_any_not_#{type.to_s.pluralize}" do |tag|
      assets = tag.locals.assets.send("not_#{type.to_s.pluralize}".intern).to_a
      tag.expand if assets.any?
    end

    desc %{
      Renders the contained elements only if there are only assets of the specified type in the current set.

      *Usage:* 
      <pre><code><r:tagged_assets:unless_any_not_#{type.to_s.pluralize}>...</r:tagged_assets:unless_any_not_#{type.to_s.pluralize}></code></pre>
    }
    tag "tagged_assets:unless_any_not_#{type.to_s.pluralize}" do |tag|
      assets = tag.locals.assets.send("not_#{type.to_s.pluralize}".intern).to_a
      STDERR.puts ">> tagged_assets:unless_any_not_#{type.to_s.pluralize}: assets are #{assets.map(&:title)}"
      tag.expand unless assets.any?
    end

    desc %{
      Loops through all the assets in the current set that are of the specified type.

      *Usage:* 
      <pre><code><r:tagged_assets:#{type.to_s.pluralize}:each>...</r:tagged_assets:#{type.to_s.pluralize}:each></code></pre>

      You can also call tagged_assets:#{type.to_s.pluralize} without the :each if you want to set the asset collection that will 
      become the context for eg. a tag cloud:
      
      <pre><code><r:tagged_assets:#{type.to_s.pluralize}><r:tagged_assets:tag_cloud /></r:tagged_assets:#{type.to_s.pluralize}></code></pre>
    }
    tag "tagged_assets:#{type.to_s.pluralize}" do |tag|
      tag.locals.assets = tag.locals.assets.send(type.to_s.pluralize.intern)
      tag.expand
    end
    tag "tagged_assets:#{type.to_s.pluralize}:each" do |tag|
      result = []
      tag.locals.assets.each do |asset|
        tag.locals.asset = asset
        result << tag.expand
      end 
      result
    end

    desc %{
      Loops through all the assets in the current set that are not of the specified type.

      *Usage:* 
      <pre><code><r:tagged_assets:not_#{type.to_s.pluralize}:each>...</r:tagged_assets:not_#{type.to_s.pluralize}:each></code></pre>
      
      You can also call tagged_assets:not_#{type.to_s.pluralize} without the :each if you want to set the asset collection that will 
      become the context for eg. a tag cloud:
      
      <pre><code><r:tagged_assets:not_#{type.to_s.pluralize}><r:tagged_assets:tag_cloud /></r:tagged_assets:not_#{type.to_s.pluralize}></code></pre>
    }
    tag "tagged_assets:not_#{type.to_s.pluralize}" do |tag|
      tag.locals.assets = tag.locals.assets.send("not_#{type.to_s.pluralize}".intern)
      tag.expand
    end
    tag "tagged_assets:not_#{type.to_s.pluralize}:each" do |tag|
      result = []
      tag.locals.assets.each do |asset|
        tag.locals.asset = asset
        result << tag.expand
      end 
      result
    end
  end

  # displaying sets of assets 
  # all of these tags require that a set of assets has been designated.
  
  desc %{ 
    Presents a standard marginal gallery block suitable for turning unobtrusively into a rollover or lightbox gallery. 
    We need to be able to work out a collection of assets: that can be defined already (eg by assets:all) or come from the current page.
    Default preview size is 'large' and thumbnail size 'thumbnail' but you can specify any of your asset sizes.
    
    *Usage:*
    <pre><code>
      <r:assets:images>
        <r:assets:minigallery [size="..."] [thumbnail_size="..."] [tags="one,or,more,tags"] />
      </r:assets:images>
    </code></pre>

  }
  tag 'assets:minigallery' do |tag|
    options = tag.attr.dup.symbolize_keys
    raise TagError, "asset collection must be available for assets:minigallery tag" unless tag.locals.assets or tag.locals.page or tag.attr[:tags]
    if options[:tags] && tags = Tag.from_list(options[:tags])
      tag.locals.assets = Asset.images.from_tags(tags)
    else
      tag.locals.assets = tag.locals.page.assets
    end
    tag.locals.assets.images.to_a     # because we can't let empty? trigger a call to count

    unless tag.locals.assets.empty?
      size = tag.attr['size'] || 'illustration'
      thumbsize = tag.attr['thumbnail_size'] || 'icon'
      result = ""
      result << %{
<div class="minigallery">}
      tag.locals.asset = tag.locals.assets.first
      result << tag.render('assets:image', {'size' => size})
      result << %{
  <p class="caption">#{tag.render('assets:caption')}</p>
  <ul class="thumbnails">}
      if tag.locals.assets.size > 1
        tag.locals.assets.each do |asset|
          tag.locals.asset = asset
          result << %{
    <li class="thumbnail">
      <a href="#{tag.render('assets:url', 'size' => 'illustration')}" title="#{asset.caption}" id="thumbnail_#{asset.id}">
        }
          result << tag.render('assets:image', {'size' => thumbsize, 'alt' => asset.title})
          result << %{
      </a>
    </li>}
        end
      end
      result << %{
  </ul>
</div>}
      result
    end
  end

  desc %{ 
    Presents a full-page gallery of the images associated with the tags supplied. If none, we show a gallery of all the images available.
    
    The gallery is quite bare: it's designed to be smartened up and turned into a paginated pick-and-show player using either the supplied javascript or (for those who don't like mootools) something like it.

    Default preview size is 'large' and thumbnail size 'icon' but you can specify any standard asset sizes.

    *Usage:*
    <pre><code>
    <r:assets:gallery [size="..."] [thumbnail_size="..."] [download_size="..."] [no_download="false"] [tags="one,or,more,tags"] [thumbnails_per_page="30"] />
    </code></pre>
    
    nb. One important difference: r:assets:minigallery defaults to displaying images associated with the current page. r:assets:gallery defaults to displaying the whole image set.
  }
  tag 'assets:gallery' do |tag|
    options = tag.attr.dup.symbolize_keys

    if options[:tags] && tags = Tag.from_list(options[:tags])
      tag.locals.assets = Asset.images.from_tags(tags)
    else
      tag.locals.assets = Asset.images
    end
    tag.locals.assets.to_a     # because we can't let empty? trigger a call to count
    
    if tag.locals.assets.empty?
      result = "<p>No images found</p>"
    else
      size = options[:size] || 'large'
      thumbsize = options[:thumbnail_size] || 'icon'
      dlsize = options[:download_size] || 'original'
      per_slide = (options[:thumbnails_per_page] || 20).to_i
      tag.locals.asset = tag.locals.assets.first
      
      result = %{
<div class="gallery">
  <div class="gallery_shower gallery_waiting"></div>
  <div class="gallery_caption"></div>
  <a class="gallery_left" href="#">&lt;</a>
  <div class="gallery_wrapper">
    <div class="gallery_slider">
      <ul class="gallery_page">}
      counter = 0
      tag.locals.assets.each do |asset|
        tag.locals.asset = asset
        copyright = %{<span class="copyright">&copy; #{asset.copyright}</span>} if asset.respond_to?(:copyright) && !asset.copyright.blank?
        result << %{
        <li class="gallery_item" id="asset_#{asset.id}">
          <a class="gallery_preview" href="#{tag.render('assets:url', 'size' => size)}">
            <img class="gallery_thumb" alt="#{tag.render('assets:title')} thumbnail" src="#{tag.render('assets:url', 'size' => thumbsize)}"/>
          </a>
          <a class="gallery_download" title="download" href="#{tag.render('assets:url', 'size' => dlsize)}">
            <strong>
              #{tag.render('assets:title')}
            </strong><br />
            #{tag.render('assets:caption')}
            #{copyright}
          </a>
        </li>}
        counter += 1
        result << %{
      </ul>
      <ul class="gallery_page">} if counter % per_slide == 0 && asset != assets.last
      end
      result << %{
      </ul>
    </div>
  </div>
  <a class="gallery_right" href="#">&gt;</a>
  <div class="gallery_foot"><p>page 1</p></div>
</div>}
    end
    result
  end        

  desc %{ 
    Presents a tag cloud built from the current set of assets. If none is defined, we show a cloud for the whole asset set.
    
    Options and enclosed markup are passed through to r:tag_cloud.
    
    *Usage:*
    <pre><code><r:assets:tag_cloud /></code></pre>
    
    This will only show tags that have been attached to assets. If you want to show a tag cloud for the whole site, use this instead: 
    
    <pre><code><r:tag_cloud all='true' /></code></pre>
    
    which will include asset-tagging (and pages and any other kind of tagged item) in its calculation of prominence.
  }
  tag 'assets:tag_cloud' do |tag|
    options = tag.attr.dup
    assets = if tag.locals.assets
      tag.locals.assets
    elsif taglist = options.delete('tags')
      _assets_for_tags(taglist)
    else
      Asset.find(:all)
    end
    
    limit = options.delete('limit') || 100
    if assets.any?
      tag.locals.tags = Tag.banded(Tag.attached_to(assets).most_popular(limit))
      tag.render('tags:cloud', options)
    end
  end

  private
      
    def _assets_for_tags(taglist, strict=false)
      tags = Tag.from_list(taglist)
      assets = Asset.from_tags(tags).find(:all)     # without the find, if we call .empty? it tries to count() and fails because of the count already in the named_scope
      assets.select!{ |a| a.match_count.to_i == tags.length} if strict and not assets.empty?
      assets
    end
    
    def _subset_assets!(tag)
      if tag.locals.assets
        asset_type = tag.attr['type']
        if asset_type && Asset.known_types.include?(asset_type)
          tag.locals.assets = tag.locals.assets.send(asset_type.pluralize.intern)
        end
      end
    end
  
end