require 'phc_string_format/b64'
require 'phc_string_format/version'
require 'phc_string_format/validations'
require 'phc_string_format/phc_string'
require 'phc_string_format/formatter'

#
# PHC string format implemented by Ruby
#
#  ```
#  $<id>[$<param>=<value>(,<param>=<value>)*][$<salt>[$<hash>]]
#  ```
#
# See:
# - https://github.com/P-H-C/phc-string-format/blob/master/phc-sf-spec.md
# - https://github.com/P-H-C/phc-string-format/pull/4
#
module PhcStringFormat
end
