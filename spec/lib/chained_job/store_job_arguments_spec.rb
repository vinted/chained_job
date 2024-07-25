# frozen_string_literal: true

RSpec.describe ChainedJob::StoreJobArguments, '.run' do
  subject { described_class.run(job_arguments_key, job_tag, array_of_job_arguments) }

  let(:job_arguments_key) { 'DummyJob' }
  let(:job_tag) { 'random-tag' }
  let(:array_of_job_arguments) { [101] }

  let(:serialized_arguments) { ChainedJob::Helpers.serialize(array_of_job_arguments) }

  it 'stores keys in redis' do
    expect(ChainedJob.redis).to receive(:rpush).with(instance_of(String), serialized_arguments)
    expect(ChainedJob.redis).to receive(:expire)

    subject
  end

  it 'sets tag in a list' do
    expect(ChainedJob.redis).to receive(:sadd).with(instance_of(String), job_tag)

    subject
  end
end
