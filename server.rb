require 'cuba'

Cuba.use Rack::Session::Cookie

Cuba.define do
  on get do
    on root do
      res.write 'Hello world!'
    end
  end
end
