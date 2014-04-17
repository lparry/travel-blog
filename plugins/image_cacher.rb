#custom filters for Octopress
require './plugins/post_filters'
require 'nokogiri'
require 'httparty'

module Jekyll
  class ImageCacher < PostFilter
    def post_render(post)
      if post.ext.match('html|textile|markdown|md|haml|slim|xml') && post.data["dont_cache_images"].nil? && post.is_post?
        post.content = ImageFetcher.cache_images(post.content)
      end
    end

    class ImageFetcher

      def self.cache_images(content)
        new.cache_images(content)
      end

      def line_contains_img_tag?(line)
        line.include?(%(<img ))
      end

      def cache_images(content)
        lines =  content.lines
        lines.map! do |line|
          if line_contains_img_tag?(line)
            fetch_image_from(line)
          else
            line
          end
        end
        lines.join
      end

      def fetch_image_from(line)
        doc = Nokogiri.parse(line)
        img_url = (doc / "img")[0].attributes["src"].value
        uri = URI.parse(img_url)
        if uri.host.nil? || uri.host == "www.lucasthenomad.com"
          line
        else
          local_path = "/images/cache#{uri.path}"
          cache(img_url, local_path)
          line.sub(img_url, local_path)
        end
      end

      def cache(url, local_path)
        destination = "source#{local_path}"
        if File.exist?(destination)
          # puts %(already downloaded "#{destination}")
        else
          download_file(url, destination)
          compress_file(destination)
        end
      end

      def download_file(uri_str, destination)
        resp = fetch(uri_str)
        FileUtils.mkdir_p(File.expand_path("..", destination))
        File.open(destination, "wb") do |file|
          file.write(resp.body)
        end
        puts %(downloaded "#{destination}")
      end

      def compress_file(path)
        `jpegoptim --strip-all -p -o -q "#{path}"`
      end

      def fetch(uri_str, limit = 10)
        response = HTTParty.get(uri_str)
        raise "response: #{response.code}" unless response.code == 200
        response
      end

    end

  end
end
