# frozen_string_literal: true

RSpec.describe ChainedJob::StoreJobArguments, '.run' do
  subject { described_class.run(job_arguments_key, job_tag, array_of_job_arguments) }

  let(:job_arguments_key) { 'DummyJob' }
  let(:job_tag) { 'random-tag' }
  let(:array_of_job_arguments) { [101] }

  let(:serialized_arguments) { ChainedJob::Helpers.serialize(array_of_job_arguments) }

  it 'stores keys in redis' do
    expect(ChainedJob.redis).to receive(:call).with(:sadd, instance_of(String), job_tag)
    expect(ChainedJob.redis).to receive(:call).with(:rpush, instance_of(String), serialized_arguments)
    expect(ChainedJob.redis).to receive(:call).with(:expire, instance_of(String), instance_of(Integer))

    subject
  end
end
