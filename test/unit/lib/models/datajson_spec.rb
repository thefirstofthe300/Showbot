require 'rspec'

require File.join Dir.pwd, 'lib/models/datajson.rb'

describe DataJSON::DataJSON do
  before(:example) do
    @persistence = double(DataJSON::Persistence::NilPersistence)
    @data_json = DataJSON::DataJSON.new(@persistence)
  end

  it 'is accessible if the persistence is' do
    allow(@persistence).to receive(:accessible?) { true }
    expect(@data_json.accessible?).to be true
  end

  it 'is not accessible if the persistence is not' do
    allow(@persistence).to receive(:accessible?) { false }
    expect(@data_json.accessible?).to be false
  end

  it 'reads a live broadcast' do
    started_at = DateTime.parse('2015-03-07T04:00:00+00:00')
    allow(@persistence).to receive(:read) do
      {
        :live => true,
        :broadcast => {
          :slug => 'slug',
          :title => 'Title',
          :started_at => started_at
        }
      }.to_json

      @data_json.read

      expect(@data_json.live?).to be true
      expect(@data_json.slug).to eq 'slug'
      expect(@data_json.title).to eq 'Title'
      expect(@data_json.started_at).to eq started_at
      expect(@data_json.written?).to be true
    end
  end

  it 'reads a non-live broadcast' do
    allow(@persistence).to receive(:read) do
      {
        :live => false
      }.to_json
    end

    @data_json.read

    expect(@data_json.live?).to be false
    expect(@data_json.written?).to be true
  end

  it 'raises IOError if it cannot parse the JSON' do
    allow(@persistence).to receive(:read) { 'this is not JSON' }

    expect { @data_json.read }.to raise_error(IOError)
  end

  it 'sets the live flag' do
    @data_json.live = true

    expect(@data_json.live?).to be true
    expect(@data_json.written?).to be false
  end

  it 'sets the slug' do
    @data_json.slug = 'slug'

    expect(@data_json.slug).to eq 'slug'
    expect(@data_json.written?).to be false
  end

  it 'sets the title' do
    @data_json.title = 'Title'

    expect(@data_json.title).to eq 'Title'
    expect(@data_json.written?).to be false
  end

  it 'writes data out' do
    started_at = DateTime.parse('2015-03-07T04:00:00+00:00')

    allow(@persistence).to receive(:write)

    @data_json.write(started_at)

    expect(@data_json.started_at).to eq started_at
    expect(@data_json.written?).to be true
  end
end
