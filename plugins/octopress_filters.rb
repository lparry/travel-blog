#custom filters for Octopress
require './plugins/backtick_code_block'
require './plugins/post_filters'
require './plugins/raw'
require './plugins/date'
require 'rubypants'

module OctopressFilters
  include BacktickCodeBlock
  include TemplateWrapper
  def pre_filter(input)
    input = render_code_block(input)
    input.gsub /(<figure.+?>.+?<\/figure>)/m do
      safe_wrap($1)
    end
  end
  def post_filter(input)
    input = unwrap(input)
    RubyPants.new(input).to_html
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

  # Used on the blog index to split posts on the <!--more--> marker
  def excerpt(input)
    if input.index(/<!--\s*more\s*-->/i)
      input.split(/<!--\s*more\s*-->/i)[0]
    else
      input
    end
  end

  # Checks for excerpts (helpful for template conditionals)
  def has_excerpt(input)
    input =~ /<!--\s*more\s*-->/i ? true : false
  end

  # Gets a person's profile, ignoring their open source content
  def person_profile(input)
    if input.index(/<!--\s*projects\s*-->/i)
      input.split(/<!--\s*projects\s*-->/i)[0]
    else
      input
    end
  end

  # Gets a person's open source content
  def person_projects(input)
    if input.index(/<!--\s*projects\s*-->/i)
      input.split(/<!--\s*projects\s*-->/i)[1]
    end
  end

  # Checks for a person's open source content
  def has_projects(input)
    input =~ /<!--\s*projects\s*-->/i ? true : false
  end

  # Summary is used on the Archive pages to return the first block of content from a post.
  def summary(input)
    if input.index(/\n\n/)
      input.split(/\n\n/)[0]
    else
      input
    end
  end

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
end
Liquid::Template.register_filter OctopressLiquidFilters


# not true filters
module CDNLiquidFilters
  def fontawesome_url_for_environment(_)
    if ENV["OCTOPRESS_ENV"] == "preview"
      "/css/font-awesome/font-awesome.css"
    else
      "//netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.css"
    end
  end

  def swanky_and_moo_moo_url_for_environment(_)
    if ENV["OCTOPRESS_ENV"] == "preview"
      "/fonts/google-webfonts/swanky-and-moo-moo.css"
    else
      "http://fonts.googleapis.com/css?family=Swanky+and+Moo+Moo"
    end
  end

  def lato_url_for_environment(_)
    if ENV["OCTOPRESS_ENV"] == "preview"
      "/fonts/google-webfonts/lato.css"
    else
      "http://fonts.googleapis.com/css?family=Lato:100,100italic,300,300italic,700,700italic"
    end
  end



  def jquery_url_for_environment(_)
    if ENV["OCTOPRESS_ENV"] == "preview"
      "/js/jquery-1.10.2.js"
    else
      "//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"
    end
  end

  def octopress_env(_)
    ENV["OCTOPRESS_ENV"]
  end

end
Liquid::Template.register_filter CDNLiquidFilters
