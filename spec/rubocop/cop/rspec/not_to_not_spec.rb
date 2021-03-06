describe RuboCop::Cop::RSpec::NotToNot, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is `not_to`' do
    let(:cop_config) { { 'EnforcedStyle' => 'not_to' } }

    it 'detects the `to_not` offense' do
      expect_violation(<<-RUBY)
        it { expect(false).to_not be_true }
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `not_to` over `to_not`
      RUBY
    end

    it 'detects no offense when using `not_to`' do
      expect_no_violations(<<-RUBY)
        it { expect(false).not_to be_true }
      RUBY
    end

    it 'auto-corrects `to_not` to `not_to`' do
      corrected =
        autocorrect_source(
          cop,
          ['it { expect(0).to_not equal 1 }'],
          'spec/foo_spec.rb'
        )
      expect(corrected).to eq 'it { expect(0).not_to equal 1 }'
    end
  end

  context 'when AcceptedMethod is `to_not`' do
    let(:cop_config) { { 'EnforcedStyle' => 'to_not' } }

    it 'detects the `not_to` offense' do
      expect_violation(<<-RUBY)
        it { expect(false).not_to be_true }
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `to_not` over `not_to`
      RUBY
    end

    it 'detects no offense when using `to_not`' do
      expect_no_violations(<<-RUBY)
        it { expect(false).to_not be_true }
      RUBY
    end

    it 'auto-corrects `not_to` to `to_not`' do
      corrected =
        autocorrect_source(
          cop,
          ['it { expect(0).not_to equal 1 }'],
          'spec/foo_spec.rb'
        )
      expect(corrected).to eq 'it { expect(0).to_not equal 1 }'
    end
  end
end
