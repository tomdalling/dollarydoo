RSpec.describe DD::Hand do
  let(:straight_flush_seven_high) { described_class["3D 4D 5D 6D 7D"] }
  let(:straight_flush_six_high) { described_class["2D 3D 4D 5D 6D"] }
  let(:four_threes) { described_class["3D 3C 3H 3S JD"] }
  let(:four_twos) { described_class["2D 2C 2H 2S JD"] }
  let(:four_twos_low_kicker) { described_class["2D 2C 2H 2S 10D"] }
  let(:three_queens_two_nines) { described_class["QD QC 9S QH 9D"] }
  let(:three_jacks_two_nines) { described_class["JD JC 9S JH 9D"] }
  let(:three_jacks_two_eights) { described_class["JD JC 8S JH 8D"] }
  let(:flush_jack_high) { described_class["2D 3D 4D 5D JD"] }
  let(:flush_ten_high) { described_class["2D 3D 4D 5D 10D"] }
  let(:flush_ten_high_low_kicker) { described_class["2D 3D 4D 5D 10D"] }
  let(:straight_seven_high) { described_class["3D 5S 4S 6C 7D"] }
  let(:straight_six_high) { described_class["2D 3D 5S 4S 6C"] }
  let(:three_jacks) { described_class["JD 3D JS 4S JC"] }
  let(:three_tens) { described_class["10D 3D 10S 4S 10C"] }
  let(:three_tens_low_kicker) { described_class["10D 2D 10S 4S 10C"] }
  let(:two_jacks_two_threes) { described_class["JD 3D JS 3S 5S"] }
  let(:two_tens_two_threes) { described_class["10D 3D 10S 3S 5S"] }
  let(:two_tens_two_twos) { described_class["10D 2D 10S 2S 5S"] }
  let(:two_tens_two_twos_low_kicker) { described_class["10D 2D 10S 2S 3S"] }
  let(:pair_of_jacks) { described_class["JD 3D JS 4S 5S"] }
  let(:pair_of_nines) { described_class["9D 3D 9S 4S 5S"] }
  let(:pair_of_nines_low_kicker) { described_class["9D 2D 9S 4S 5S"] }
  let(:king_high) { described_class["KD 3D JS 4S 5S"] }
  let(:queen_high) { described_class["QD 3D JS 4S 5S"] }
  let(:queen_high_low_kicker) { described_class["QD 2D JS 4S 5S"] }

  describe "#type" do
    it("detects high cards") { expect(king_high.type).to eq(:high_card) }
    it("detects pairs") { expect(pair_of_jacks.type).to eq(:pair) }
    it("detects two pairs") { expect(two_jacks_two_threes.type).to eq(:two_pairs) }
    it("detects three of a kind") { expect(three_jacks.type).to eq(:three_of_a_kind) }
    it("detects straights") { expect(straight_six_high.type).to eq(:straight) }
    it("detects flushes") { expect(flush_jack_high.type).to eq(:flush) }
    it("detects full houses") { expect(three_jacks_two_nines.type).to eq(:full_house) }
    it("detects four of a kind") { expect(four_twos.type).to eq(:four_of_a_kind) }
    it("detects straight flushes") { expect(straight_flush_six_high.type).to eq(:straight_flush) }
  end

  it "compares/orders hands properly" do
    hands_ascending = [
      queen_high_low_kicker,
      queen_high,
      king_high,
      pair_of_nines_low_kicker,
      pair_of_nines,
      pair_of_jacks,
      two_tens_two_twos_low_kicker,
      two_tens_two_twos,
      two_tens_two_threes,
      two_jacks_two_threes,
      three_tens_low_kicker,
      three_tens,
      three_jacks,
      straight_six_high,
      straight_seven_high,
      flush_ten_high_low_kicker,
      flush_ten_high,
      flush_jack_high,
      three_jacks_two_eights,
      three_jacks_two_nines,
      three_queens_two_nines,
      four_twos_low_kicker,
      four_twos,
      four_threes,
      straight_flush_six_high,
      straight_flush_seven_high,
    ]

    expect(hands_ascending.reverse.sort).to eq(hands_ascending)
    20.times do
      expect(hands_ascending.shuffle.sort).to eq(hands_ascending)
    end
  end
end
