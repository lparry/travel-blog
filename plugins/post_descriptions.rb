module Jekyll
  class Post
    alias :data_orig :data
    def data
      data_orig["description"] ||= content
      data_orig
    end
  end
end
