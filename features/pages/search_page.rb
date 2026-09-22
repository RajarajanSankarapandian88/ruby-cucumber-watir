# frozen_string_literal: true

require "base64"
require "uri"

class SearchPage
  URL = "https://www.bing.com".freeze

  def initialize(browser)
    @browser = browser
  end

  def open
    @browser.goto(URL)
    dismiss_consent_if_present
    self
  end

  def search_for(query)
    encoded_query = URI.encode_www_form_component(query)
    @browser.goto("#{URL}/search?q=#{encoded_query}&form=QBLH")
    wait_for_results
    self
  end

  def results
    @browser.elements(css: "li.b_algo h2 a").filter_map do |link|
      next unless link.present?

      title = link.text.strip
      url = direct_url(link.attribute_value("href"))
      next if title.empty? || !http_url?(url)

      { title: title, url: url }
    end
  end

  private

  def dismiss_consent_if_present
    button = @browser.button(id: "bnp_btn_accept")
    button.click if button.present?
  end

  def wait_for_results
    Watir::Wait.until(timeout: 20, message: "Search results did not appear") do
      @browser.element(css: "li.b_algo h2 a").present?
    end
  end

  def direct_url(url)
    uri = URI.parse(url)
    if uri.host&.end_with?("duckduckgo.com")
      target = URI.decode_www_form(uri.query.to_s).to_h["uddg"]
      return target if target&.start_with?("http")
    end

    return url unless uri.host&.end_with?("bing.com")

    encoded = URI.decode_www_form(uri.query.to_s).to_h["u"]
    return url unless encoded&.start_with?("a1")

    payload = encoded.delete_prefix("a1")
    payload += "=" * ((4 - payload.length % 4) % 4)
    decoded = Base64.urlsafe_decode64(payload)
    http_url?(decoded) ? decoded : url
  rescue ArgumentError, URI::InvalidURIError
    url
  end

  def http_url?(url)
    uri = URI.parse(url.to_s)
    %w[http https].include?(uri.scheme) && !uri.host.to_s.empty?
  rescue URI::InvalidURIError
    false
  end
end
