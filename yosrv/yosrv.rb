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
    
    puts "new connection (#{key})"

    #remove/close old connection if exists
    if connections.include? key
      connections[key].close
      connections.delete(key)
    end
    
    #store stream for redirection later
    connections[params[:apikey]] = stream
    
    #delete if stream closes
    stream.callback { 
      puts "stream closed (#{key})"
      connections.delete(key) 
    }

    stream.errback {
      puts "stream errored (#{key})"
      connections.delete(key)
    }
    
    #create the queue
    message_queues[key] ||= [] 
    
    #push queued messages out
    message_queues[key].drop_while {|yo| stream << yo}
  end
end

#yoapi callback
get '/yo/:apikey' do
  key = params[:apikey]
  
  #check for existing queue
  unless message_queues.include? key
    puts "queue doesn't exist (#{key})"
    halt 400
  end

  #check for valid request:
  unless params.include? 'username'
    puts "yo missing yosername (#{key})"
    halt 400
  end

  #extract relevant dict fields  	
  yo = params.select {|key,_| ['username'].include? key}
  yo['timestamp'] = Time.now
  queue = message_queues[key]

  if connections.include? key
    # send the received yo to the client
    puts "forwarding yo from #{yo['username']} (#{key})"
    connection = connections[key]
    connection << yo.to_json
    
  else
    # add the received yo to the cache queue
    # only for previously connected clients
    puts "queueing yo from #{yo['username']} (#{key})"
    
    queue << yo
    
    #remove oldest yo if queue overflow
    queue.shift if queue.size > QUEUE_LENGTH  
  end
end
