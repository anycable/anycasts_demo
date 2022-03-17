# frozen_string_literal: true

require "system_helper"

describe "/", type: :system do
  let!(:channels) { create_pair(:channel) }

  before { visit root_path }

  it "has channels links with no active channel by default" do
    channels.each do |ch|
      expect(page).to have_link("##{ch.name}", href: "/channels/#{ch.id}")
    end

    expect(page).to have_text("No channel selected")
  end
end
