module AssetGalleryTags
  include Radiant::Taggable
  
  class TagError < StandardError; end

  # mostly we're just extending TaggableTags with Asset versions of the Page tags
  # assets from many tags

  %W{all top page requested coincident}.each do |these|

    # assety suffixes pass on to the relevant tags:assets method. Again, only requested_tags is likely to be much used here.

    desc %{
      Lists all the assets tagged with any of the set of #{these} tags, in descending order of overlap.

      *Usage:* 
      <pre><code><r:#{these}_tags:assets:each>...</r:#{these}_tags:assets:each></code></pre>
    }
    tag "#{these}_tags:assets" do |tag|
      tag.locals.assets = Asset.from_all_tags(tag.locals.tags)
      tag.expand
    end
    tag "#{these}_tags:assets:each" do |tag|
      tag.render('asset_list', tag.attr.dup, &tag.block)
    end

    desc %{
      Renders the contained elements only if there are any assets associated with the set of #{these} tags.

      *Usage:* 
      <pre><code><r:#{these}_tags:if_assets>...</r:#{these}_tags:if_assets></code></pre>
    }
    tag "#{these}_tags:if_assets" do |tag|
      tag.render('tags:if_assets', tag.attr.dup, &tag.block)
    end

    desc %{
      Renders the contained elements only if there are no assets associated with the set of #{these} tags.

      *Usage:* 
      <pre><code><r:#{these}_tags:unless_assets>...</r:#{these}_tags:unless_assets></code></pre>
    }
    tag "#{these}_tags:unless_assets" do |tag|
      tag.render('tags:unless_assets', tag.attr.dup, &tag.block)
    end
    
    # then we disappear up the various asset types and the many conditional possibilities
    
    Asset.known_types.each do |type|
      
      desc %{
        Loops through all assets of type #{type} associated with the set of #{these} tags

        *Usage:* 
        <pre><code><r:#{these}_tags:#{type.to_s.pluralize}>...</r:#{these}_tags:#{type.to_s.pluralize}></code></pre>
      }
      tag "#{these}_tags:#{type.to_s.pluralize}" do |tag|
        tag.locals.assets = Asset.from_all_tags(tag.locals.tags).send("#{type.to_s.pluralize}".intern)
        tag.expand
      end
      tag "#{these}_tags:#{type.to_s.pluralize}:each" do |tag|
        tag.render('asset_list', tag.attr.dup, &tag.block)
      end

      desc %{
        Loops through all assets not of type #{type} associated with the set of #{these} tags

        *Usage:* 
        <pre><code><r:#{these}_tags:non_#{type.to_s.pluralize}>...</r:#{these}_tags:non_#{type.to_s.pluralize}></code></pre>
      }
      tag "#{these}_tags:non_#{type.to_s.pluralize}" do |tag|
        tag.locals.assets = Asset.from_all_tags(tag.locals.tags).send("not_#{type.to_s.pluralize}".intern)
        tag.expand
      end
      tag "#{these}_tags:non_#{type.to_s.pluralize}:each" do |tag|
        tag.render('asset_list', tag.attr.dup, &tag.block)
      end

      desc %{
        Renders the contained elements only if there are any assets of type #{type} associated with the set of #{these} tags.

        *Usage:* 
        <pre><code><r:#{these}_tags:if_#{type.to_s.pluralize}>...</r:#{these}_tags:if_#{type.to_s.pluralize}></code></pre>
      }
      tag "#{these}_tags:if_#{type.to_s.pluralize}" do |tag|
        assets = Asset.from_all_tags(tag.locals.tags).send("#{type.to_s.pluralize}".intern)
        tag.expand if assets.any?
      end

      desc %{
        Renders the contained elements only if there are no assets of type #{type} associated with the set of #{these} tags.

        *Usage:* 
        <pre><code><r:#{these}_tags:unless_#{type.to_s.pluralize}>...</r:#{these}_tags:unless_#{type.to_s.pluralize}></code></pre>
      }
      tag "#{these}_tags:unless_#{type.to_s.pluralize}" do |tag|
        assets = Asset.from_all_tags(tag.locals.tags).send("#{type.to_s.pluralize}".intern)
        tag.expand unless assets.any?
      end

      desc %{
        Renders the contained elements only if there are assets not of type #{type} associated with the set of #{these} tags.

        *Usage:* 
        <pre><code><r:#{these}_tags:if_non_#{type.to_s.pluralize}>...</r:#{these}_tags:if_non_#{type.to_s.pluralize}></code></pre>
      }
      tag "#{these}_tags:if_non_#{type.to_s.pluralize}" do |tag|
        assets = Asset.from_all_tags(tag.locals.tags).send("not_#{type.to_s.pluralize}".intern)
        tag.expand if assets.any?
      end

      desc %{
        Renders the contained elements only if there no assets not of type #{type} associated with the set of #{these} tags.

        *Usage:* 
        <pre><code><r:#{these}_tags:unless_non_#{type.to_s.pluralize}>...</r:#{these}_tags:unless_non_#{type.to_s.pluralize}></code></pre>
      }
      tag "#{these}_tags:unless_non_#{type.to_s.pluralize}" do |tag|
        assets = Asset.from_all_tags(tag.locals.tags).send("not_#{type.to_s.pluralize}".intern)
        tag.expand unless assets.any?
      end
    end
  end
  
  desc %{
    Lists all the assets associated with a set of tags, in descending order of relatedness.
    
    *Usage:* 
    <pre><code><r:tags:assets:each>...</r:tags:assets:each></code></pre>
  }
  tag 'tags:assets' do |tag|
    tag.locals.assets ||= Asset.from_all_tags(tag.locals.tags)
    tag.expand
  end
  tag 'tags:assets:each' do |tag|
    tag.render('asset_list', tag.attr.dup, &tag.block)
  end
    
  desc %{
    Renders the contained elements only if there are any assets associated with the current set of tags.

    *Usage:* 
    <pre><code><r:tags:if_assets>...</r:tags:if_assets></code></pre>
  }
  tag "tags:if_assets" do |tag|
    tag.locals.assets = Asset.from_all_tags(tag.locals.tags)
    tag.expand if tag.locals.assets.any?
  end

  desc %{
    Renders the contained elements only if there are no pages associated with the current set of tags.

    *Usage:* 
    <pre><code><r:tags:unless_assets>...</r:tags:unless_assets></code></pre>
  }
  tag "tags:unless_assets" do |tag|
    tag.locals.assets = Asset.from_all_tags(tag.locals.tags)
    tag.expand unless tag.locals.assets.any?
  end
  
  
  
  # tags from one asset
  
  desc %{
    Cycles through all tags attached to present asset.
    
    *Usage:* 
    <pre><code><r:assets:tags><r:tag:title /></r:assets:tags></code></pre>
  }    
  tag 'assets:tags' do |tag|
    raise TagError, "asset must be defined for asset:tags tag" unless tag.locals.asset
    tag.locals.tags = tag.locals.asset.tags
    tag.expand
  end
  tag 'assets:tags:each' do |tag|
    tag.render('tags:each', tag.attr.dup, &tag.block)
  end

  desc %{
    Lists all the assets similar to this asset (based on its tagging), in descending order of relatedness.
    
    *Usage:* 
    <pre><code><r:related_assets:each>...</r:related_assets:each></code></pre>
  }
  tag 'related_assets' do |tag|
    raise TagError, "asset must be defined for related_assets tag" unless tag.locals.asset
    tag.locals.assets = tag.locals.asset.related_assets
    tag.expand
  end
  tag 'related_assets:each' do |tag|
    tag.render('assets:each', tag.attr.dup, &tag.block)
  end




  # assets from one tag

  desc %{
    Loops through the assets to which the present tag has been applied
    
    *Usage:* 
    <pre><code><r:tag:assets:each>...</r:tag:assets:each></code></pre>
  }    
  tag 'tag:assets' do |tag|
    raise TagError, "tag must be defined for tag:assets tag" unless tag.locals.tag
    tag.locals.assets = tag.locals.tag.assets
    tag.expand
  end
  tag 'tag:assets:each' do |tag|
    tag.render('assets:each', tag.attr.dup, &tag.block)
  end

  



  # page-candy: displaying sets of assets in a stylable way
  # all of these tags require that a set of assets is in context.
  
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
      tag.locals.assets = Asset.images.from_all_tags(tags)
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
      tag.locals.assets = Asset.images.from_all_tags(tags)
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
    
    See r:tags:cloud for formatting and selection parameters.
    
    *Usage:*
    <pre><code><r:assets:tag_cloud /></code></pre>
        
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
    assets = Asset.from_all_tags(tags).find(:all)     # without the find, if we call .empty? it tries to count() and fails because of the count already in the named_scope
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