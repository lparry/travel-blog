# not true filters
module CDNLiquidFilters
  def fontawesome_url_for_environment(_)
    if ENV["OCTOPRESS_ENV"] == "preview"
      "/css/font-awesome.css"
    else
      "//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css"
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
