# frozen_string_literal: true

# Rails is not flexible enough; at least for now(
module BetterRailsSystemTests
  # Use relative path in screenshot message to make it clickable in VS Code when running in Docker
  def image_path
    absolute_image_path.relative_path_from(Rails.root).to_s
  end

  # Make failure screenshots compatible with multi-session setup
  def take_screenshot
    return super unless Capybara.last_used_session

    Capybara.using_session(Capybara.last_used_session) { super }
  end

  # Convert dom_id to selector
  def dom_id(*args)
    "##{super}"
  end
end

RSpec.configure do |config|
  # Add #dom_id support
  config.include ActionView::RecordIdentifier, type: :system
  config.include BetterRailsSystemTests, type: :system

  # Make sure this hook runs before others
  config.prepend_before(:each, type: :system) do
    # Use JS driver always
    driven_by Capybara.javascript_driver
  end
end
