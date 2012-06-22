module Puppet::Parser::Functions
  newfunction(:hiera_resources) do |*args|
    if args[0].is_a?(Array)
      args = args[0]
    end

    type = args[0]
    key = args[1]
    default = args[2]
    override = args[3]

    configfile = File.join([File.dirname(Puppet.settings[:config]), "hiera.yaml"])

    raise(Puppet::ParseError, "Hiera config file #{configfile} not readable") unless File.exist?(configfile)

    require 'hiera'
    require 'hiera/scope'

    config = YAML.load_file(configfile)
    config[:logger] = "puppet"

    hiera = Hiera.new(:config => config)

    hiera_scope = self.respond_to?("{}") ? self : Hiera::Scope.new(self)

    method = Puppet::Parser::Functions.function(:create_resources)
    answer = hiera.lookup(key, default, hiera_scope, override, :hash)
    raise(Puppet::ParseError, "Could not find data item #{key} in any Hiera data file and no default supplied") if answer.empty?
    send(method, [type, answer])
    
  end
end
