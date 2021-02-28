# frozen_string_literal: true

require 'pry'

RSpec.describe PhcStringFormat::B64 do
  it 'is reversible' do
    test_cases = [
      '4fXXG0spB92WPB1NitT8/OH0VKI',
      'iPBVuORECm5biUsjq33hn9/7BKqy9aPWKhFfK2haEsM'
    ]
    test_cases.each do |test_case|
      actual = PhcStringFormat::B64.encode(PhcStringFormat::B64.decode(test_case))
      expect(actual).to eq(test_case)
    end
  end
end
