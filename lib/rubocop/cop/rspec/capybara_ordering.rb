require 'capybara/rspec/matchers'
require 'rspec/matchers'

module RuboCop
  module Cop
    module RSpec
      # When using acceptance testing with Capybara, using
      # non-Capybara matchers before Capybara matchers will
      # introduce intermittent errors and should be avoided.
      #
      # @example
      #   # bad
      #   it '...' do
      #     expect(Model.last.name).to eq('model name')
      #     expect(page).to have_text('model name')
      #   end
      #
      #   # good
      #   it '...' do
      #     expect(page).to have_text('model name')
      #     expect(Model.last.name).to eq('model name')
      #   end
      class CapybaraOrdering < Cop
        include RuboCop::RSpec::SpecOnly,
          RuboCop::RSpec::Language

        MSG = 'To maintain Capybara concurrency protection, swap the line sequence of `%{one}` and `%{two}`.'.freeze

        SAFE_MATCHERS = Capybara::RSpecMatchers.instance_methods(false).freeze
        # expect is used by both so we don't care
        UNSAFE_MATCHERS = ::RSpec::Matchers.instance_methods(false).
          tap {|h| h.delete(:expect) }.freeze
        ALL_MATCHERS = SAFE_MATCHERS + UNSAFE_MATCHERS

        def_node_matcher :example?, <<-PATTERN
          (block (send _ {#{Examples::ALL.to_node_pattern}} ...) ...)
        PATTERN

        def_node_search :matcher, <<-PATTERN
          (send _ {
          #{ALL_MATCHERS.to_s.delete('[]').gsub(',',"\n")}
          }
         ...)
        PATTERN

        def on_block(node)
          return unless example?(node) && (matchers = matcher(node))

          one = matchers.next
          two = matchers.next

          if UNSAFE_MATCHERS.include?(one.method_name) && SAFE_MATCHERS.include?(two.method_name)
            add_offense(one, :expression, MSG % { one: one.method_name, two: two.method_name} )
          end
        end

        def autocorrect(node)
          _receiver, method_name, *_args = *node
          lambda do |corrector|
            corrector.replace(node.loc.selector,
                              method_name.equal?(:not_to) ? 'to_not' : 'not_to')
          end
        end
      end
    end
  end
end
