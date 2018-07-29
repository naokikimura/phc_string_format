require 'pry'

RSpec.describe PhcStringFormat::PhcString do
  describe '#parse' do
    it 'can parse PHC string' do
      expected = {
        id: 'argon2i',
        version: 19,
        params: { 'm' => 4096, 't' => 3, 'p' => 1 },
        salt: ['21f1f94773b7af7e74d437c69c6af6af'].pack('H*'),
        hash: ['0df43c1eff51d9e176b81b35751f7d2068d58c397fae990922468dc99d60de99'].pack('H*')
      }
      encrypted_password = '$argon2i$v=19$m=4096,t=3,p=1' \
        '$IfH5R3O3r3501DfGnGr2rw$DfQ8Hv9R2eF2uBs1dR99IGjVjDl/rpkJIkaNyZ1g3pk'
      phc_string = PhcStringFormat::PhcString.parse(encrypted_password)
      expect(phc_string.to_h).to eq expected
    end

    it 'is reversible' do
      encrypted_password = '$argon2i$v=19$m=4096,t=3,p=1' \
        '$IfH5R3O3r3501DfGnGr2rw$DfQ8Hv9R2eF2uBs1dR99IGjVjDl/rpkJIkaNyZ1g3pk'
      phc_string = PhcStringFormat::PhcString.parse(encrypted_password)
      expect(phc_string.to_s).to eq encrypted_password
    end
  end

  describe '#create' do
    it 'can create PHC string' do
      expected = '$argon2i$v=19$m=4096,t=3,p=1' \
        '$IfH5R3O3r3501DfGnGr2rw$DfQ8Hv9R2eF2uBs1dR99IGjVjDl/rpkJIkaNyZ1g3pk'
      phc_string_parameters = {
        id: 'argon2i',
        version: 19,
        params: { 'm' => 4096, 't' => 3, 'p' => 1 },
        salt: ['21f1f94773b7af7e74d437c69c6af6af'].pack('H*'),
        hash: ['0df43c1eff51d9e176b81b35751f7d2068d58c397fae990922468dc99d60de99'].pack('H*')
      }
      phc_string = PhcStringFormat::PhcString.create(phc_string_parameters)
      expect(phc_string.to_s).to eq expected
    end

    it 'is reversible' do
      phc_string_parameters = {
        id: 'argon2i',
        version: 19,
        params: { 'm' => 4096, 't' => 3, 'p' => 1 },
        salt: ['21f1f94773b7af7e74d437c69c6af6af'].pack('H*'),
        hash: ['0df43c1eff51d9e176b81b35751f7d2068d58c397fae990922468dc99d60de99'].pack('H*')
      }
      phc_string = PhcStringFormat::PhcString.create(phc_string_parameters)
      expect(phc_string.to_h).to eq phc_string_parameters
    end
  end
end
