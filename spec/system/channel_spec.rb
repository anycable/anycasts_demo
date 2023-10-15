# frozen_string_literal: true

require "system_helper"

describe "/channels/{id}" do
  let(:user) { create(:user) }
  let(:dhh) { create(:user, username: "DHH") }
  let(:channel) { create(:channel) }
  let!(:message) { create(:message, channel: channel, content: "Progress is good", user: dhh) }

  before { login(user) }

  before do
    visit channel_path(id: channel.id)
  end

  it "has message in channel" do
    expect(page).to have_text("Progress is good")
    expect(page).to have_text("DHH")
    expect(page).to have_css("#messages .message", count: 1)
  end

  it "creates a message after form submit" do
    within "form#new_message" do
      fill_in "message_content", with: "Are you going to RailsConf?"
    end

    click_button "Send"

    expect(page).to have_text("Are you going to RailsConf?")
    expect(page).to have_css("#messages .message", count: 2)
  end

  it "broadcast message to active users" do
    within "form#new_message" do
      fill_in "message_content", with: "Have you been at RailsWorld?"
    end

    using_session(:dhh) do
      login(dhh)

      visit channel_path(id: channel.id)

      expect(page).to have_text("Progress is good")
    end

    click_button "Send"

    expect(page).to have_text("Have you been at RailsWorld?")

    using_session(:dhh) do
      expect(page).to have_text("Have you been at RailsWorld?")

      within "form#new_message" do
        fill_in "message_content", with: "Sure! It was awesome!"
      end

      click_button "Send"

      expect(page).to have_text("Sure! It was awesome!")

      expect(page).to have_css("#messages .message", count: 3)
    end

    # Back to the first session
    expect(page).to have_text("Sure! It was awesome!")
    expect(page).to have_css("#messages .message", count: 3)
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
