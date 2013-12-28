# horrible monkey patch because Jekyll sucks at tags

module Jekyll
  class Post
    def tags
      @tags.map{|tag| safe_tag_characters(tag.downcase) }.uniq
    end

    def safe_tag_characters(tag)
      tag.gsub(/[^a-z0-9\-]/, '')
    end
  end
end
