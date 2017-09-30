require 'spec_helper'
require_relative '../bin/example'
 
describe '#hm2s' do
  it 'should convert 3h 30m to 12600' do
    expect(hm2s('3h 30m')).to eq 12600
  end
end