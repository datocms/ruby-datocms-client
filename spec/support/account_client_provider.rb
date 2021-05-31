# frozen_string_literal: true

module AccountClientProvider
  def generate_account_client!(options = {})
    random_string = (0...8).map { rand(65..90).chr }.join

    anonymous_client = Dato::Account::Client.new(
      nil,
      base_url: ENV.fetch("ACCOUNT_API_BASE_URL"),
    )

    account = anonymous_client.account.create(
      email: "#{random_string}@delete-this-at-midnight-utc.tk",
      password: "veryst_9rong_passowrd4_",
      name: "Test",
      company: "DatoCMS",
    )

    Dato::Account::Client.new(
      account[:id],
      options.merge(
        base_url: ENV.fetch("ACCOUNT_API_BASE_URL"),
      ),
    )
  end
end

RSpec.configure do |_config|
  include AccountClientProvider
end
