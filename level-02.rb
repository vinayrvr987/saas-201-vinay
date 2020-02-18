def get_command_line_argument
 
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

domain = get_command_line_argument

dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  dns_records = {}

  dns_raw.
    map { |line| line.strip }.
    reject { |line| line.empty? }.
    reject { |line| line[0] == "#" }.
    each do |line|
    data = line.split ","
    dns_records[data[1].strip] = { :type => data[0].strip, :val => data[2].strip }
  end

  return dns_records
end

def resolve(dns_records, lookup_chain, domain)
  lookup_result = dns_records[domain]

  if lookup_result == nil
    lookup_chain = ["Error: record is not found for #{domain}"]
  else
    lookup_chain.push lookup_result[:val]
    lookup_chain = resolve(dns_records, lookup_chain, lookup_result[:val]) if lookup_result[:type] == "CNAME"
  end

  return lookup_chain
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
