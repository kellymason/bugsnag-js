When("I navigate to the URL {string}") do |path|
  $driver.navigate.to get_test_url path
end

When("I let the test page run for up to {int} seconds") do |n|
  wait = Selenium::WebDriver::Wait.new(timeout: n)
  wait.until {
    $driver.find_element(id: 'bugsnag-test-state') &&
    $driver.find_element(id: 'bugsnag-test-state').text == 'DONE'
  }
end

When("the exception matches the {string} values for the current browser") do |fixture|
  err = get_error_message(fixture)
  steps %Q{
    And the exception "errorClass" equals "#{err['errorClass']}"
    And the exception "message" equals "#{err['errorMessage']}"
  }
end

Then(/^the request is a valid browser payload for the error reporting API$/) do
  if !/^ie_[89]$/.match(ENV['BROWSER'])
    steps %Q{
      Then the "Bugsnag-API-Key" header is not null
      And the "Content-Type" header equals "application/json"
      And the "Bugsnag-Payload-Version" header equals "4.0"
      And the "Bugsnag-Sent-At" header is a timestamp
    }
  else
    steps %Q{
      Then the "apiKey" query parameter is not null
      And the "payloadVersion" query parameter equals "4.0"
      And the "sentAt" query parameter is a timestamp
    }
  end
  steps %Q{
    And the payload field "notifier.name" is not null
    And the payload field "notifier.url" is not null
    And the payload field "notifier.version" is not null
    And the payload field "events" is a non-empty array

    And each element in payload field "events" has "severity"
    And each element in payload field "events" has "severityReason.type"
    And each element in payload field "events" has "unhandled"
    And each element in payload field "events" has "exceptions"
  }
end