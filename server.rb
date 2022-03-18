require 'sinatra'
require 'handlebars-engine'

get '/' do
  halt 405, 'needs to be post'
end

post '/' do
  rendered = 'SOMETHING WENT WRONG IN THE TEMPLATE'
  error = nil
  body = request.body.read

  halt 401, 'wrong hmac' unless authenticate(body)

  begin
    parsed_body = JSON.parse body

    context = parsed_body['context']

    logger.info 'BODY'
    logger.info parsed_body

    template = parsed_body['template']

    handlebars = Handlebars::Engine.new
    begin
      h_template = handlebars.compile(template)
      rendered = h_template.call(context)
    rescue StandardError => e
      logger.info e.to_s
      error = e.to_s
    end
  rescue StandardError => e
    logger.info e.to_s
    error = e.to_s
  end

  {
    rendered: rendered,
    error: error
  }.delete_if { |key, value| value == nil }.to_json
end

not_found do
  '404'
end

def authenticate(body)
  secret = ENV['SECRET']

  hmac = request.env["HTTP_X_HMAC_SHA256"]

  halt 401, 'missing hmac' if hmac == nil

  calculated_hmac = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', secret, body))

  calculated_hmac == hmac
end
