require 'middleman-core'

module Middleman
  module S3Redirect
    class << self
      attr_accessor :options, :redirects
    end

    class Extension < ::Middleman::Extension
      option :prefix
      option :bucket
      option :region
      option :path_style, true
      option :aws_access_key_id
      option :aws_secret_access_key

      expose_to_config :redirect, :redirects

      def initialize(app, options_hash={}, &block)
        super
      end

      def after_configuration
        self.read_config

        options.aws_access_key_id ||= ENV['AWS_ACCESS_KEY_ID']
        options.aws_secret_access_key ||= ENV['AWS_SECRET_ACCESS_KEY']
        options.region ||= ENV['AWS_DEFAULT_REGION']
        options.bucket ||= ENV['BUCKET']

        ::Middleman::S3Redirect.options = options
        ::Middleman::S3Redirect.redirects = redirects
      end

      def redirect(from, to)
        redirects << RedirectEntry.new(from, to)
      end

      def redirects
        @redirects ||= []
      end

      protected

      def read_config(io = nil)
        unless io
          root_path = ::Middleman::Application.root
          config_file_path = File.join(root_path, ".s3_sync")

          # skip if config file does not exist
          return unless File.exists?(config_file_path)

          io = File.open(config_file_path, "r")
        end

        config = YAML.load(io)

        options.aws_access_key_id = config["aws_access_key_id"] if config["aws_access_key_id"]
        options.aws_secret_access_key = config["aws_secret_access_key"] if config["aws_secret_access_key"]
      end

      class RedirectEntry
        attr_reader :from, :to
        def initialize(from, to)
          @from = normalize(from)
          @to = to
        end

        protected

        def normalize(path)
          # paths without a slash are preserved as is: e.g. path => path, or path.html => path.html
          # paths with a slash get an index.html: e.g. path/ => path/index.html
          # paths with a preceding slash, have the preceding slash removed
          path << 'index.html' if path =~ /\/$/
          path.sub(/^\//, '')
        end
      end
    end
  end
end
