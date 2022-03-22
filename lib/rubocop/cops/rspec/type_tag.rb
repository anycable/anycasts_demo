# frozen_string_literal: true

require "rubocop-rspec"

module RuboCop
  module Cop
    module RSpec
      # This cops checks that default `type` tag is not specified explicitly.
      #
      #  # bad
      #  describe UsersController, type: :controller do
      #    # ...
      #  end
      #
      #  # good
      #  describe UsersController do
      #    # ...
      #  end
      #
      class TypeTag < RuboCop::Cop::RSpec::Base
        include RuboCop::Cop::RSpec::TopLevelGroup

        MSG = "Avoid specifiying inferrable type tags explicitly. " \
              "Remove `type: :%s` (it's inferred automatically)"

        def_node_matcher :type_tag, <<~PATTERN
          (pair (sym :type) (sym $_))
        PATTERN

        def on_top_level_example_group(node)
          metadata = node.children.first.children[3]
          return unless metadata

          metadata.children.each do |arg|
            actual_tag = type_tag(arg)
            next unless actual_tag
            next if actual_tag != expected_tag

            break add_offense(node, message: MSG % actual_tag)
          end
        end

        private

        def expected_tag
          file_path = processed_source.file_path
          if file_path =~ %r{/spec/([^/]+)/}
            Regexp.last_match[1].gsub(/s$/, "").to_sym
          end
        end
      end
    end
  end
end
