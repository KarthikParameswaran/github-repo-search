require 'net/http'
require 'uri'
require 'JSON'
# ----------------------------------------------------------------
# RepoSearchService
# Service used to get search data from cache or using GitHub API
# ----------------------------------------------------------------
class RepoSearchService
    # Search Repo
    def self.search(key)
        result = []
        items = check_cache_data(key) || get_curl_data(key)
        items&.each do |item|
            license = item["license"]
            result << {
                html_url: item["html_url"],
                name: item["name"],
                description: item["description"],
                license: (license.present? ? license["name"] : ''),
                visibility: item["visibility"],
                score: item["score"]
            }
        end
        result
    end

    # Check Redis Cache
    def self.check_cache_data(key)
        items = $redis.get(key)
        items.present? ? JSON.parse(items) : nil
    end

    # Get data using GitHub API - curl
    def self.get_curl_data(key)
        uri = URI.parse("https://api.github.com/search/repositories?q=#{key}")
        request = Net::HTTP::Get.new(uri)
        request["Accept"] = "application/vnd.github.v3+json"
        req_options = {
            use_ssl: uri.scheme == "https",
        }
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
        end
        items = JSON.parse(response.body)["items"]
        $redis.set(key, items.to_json, ex: REDIS_EXPIRY)
        items
    end
end
