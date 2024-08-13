require 'spec_helper'

RSpec.describe BoringService::Parameter do
  describe "#default?" do
    context "when the defined parameter includes a default" do
      parameter = described_class.new(:foo, String, default: "bar")

      it { expect(parameter.default?).to be true }
    end

    context "when the defined parameter doesn't include a default" do
      parameter = described_class.new(:foo, String)

      it { expect(parameter.default?).to be false }
    end
  end

  describe '#default' do
    parameter = described_class.new(:foo, String, default: 'bar')

    it { expect(parameter.default).to eq 'bar' }
  end

  describe "#acceptable?" do
    parameter = described_class.new(:number_string, String)

    it { expect(parameter.acceptable?("five")).to be true }
    it { expect(parameter.acceptable?(5)).to be false }
  end

  describe "#nullable?" do
    parameter_with_no_default = described_class.new(:foo, String)
    parameter_with_nil_default = described_class.new(:foo, String, default: nil)

    it { expect(parameter_with_no_default.nullable?).to be false }
    it { expect(parameter_with_nil_default.nullable?).to be true }
  end
end
