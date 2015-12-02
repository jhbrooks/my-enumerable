require "spec_helper"

describe Enumerable do
  let(:test_arr) { [] }
  let(:test_hash) { {} }

  describe "#my_each" do
    context "when not given a block" do
      it "raises a LocalJumpError" do
        expect { [1, 2].my_each }.to raise_error(LocalJumpError)
      end
    end

    context "when called on an object lacking the length method" do
      it "raises a NoMethodError" do
        expect { 1.my_each { |_e| test_arr << 1 } }
               .to raise_error(NoMethodError)
      end
    end

    context "when called on an array" do
      it "passes each element to the given block" do
        [1, 2].my_each { |e| test_arr << e }
        expect(test_arr).to eq([1, 2])
      end

      it "does nothing if the array is empty" do
        [].my_each { |_e| test_arr << 1 }
        expect(test_arr).to eq([])
      end
    end

    context "when called on a hash" do
      it "passes each key value pair to the given block" do
        {one: 1, two: 2}.my_each { |k, v| test_hash[k] = v }
        expect(test_hash).to eq({one: 1, two: 2})
      end

      it "does nothing if the hash is empty" do
        {}.my_each { |k, v| test_hash[:one] = 1}
        expect(test_hash).to eq({})
      end
    end
  end

  describe "#my_each_with_index" do
    context "when not given a block" do
      it "raises a LocalJumpError" do
        expect { [1, 2].my_each_with_index }.to raise_error(LocalJumpError)
      end
    end

    context "when called on an object lacking the length method" do
      it "raises a NoMethodError" do
        expect { 1.my_each_with_index { |_e| test_arr << 1 } }
               .to raise_error(NoMethodError)
      end
    end

    context "when called on an array" do
      it "passes each element and index to the given block" do
        [1, 2].my_each_with_index { |e, i| test_arr << (e + i) }
        expect(test_arr).to eq([1, 3])
      end

      it "does nothing if the array is empty" do
        [].my_each_with_index { |_e, _i| test_arr << 1 }
        expect(test_arr).to eq([])
      end
    end

    context "when called on a hash" do
      it "passes each key value pair and index to the given block" do
        {one: 1, two: 2}.my_each_with_index do |(k, v), i| 
          test_hash[k] = v + i
        end
        expect(test_hash).to eq({one: 1, two: 3})
      end

      it "does nothing if the hash is empty" do
        {}.my_each_with_index { |(_k, _v), _i| test_hash[:one] = 1}
        expect(test_hash).to eq({})
      end
    end
  end

  describe "#my_select" do
    context "when not given a block" do
      it "raises a LocalJumpError" do
        expect { [1, 2].my_select }.to raise_error(LocalJumpError)
      end
    end

    context "when called on an object lacking the length method" do
      it "raises a NoMethodError" do
        expect { 1.my_select { |_e| true } }.to raise_error(NoMethodError)
      end
    end

    context "when called on an array" do
      it "passes each element to the given block" do
        test_arr = [1, 2].my_select { |_e| true }
        expect(test_arr).to eq([1, 2])
      end

      it "selects elements based on the condition in the block" do
        test_arr = [1, 2, "a"].my_select { |e| e == 2 }
        expect(test_arr).to eq([2])
      end

      it "returns an empty array if the array is empty" do
        test_arr = [].my_select { |_e| true }
        expect(test_arr).to eq([])
      end
    end

    context "when called on a hash" do
      it "passes each key value pair to the given block" do
        test_hash = {one: 1, two: 2}.my_select { |_k, _v| true }
        expect(test_hash).to eq({one: 1, two: 2})
      end

      it "selects key value pairs based on the condition in the block" do
        test_hash = {one: 1, two: 2, a: "a"}
                  .my_select { |k, v| v == 2 || k == :a }
        expect(test_hash).to eq({two: 2, a: "a"})
      end

      it "returns an empty hash if the hash is empty" do
        test_hash = {}.my_select { |_k, _v| true}
        expect(test_hash).to eq({})
      end
    end
  end

  describe "#my_count" do
    context "when called on an object lacking the length method" do
      it "raises a NoMethodError" do
        expect { 1.my_count }.to raise_error(NoMethodError)
      end
    end

    context "when given more than one target" do
      it "raises an ArgumentError" do
        expect { [1, 2].my_count(1, 3) }.to raise_error(ArgumentError)
      end
    end

    context "when called on an array" do
      context "with only a target" do
        it "counts all elements that match the target" do
          expect([1, 2, 1].my_count(1)).to eq(2)
        end

        it "returns 0 if the target is not found" do
          expect([1, 2].my_count(3)).to eq(0)
        end

        it "returns 0 if the array is empty" do
          expect([].my_count(1)).to eq(0)
        end
      end

      context "with only a block" do
        it "counts all elements that match the condition" do
          expect([1, 2, 1].my_count { |e| e == 1 }).to eq(2)
        end

        it "returns 0 if the condition is never satisfied" do
          expect([1, 2].my_count { |e| e == 3 }).to eq(0)
        end

        it "returns 0 if the array is empty" do
          expect([].my_count { |e| e == 1 }).to eq(0)
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
          expect(STDOUT).to receive(:puts)
                                   .with("warning: given block not used")
          [1, 2].my_count(3) { |e| e == 1 }
        end
      end

      context "with neither a target nor a block" do
        it "counts all elements" do
          expect([1, 2].my_count).to eq(2)
        end

        it "returns 0 if the array is empty" do
          expect([].my_count).to eq(0)
        end
      end
    end

    context "when called on a hash" do
      context "with only a target" do
        it "counts all key value pairs that match the target pair" do
          expect({one: 1, two: 2}.my_count([:two, 2])).to eq(1)
        end

        it "returns 0 if the target pair is not found" do
          expect({one: 1, two: 2}.my_count(2)).to eq(0)
        end

        it "returns 0 if the hash is empty" do
          expect({}.my_count(2)).to eq(0)
        end
      end

      context "with only a block" do
        it "counts all key value pairs that match the condition" do
          expect({one: 1, two: 2, four: 2}.my_count { |k, v| v == 2}).to eq(2)
        end

        it "returns 0 if the condition is never satisfied" do
          expect({one: 1, two: 2}.my_count{ |k, v| v == 3 }).to eq(0)
        end

        it "returns 0 if the hash is empty" do
          expect({}.my_count { |k, v| v == 2}).to eq(0)
        end        
      end

      context "with a target and a block" do
        before do
          allow(STDOUT).to receive(:puts)
        end
        it "uses the target and ignores the block" do
          expect({one: 1, two: 2}.my_count(3) { |k, v| v == 1 }).to eq(0)
        end
        it "issues a warning about the ignored block" do
          expect(STDOUT).to receive(:puts)
                                   .with("warning: given block not used")
          {one: 1, two: 2}.my_count(3) { |k, v| v == 1 }
        end
      end

      context "with neither a target nor a block" do
        it "counts all key value pairs" do
          expect({one: 1, two: 2}.my_count).to eq(2)
        end

        it "returns 0 if the hash is empty" do
          expect({}.my_count).to eq(0)
        end
      end
    end
  end

  describe "#my_map_pb" do
    let(:proc_a) { Proc.new { |e| e + 1 } }
    let(:proc_h) { Proc.new { |_k, v| v + 1 } }

    context "when called on an object lacking the length method" do
      it "raises a NoMethodError" do
        expect { 1.my_map_pb(:proc_a) }.to raise_error(NoMethodError)
      end
    end

    context "when given more than one proc" do
      it "raises an ArgumentError" do
          expect { [1, 2].my_map_pb(proc_a, proc_h) }
                 .to raise_error(ArgumentError)
      end
    end

    context "when given neither a proc nor a block" do
      it "raises an ArgumentError" do
        expect { [1, 2].my_map_pb }
               .to raise_error(ArgumentError)
      end
    end

    context "when called on an array" do
      context "with only a proc" do
        it "passes each element to the proc and returns an array" do
          test_arr = [1, 2].my_map_pb(proc_a)
          expect(test_arr).to eq([2, 3])
        end

        it "returns an empty array if the array is empty" do
          expect([].my_map_pb(proc_a)).to eq([])
        end
      end

      context "with only a block" do
        it "issues a warning about the ignored block" do
          expect(STDOUT).to receive(:puts)
                                   .with("warning: given block not used "\
                                         "(must have proc as argument)")
          [1, 2].my_map_pb { |e| e + 2 }
        end

        before do
          allow(STDOUT).to receive(:puts)
        end

        it "returns the object it was called on" do
          expect([1, 2].my_map_pb { |e| e + 2 }).to eq([1, 2])
        end
      end

      context "with a proc and a block" do
        it "passes each element to the proc/block and returns an array" do
          test_arr = [1, 2].my_map_pb(proc_a) { |e| e + 2 }
          expect(test_arr).to eq([4, 5])
        end

        it "passes to the proc before the block" do
          test_arr = [1, 2].my_map_pb(proc_a) { |e| e * 2 }
          expect(test_arr).to eq([4, 6])
        end

        it "returns an empty array if the array is empty" do
          expect([].my_map_pb(proc_a) { |e| e + 2 }).to eq([])
        end
      end
    end

    context "when called on a hash" do
      context "with only a proc" do
        it "passes each key value pair to the proc and returns an array" do
          test_hash = {one: 1, two: 2}.my_map_pb(proc_h)
          expect(test_hash).to eq([2, 3])
        end

        it "returns an empty array if the hash is empty" do
          expect({}.my_map_pb(proc_h)).to eq([])
        end
      end

      context "with only a block" do
        it "issues a warning about the ignored block" do
          expect(STDOUT).to receive(:puts)
                                   .with("warning: given block not used "\
                                         "(must have proc as argument)")
          {one: 1, two: 2}.my_map_pb { |e| e + 2 }
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
        it "passes each key value pair to the proc/block "\
           "and returns an array" do
          test_hash = {one: 1, two: 2}.my_map_pb(proc_h) { |e| e + 2 }
          expect(test_hash).to eq([4, 5])
        end

        it "passes to the proc before the block" do
          test_arr = {one: 1, two: 2}.my_map_pb(proc_h) { |e| e * 2 }
          expect(test_arr).to eq([4, 6])
        end

        it "returns an empty array if the hash is empty" do
          expect({}.my_map_pb(proc_h) { |e| e + 2 }).to eq([])
        end
      end
    end
  end

  describe "#my_inject" do
    context "when not given a block" do
      it "raises a LocalJumpError" do
        expect { [1, 2].my_inject }.to raise_error(LocalJumpError)
      end
    end
    
    context "when called on an object lacking the length method" do
      it "raises a NoMethodError" do
        expect { 1.my_inject { |_m, _e| 1 } }.to raise_error(NoMethodError)
      end
    end

    context "when given more than one initial value" do
      it "raises an ArgumentError" do
        expect { [1, 2].my_inject(1, 2) { |m, e| m + e} }
               .to raise_error(ArgumentError)
      end
    end

    context "when called on an array" do
      context "with only a block" do
        it "accumulates from the first element" do
          expect([1, 2].my_inject { |m, e| m + e}).to eq(3)
        end

        it "returns nil if the array is empty" do
          expect([].my_inject { |_m, _e| 1 }).to be(nil)
        end
      end

      context "with an initial value and a block" do
        it "accumulates from the initial value" do
          expect([1, 2].my_inject(-9) { |m, e| m + e}).to eq(-6)
        end

        it "returns the initial value if the array is empty" do
          expect([].my_inject(2) { |_m, _e| 1 }).to eq(2)
        end
      end
    end

    context "when called on a hash" do
      context "with only a block" do
        it "accumulates from the first key value pair" do
          expect({one: 1, two: 2}.my_inject do |m, (k, v)|
            m_v = m.pop
            m << (m_v + v)
          end).to eq([:one, 3])
        end

        it "returns nil if the hash is empty" do
          expect({}.my_inject { |_m, _e| 1 }).to be(nil)
        end
      end

      context "with an initial value and a block" do
        it "accumulates from the initial value" do
          expect({one: 1, two: 2}.my_inject(-9) { |m, (k, v)| m + v}).to eq(-6)
        end

        it "returns the initial value if the hash is empty" do
          expect({}.my_inject(2) { |_m, _e| 1 }).to eq(2)
        end
      end
    end
  end
end
