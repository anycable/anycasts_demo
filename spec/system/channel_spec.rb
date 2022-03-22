# frozen_string_literal: true

require "system_helper"

describe "/channels/{id}" do
  let(:channel) { create(:channel) }

  before do
    create(:message, channel: channel, content: "Progress is good", author: "DHH")
    visit channel_path(id: channel.id)
  end

  it "has message in channel" do
    expect(page).to have_text("Progress is good")
    expect(page).to have_text("DHH")
  end

  it "creates a message after form submit" do
    within "form#new_message" do
      fill_in "message_content", with: "Are you going to RailsConf?"
    end

    click_button "Send"
    visit channel_path(id: channel.id)

    expect(page).to have_text("Are you going to RailsConf?")
  end

  context "change channel" do
    let!(:msg) { create(:message, channel: create(:channel), content: "Another channel's message") }

    it "loads all messages in new channel" do
      visit root_path
      click_link(href: channel_path(id: msg.channel.id))
      expect(page).to have_text("Another channel's message")
    end
  end
end
