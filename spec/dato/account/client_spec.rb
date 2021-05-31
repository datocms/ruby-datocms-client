# frozen_string_literal: true

require "spec_helper"

module Dato
  module Account
    describe Client, :vcr do
      let(:client) do
        generate_account_client!
      end

      describe "Not found" do
        it "raises Dato::ApiError" do
          expect { client.sites.find(9999) }.to raise_error Dato::ApiError
        end
      end

      describe "Account" do
        it "fetch, update" do
          account = client.account.find

          client.account.update(account.merge(company: "Dundler Mifflin"))
          expect(client.account.find[:company]).to eq "Dundler Mifflin"
        end
      end

      describe "Sites" do
        it "fetch, create, update and destroy" do
          name = "Integration test"

          new_site = client.sites.create(name: name)

          client.sites.update(
            new_site[:id],
            new_site.merge(name: "#{name}!"),
          )

          expect(client.sites.find(new_site[:id])[:name]).to eq("#{name}!")

          client.sites.destroy(new_site[:id])
        end
      end
    end
  end
end
