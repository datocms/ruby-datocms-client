require "faraday"
require "faraday_middleware"
require "zip"

class DownloadSchema
  BASE_URL = "https://gitlab.cantierecreativo.net/api/v3"

  attr_reader :project_id, :token

  def initialize(token, project_id)
    @token = token
    @project_id = project_id
  end

  def schema(file)
    response = connection.get(
      "#{BASE_URL}/projects/#{project_id}/builds/#{build_id}/artifacts",
      private_token: token
    )

    File.open("build.zip", "wb") { |fp| fp.write(response.body) }
    File.delete("lib/schema.json") if File.exist? "lib/schema.json"

    Zip::File.open("build.zip") do |zip_file|
      zip_file.glob("**/#{file}").first.extract("schema.json")
    end

    schema = File.read("schema.json")

    File.delete("build.zip")
    File.delete("schema.json")

    schema
  end

  def build_id
    connection.get(
      "#{BASE_URL}/projects/#{project_id}/builds?scope=success",
      private_token: token
    ).body.first["id"]
  end

  def connection
    @connection ||= Faraday.new(
      headers: { "Accept" => "application/json" }
    ) do |c|
      c.request :url_encoded
      c.response :json, content_type: /\bjson$/
      c.response :raise_error
      c.adapter :net_http
    end
  end
end
