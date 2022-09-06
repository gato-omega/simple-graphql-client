# frozen_string_literal: true

require "rest_client"
require "json"

module SimpleGraphqlClient
  class Client
    attr_reader :options

    def initialize(url:, options: {}, &block)
      @url = url
      @options = options
      @request_options = block
    end

    def query(gql:, variables: {})
      response = RestClient.post(@url, {
        query: gql,
        variables: variables
      }.to_json, request_options)
      handle_response(JSON.parse(response.body, object_class: options.fetch(:parsing_class, OpenStruct)))
    end

    private

    def request_options
      base_options = { content_type: :json }
      options = @request_options ? @request_options.call : {}
      base_options.merge(options)
    end

    def handle_response(body)
      raise SimpleGraphqlClient::Errors::QueryError, body.errors if body.errors

      body.data
    end
  end
end
