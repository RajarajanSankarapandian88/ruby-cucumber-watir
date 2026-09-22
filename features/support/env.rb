# frozen_string_literal: true

require "allure-cucumber"
require "fileutils"
require "watir"

require_relative "../pages/search_page"

AllureCucumber.configure do |config|
  config.results_directory = "allure-results"
  config.clean_results_directory = true
  config.environment = ENV.fetch("TEST_ENV", "local")
  config.environment_properties = {
    browser: ENV.fetch("BROWSER", "chrome"),
    headless: ENV.fetch("HEADLESS", "true"),
    ruby: RUBY_VERSION,
    platform: RUBY_PLATFORM
  }
end

module BrowserWorld
  attr_reader :browser, :search_page, :search_results

  def start_browser
    browser_name = ENV.fetch("BROWSER", "chrome").to_sym
    headless = ENV.fetch("HEADLESS", "true").casecmp?("true")
    arguments = ["--window-size=1440,1000", "--disable-search-engine-choice-screen"]
    arguments.concat(["--headless=new", "--disable-gpu"]) if headless

    options_class = browser_name == :edge ? Selenium::WebDriver::Edge::Options : Selenium::WebDriver::Chrome::Options
    options = options_class.new(args: arguments)
    browser_arguments = { options: options }
    if browser_name == :chrome
      driver_path = File.expand_path("../../tools/chromedriver-win64/chromedriver.exe", __dir__)
      browser_arguments[:service] = Selenium::WebDriver::Service.chrome(path: driver_path) if File.exist?(driver_path)
    end

    @browser = Watir::Browser.new(browser_name, **browser_arguments)
    @browser.window.resize_to(1440, 1000) unless headless
    @search_page = SearchPage.new(@browser)
  end
end

World(BrowserWorld)

Before do
  start_browser
end

After do |scenario|
  if scenario.failed? && @browser&.exists?
    FileUtils.mkdir_p("artifacts/screenshots")
    name = scenario.name.gsub(/[^0-9A-Za-z]+/, "_").downcase
    path = File.join("artifacts", "screenshots", "#{name}.png")
    @browser.screenshot.save(path)
    attach(File.binread(path), "image/png", "Failure screenshot")
  end
ensure
  @browser&.quit
end
