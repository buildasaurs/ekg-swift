#!/bin/env ruby

require 'excon'
require 'json'
require 'terminal-table'
require 'set'
require 'colored'

def print_all_event_data(data, head, title)
  table = Terminal::Table.new do |t|
    memory = {
      "all_events" => data
    }
    data.each do |event|
      memory['event'] = event
      r = head.map { |h| process_value(h, event[h], memory) }
      t.add_row r
    end
  end
  table.title = title
  table.headings = head
  puts table.to_s
end

def all_keys(data)
  keys = Set.new
  data.each do |event|
    keys |= Set.new(event.keys)
  end
  return keys
end

def process_value(key, value, memory)

  all_events = memory['all_events']
  event = memory['event']
  event_id = event['event_id']

  case key
  when "timestamp"
    # timestamp - convert to human readable
    new_value = Time.at(value/1000).strftime('%Y-%m-%d %H:%M:%S')
  when "uptime"
    seconds = value.to_i
    days = (value.to_f / (24 * 60 * 60)).round
    new_value = "#{days} day#{days > 1 ? 's' : ''} (#{seconds}s)"
  when "token"
    # add the number of the event for this token
    token_memory = memory['token_memory'] || Hash.new(0)
    count = token_memory[value] + 1
    token_memory[value] = count
    memory['token_memory'] = token_memory
    new_value = "#{value} -> #{count}"

    # color first and last event for this token
    all = all_events.select { |e| e['token'] == value }

    is_first = all.first['event_id'] == event_id
    new_value = new_value.green if is_first
    new_value = new_value.yellow if !is_first && all.last['event_id'] == event_id

  when "running_syncers"
    new_value = value.to_i > 0 ? value.to_s.green : value.to_s.red
  when "event_type"
    case value 
    when 'heartbeat'
      new_value = value.green
    when 'update'
      new_value = value.red
    else
      new_value = value.blue
    end
  when "running_syncer_types"
  	new_value = value ? value.map { |k, v| "#{k}:#{v}" }.join(",") : ""
  else
  	new_value = value 
  end
  return new_value
end

def filter_json(json, keys)
  new_json = {}
  json.each do |k,v|
    new_json[k] = v if keys.member?(k)
  end
  return new_json
end

def download_data
  response = Excon.get("https://builda-ekg.herokuapp.com/v1/beep/all")
  raise "Failed to fetch data #{response.body}" unless response.status == 200
  parsed = JSON.parse(response.body)

  # only use the events from last week
  # parsed = parsed.select { |e| e["timestamp"] > (Time.new.to_i - 7*24*60*60)*1000 }

  return parsed
end

def print_table(downloaded, headers, name)
  print_all_event_data(downloaded, headers, name)
end

def map_tokens_to_events(data)
  map = {}
  data.each { |e| map[e['token']] = (map[e['token']] || []) << e }
  return map
end

def print_basic_data(data)

  # basic info of how many unique instances and how many of them running syncers
  mapped_events = map_tokens_to_events(data)
  total_instances = mapped_events.count
  last_beats = mapped_events.map do |token,events|
    events.select { |e| e['event_type'] == 'heartbeat' }.last || {}
  end.select { |e| e['event_id'] != nil }
  instances_with_running_syncers = last_beats.map do |beat|
    beat['running_syncers'] || 0
  end.select { |n| n > 0 }.count

  puts "----------------------------------------------------------------------"
  puts "Events from #{total_instances} instances, out of which #{instances_with_running_syncers} have running syncers".green
  puts "----------------------------------------------------------------------"

  print_versions(last_beats)
  print_syncers(last_beats)
end

def print_syncers(last_beats)

  syncers = last_beats.reduce(Hash.new) do |all, beat|
    c = beat['running_syncers']
    all[c] = (all[c] || 0) + 1
    all
  end

  head = ["Running Syncers", "Count of Instances"]
  syncers_out = []
  syncers.keys.sort.each do |k|
    syncers_out << [k, syncers[k]]
  end

  table = Terminal::Table.new do |t|
    syncers_out.each do |it|
      out = it
      t.add_row out
    end
  end
  table.title = "By running syncers"
  table.headings = head
  puts table.to_s

end

def print_versions(last_beats)

  # versions
  versioned = last_beats.reduce(Hash.new) do |all, beat|
    v = beat['version']
    s = beat['running_syncers']
    it = all[v] || [0,0]
    all[v] = [it[0] + 1, it[1] + (s > 0 ? 1 : 0)]
    all
  end

  # add percentages
  versionedWithPercent = versioned.map do |v, it|
    [v, it[0], it[1], "#{(100*it[1].to_f/it[0].to_f).to_i}%"]
  end

  version_mapped = Hash.new
  versionedWithPercent.each do |v|
    version_mapped[v[0]] = v
  end

  head = ["Version", "All", "Running", "% Running"]

  table = Terminal::Table.new do |t|
    version_mapped.keys.sort.each do |k|
      ver = version_mapped[k]
      out = (0...head.count).map { |h| ver[h].to_s }
      t.add_row out
    end
  end
  table.title = "Instances by version"
  table.headings = head
  puts table.to_s
end

def print_services(services)

  # add percentages
  total = services.reduce(0) { |all, data| all + data[1] }
  services_split = services.map do |name, count|
    [name, count, "#{(100*count.to_f/total.to_f).to_i}%"]
  end

  head = ["Name", "Count", "% Count"]

  services_mapped = services_split.reduce({}) { |all, i|
    all[i[0]] = i
    all
  }

  table = Terminal::Table.new do |t|
    services_mapped.keys.sort.each do |k|
      dat = services_mapped[k]
      out = (0...head.count).map { |h| dat[h].to_s }
      t.add_row out
    end
  end
  table.title = "Git services"
  table.headings = head
  puts table.to_s
end

# run
downloaded = download_data

# print basic metadata
print_basic_data(downloaded)

headers = [
  "timestamp",
  "event_id",
  "token", 
  "event_type", 
  "version", 
  "build", 
  "uptime", 
  "running_syncers",
  "running_syncer_types"
]

if (true)

  events_syncer_types = map_tokens_to_events(downloaded).map { |k, v|
    v.select { |e| (e["running_syncer_types"] || {}).keys.count > 0 }.last
  }.select { |e| e != nil }

	unique_tokens = events_syncer_types.map { |e| e["token"] }.to_set
	
  # look at how many syncers each service has
  service_stats = events_syncer_types.reduce({}) { |all, e| 
    e['running_syncer_types'].each { |type, count| all[type] = (all[type] || 0) + count }
    all
  }

  # puts service_stats
  print_services(service_stats)
  puts "Syncer type data available from #{unique_tokens.count} instances."

end

if (false)
  # print all events
  print_table(
    downloaded, 
    headers,
    "all ekg data"
    )

  puts "\n\t\t\t----\n\n"

  # print events for each token
  # map_tokens_to_events(downloaded).each do |token, events|
  #   print_table(
  #     events, 
  #     headers, 
  #     "ekg data for token #{token}"
  #     )
  # end
end



