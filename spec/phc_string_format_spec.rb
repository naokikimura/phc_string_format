require 'pry'

RSpec.describe PhcStringFormat do
  it "has a version number" do
    expect(PhcStringFormat::VERSION).not_to be nil
  end

  it "is reversible" do
    test_cases = [
      "$argon2i$m=120,t=5000,p=2",
      "$argon2i$m=120,t=4294967295,p=2",
      "$argon2i$m=2040,t=5000,p=255",
      "$argon2i$m=120,t=5000,p=2,keyid=Hj5+dsK0",
      "$argon2i$m=120,t=5000,p=2,keyid=Hj5+dsK0ZQ",
      "$argon2i$m=120,t=5000,p=2,keyid=Hj5+dsK0ZQA",
      "$argon2i$m=120,t=5000,p=2,data=sRlHhRmKUGzdOmXn01XmXygd5Kc",
      "$argon2i$m=120,t=5000,p=2,keyid=Hj5+dsK0,data=sRlHhRmKUGzdOmXn01XmXygd5Kc",
      "$argon2i$m=120,t=5000,p=2$/LtFjH5rVL8",
      "$argon2i$m=120,t=5000,p=2$4fXXG0spB92WPB1NitT8/OH0VKI",
      "$argon2i$m=120,t=5000,p=2$BwUgJHHQaynE+a4nZrYRzOllGSjjxuxNXxyNRUtI6Dlw/zlbt6PzOL8Onfqs6TcG",
      "$argon2i$m=120,t=5000,p=2,keyid=Hj5+dsK0$4fXXG0spB92WPB1NitT8/OH0VKI",
      "$argon2i$m=120,t=5000,p=2,data=sRlHhRmKUGzdOmXn01XmXygd5Kc$4fXXG0spB92WPB1NitT8/OH0VKI",
      "$argon2i$m=120,t=5000,p=2,keyid=Hj5+dsK0,data=sRlHhRmKUGzdOmXn01XmXygd5Kc$4fXXG0spB92WPB1NitT8/OH0VKI",
      "$argon2i$m=120,t=5000,p=2$4fXXG0spB92WPB1NitT8/OH0VKI$iPBVuORECm5biUsjq33hn9/7BKqy9aPWKhFfK2haEsM",
      "$argon2i$m=120,t=5000,p=2,keyid=Hj5+dsK0$4fXXG0spB92WPB1NitT8/OH0VKI$iPBVuORECm5biUsjq33hn9/7BKqy9aPWKhFfK2haEsM",
      "$argon2i$m=120,t=5000,p=2,data=sRlHhRmKUGzdOmXn01XmXygd5Kc$4fXXG0spB92WPB1NitT8/OH0VKI$iPBVuORECm5biUsjq33hn9/7BKqy9aPWKhFfK2haEsM",
      "$argon2i$m=120,t=5000,p=2,keyid=Hj5+dsK0,data=sRlHhRmKUGzdOmXn01XmXygd5Kc$4fXXG0spB92WPB1NitT8/OH0VKI$iPBVuORECm5biUsjq33hn9/7BKqy9aPWKhFfK2haEsM",
      "$argon2i$m=120,t=5000,p=2,keyid=Hj5+dsK0,data=sRlHhRmKUGzdOmXn01XmXygd5Kc$iHSDPHzUhPzK7rCcJgOFfg$EkCWX6pSTqWruiR0",
      "$argon2i$m=120,t=5000,p=2,keyid=Hj5+dsK0,data=sRlHhRmKUGzdOmXn01XmXygd5Kc$iHSDPHzUhPzK7rCcJgOFfg$J4moa2MM0/6uf3HbY2Tf5Fux8JIBTwIhmhxGRbsY14qhTltQt+Vw3b7tcJNEbk8ium8AQfZeD4tabCnNqfkD1g",
      "$argon2i$v=19$m=4096,t=3,p=1$IfH5R3O3r3501DfGnGr2rw$DfQ8Hv9R2eF2uBs1dR99IGjVjDl/rpkJIkaNyZ1g3pk",
    ]
    test_cases.each do |test_case|
      phc_params = PhcStringFormat::Formatter.parse(test_case)
      phc_string = PhcStringFormat::Formatter.format(phc_params)
      expect(phc_string).to eq(test_case)
    end
  end

  it "can pick when parsing" do
    string = "$argon2i$v=19$m=4096,t=3,p=1$IfH5R3O3r3501DfGnGr2rw$DfQ8Hv9R2eF2uBs1dR99IGjVjDl/rpkJIkaNyZ1g3pk"
    params = PhcStringFormat::Formatter.parse(string, pick: [:id, :params, :version])
    expect(params).to eq({ id: 'argon2i', version: 19, params: {'m' => 4096, 't' => 3, 'p' => 1}})
  end
end
