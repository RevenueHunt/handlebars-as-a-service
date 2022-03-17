require 'sinatra'
require 'handlebars-engine'

get '/api-hbs' do
  'needs to be post'
end

post '/api-hbs' do
  rendered = 'SOMETHING WENT WRONG IN THE TEMPLATE'
  error = ''

  begin
    body = JSON.parse request.body.read
    logger.info body

    # body is a json that contains a params field with a hash with the parameters
    # and a template field that contains the handlebars template
    body = JSON.parse body
    params = body['params']
    template = body['template']

    handlebars = Handlebars::Engine.new
    begin
      h_template = handlebars.compile(template)
      rendered = h_template.call(params)
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
  }.to_json
end

not_found do
  '404'
end
