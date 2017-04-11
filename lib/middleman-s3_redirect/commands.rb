require 'middleman-core/cli'
require 'middleman-s3_redirect/extension'
require 'fog'

module Middleman
  module Cli
    class S3Redirect < Thor::Group
      include Thor::Actions

      check_unknown_options!

      namespace :s3_redirect

      class_option :environment,
                   aliases: '-e',
                   default: ENV['MM_ENV'] || ENV['RACK_ENV'] || 'production'
      class_option :verbose,
                   type: :boolean,
                   default: false,
                   desc: 'Print debug messages'
      class_option :instrument,
                   type: :boolean,
                   default: false,
                   desc: 'Print instrument messages'

      def self.exit_on_failure?
        true
      end

      def s3_redirect
        env = options['environment'] ? :production : options['environment'].to_s.to_sym
        verbose = options['verbose'] ? 0 : 1
        instrument = options['instrument']

        @app = ::Middleman::Application.new do
          config[:mode] = :build
          config[:environment] = env
          ::Middleman::Logger.singleton(verbose, instrument)
        end

        generate
      end

      protected

      def options
        ::Middleman::S3Redirect.options
      end

      def redirects
        ::Middleman::S3Redirect.redirects
      end

      def generate
        redirects.each do |redirect|
          puts "Redirecting /#{redirect.from} to #{redirect.to}"
          bucket.files.create({
            :key => redirect.from,
            :public => true,
            :acl => 'public-read',
            :body => '',
            'cache-control' => 'public, max-age=86400', # 1 day, should make this customizable
            'x-amz-website-redirect-location' => "#{redirect.to}"
          })
        end
      end

      def connection
        @connection ||= Fog::Storage.new({
          :provider => 'AWS',
          :aws_access_key_id => options.aws_access_key_id,
          :aws_secret_access_key => options.aws_secret_access_key,
          :region => options.region,
          :path_style => options.path_style
        })
      end

      def bucket
        @bucket ||= connection.directories.get(options.bucket)
      end
    end

    Base.register(Middleman::Cli::S3Redirect, 's3_redirect', 's3_redirect', 'Creates redirect objects directly in S3')
  end
end
