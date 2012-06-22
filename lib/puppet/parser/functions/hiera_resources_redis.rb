module Puppet::Parser::Functions
  newfunction(:hiera_resources_redis, :doc => <<-'ENDHEREDOC') do |*args|
    Builds Puppet resources from the data found via Hiera.

      This seperate function was needed because Redis does not support real hashes.
      Our work-around is to store a resource across 3 Redis sets like so:

      sadd common:messages "message 1" "message 2" "messages 3"
      sadd "common:messages:message 1" message
      sadd "common:messages:message 2" message
      sadd "common:messages:message 3" message
      sadd "common:messages:message 1:message" "This is the first message."
      sadd "common:messages:message 2:message" "This is the second message."
      sadd "common:messages:message 3:message" "This is the third message."

      Assuming hiera.yaml includes common in the hierarchy, we can now create all
      3 notify resources like so:

      hiera_resources_redis('notify', 'messages')
    ENDHEREDOC
    if args[0].is_a?(Array)
      args = args[0]
    end

    type = args[0]
    key = args[1]
    @default = args[2]
    override = args[3]

    configfile = File.join([File.dirname(Puppet.settings[:config]), "hiera.yaml"])

    raise(Puppet::ParseError, "Hiera config file #{configfile} not readable") unless File.exist?(configfile)

    require 'hiera'
    require 'hiera/scope'

    @config = YAML.load_file(configfile)
    @config[:logger] = "puppet"
    @hiera_scope = self.respond_to?("[]") ? self : Hiera::Scope.new(self)

    method = Puppet::Parser::Functions.function(:create_resources)

    def hiera(args)
      Hiera.new(:config => config(args))
    end

    def lookup(args)
      h = hiera(args)
      h.lookup(args[:key], @default, @hiera_scope)
    end

    def config(args = {})
      @config.merge(args)
    end

    def find_start_key(key)
      @config[:hierarchy].each do |hierarchy|
        return hierarchy unless lookup(:key => key, :hierarchy => hierarchy).nil?
      end
    end

    resources = {}

    # find our starting point unless override was passed in
    start_key = override.nil? ? find_start_key(key) : override
    raise(Puppet::ParseError, "Could not find data item #{key} in any Hiera data file and no default supplied") if start_key.empty?
    titles = lookup(:key => key, :hierarchy => start_key)

    titles.each do |title|
      parameters = lookup(:key => title, :hierarchy => "#{start_key}:#{key}")
      parameters.each do |parameter|
        values = lookup(:key => parameter, :hierarchy => "#{start_key}:#{key}:#{title}")
        params = Hash[parameter => values]
        resources[title] = params
      end
    end

    send(method, [type, resources]) unless resources.empty?
  end
end
