Overview
========

hiera_resources has 1 job in life; create puppet resources from a hash returned by Hiera

This document will cover using the function with 2 Hiera backends:
  - yaml
  - redis (hashes must be serialized using JSON or YAML)

Setup for both YAML and Redis backends
=======================================

Ensure the following gem versions are installed:

  - hiera gem >= 1.0.0
  - hiera-puppet >= 1.0.0
  - hiera-redis >= 1.0.0 (coming soon...)

Create a Hiera configuration in ~/.puppet/hiera.yaml

<pre>
---
:hierarchy:
  - common
:backends:
  - yaml
  - redis
:yaml:
  :datadir: /tmp/hiera/data
</pre>

<pre>
mkdir -p /tmp/hiera/data
</pre>

Create some YAML data in /tmp/hiera/data/common.yaml

<pre>
---
messages1:
  resource title 1:
    message: this is the first message stored in YAML
  resource title 2:
    message: this is the second message stored in YAML
  resource title 3:
    message: this is the third message stored in YAML
</pre>

Creating Puppet resources from the YAML backend
======================================

Create a simple puppet manifest
<pre>
$ echo "hiera_resources('notify', 'messages1')" > /tmp/yaml.pp
</pre>

Now apply the manifest
<pre>
$ puppet apply /tmp/yaml.pp
</pre>

Creating Puppet resources from the Redis backend
=======================================

Make sure Redis is running on localhost:6379

Fire up irb or pry to add a JSON serialized hash into Redis

<pre>
require 'redis'
require 'json'

messages = {
  'resource title 1' => { 'message' => 'This is the first message stored in Redis.' },
  'resource title 2' => { 'message' => 'This is the second message stored in Redis.' },
  'resource title 3' => { 'message' => 'This is the third message stored in Redis.' }
}

r = Redis.new
r.set 'common:messages2', messages.to_json
</pre>

Configure deserialization in Hiera's configuration file. Use :yaml if
appropriate.
<pre>
:redis:
  :deserialize: :json
</pre>

Create a simple Puppet manifest

<pre>
$ echo "hiera_resources_redis('notify', 'messages2')" > /tmp/redis.pp
</pre>

Now apply the manifest

<pre>
$ puppet apply /tmp/redis.pp
</pre>

Additional features
===================

hiera_resources will accept a hash as a 3rd argument. When present, the hash will be used as a default if the key can not be found.
