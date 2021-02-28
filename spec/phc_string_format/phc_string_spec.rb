# frozen_string_literal: true

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

    context 'when string is incorrect format' do
      it 'should raise the error' do
        expect { PhcStringFormat::PhcString.parse(nil) }
          .to raise_error PhcStringFormat::ParseError
      end
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
      phc_string = PhcStringFormat::PhcString.create(**phc_string_parameters)
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
      phc_string = PhcStringFormat::PhcString.create(**phc_string_parameters)
      expect(phc_string.to_h).to eq phc_string_parameters
    end
  end

  describe '#initialize' do
    context 'when id is blank' do
      it 'should raise the error' do
        expect { PhcStringFormat::PhcString.new(nil, nil, nil, nil, nil) }
          .to raise_error ArgumentError, 'id is non-compliant'
      end
    end

    context 'when id contains characters other than: [a-z0-9-]' do
      it 'should raise the error' do
        id = 'foo_bar_baz'
        expect { PhcStringFormat::PhcString.new(id, nil, nil, nil, nil) }
          .to raise_error ArgumentError, 'id is non-compliant'
      end
    end

    context 'when the id exceeds 32 characters' do
      it 'should raise the error' do
        id = 'foo' * 11
        expect { PhcStringFormat::PhcString.new(id, nil, nil, nil, nil) }
          .to raise_error ArgumentError, 'id is non-compliant'
      end
    end

    context 'when version is empty' do
      it 'should raise the error' do
        version = ''
        expect { PhcStringFormat::PhcString.new('argon2i', version, nil, nil, nil) }
          .to raise_error ArgumentError, 'version is non-compliant'
      end
    end

    context 'when version parameter name is incorrect' do
      it 'should raise the error' do
        version = 'b=1'
        expect { PhcStringFormat::PhcString.new('argon2i', version, nil, nil, nil) }
          .to raise_error ArgumentError, 'version is non-compliant'
      end
    end

    context 'when version value is blank' do
      it 'should raise the error' do
        version = 'v='
        expect { PhcStringFormat::PhcString.new('argon2i', version, nil, nil, nil) }
          .to raise_error ArgumentError, 'version is non-compliant'
      end
    end

    context 'when version value contains characters other than: [0-9]' do
      it 'should raise the error' do
        version = 'v=foo'
        expect { PhcStringFormat::PhcString.new('argon2i', version, nil, nil, nil) }
          .to raise_error ArgumentError, 'version is non-compliant'
      end
    end

    context 'when parameters is empty' do
      it 'should raise the error' do
        expect { PhcStringFormat::PhcString.new('argon2i', nil, '', nil, nil) }
          .to raise_error ArgumentError, 'parameters is non-compliant'
        expect { PhcStringFormat::PhcString.new('argon2i', nil, 'foo=0,,bar=1,', nil, nil) }
          .to raise_error ArgumentError, 'parameters is non-compliant'
      end
    end

    context 'when parameter name contains characters other than: [a-z0-9-]' do
      it 'should raise the error' do
        expect { PhcStringFormat::PhcString.new('argon2i', nil, '01_foo=0', nil, nil) }
          .to raise_error ArgumentError, 'parameters is non-compliant'
      end
    end

    context 'when the parameter name exceeds 32 characters' do
      it 'should raise the error' do
        params_string = "#{'bar' * 11}=0"
        expect { PhcStringFormat::PhcString.new('argon2i', nil, params_string, nil, nil) }
          .to raise_error ArgumentError, 'parameters is non-compliant'
      end
    end

    context 'when parameter value contains characters other than: [a-zA-Z0-9/+.-]' do
      it 'should raise the error' do
        expect { PhcStringFormat::PhcString.new('argon2i', nil, 'p=?', nil, nil) }
          .to raise_error ArgumentError, 'parameters is non-compliant'
      end
    end

    context 'when encoded salt is empty' do
      it 'should return a instance' do
        phc_string = PhcStringFormat::PhcString.new('argon2i', nil, nil, '', nil)
        expect(phc_string).to be_a_kind_of(PhcStringFormat::PhcString)
      end
    end

    context 'when encoded salt contains characters other than: [a-zA-Z0-9/+.-]' do
      it 'should raise the error' do
        expect { PhcStringFormat::PhcString.new('argon2i', nil, nil, 'q-_N', nil) }
          .to raise_error ArgumentError, 'encoded salt is non-compliant'
      end
    end

    context 'when encoded hash is empty' do
      it 'should return a instance' do
        phc_string = PhcStringFormat::PhcString.new('argon2i', nil, nil, '', '')
        expect(phc_string).to be_a_kind_of(PhcStringFormat::PhcString)
      end
    end

    context 'when encoded hash contains characters other than: [a-zA-Z0-9/+]' do
      it 'should raise the error' do
        expect { PhcStringFormat::PhcString.new('argon2i', nil, nil, 'q+/N', 'q-_N') }
          .to raise_error ArgumentError, 'encoded hash is non-compliant'
      end
    end

    context 'when salt is nil and hash is present' do
      it 'should raise the error' do
        expect { PhcStringFormat::PhcString.new('argon2i', nil, nil, nil, '') }
          .to raise_error ArgumentError, 'hash needs salt'
        expect { PhcStringFormat::PhcString.new('argon2i', nil, nil, nil, 'UEAkJHcwcmQ') }
          .to raise_error ArgumentError, 'hash needs salt'
      end
    end
  end

  describe '#==' do
    it 'can equality compare' do
      encrypted_password = '$argon2i$v=19$m=4096,t=3,p=1' \
        '$IfH5R3O3r3501DfGnGr2rw$DfQ8Hv9R2eF2uBs1dR99IGjVjDl/rpkJIkaNyZ1g3pk'
      expected = PhcStringFormat::PhcString.parse(encrypted_password)
      actual = PhcStringFormat::PhcString.parse(encrypted_password)
      expect(actual).to eq expected
    end
  end

  describe '#to_s' do
    it 'can be formatted as PHC string' do
      expected = '$argon2i$v=19$m=4096,t=3,p=1' \
        '$IfH5R3O3r3501DfGnGr2rw$DfQ8Hv9R2eF2uBs1dR99IGjVjDl/rpkJIkaNyZ1g3pk'
      phc_string = PhcStringFormat::PhcString.new \
        'argon2i',
        'v=19',
        'm=4096,t=3,p=1',
        'IfH5R3O3r3501DfGnGr2rw',
        'DfQ8Hv9R2eF2uBs1dR99IGjVjDl/rpkJIkaNyZ1g3pk'
      expect(phc_string.to_s).to eq expected
    end

    context 'when salt is empty and hash is empty' do
      it 'should end with "$$"' do
        expected = '$example$v=19$m=4096,t=3,p=1$$'
        phc_string = PhcStringFormat::PhcString.new \
          'example',
          'v=19',
          'm=4096,t=3,p=1',
          '',
          ''
        expect(phc_string.to_s).to eq expected
      end
    end

    context 'when salt is empty and hash is present (eg "AAAA")' do
      it 'should end with "$$AAAA"' do
        expected = '$example$v=19$m=4096,t=3,p=1$$AAAA'
        phc_string = PhcStringFormat::PhcString.new \
          'example',
          'v=19',
          'm=4096,t=3,p=1',
          '',
          'AAAA'
        expect(phc_string.to_s).to eq expected
      end
    end
  end
end
