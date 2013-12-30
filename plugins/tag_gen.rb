module Jekyll
  class TagIndex < Page
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag_index.html')
      self.data['tag'] = tag
      tag_title_prefix = site.config['tag_title_prefix'] || 'Posts Tagged &ldquo;'
      tag_title_suffix = site.config['tag_title_suffix'] || '&rdquo;'
      self.data['title'] = "#{tag_title_prefix}#{tag}#{tag_title_suffix}"
    end
  end
  class TagGenerator < Generator
    safe true
    def generate(site)
      if site.layouts.key? 'tag_index'
        dir = site.config['tag_dir'] || 'tag'
        site.tags.keys.each do |tag|
          add_to_site_pages(site, File.join(dir, tag), tag)
        end
      end
    end
    def add_to_site_pages(site, dir, tag)
      site.pages << TagIndex.new(site, site.source, dir, tag)
    end
  end

  # Hax for tags by usages, and plain alphabetical
  class Site
    def ordered_tags
      tags.to_a.sort do |pair1, pair2|
        pair2.last.size <=> pair1.last.size
      end.reject do |pair|
        pair.last.count < 2
      end.map(&:first)
    end

    def sorted_tags
      tags.keys.sort
    end

    alias :site_payload_orig :site_payload

    def site_payload
      payload = site_payload_orig
      payload["site"].tap do |site|
        site["ordered_tags"] = ordered_tags
        site["sorted_tags"]  = sorted_tags
      end
      payload
    end
  end
end
