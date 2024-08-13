require 'spec_helper'

class CustomService < BoringService
  parameter :required_param, String
  parameter :optional_param, String, default: 'something'

  before :first_pre_hook
  before { @second_pre_hook_time = Time.now }

  def call
    {
      first_pre_hook_time: @first_pre_hook_time,
      second_pre_hook_time: @second_pre_hook_time
    }
  end

  private

  def first_pre_hook
    @first_pre_hook_time = Time.now
  end
end

RSpec.describe BoringService do
  describe ".call" do
    it "should raise an error if a required param is not passed" do
      expect { CustomService.call }.to raise_error BoringService::ParameterRequired
    end

    it "should raise an error if a param is the wrong type" do
      expect { CustomService.call(required_param: 5) }.to raise_error BoringService::InvalidParameterValue
    end

    it "should raise an error if an undefined param is passed" do
      expect { CustomService.call(undefined_param: 5) }.to raise_error BoringService::UnknownParameter
    end

    it "should call before hooks in the order that they're defined" do
      response = CustomService.call(required_param: "foo")

      expect(response[:first_pre_hook_time] < response[:second_pre_hook_time]).to be true
    end

    it "should throw an error if the `.call` method is not overridden" do
      class BadService < BoringService; end

      expect { BadService.call }.to raise_error NotImplementedError
    end
  end
end
