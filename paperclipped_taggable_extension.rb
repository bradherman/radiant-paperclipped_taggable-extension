class PaperclippedTaggableExtension < Radiant::Extension
  version "1.0"
  description "Assign tags to paperclipped assets and display galleries based on tags, page, or whatever you like"
  url "http://spanner.org/radiant/paperclipped_taggable"
  
  extension_config do |config|
    config.extension 'paperclipped'
  end
  
  def activate
    Asset.send :is_taggable                                              # make pages taggable 
    Asset.send :include, TaggableAsset                                   # add a keywords method for compatibility with pages
    Page.send :include, AssetGalleryTags                                 # and a load of new page tags for displaying galleries and lists of assets
  end
  
end
