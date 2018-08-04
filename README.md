# PhcStringFormat

[![Gem Version](https://badge.fury.io/rb/phc_string_format.svg)](https://badge.fury.io/rb/phc_string_format)
[![Build Status](https://travis-ci.org/naokikimura/phc_string_format.svg?branch=master)](https://travis-ci.org/naokikimura/phc_string_format)
[![Known Vulnerabilities](https://snyk.io/test/github/naokikimura/phc_string_format/badge.svg?targetFile=Gemfile.lock)](https://snyk.io/test/github/naokikimura/phc_string_format?targetFile=Gemfile.lock)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/cbcb6fa3556447a4af16980f3cc6f1eb)](https://app.codacy.com/app/naokikimura/phc_string_format?utm_source=github.com&utm_medium=referral&utm_content=naokikimura/phc_string_format&utm_campaign=badger)
[![Codacy Badge](https://api.codacy.com/project/badge/Coverage/26df342921414ee69b69f028cefe4f3b)](https://www.codacy.com/app/naokikimura/phc_string_format?utm_source=github.com&utm_medium=referral&utm_content=naokikimura/phc_string_format&utm_campaign=Badge_Coverage)

PHC string format implemented by Ruby

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'phc_string_format'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install phc_string_format

## Usage

```ruby
require 'phc_string_format'

encrypted_password = '$argon2i$v=19$m=4096,t=3,p=1$IfH5R3O3r3501DfGnGr2rw$DfQ8Hv9R2eF2uBs1dR99IGjVjDl/rpkJIkaNyZ1g3pk'

# parse
phc_string_args = PhcStringFormat::Formatter.parse(encrypted_password)
# => {:id=>"argon2i", :version=>19, :params=>{"m"=>4096, "t"=>3, "p"=>1}, :salt=>"!\xF1\xF9Gs\xB7\xAF~t\xD47\xC6\x9Cj\xF6\xAF", :hash=>"\r\xF4<\x1E\xFFQ\xD9\xE1v\xB8\e5u\x1F} h\xD5\x8C9\x7F\xAE\x99\t\"F\x8D\xC9\x9D`\xDE\x99"}

# format
password_hash = PhcStringFormat::Formatter.format(phc_string_args)

password_hash == encrypted_password
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/naokikimura/phc_string_format.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
