#! /usr/bin/env ruby
require 'sinatra'
require 'json'

QUEUE_LENGTH = 10

connections = {}
message_queues = {}

#get request for yo's
get '/stream/:apikey', provides: 'text/event-stream' do
  stream :keep_open do |stream| 
    #extract key of request
    key = params[:apikey]
    
    #remove/close old connection if exists
    if connections.include? key
      connections[key].close
      connections.delete(key)
    end
    
    #store stream for redirection later
    connections[params[:apikey]] = stream
    
    #delete if stream closes
    stream.callback { connections.delete(key) } 
    
    #create the queue
    message_queues[key] ||= [] 
    
    #push queued messages out
    #TODO
  end
end

#yoapi callback
get '/yo/:apikey' do
  #extract relevant dict fields  
  yo = params.select {|key,_| ['username'].include? key}
  yo = params[:timestamp] = Time.now
  key = params[:apikey]
  queue = message_queues[key]
    
  if connections.include? key
    # send the received yo to the client
    connection = connections[key]
    connection << yo.to_json
    
  elsif message_queues.include? key
    # add the received yo to the cache queue
    # only for previously connected clients
    queue = message_queues[key]
    
    queue << yo
    
    #remove oldest yo if queue overflow
    queue.shift if queue.size > QUEUE_LENGTH  
  end
end
