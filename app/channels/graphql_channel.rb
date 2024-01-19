# frozen_string_literal: true

class GraphQLChannel < ApplicationCable::Channel
  def unsubscribed
    ApplicationSchema.subscriptions.delete_channel_subscriptions(self)
  end

  def execute(data)
    query = data["query"]
    variables = data["variables"]
    context = {}
    context[:channel] = self

    graphql_options = {
      query: query,
      context: context,
      operation_name: data["operationName"],
      variables: variables
    }

    result = ApplicationSchema.execute(**graphql_options)

    payload = {
      result: result.to_h,
      more: result.subscription?
    }

    transmit(payload)
  end
end
