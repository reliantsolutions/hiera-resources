# Usage examples:
#   hiera_resources('notice', 'messages')
# a default can be used if the 2nd argument can not be found
#   hiera_resources('notice', 'not_found', $default)
Puppet::Parser::Functions.newfunction(:hiera_resources) do |args|

  raise Puppet::Error, "hiera_resources requires 2 arguments; got %s" % args.length unless args.length >= 2

  if args[2]
    raise Puppet::Error, "hiera_resources expects a hash as the 3rd argument; got %s" % args[2].class unless args[2].is_a? Hash
  end

  res_type = args[0]

  # The default is optional in order to permit Heira to fail when the following is true:
  # - key is not found
  # - no default provided
  res_attr = args[1, 2]

  # notice how we avoid passing a static default to the hiera_hash function...
  answer = function_hiera_hash(res_attr)
  method = Puppet::Parser::Functions.function :create_resources
  send(method, [res_type, answer]) unless answer.empty?
end
