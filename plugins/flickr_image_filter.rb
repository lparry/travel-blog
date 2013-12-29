#custom filters for Octopress
require './plugins/post_filters'

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

      def get_title(line)
        line.sub(/.* alt="([^"]*)".*/,'\1').chomp
      end

      def format_image(line)
        %(<p class="centered">#{line_with_p_tags_stripped(line)}<br/>\n<em>#{get_title(line)}</em></p>\n)
      end

      def line_with_p_tags_stripped(line)
        line.chomp.gsub(/<\/?p>/,"").sub(/<img src=/, "<img class='img-responsive' src=")
      end

      def line_needs_formatting?(line)
        #it's a flickr image link
        line.match(/flickr\.com.*\.jpg"/) &&
          #and we havent already formatted it
          !line.include?(%(p class="centered">))
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
