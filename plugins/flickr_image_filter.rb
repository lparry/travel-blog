#custom filters for Octopress
require './plugins/post_filters'
require 'nokogiri'

module Jekyll
  class FlickrImageCaptionFilter < PostFilter
    def post_render(post)
      if post.ext.match('html|textile|markdown|md|haml|slim|xml')
        post.content = FlickrCaptions.captionize(post.content)
      end
    end

    class FlickrCaptions

      def self.captionize(content)
        new.captionize(content)
      end

      def format_image(line)
        doc = Nokogiri.parse(line)
        (doc / "img").add_class("img-responsive")
        title = (doc / "img").attr("alt")
        (doc / "img").after("<em>#{title}</em>")
        %(<p class="flickr-image-container"><span class="polaroid">#{(doc / "a").to_html}</span></p>)
      end

      def line_needs_formatting?(line)
        #it's a flickr image link
        line.match(/flickr\.com.*\.jpg"/) &&
          #and we havent already formatted it
          !line.include?(%(div class="flickr-image-container">))
      end

      def captionize(content)
        lines =  content.lines
        lines.map! do |line|
          if line_needs_formatting?(line)
            format_image(line)
          else
            line
          end
        end
        lines.join
      end

    end

  end
end
