class PaperclippedTaggableExtension < Radiant::Extension
  version "1.0"
  description "Assign tags to paperclipped assets and display galleries based on tags, page, or whatever you like"
  url "http://spanner.org/radiant/paperclipped_taggable"
  
  def activate
    Asset.send :is_taggable
    Page.send :include, AssetGalleryTags
  end
  
end
