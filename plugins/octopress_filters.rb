#custom filters for Octopress
# require './plugins/backtick_code_block'
require './plugins/post_filters'
#require './plugins/raw'
require './plugins/date'
require 'rubypants'

module OctopressFilters
  # include BacktickCodeBlock
  # include TemplateWrapper
  def pre_filter(input)
    # input = render_code_block(input)
    # input.gsub /(<figure.+?>.+?<\/figure>)/m do
    #   safe_wrap($1)
    # end
    input
  end
  def post_filter(input)
    # input = unwrap(input)
    RubyPants.new(input.gsub(/’/, "'").gsub(/[“”]/, '"').gsub(/…/, "...")).to_html
  end
end

module Jekyll
  class ContentFilters < PostFilter
    include OctopressFilters
    def pre_render(post)
      if post.ext.match('html|textile|markdown|md|haml|slim|xml')
        post.content = pre_filter(post.content)
      end
    end
    def post_render(post)
      if post.ext.match('html|textile|markdown|md|haml|slim|xml')
        post.content = post_filter(post.content)
      end
    end
  end
end


module OctopressLiquidFilters
  include Octopress::Date

  # Extracts raw content DIV from template, used for page description as {{ content }}
  # contains complete sub-template code on main page level
  def raw_content(input)
    /<div class="entry-content">(?<content>[\s\S]*?)<\/div>\s*<(footer|\/article)>/ =~ input
    return (content.nil?) ? input : content
  end

  # Escapes CDATA sections in post content
  def cdata_escape(input)
    input.gsub(/<!\[CDATA\[/, '&lt;![CDATA[').gsub(/\]\]>/, ']]&gt;')
  end

  # Replaces relative urls with full urls
  def expand_urls(input, url='')
    url ||= '/'
    input.gsub /(\s+(href|src)\s*=\s*["|']{1})(\/[^\"'>]*)/ do
      $1+url+$3
    end
  end

  def rewrite_flickr_urls(input, url)
    input.gsub %r(href=["']https?://www\.flickr\.com/[^'"]*["']), %(href="#{url}")
  end


  def fix_tag_hyphens(input)
    input.split("-").map{|word| word.capitalize}.join(" ")
  end

  # Improved version of Liquid's truncate:
  # - Doesn't cut in the middle of a word.
  # - Uses typographically correct ellipsis (…) insted of '...'
  def truncate(input, length)
    if input.length > length && input[0..(length-1)] =~ /(.+)\b.+$/im
      $1.strip + ' &hellip;'
    else
      input
    end
  end

  # Improved version of Liquid's truncatewords:
  # - Uses typographically correct ellipsis (…) insted of '...'
  def truncatewords(input, length)
    truncate = input.split(' ')
    if truncate.length > length
      truncate[0..length-1].join(' ').strip + ' &hellip;'
    else
      input
    end
  end

  # Condenses multiple spaces and tabs into a single space
  def condense_spaces(input)
    input.gsub(/\s{2,}/, ' ')
  end

  # Removes trailing forward slash from a string for easily appending url segments
  def strip_slash(input)
    if input =~ /(.+)\/$|^\/$/
      input = $1
    end
    input
  end

  # Returns a url without the protocol (http://)
  def shorthand_url(input)
    input.gsub /(https?:\/\/)(\S+)/ do
      $2
    end
  end

  # Returns a title cased string based on John Gruber's title case http://daringfireball.net/2008/08/title_case_update
  def titlecase(input)
    input.titlecase
  end

  # StandardFilters version concats words together, it's fucked
  def strip_newlines(input)
    input.to_s.gsub(/\n/, ' ')
  end

  def strip_images(input)
    input.to_s.split("\n").reject{|line| line =~ /img src/}.join("\n")
  end

  # determine if we should show the latest post well
  def is_homepage_or_latest_post(page, latest)
    page["url"] == latest["url"] || page["url"] == "/index.html"
  end
end
Liquid::Template.register_filter OctopressLiquidFilters

