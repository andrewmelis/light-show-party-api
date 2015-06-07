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
  sqs_client.get_queue_attributes(queue_url: PARTY_QUEUE, attribute_names: ["QueueArn"]).each do |response|
    response.attributes
  end
end

post '/party' do
  party = JSON.parse(request.body.read)
  enqueue_party(party)
  "woohoo"
end

post '/partygoer' do
  partygoer = JSON.parse(request.body.read)
  puts partygoer
  put_partygoer_on_the_list(partygoer["token"])
  partygoer["token"]
end

