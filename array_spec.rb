require_relative 'array'

describe Array do
  describe "#binary_insert" do
    context "random numbers" do
      let(:length) { rand(100..200) }
      let(:numbers) { ([nil]*length).map{ rand(100) } }
      it "sorts" do
        a = []
        numbers.each {|n| a.binary_insert n }
        expect(a).to eq numbers.sort
      end
    end

    context 'with block' do
      let(:length) { rand(100..200) }
      let(:numbers) { ([nil]*length).map{ rand(100) } }
      it "sorts reverse" do
        arr = []
        numbers.each do |n|
          arr.binary_insert(n) { |o| o * -1 }
        end
        expect(arr).to eq numbers.sort.reverse
      end
    end
  end
end
