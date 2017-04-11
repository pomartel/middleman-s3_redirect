require 'middleman-core'
require 'middleman-s3_redirect/commands'

::Middleman::Extensions.register(:s3_redirect) do
  require 'middleman-s3_redirect/extension'
  ::Middleman::S3Redirect::Extension
end
