require "spec_helper"

describe Enumerable do
  let(:test_arr) { [] }
  let(:test_hash) { {} }

  describe "#my_each" do
    it "fails when not given a block" do
      expect { [1, 2].my_each }.to raise_error(LocalJumpError)
    end

    it "fails when called on an object lacking the length method" do
      expect { 1.my_each { |_e| test_arr << 1 } }.to raise_error(NoMethodError)
    end

    it "operates on each element in an array" do
      [1, 2].my_each { |e| test_arr << e }
      expect(test_arr).to eq([1, 2])
    end

    it "operates on each key value pair in a hash" do
      {one: 1, two: 2}.my_each { |k, v| test_hash[k] = v }
      expect(test_hash).to eq({one: 1, two: 2})
    end

    it "does nothing with an empty array" do
      [].my_each { |_e| test_arr << 1 }
      expect(test_arr).to eq([])
    end

    it "does nothing with an empty hash" do
      {}.my_each { |k, v| test_hash[:one] = 1}
      expect(test_hash).to eq({})
    end
  end

  describe "#my_each_with_index" do
    it "fails when not given a block" do
      expect { [1, 2].my_each_with_index }.to raise_error(LocalJumpError)
    end

    it "fails when called on an object lacking the length method" do
      expect { 1.my_each_with_index { |_e| test_arr << 1 } }
             .to raise_error(NoMethodError)
    end

    it "operates on each element and index in an array" do
      [1, 2].my_each_with_index { |e, i| test_arr << (e + i) }
      expect(test_arr).to eq([1, 3])
    end

    it "operates on each key value pair and index in a hash" do
      {one: 1, two: 2}.my_each_with_index { |(k, v), i| test_hash[k] = v + i }
      expect(test_hash).to eq({one: 1, two: 3})
    end

    it "does nothing with an empty array" do
      [].my_each_with_index { |_e, _i| test_arr << 1 }
      expect(test_arr).to eq([])
    end

    it "does nothing with an empty hash" do
      {}.my_each_with_index { |(_k, _v), _i| test_hash[:one] = 1}
      expect(test_hash).to eq({})
    end
  end

  describe "#my_select" do
    it "fails when not given a block" do
      expect { [1, 2].my_select }.to raise_error(LocalJumpError)
    end

    it "fails when called on an object lacking the length method" do
      expect { 1.my_select { |_e| true } }.to raise_error(NoMethodError)
    end

    it "operates on each element in an array" do
      test_arr = [1, 2].my_select { |_e| true }
      expect(test_arr).to eq([1, 2])
    end

    it "operates on each key value pair in a hash" do
      test_hash = {one: 1, two: 2}.my_select { |_k, _v| true }
      expect(test_hash).to eq({one: 1, two: 2})
    end

    it "properly selects from an array based on the given condition" do
      test_arr = [1, 2, "a"].my_select { |e| e == 2 }
      expect(test_arr).to eq([2])
    end

    it "properly selects from a hash based on the given condition" do
      test_hash = {one: 1, two: 2, a: "a"}
                  .my_select { |k, v| v == 2 || k == :a }
      expect(test_hash).to eq({two: 2, a: "a"})
    end

    it "returns an empty array when called on an empty array" do
      test_arr = [].my_select { |_e| true }
      expect(test_arr).to eq([])
    end

    it "returns an empty hash when called on an empty hash" do
      test_hash = {}.my_select { |_k, _v| true}
      expect(test_hash).to eq({})
    end
  end

  describe "#my_count" do
    it "fails when called on an object lacking the length method" do
      expect { 1.my_count }.to raise_error(NoMethodError)
    end
    it "returns 0 when called on an empty array" do
      expect([].my_count).to eq(0)
    end
    it "returns 0 when called on an empty hash" do
      expect({}.my_count).to eq(0)
    end

    context "with only a target" do
      it "counts all elements in an array that match the target" do
        expect([1, 2, 1].my_count(1)).to eq(2)
      end
      it "counts all key value pairs in a hash "\
         "that match the target pair array" do
        expect({one: 1, two: 2}.my_count([:two, 2])).to eq(1)
      end
      it "returns 0 when the target is not found" do
        expect([1, 2].my_count(3)).to eq(0)
      end
      it "raises an ArgumentError when passed more than one target" do
        expect { [1, 2].my_count(1, 3) }.to raise_error(ArgumentError)
      end
    end

    context "with only a block" do
      it "counts all elements in an array that match the condition" do
        expect([1, 2, 1].my_count { |e| e == 1 }).to eq(2)
      end
      it "counts all key value pairs in a hash that match the condition" do
        expect({one: 1, two: 2}
              .my_count { |k, v| k == :two && v == 2}).to eq(1)
      end
      it "returns 0 when the condition is never satisfied" do
        expect([1, 2].my_count{ |e| e == 3 }).to eq(0)
      end
    end

    context "with a target and a block" do
      before do
        allow(STDOUT).to receive(:puts)
      end
      it "uses the target and ignores the block" do
        expect([1, 2].my_count(3) { |e| e == 1 }).to eq(0)
      end
      it "issues a warning about the ignored block" do
        expect(STDOUT).to receive(:puts).with("warning: given block not used")
        [1, 2].my_count(3) { |e| e == 1 }
      end
      it "raises an ArgumentError when passed more than one target" do
        expect { [1, 2].my_count(1, 3) { |e| e == 1 } }
               .to raise_error(ArgumentError)
      end
    end

    context "with neither a target nor a block" do
      it "counts all elements in an array" do
        expect([1, 2].my_count).to eq(2)
      end
      it "counts all key value pairs in a hash" do
        expect({one: 1, two: 2}.my_count).to eq(2)
      end
    end
  end

  describe "#my_map_pb" do
    let(:proc_a) { Proc.new { |e| e + 1 } }
    let(:proc_h) { Proc.new { |_k, v| v + 1 } }

    it "returns an empty array when called on an empty array" do
      expect([].my_map_pb(proc_a)).to eq([])
    end

    it "returns an empty array when called on an empty hash" do
      expect({}.my_map_pb(proc_h)).to eq([])
    end

    context "with only a proc" do
      it "operates on each element in an array and returns an array" do
        test_arr = [1, 2].my_map_pb(proc_a)
        expect(test_arr).to eq([2, 3])
      end
      it "operates on each key value pair in a hash and returns an array" do
        test_hash = {one: 1, two: 2}.my_map_pb(proc_h)
        expect(test_hash).to eq([2, 3])
      end
      it "raises an ArgumentError when passed more than one proc" do
        expect { [1, 2].my_map_pb(proc_a, proc_h) }
               .to raise_error(ArgumentError)
      end
    end

    context "with only a block" do
      it "issues a warning about the ignored block" do
        expect(STDOUT).to receive(:puts).with("warning: given block not used "\
                                              "(must have proc as argument)")
        [1, 2].my_map_pb { |e| e + 2 }
      end
      before do
        allow(STDOUT).to receive(:puts)
      end
      it "returns the object it was called on" do
        expect({one: 1, two: 2}.my_map_pb { |e| e + 2 })
                               .to eq({one: 1, two: 2})
      end
    end

    context "with a proc and a block" do
      it "operates twice on each element in an array and returns an array" do
        test_arr = [1, 2].my_map_pb(proc_a) { |e| e + 2 }
        expect(test_arr).to eq([4, 5])
      end
      it "operates twice on each key value pair "\
         "in a hash and returns an array" do
        test_hash = {one: 1, two: 2}.my_map_pb(proc_h) { |e| e + 2 }
        expect(test_hash).to eq([4, 5])
      end
      it "performs the operation from the proc first" do
        test_arr = [1, 2].my_map_pb(proc_a) { |e| e * 2 }
        expect(test_arr).to eq([4, 6])
      end
    end

    context "with neither a proc nor a block" do
      it "raises an ArgumentError" do
        expect { [1, 2].my_map_pb }
               .to raise_error(ArgumentError)
      end
    end
  end

  describe "#my_inject" do
    it "fails when not given a block" do
      expect { [1, 2].my_inject }.to raise_error(LocalJumpError)
    end

    it "fails when called on an object lacking the length method" do
      expect { 1.my_inject { |_m, _e| 1 } }.to raise_error(NoMethodError)
    end

    context "with only a block" do
      it "accumulates from the first element in an array" do
        expect([1, 2].my_inject { |m, e| m + e}).to eq(3)
      end
      it "accumulates from the first key value pair in a hash" do
        expect({one: 1, two: 2}.my_inject do |m, (k, v)|
          m_v = m.pop
          m << (m_v + v)
        end).to eq([:one, 3])
      end
      it "returns nil when called on an empty array" do
        expect([].my_inject { |_m, _e| 1 }).to be(nil)
      end
      it "returns nil when called on an empty hash" do
        expect({}.my_inject { |_m, _e| 1 }).to be(nil)
      end
    end

    context "with an initial value and a block" do
      it "accumulates from the initial value with an array" do
        expect([1, 2].my_inject(-9) { |m, e| m + e}).to eq(-6)
      end
      it "accumulates from the initial value with a hash" do
        expect({one: 1, two: 2}.my_inject(-9) { |m, (k, v)| m + v}).to eq(-6)
      end
      it "returns the initial value when called on an empty array" do
        expect([].my_inject(2) { |_m, _e| 1 }).to eq(2)
      end
      it "returns the initial value when called on an empty hash" do
        expect({}.my_inject(2) { |_m, _e| 1 }).to eq(2)
      end
      it "raises an ArgumentError when passed more than one initial value" do
        expect { [1, 2].my_inject(1, 2) { |m, e| m + e} }
               .to raise_error(ArgumentError)
      end
    end
  end
end
