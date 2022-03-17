# frozen_string_literal: true

require "system_helper"

describe "/channels/{id}", type: :system do
  let(:channel) { create(:channel) }
  let(:message) { "Progress is good. Complexity is a bridge. Simplicity is the destination." }
  let(:author) { "DHH" }
  let(:new_message) { "hello" }

  before do
    create(:message, channel: channel, content: message, author: author)
    visit channel_path(id: channel.id)
  end

  it "has message in channel" do
    expect(page).to have_text(message)
    expect(page).to have_text(author)
  end

  it "has form to send new message in channel" do
    expect(page).to have_selector "form#new_message"
    expect(page).to have_button "Send"
  end

  it "creates a message after form submit" do
    within "form#new_message" do
      fill_in "message_content", with: new_message
    end

    click_button "Send"
    visit channel_path(id: channel.id)

    expect(page).to have_text(new_message)
  end

  context "change channel" do
    let!(:msg) { create(:message, channel: create(:channel)) }

    it "loads all messages in new channel" do
      visit root_path
      click_link(href: channel_path(id: msg.channel.id))
      expect(page).to have_text(msg.content)
    end
  end
end
