# frozen_string_literal: true

require "fileutils"
require "json"

Given("I open the search engine") do
  search_page.open
end

When("I search for {string}") do |query|
  @query = query
  search_page.search_for(query)
  @search_results = search_page.results
end

When("I search for the latest AI test automation trends") do
  @query = "latest AI trends in test automation 2026"
  search_page.search_for(@query)
  @search_results = search_page.results
end

Then("I should see at least {int} search results") do |minimum|
  actual = search_results.length
  raise "Expected at least #{minimum} results, but found #{actual}" if actual < minimum
end

Then("I save the AI trend search results") do
  FileUtils.mkdir_p("artifacts")
  timestamp = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S UTC")
  lines = ["AI test automation trends", "Search: #{@query}", "Captured: #{timestamp}", ""]
  search_results.each_with_index do |result, index|
    lines << "#{index + 1}. #{result[:title]}"
    lines << "   #{result[:url]}"
  end

  output = lines.join("\n")
  File.write("artifacts/ai_trends.txt", output)
  File.write("artifacts/ai_trends.json", JSON.pretty_generate(search_results))
  attach(output, "text/plain", "AI trend search results")
  attach(JSON.pretty_generate(search_results), "application/json", "AI trend search results (JSON)")
end
