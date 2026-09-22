# frozen_string_literal: true

require "allure-cucumber"
require "fileutils"
require "watir"

require_relative "../pages/search_page"

AllureCucumber.configure do |config|
  config.results_directory = "allure-results"
  # Runner-managed executions prepare results once before workers start.
  # Direct serial Cucumber runs retain formatter cleanup to avoid stale reports.
  config.clean_results_directory = !ENV.fetch("ALLURE_RESULTS_PREPARED", "false").casecmp?("true")
  config.environment = ENV.fetch("TEST_ENV", "local")
  config.environment_properties = {
    browser: ENV.fetch("BROWSER", "chrome"),
    headless: ENV.fetch("HEADLESS", "true"),
    ruby: RUBY_VERSION,
    platform: RUBY_PLATFORM
  }
end

module BrowserWorld
  SUPPORTED_BROWSERS = %i[chrome edge].freeze

  attr_reader :browser, :search_page, :search_results

  def start_browser
    browser_name = ENV.fetch("BROWSER", "chrome").downcase.to_sym
    unless SUPPORTED_BROWSERS.include?(browser_name)
      raise ArgumentError,
            "Unsupported BROWSER=#{browser_name.inspect}. Supported browsers: #{SUPPORTED_BROWSERS.join(", ")}."
    end

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

After("@ui") do |scenario|
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

Before("@ui") do
  start_browser
end
