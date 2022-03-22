# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # This cops checks that top-level described is not namespaced:
      #
      #  # bad
      #  RSpec.describe MyClass do
      #    # ...
      #  end
      #
      #  # good
      #  describe MyClass do
      #    # ...
      #  end
      class Describe < RuboCop::Cop::Cop
        MSG = "Use `describe` instead of `RSpec.describe`."

        def_node_matcher :rspec_describe?, <<~PATTERN
          (send (const nil? :RSpec) :describe ...)
        PATTERN

        def on_send(node)
          return unless rspec_describe?(node)
          add_offense(node, location: :selector, message: MSG)
        end
      end
    end
  end
end
