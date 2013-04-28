module Jekyll

  class PeopleShuffler < Jekyll::Generator
    safe true
    priority :lowest

    def generate(site)
        people = site.pages.select { |page| page.data['type'] == 'person' }

        # Access this collection in Liquid using: site.people
        site.config["people"] = people.shuffle
    end
  end
end