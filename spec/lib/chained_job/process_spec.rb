# frozen_string_literal: true

RSpec.describe ChainedJob::Process, '.run' do
  subject { described_class.run(args, job_instance, job_arguments_key, worker_id, job_tag) }

  let(:args) { {} }
  let(:job_instance) do
    double(
      process: ->() {},
      class: double(perform_later: ->(args, worker_id, job_tag) {}),
      try: ->(method_name) { handle_retry? },
    )
  end
  let(:job_arguments_key) { 'DummyJob' }
  let(:worker_id) { 1 }
  let(:job_tag) { '1595253473.6297688' }
  let(:array_of_arguments) { [101] }
  let(:serialized_array_of_arguments) { ChainedJob::Helpers.serialize(array_of_arguments) }
  let(:redis_key) { "chained_job:#{job_arguments_key}:#{job_tag}" }
  let(:handle_retry?) { false }

  before do
    ChainedJob.redis.rpush(redis_key, serialized_array_of_arguments)
  end

  it 'process argument and enqueues job' do
    expect(job_instance).to receive(:process).with(101)
    expect(job_instance.class).to receive(:perform_later).with(args, worker_id, job_tag)

    subject
  end

  context 'when arguments are not found' do
    let(:redis_key) { 'non-existing-key' }

    it 'logs about finished worker' do
      expect(ChainedJob.logger).to receive(:info).with(/finished/)

      subject
    end
  end

  context 'when error is raised' do
    before { allow(job_instance).to receive(:process).and_raise('Runtime error') }

    it 'raises error' do
      expect(job_instance.class).not_to receive(:perform_later).with(args, worker_id, job_tag)

      expect { subject }.to raise_error('Runtime error')
    end

    context 'when handle retry is enabled' do
      let(:handle_retry?) { true }

      it 'pushes argument back and raises error' do
        expect(ChainedJob.redis)
          .to receive(:rpush)
          .with(redis_key, ChainedJob::Helpers.serialize([101]))

        expect { subject }.to raise_error('Runtime error')
      end
    end
  end
end
