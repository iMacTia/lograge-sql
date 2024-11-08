# Lograge::Sql

[![Gem Version](https://badge.fury.io/rb/lograge-sql.svg)](https://badge.fury.io/rb/lograge-sql)
[![CI](https://github.com/iMacTia/lograge-sql/actions/workflows/ci.yml/badge.svg)](https://github.com/iMacTia/lograge-sql/actions/workflows/ci.yml)

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

## Configuration

### Minimum query duration threshold

By default, `lograge-sql` stores all queries, but you can set a `min_duration_ms` config.
When you do so, only queries that run for AT LEAST `min_duration_ms` milliseconds will be logged, and all others will be ignored.
This can be really helpful if you want to detect `Slow SQL queries`.

```ruby
# config/initializers/lograge.rb
Rails.application.configure do
  # Defaults is zero
  config.lograge_sql.min_duration_ms = 5000 # milliseconds
end
```

### Filtering sql queries by name

You can filter out queries using the `query_name_denylist` configuration. 
This takes an array of regular expressions to match against the query name. If the query name matches any of the regular expressions, it will be ignored. By default, `lograge-sql` ignores queries named `SCHEMA` and queries from the `SolidCable` namespace.
If you are using Solid Cable in your project, be careful  when removing this default value as it will cause a [memory leak](https://github.com/iMacTia/lograge-sql/issues/59).

```ruby
# config/initializers/lograge.rb
Rails.application.configure do
  # Defaults is [/\ASCHEMA\z/, /\ASolidCable::/]
  config.lograge_sql.query_name_denylist << /\AEXACT NAME TO IGNORE\z/
end
```

### Output Customization

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

### Filtering out sensitive info in SQL logs
By default, `lograge-sql` will log full query but if you have sensitive data that need to be filtered out, you can set `query_filter` config:

```ruby
Rails.application.configure do
  config.lograge_sql.query_filter = ->(query) { query.gsub(/custom_regexp/, "[FILTERED]".freeze) }
end
```

### Thread-safety

[Depending on the web server in your project](https://github.com/steveklabnik/request_store#the-problem) you might benefit from improved thread-safety by adding [`request_store`](https://github.com/steveklabnik/request_store) to your Gemfile. It will be automatically picked up by `lograge-sql`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iMacTia/lograge-sql.
