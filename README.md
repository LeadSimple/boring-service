# BoringService

Provides a lightweight, standard (quite frankly, boring) implementation for the service-object pattern.

The benefits of using this over a [PORO](https://en.wikipedia.org/wiki/Plain_old_Java_object), besides having a standard way to define and run service-object methods, is the addition of parameter type-checking and before hooks.

In every other way, this leaves you with vanilla, semantic Ruby. Boring is powerful.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'boring-service'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install boring-service

## Usage

### Parameters

#### Defining Parameters
```ruby
class RandomService < BoringService
  # Type checking is optional. If omitted, anything is accepted.
  parameter :random_object

  def call
    random_object&.class
  end
end

# The class-method version of `call` accepts the arguments as named parameters and, subsequently, calls the
# instance-method version of `call` (as it's defined in your service class).
RandomService.call                        #=> raise BoringService::ParameterRequired
RandomService.call(random_object: 'test') #=> String
RandomService.call(random_object: 1)      #=> Integer
```

#### Basic Parameter Type Checking
```ruby
class CalculationService < BoringService
  # If a type checking Class is provided, the type check will be enforced against the defined parameter.
  parameter :start_number, Integer

  # Parameters that define a `default` are optional.
  parameter :end_number, Integer, default: 2

  def call
    @magic_number = 42
    perform_complex_calculation
  end

  private

  def perform_complex_calculation
    # The arguments are available as accessors
    start_number + end_number + @magic_number
  end
end

CalculationService.call(start_number: 1, end_number: 3) #=> 46
CalculationService.call(start_number: 1)                #=> 45
CalculationService.call(start_number: '1')              #=> BoringService::InvalidParameterValue
CalculationService.call(end_number: 3)                  #=> raise BoringService::ParameterRequired
```

#### Advanced Options for Parameter Type Checking
```ruby
class MoreOptionsService < BoringService
  # Type checking can also be done with an Array of classes, a proc/lambda, or anything that responds to #===.
  parameter :times_to_run, [String, Integer]
  parameter :return_output, -> (param) { param.in?([true, false]) }

  # `default` also supports a proc/lambda, that gets evaluated at object instantiation.
  parameter :timestamp, Time, default: -> { Time.now.beginning_of_day }

  def call
    Array.new(times_to_run.to_i) { timestamp if return_output }
  end
end

MoreOptionsService.call(times_to_run: 1, return_output: true)    #=> [2024-08-30 00:00:00 -0400]
MoreOptionsService.call(times_to_run: 1, return_output: false)   #=> [nil]
MoreOptionsService.call(times_to_run: 5, return_output: false)   #=> [nil, nil, nil, nil, nil]
MoreOptionsService.call(times_to_run: '5', return_output: false) #=> [nil, nil, nil, nil, nil]
MoreOptionsService.call(times_to_run: 5, return_output: 'false') #=> raise BoringService::InvalidParameterValue
MoreOptionsService.call(
  times_to_run: 1, 
  return_output: true, 
  timestamp: Time.now.beginning_of_day - 1.day
)                                                                #=> [2024-08-29 00:00:00 -0400]
```

### Hooks

```ruby
class RandomService < BoringService
  # Before hooks may be defined as a Symbol method name (which calls the named method) or as a block
  before :set_start_time
  before { puts "Started at #{@start_time}" }

  def call
    puts "Called"
  end

  private

  def set_start_time
    @start_time = Time.now
  end
end

RandomService.call

#=> "Started at 2024-03-26 13:40:11.466186 -0400"
#=> "Called"
```


### Errors

* `BoringService::ParameterRequired` is raised when a required parameter is not set on `call`
* `BoringService::InvalidParameterValue` is raised when a given value's type does not match the type specified for the parameter
* `BoringService::UnknownParameter` is raised when using an undefined parameter

All these classes inherit from `BoringService::ParameterError`, which inherits from `ArgumentError`.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/LeadSimple/boring-service. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
