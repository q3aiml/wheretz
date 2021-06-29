# frozen_string_literal: true

describe WhereTZ do
  describe '#lookup' do
    subject { described_class.method(:lookup) }

    context 'when unambiguous bounding box: Moscow' do
      its_call(55.75, 37.616667) {
        is_expected.to ret('Europe/Moscow').and dont.send_message(File, :read)
      }
    end

    context 'when ambiguous bounding box: Kharkiv' do
      before {
        expect(File).to receive(:read).twice.and_call_original # rubocop:disable RSpec/ExpectInHook,RSpec/MessageSpies
      }

      its_call(50.004444, 36.231389) { is_expected.to ret 'Europe/Kiev' }
    end

    context 'when edge case' do
      its_call(43.6605555555556, 7.2175) { is_expected.to ret 'Europe/Paris' }
    end

    context 'when no timezone: middle of the ocean' do
      its_call(35.024992, -39.481339) { is_expected.to ret nil }
    end

    # FIXME: Can't find new point with overlapping timezones for testing, America/Swift_Current was fixed in 2020a
    xcontext 'when ambiguous timezones' do
      its_call(50.28337, -107.80135) {
        is_expected.to ret ['America/Swift_Current', 'America/Regina']
      }
    end

    context 'when timezone name contains hypen(-) char' do
      its_call(64.56027, 143.22666) { is_expected.to ret 'Asia/Ust-Nera' }
    end

    context 'when timezone has a hole' do
      its_call(35.93, -110.60) { is_expected.to ret 'America/Phoenix' }
    end
  end

  describe '#get' do
    subject { described_class.method(:get) }

    its_call(55.75, 37.616667) { is_expected.to ret TZInfo::Timezone.get('Europe/Moscow') }
    its_call(35.024992, -39.481339) { is_expected.to ret nil }

    # FIXME: Can't find new point with overlapping timezones for testing, America/Swift_Current was fixed in 2020a
    xcontext 'when ambiguous timezones' do
      its_call(50.28337, -107.80135) {
        is_expected.to ret [TZInfo::Timezone.get('America/Swift_Current'),
                            TZInfo::Timezone.get('America/Regina')]
      }
    end
  end
end
