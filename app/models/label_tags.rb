module LabelTags
  include Radiant::Taggable
  
  class TagError < StandardError; end
  
  desc %{
    The namespace for referencing collections of labels. Only really useful for labels:each
    
    *Usage:* 
    <pre><code><r:labels>...</r:assets></code></pre>
  }    
  tag 'labels' do |tag|
    tag.expand
  end
  
  desc %{
    Cycles through all labels
    Takes the same parameters as children:each
    
    *Usage:* 
    <pre><code><r:labels:each>...</r:labels:each></code></pre>
  }    
  tag 'labels:each' do |tag|
    result = []
    labels = Label.find(:all, _find_options(tag))
    labels.each do |item|
      tag.locals.label = item
      result << tag.expand
    end 
    result
  end
  
  desc %{
    Cycles through all labels attached to present page
    Takes the same sort and order parameters as children:each
    
    *Usage:* 
    <pre><code><r:page:labels>...</r:page:labels></code></pre>
  }    
  tag 'page:labels' do |tag|
    raise TagError, "page must be defined for page:labels tag" unless tag.locals.page
    tag.expand
  end
  tag 'page:labels:each' do |tag|
    result = []
    labels = tag.locals.page.labels.find(:all, _find_options(tag))
    labels.each do |item|
      tag.locals.label = item
      result << tag.expand
    end 
    result
  end
  
  desc %{
    Cycles through all labels attached to present asset.
    Takes the same sort and order parameters as children:each.
    
    *Usage:* 
    <pre><code><r:asset:labels><r:label:title /></r:asset:labels></code></pre>
  }    
  tag 'asset:labels' do |tag|
    raise TagError, "asset must be defined for asset:labels tag" unless tag.locals.asset
    tag.expand
  end
  tag 'asset:labels:each' do |tag|
    result = []
    labels = tag.locals.asset.labels.find(:all, _find_options(tag))
    labels.each do |item|
      tag.locals.label = item
      result << tag.expand
    end 
    result
  end
  
  # related pages and assets?
  
  desc %{
    Cycles through related pages of either page or asset in descending order of relatedness
    
    *Usage:* 
    <pre><code><r:related_pages:each>...</r:related_pages:each></code></pre>
  }    
  tag 'related_pages' do |tag|
    raise TagError, "page or asset must be defined for related_pages tag" unless tag.locals.page or tag.locals.asset
    tag.expand
  end
  tag 'related_pages:each' do |tag|
    result = []
    thing = tag.locals.page || tag.locals.asset
    thing.related_pages.each do |page|
      tag.locals.page = page
      result << tag.expand
    end 
    result
  end
  
  desc %{
    Cycles through related assets of either page or asset in descending order of relatedness.
    If labels are supplied we'll use those instead.
    
    *Usage:* 
    <pre><code><r:related_assets:each>...</r:related_assets:each></code></pre>
  }    
  tag 'related_assets' do |tag|
    raise TagError, "page or asset must be defined or labels specified for related_pages tag" unless tag.locals.page or tag.locals.asset
    tag.expand
  end
  tag 'related_assets:each' do |tag|
    result = []
    # if labels
    # else if page or asset...
    
    
    thing = tag.locals.page || tag.locals.asset
    thing.related_assets.each do |asset|
      tag.locals.asset = asset
      result << tag.expand
    end 
    result
  end












  desc %{
    The namespace for referencing a single label. You can supply a 'title' or 'id'
    attribute on this tag for all contained tags to refer to that label, or
    allow the label to be defined by labels:each or page:labels or asset:labels
    
    *Usage:* 
    <pre><code><r:label [title="tag_title"]>...</r:assets></code></pre>
  }    
  tag 'label' do |tag|
    tag.locals.label ||= _get_label(tag, tag.attr.dup)
  end
  
  desc %{
    Loops through the pages to which this label has been applied
    setting page context for all contained tags. works just like children:each 
    or other page tags.
    
    *Usage:* 
    <pre><code><r:label:pages:each>...</r:label:pages:each></code></pre>
  }    
  tag 'label:pages' do |tag|
    raise TagError, "label must be defined for label:pages tag" unless tag.locals.label
    tag.expand
  end
  tag 'label:pages:each' do |tag|
    result = []
    pages = tag.locals.label.pages.find(:all, _find_options(tag, Page))
    pages.each do |item|
      tag.locals.page = item
      result << tag.expand
    end 
    result
  end

  desc %{
    Loops through the assets to which the present label has been applied
    
    *Usage:* 
    <pre><code><r:label:assets:each>...</r:label:assets:each></code></pre>
  }    
  tag 'label:assets' do |tag|
    raise TagError, "label must be defined for label:assets tag" unless tag.locals.label
    tag.expand
  end
  tag 'label:assets:each' do |tag|
    result = []
    assets = tag.locals.label.assets.find(:all, _find_options(tag, Page))
    assets.each do |item|
      tag.locals.asset = item
      result << tag.expand
    end 
    result
  end

  desc %{
    Steps through all the assets with any of the specified labels,
    In descending order of overlap between asset labels and specified list
    
    *Usage:* 
    <pre><code><r:assets:labelled labels="label1[,...]">...</r:assets:labelled></code></pre>
  }    
  tag 'assets:labelled' do |tag|
    options = tag.attr.dup
    tag.locals.labels = _get_labels(tag)
    result = []
    assets = Asset.from_labels(tag.locals.labels)   # this will need pagination
    assets.each do |asset|
      tag.locals.asset = asset
      result << tag.expand
    end 
    result
  end







  private
    
    def _find_options(tag, model=Label)
      attr = tag.attr.symbolize_keys
    
      options = {}
    
      [:limit, :offset].each do |symbol|
        if number = attr[symbol]
          if number =~ /^\d{1,4}$/
            options[symbol] = number.to_i
          else
            raise TagError.new("`#{symbol}' attribute of `each' tag must be a positive number between 1 and 4 digits")
          end
        end
      end
    
      by = (attr[:by] || 'title').strip
      order = (attr[:order] || 'asc').strip
      order_string = ''
      if model.column_names.include?(by)
        order_string << by
      else
        raise TagError.new("`by' attribute of `each' tag must be set to a valid field name")
      end
      if order =~ /^(asc|desc)$/i
        order_string << " #{$1.upcase}"
      else
        raise TagError.new(%{`order' attribute of `each' tag must be set to either "asc" or "desc"})
      end
      options[:order] = order_string
    
      options
    end

    def _get_label(tag, options)
      raise TagError, "'title' attribute required" unless title = options.delete('title') or id = options.delete('id') or tag.locals.label
      tag.locals.label || Label.find_by_title(title) || Label.find(id)
    end
    
    def _get_labels(tag)
      labels = []
      labels = Label.from_list(tag.attr['labels']) if tag.attr['labels'] && !tag.attr['labels'].blank?
      labels ||= tag.locals.page.labels if labels.empty? && tag.locals.page
      labels ||= tag.locals.asset.labels if labels.empty? && tag.locals.asset
      raise TagError, "can't find any labels" if labels.empty?
      labels
    end

  
  
  
  
end