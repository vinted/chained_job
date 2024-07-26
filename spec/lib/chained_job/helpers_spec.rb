# frozen_string_literal: true

RSpec.describe ChainedJob::Helpers do
  describe '.job_key' do
    subject { described_class.job_key(job_arguments_key) }

    let(:job_arguments_key) { 'DummyJob' }

    it { is_expected.to eq("chained_job:#{job_arguments_key}") }
  end

  describe '.redis_key' do
    subject { described_class.redis_key(job_key, tag) }

    let(:job_key) { "chained_job:DummyJob" }
    let(:tag) { '1595252432.198516' }

    it { is_expected.to eq("#{job_key}:#{tag}") }
  end

  describe '.tag_list' do
    subject { described_class.tag_list(prefix) }

    let(:prefix) { 'DummyJob' }

    it { is_expected.to eq("#{prefix}:tags") }
  end
end
