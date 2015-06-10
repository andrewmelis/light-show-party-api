require 'sinatra'
require 'aws-sdk'
require 'json'

### METHODS ###

PARTY_QUEUE = "https://sqs.us-east-1.amazonaws.com/405483072970/remote-light-show"

def sqs_client
  @sqs_client ||= Aws::SQS::Client.new(region: 'us-east-1')
end

def enqueue_party(party)
  50.times { send_message(party) }
end

def send_message(party)
  sqs_client.send_message(queue_url: PARTY_QUEUE,
                          message_body: {name: party["name"]}.to_json)
end

def put_partygoer_on_the_list(partygoer)
  sqs_client.send_message(queue_url: PARTY_QUEUE,
                          message_body: {token: partygoer}.to_json)
end

### ENDPOINTS ###
get '/' do
  puts "if you don't know..."
end

post '/party' do
  party = JSON.parse(request.body.read)
  enqueue_party(party["name"])
  "party time for #{party}"
end

post '/partygoer' do
  partygoer = JSON.parse(request.body.read)
  put_partygoer_on_the_list(partygoer["token"])
  partygoer
end

