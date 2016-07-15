# Lograge::Sql

[<img src="https://img.shields.io/badge/version-0.1.1-green.svg" alt="version" />](https://github.com/iMacTia/lograge-sql) [<img src="https://travis-ci.org/iMacTia/lograge-sql.svg?branch=master" alt="version" />](https://travis-ci.org/iMacTia/lograge-sql)

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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iMacTia/lograge-sql.

