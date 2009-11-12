module SitesHelper
  def error_messages_with_div_for_site
    if @site.errors.count > 0
      "<div class=\"active-record-validation-errors\">\n#{error_messages_for :site}\n</div>"
    else
      ""
    end
  end
end
