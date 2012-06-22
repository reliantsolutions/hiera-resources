Setup for both YAML and Redis use cases
=======================================

1. Create ~/.puppet/hiera.yaml

<pre>
---
:hierarchy:
  - common

:backends:
: - yaml
  - redis

:yaml:
  :datadir: /tmp/hiera/data

:redis:
  :port: 6379
</pre>

2. Create /tmp/hiera/data/common.yaml

<pre>
---
messages:
  message 1:
    message: this is the first resource stored in YAML
  message 2:
    message: this is the second resource stored in YAML
  message 3:
    message: this is the third resource stored in YAML
</pre>

3. Create a dummy module

<pre>
$ FUNCTION_DIR=/tmp/modules/lib/puppet/parser/functions
$ mkdir -p $FUNCTION_DIR
$ cp hiera_resources*.rb $FUNCTION_DIR
</pre>

Creating resources from a YAML backend
======================================

Create a simple puppet manifest
<pre>
$ echo "hiera_resources('notify', 'messages')" > /tmp/yaml.pp
</pre>

Now apply the manifest
<pre>
$ sudo puppet apply --modulepath=/tmp/modules /tmp/yaml.pp
</pre>

Creating resources from a Redis backend
=======================================

Make sure Redis is running on localhost:6379

Add the following data to Redis:

<pre>
sadd common:messages2 'message 1' 'message 2' 'message 3'
sadd 'common:messages2:message 1' message
sadd 'common:messages2:message 2' message
sadd 'common:messages2:message 3' message
sadd 'common:messages2:message 1:message 'This is the first resource stored in Redis'
sadd 'common:messages2:message 2:message 'This is the second resource stored in Redis''
sadd 'common:messages2:message 3:message 'This is the third resource stored in Redis'
</pre>

Create a simple puppet manifest

<pre>
$ echo "hiera_resources_redis('notify', 'messages2')" > /tmp/redis.pp
</pre>

Now apply the manifest

<pre>
$ sudo puppet apply --modulepath=/tmp/modules /tmp/redis.pp
</pre>
