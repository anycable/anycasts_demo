# frozen_string_literal: true

require "rails_helper"

describe Channel do
  describe ".find_or_create_direct_for" do
    let(:users) { create_pair(:user) }

    subject { described_class.find_or_create_direct_for(*users) }

    it "creates a new direct channel for users" do
      expect { subject }.to change(users.first.direct_channels, :count).by(1)
        .and change(users.last.direct_channels, :count).by(1)

      expect(subject).to be_direct
    end

    context "when channel already exists" do
      let!(:channel) { described_class.find_or_create_direct_for(*users) }

      it "returns the existing channel" do
        expect { subject }.to change(Channel, :count).by(0)
          .and change(Channel::Membership, :count).by(0)
        expect(subject).to eq(channel)
      end
    end
  end

  describe ".direct_channel_name_for" do
    let(:users) { create_pair(:user) }

    specify do
      id_1, id_2 = users.map(&:id)

      expect(described_class.direct_channel_name_for(*users.reverse))
        .to eq("$u#{id_1}_u#{id_2}")
    end
  end
end
