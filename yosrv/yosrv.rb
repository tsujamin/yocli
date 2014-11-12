#! /usr/bin/env ruby
require 'sinatra'
require 'sinatra/streaming'
require 'json'

QUEUE_LENGTH = 10

streams = {}
queues = {}

#get request for yo's
get '/stream/:apikey', provides: 'text/event-stream' do
  stream :keep_open do |stream|
    #extract key of request
    key = params[:apikey]
    
    puts "new connection (#{key})"

    #remove/close old connection if exists
    if streams.include? key
      streams[key].close
      streams.delete(key)
    end
    
    #store stream for redirection later
    streams[params[:apikey]] = stream
    
    #delete if stream closes
    stream.callback { 
      puts "stream closed (#{key})"
      streams.delete(key) 
    }

    stream.errback {
      puts "stream errored (#{key})"
      streams.delete(key)
    }
    
    #create the queue
    queues[key] ||= [] 
    
    #push queued messages out
    queues[key].drop_while {|yo| stream << yo.to_json + "\n"}
    stream.flush
  end  
end

#yoapi callback
get '/yo/:apikey' do
  key = params[:apikey]
  
  #check for existing queue
  unless queues.include? key
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
  queue = queues[key]

  if streams.include? key
    # send the received yo to the client
    puts "forwarding yo from #{yo['username']} (#{key})"
    stream = streams[key]
    stream << yo.to_json
    stream.flush
    
  else
    # add the received yo to the cache queue
    # only for previously connected clients
    puts "queueing yo from #{yo['username']} (#{key})"
    
    queue << yo
    
    #remove oldest yo if queue overflow
    queue.shift if queue.size > QUEUE_LENGTH  
  end
end
