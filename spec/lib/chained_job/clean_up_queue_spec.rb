# frozen_string_literal: true

RSpec.describe ChainedJob::CleanUpQueue, '.run' do
  subject { described_class.run(job_arguments_key) }

  let(:job_arguments_key) { 'DummyJob' }
  let(:tag_list) { ChainedJob::Helpers.tag_list(job_key) }
  let(:job_key) { ChainedJob::Helpers.job_key(job_arguments_key) }
  let(:job_tag_1) { 'Tag_One' }
  let(:job_tag_2) { 'Tag_Two' }
  let(:array_of_job_arguments) { %w(1 2 3) }

  before do
    ChainedJob.redis.call(:sadd, tag_list, job_tag_1)
    ChainedJob.redis.call(:sadd, tag_list, job_tag_2)

    ChainedJob.redis.call(
      :rpush, ChainedJob::Helpers.redis_key(job_key, job_tag_1), array_of_job_arguments
    )
    ChainedJob.redis.call(
      :rpush, ChainedJob::Helpers.redis_key(job_key, job_tag_2), array_of_job_arguments
    )
  end

  it 'cleanups queue' do
    expect(
      ChainedJob.redis.call(:lrange, ChainedJob::Helpers.redis_key(job_key, job_tag_1), 0, -1)
    ).to eq(array_of_job_arguments)
    expect(
      ChainedJob.redis.call(:lrange, ChainedJob::Helpers.redis_key(job_key, job_tag_2), 0, -1)
    ).to eq(array_of_job_arguments)

    subject

    expect(
      ChainedJob.redis.call(:lrange, ChainedJob::Helpers.redis_key(job_key, job_tag_1), 0, -1)
    ).to eq([])
    expect(
      ChainedJob.redis.call(:lrange, ChainedJob::Helpers.redis_key(job_key, job_tag_2), 0, -1)
    ).to eq([])
  end
end
