# frozen_string_literal: true

require "system_helper"

describe "/" do
  let(:user) { create(:user) }
  let!(:channels) { create_pair(:channel) }

  before { login(user) }

  it "has channels links with no active channel by default" do
    visit root_path

    channels.each do |ch|
      expect(page).to have_link("##{ch.name}", href: "/channels/#{ch.id}")
    end

    expect(page).to have_text("No channel selected")
  end

  context "with direct channels" do
    let(:another_user) { create(:user, username: "matroskin") }

    let!(:direct_channel) do
      create(:channel, :direct, members: [user, another_user])
    end

    it "shows direct channels" do
      visit root_path

      expect(page).to have_link("@matroskin", href: "/channels/#{direct_channel.id}")
    end
  end
end
