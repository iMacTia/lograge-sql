# Lograge::Sql

[![Gem Version](https://badge.fury.io/rb/lograge-sql.svg)](https://badge.fury.io/rb/lograge-sql)
[![Build Status](https://travis-ci.org/iMacTia/lograge-sql.svg)](https://travis-ci.org/iMacTia/lograge-sql)

Lograge::Sql is an extension to the famous [Lograge](https://github.com/roidrage/lograge) gem, which adds SQL queries to the Lograge Event and disable default ActiveRecord logging.
This is extremely useful if you're using Lograge together with the ELK stack.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lograge-sql'
```

## Usage

In order to enable SQL logging in your application, you'll simply need to add this on top of your lograge initializer:

```ruby
# config/initializers/lograge
require 'lograge/sql/extension'
```

By default, Lograge::Sql disables default logging on ActiveRecord. To preserve default logging, add this to your lograge initializer:

```ruby
config.lograge_sql.keep_default_active_record_log = true
```

## Customization

By default, the format is a string concatenation of the query name, the query duration and the query itself joined by `\n` newline:

```
method=GET path=/mypath format=html ...
Object Load (0.42) SELECT "objects.*" FROM "objects"
Associations Load (0.42) SELECT "associations.*" FROM "associations" WHERE "associations"."object_id" = "$1"
```

However, having `Lograge::Formatters::Json.new`, the relevant output is

```json
{
    "sql_queries": "name1 ({duration1}) {query1}\nname2 ({duration2}) query2 ...",
    "sql_queries_count": 3
}
```

To customize the output:

```ruby
# config/initializers/lograge.rb
Rails.application.configure do

  # Instead of extracting event as Strings, extract as Hash. You can also extract
  # additional fields to add to the formatter
  config.lograge_sql.extract_event = Proc.new do |event|
    { name: event.payload[:name], duration: event.duration.to_f.round(2), sql: event.payload[:sql] }
  end
  # Format the array of extracted events
  config.lograge_sql.formatter = Proc.new do |sql_queries|
    sql_queries
  end
end
```

Lograge-sql keeps an array with all sql queries in memory for the duration of request.
You can make it more memory efficient by keeping just a query counter:

```ruby
# config/initializers/lograge.rb
Rails.application.configure do
  config.lograge_sql.counter_only = true
end
```

#### Thread-safety

[Depending on the web server in your project](https://github.com/steveklabnik/request_store#the-problem) you might benefit from improved thread-safety by adding [`request_store`](https://github.com/steveklabnik/request_store) to your Gemfile. It will be automatically picked up by `lograge-sql`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iMacTia/lograge-sql.

