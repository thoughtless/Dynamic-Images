module PagesHelper

  def example(prefix, path)
    "<span class=\"example\"><span class=\"example-path\">#{path}</span>" + image_tag(prefix + path, :alt => path) + '</span>'
  end
end
