module Enumerable
	def my_each
		0.upto(self.length - 1) do |index|
			yield(self[index])
		end
	end

	def my_each_with_index
		0.upto(self.length - 1) do |index|
			yield(self[index], index)
		end
	end

	def my_select
		results = []
		self.my_each do |item|
			if yield(item)
				results << item
			end
		end
		results
	end

	def my_all?
		self.my_select{|item| yield(item)} == self
	end

	def my_any?
		self.my_select{|item| yield(item)}.length > 0
	end

	def my_none?
		!(self.my_any?{|item| yield(item)})
	end

	def my_count(*targets, &block)
		if targets.length == 1
			if block_given?
				puts "warning: given block not used"
			end
			return self.my_select{|item| item == targets[0]}.length
		elsif targets.length == 0 && !block_given?
			return self.length
		elsif targets.length > 1
			raise ArgumentError, "wrong number of arugments (#{targets.length} for 1)"
		else
			return self.my_select(&block).length
		end
	end

	def my_map
		results = []
		self.my_each do |item|
			results << yield(item)
		end
		results
	end

=begin
	#this my_map takes a proc instead of a block
	def my_map(proc)
		results = []
		self.my_each do |item|
			results << proc.call(item)
		end
		results
	end
=end

=begin
	#this my_map takes a proc, and can also take a block
	#the block will only execute if a proc has been supplied
	def my_map(*procs)
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
=end

	#this version of inject does not deal with symbols; the block is required
	def my_inject(*initials)
		if initials.length == 1
			result = initials[0]
		elsif initials.length == 0
			result = self[0]
		else
			raise ArgumentError, "wrong number of arugments (#{initials.length} for 1)"
		end

		self.my_each do |item|
				result = yield(result, item)	
		end

		return result
	end
end

def multiply_els(numbers)
		numbers.my_inject(1){|product, n| product * n}
end
