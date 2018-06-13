# frozen_string_literal: true

module Logux
  class Action
    class UnknownTypeError < StandardError; end

    attr_reader :params, :meta

    def initialize(params:, meta: {})
      @params = params
      @meta = meta
    end

    def subscribe
      channel_class = subscribe_class || params.channel_name.camelcase.constantize
      if !defined?(ActiveRecord) || channel_class.is_a?(ActiveRecord::Base)
        raise_unknown_type_error!
      end
      channel_class.find_by(id: subscribe_id || params.channel_id)
    rescue NameError
      raise_unknown_type_error!
    end

    def respond(status, with_params: params, with_meta: meta, custom_data: nil)
      Logux::Response.new(status,
                          params: with_params,
                          meta: with_meta,
                          custom_data: custom_data)
    end

    def subscribe_class; end

    def subscribe_id; end

    private

    def raise_unknown_type_error!
      raise Logux::Action::UnknownTypeError
    end
  end
end
