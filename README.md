Overview
========

hiera_resources has 1 job in life; create Puppet resources from a hash returned by Hiera. The hash returned should match the structure of the hash required by Puppet's [create_resources]{http://docs.puppetlabs.com/references/latest/function.html#createresources} function. Examples for using this with YAML and Redis (serialized) backends are included below.

Credit
======

This version of hiera_resources is basically a complete refactoring
based on this excellent [blog post by Robin Bowes]{http://yo61.com/assigning-resources-to-nodes-with-hiera-in-puppet.html}.

Setup for both YAML and Redis backends
=======================================

Ensure the following gem versions are installed:

  - [hiera]{http://rubygems.org/gems/hiera} gem >= 1.0.0
  - [hiera-puppet]{http://rubygems.org/gems/hiera-puppet} >= 1.0.0
  - [hiera-redis]{http://rubygems.org/gems/hiera-redis} >= 1.0.0 (coming soon...)

This function should exist in a place where puppet can find it.
~/.puppet/var/lib/puppet/parser/functions is certainly fine for testing
purposes.

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

    $ mkdir -p /tmp/hiera/data

Create some YAML data in /tmp/hiera/data/common.yaml

<pre>
---
messages1:
  notify:
    title 1:
      message: this is the first message stored in YAML
    title 2:
      message: this is the second message stored in YAML
</pre>

Creating Puppet resources from the YAML backend
======================================

Apply a manifest

<pre>
$ puppet apply -e "hiera_resources('messages1')"
notice: This is the second message stored in YAML.
notice: /Stage[main]//Notify[title 2]/message: defined 'message' as 'This is the second message stored in YAML.'
notice: This is the first message stored in YAML.
notice: /Stage[main]//Notify[title 1]/message: defined 'message' as 'This is the first message stored in YAML.'
</pre>

Creating Puppet resources from the Redis backend
=======================================

Make sure Redis is running on localhost:6379 (or tweak the call to
Redis.new below)

Fire up your favorite ruby REPL and add a few serialized Puppet resources
into a Redis key.

<pre>
require 'redis'
require 'json'

resources = { 'notify' => {
  'title 1' => {
    'message' => 'This is the first message stored in Redis.'
    },
  'title 2' => {
    'message' => 'This is the second message stored in Redis.'
    }
  }
}

r = Redis.new
r.set 'common:messages2', resources.to_json
</pre>

Configure deserialization in ~/.puppet/hiera.yaml (use :yaml instead of
:json if appropriate).
<pre>
:redis:
  :deserialize: :json
</pre>

Now apply a manifest

<pre>
$ puppet apply -e "hiera_resources('messages2')"
notice: This is the second message stored in Redis.
notice: /Stage[main]//Notify[title 2]/message: defined 'message' as 'This is the second message stored in Redis.'
notice: This is the first message stored in Redis.
notice: /Stage[main]//Notify[title 1]/message: defined 'message' as 'This is the first message stored in Redis.'
</pre>

Additional features
===================

hiera_resources will accept a hash as a 2nd argument. When present, the hash will be used as a default if the key can not be found.
