module DestroySiteAndWait
  def destroy_site_and_wait(site)
    account_client.sites.destroy(site[:id])
    loop do
      begin
        account_client.sites.find(site[:id])
      rescue
        break
      end
      sleep 1
    end
  end
end

RSpec.configure do |_config|
  include DestroySiteAndWait
end
