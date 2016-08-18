describe RuboCop::Cop::RSpec::CapybaraOrdering do
  subject(:cop) { described_class.new }

  it 'detects offense when matchers sequenced unsafely' do
    expect_violation(<<-RUBY)
        it '...' do
          expect(Model.last.name).to eq('model name')
                                     ^^^^^^^^^^^^^^^^ To maintain Capybara concurrency protection, swap the line sequence of `eq` and `have_text`.
          expect(page).to have_text('model name')
        end
    RUBY
  end

  it 'detects no offense when matchers sequenced safely' do
    expect_no_violations(<<-RUBY)
        it '...' do
          expect(page).to have_text('model name')
          expect(Model.last.name).to eq('model name')
        end
    RUBY
  end

  it 'detects no offense when matchers are all safe' do
    expect_no_violations(<<-RUBY)
        it '...' do
          expect(page).to have_text('model name')
          expect(page).to have_css('#css')
          expect(page).to_not have_link('http://link.url')
        end
    RUBY
  end

  it 'can deal with scenarios using `within`' do
    expect_no_violations(<<-RUBY)
    scenario '...' do
      within('#css_selector') do
        expect(page).to have_text 'some text'
        expect(page).to have_text 2
        expect(page).to_not have_text 'other text'
      end
    end
    RUBY
  end

  it 'auto-corrects ordering if line swap is enough' do
    corrected =
      autocorrect_source(
        cop,
        [<<-RUBY
        it '...' do
          expect(Model.last.name).to eq('model name')
          expect(page).to have_text('model name')
        end
         RUBY
    ],
    'spec/foo_spec.rb'
    )
    expect(corrected).to eq(<<-RUBY)
        it '...' do
          expect(page).to have_text('model name')
          expect(Model.last.name).to eq('model name')
        end
    RUBY
  end
end
