# frozen_string_literal: true

RSpec.describe ChainedJob::StartChains, '.run' do
  subject do
    described_class.run(args, job_class, job_arguments_key, array_of_job_arguments, parallelism)
  end

  let(:args) { {} }
  let(:job_class) do
    double(
      perform_later: ->(args, worker_id, job_tag) {},
    )
  end
  let(:job_arguments_key) { 'DummyJob' }
  let(:array_of_job_arguments) { [101] }
  let(:parallelism) { 2 }

  it 'stores arguments and enqueues job' do
    expect(ChainedJob::CleanUpQueue).to receive(:run).with(job_arguments_key)
    expect(ChainedJob::StoreJobArguments).to receive(:run).with(
      job_arguments_key, instance_of(String), array_of_job_arguments
    )

    expect(job_class).to receive(:perform_later).twice

    subject
  end

  context 'when array of arguments are empty' do
    let(:array_of_job_arguments) { [] }

    it 'does not start chains' do
      expect(ChainedJob::CleanUpQueue).to receive(:run).with(job_arguments_key)

      expect(job_class).not_to receive(:perform_later)

      subject
    end
  end
end
