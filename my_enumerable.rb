module Enumerable
	def my_each(&block)
		if self.instance_of?(Hash)
			pairs = []
			self.keys.my_each do |key| 
				pairs << [key, self[key]]
			end
			pairs.my_each(&block)
		else
			0.upto(self.length - 1) do |index|
				yield(self[index])
			end
		end
		self
	end

	def my_each_with_index(&block)
		if self.instance_of?(Hash)
			pairs = []
			self.keys.my_each do |key| 
				pairs << [key, self[key]]
			end
			pairs.my_each_with_index(&block)
		else
			0.upto(self.length - 1) do |index|
				yield(self[index], index)
			end
		end
		self
	end

	def my_select
		results = []
		self.my_each do |item|
			if self.instance_of?(Hash)
				if yield(item[0], item[1])
					results << item
				end
			else
				if yield(item)
					results << item
				end
			end
		end

		if self.instance_of?(Hash)
			results_hash = {}
			results.my_each do |pair|
				results_hash[pair[0]] = pair[1]
			end
			results = results_hash
		end

		results
	end

	def my_all?(&block)
		self.my_select(&block) == self
	end

	def my_any?(&block)
		self.my_select(&block).length > 0
	end

	def my_none?(&block)
		!(self.my_any?(&block))
	end

	def my_count(*targets, &block)
		count = 0
		if targets.length == 1
			if block_given?
				puts "warning: given block not used"
			end
			self.my_each do |item|
				if item == targets[0]
					count += 1
				end
			end
			return count
		elsif targets.length == 0 && !block_given?
			return self.length
		elsif targets.length > 1
			raise ArgumentError, "wrong number of arugments (#{targets.length} for 1)"
		else # no targets, and block given
			self.my_each do |item|
				if yield(item)
					count += 1
				end
			end
			return count
		end
	end

	def my_map
		results = []
		self.my_each do |item|
			results << yield(item)
		end
		results
	end

	#this my_map takes a proc instead of a block
	def my_map_p(proc)
		results = []
		self.my_each do |item|
			results << proc.call(item)
		end
		results
	end


	#this my_map takes a proc, and can also take a block
	#the block will only execute if a proc has been supplied
	def my_map_pb(*procs)
		results = []
		block_results = []
		if procs.length == 1
			self.my_each do |item|
				results << procs[0].call(item)
			end
			if block_given?
				results.my_each do |item|
					block_results << yield(item)
				end
				results = block_results
			end
		elsif procs.length == 0 && block_given?
			puts "warning: given block not used (must have proc as argument)"
			return self
		else
			raise ArgumentError, "wrong number of arugments (#{procs.length} for 1)"
		end
		results
	end

	#this version of inject does not deal with symbols; the block is required
	def my_inject(*initials)
		if initials.length == 1
			result = initials[0]
		elsif initials.length == 0
			if self.instance_of?(Hash)
				result = [self.keys[0], self[self.keys[0]]]
				result = nil if self == {}
			else
				result = self[0]
			end
		else
			raise ArgumentError, "wrong number of arugments (#{initials.length} for 1)"
		end

		is_first_item = true
		self.my_each do |item|
			unless initials.length == 0 && is_first_item
				result = yield(result, item)
			end
			is_first_item = false
		end

		return result
	end
end

def multiply_els(numbers)
		numbers.my_inject(1){|product, n| product * n}
end
