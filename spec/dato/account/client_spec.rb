# frozen_string_literal: true
require "spec_helper"

module Dato
  module Account
    describe Client, :vcr do
      let(:client) do
        Dato::Account::Client.new(
          "XXX",
          base_url: "http://account-api.lvh.me:3001"
        )
      end

      describe "Not found" do
        it "raises Dato::ApiError" do
          expect { client.sites.find(9999) }.to raise_error Dato::ApiError
        end
      end

      describe "Account" do
        it "fetch, update" do
          account = client.account.find
          email = "integration@test.com"

          client.account.update(account.merge(email: email))
          expect(client.account.find[:email]).to eq email
        end
      end

      describe "Sites" do
        it "fetch, create, update and destroy" do
          name = "Integration test"

          new_site = client.sites.create(name: name)

          client.sites.update(
            new_site[:id],
            new_site.merge(name: name + "!")
          )

          new_sites_count = client.sites.all.size
          expect(client.sites.find(new_site[:id])[:name]).to eq(name + "!")

          client.sites.destroy(new_site[:id])
        end
      end
    end
  end
end
