# ChainedJob

The library provides ability to use chained background jobs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chained_job'
```

And then execute:

    $ bundle install

Or install the gem yourself:

    $ gem install chained_job


## How it works

`chained_job` stores background job arguments array in Redis and starts processing them in parallel by number of workers provided.

Job re-enqueues itself until there are no more stored arguments in Redis for that specific job.

### Configuration

```ruby
require 'logger'
require 'redis_config'

ChainedJob.configure do |config|
  # Default value is 1_000
  config.arguments_batch_size = 2_000

  # Default value is 7 days
  config.arguments_queue_expiration = 3 * 24 * 60 * 60 # 3 days

  # Error will be raised while running job if redis is not setup
  config.redis = Svc.redis # redis-client
  config.logger = ::Logger.new(STDOUT)
end
```

#### Custom Hooks

There are three types of hooks: `around_start_chains`, `around_chain_process` and `around_array_of_job_arguments` as lambda functions. Both of the hooks gets `options` hash.

For `around_start_chains` callback `options` hash contains four keys:

```ruby
{
  job_class: CheckUsersActivityJob,
  array_of_job_arguments: [1, 2 ,3],
  parallelism: 2,
  args: [{"job_argument" => "value"}],
}
```

For `around_chain_process`:
```ruby
{
  job_class: CheckUsersActivityJob,
  worker_id: 2,
  args: [{"job_argument" => "value"}],
}
```

For `around_array_of_job_arguments`:
```ruby
{
  job_class: CheckUsersActivityJob,
  args: [{"job_argument" => "value"}],
}
```

You can configure callbacks:

```ruby
ChainedJob.configure do |config|
  config.around_start_chains = ->(options, &block) do
    time = Benchmark.ms { block.call }

    puts "It took #{time} to start the chains for #{options[:job_class]} job"
  end
end
```

### Usage

Example of creating new background ActiveJob:

```ruby

# frozen_string_literal: true

class CheckUsersActivityJob < ActiveJob::Base
  include ChainedJob::Middleware

  def parallelism
    2
  end

  def array_of_job_arguments
    User.last(100).ids
  end

  def process(user_id)
    user = User.find_by(id: user_id)

    return unless user

    UserActivities::Check.run(user)
  end
end
```

### On Failure (retry queue)
In this case, if one of your chained workers fails to process some ids - it will go into the retry queue and restarts as you would expect. However important to note that args picked from Redis are no longer available, and hence those ids won't be processed anymore.

In case you want that during exception your arguments would be pushed back to Redis, you can use

```ruby

# frozen_string_literal: true

class CheckUsersActivityJob < ActiveJob::Base
  include ChainedJob::Middleware

  def handle_retry?
    true
  end
end
```

## Development

For running tests use `bundle exec rake test`.
To check linter errors use rubocop: `bundle exec rubocop`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vinted/chained_job.
