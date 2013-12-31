module FixnumExt
  refine Fixnum do
    def +(s)
      "#{self}#{s}"
    end
  end
end
module Example
  using FixnumExt
  puts "1 + 1 = #{1 + 1}"
end
puts "1 + 1 = #{1 + 1}"
