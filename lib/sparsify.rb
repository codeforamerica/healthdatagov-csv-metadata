# Extend into a hash to provide sparse and unsparse methods. 
# 
# {'foo'=>{'bar'=>'bingo'}}.sparse #=> {'foo.bar'=>'bingo'}
# {'foo.bar'=>'bingo'}.unsparse => {'foo'=>{'bar'=>'bingo'}}
# 
# options:
module Sparsify
  def sparse(options={})
    self.map do |k,v|
      prefix = (options.fetch(:prefix,[])+[k])
      next Sparsify::sparse( v, options.merge(:prefix => prefix ) ) if v.is_a? Hash
      { prefix.join(options.fetch( :separator, '.') ) => v}
    end.reduce(:merge) || Hash.new
  end
  def sparse!
    self.replace(sparse)
  end

  def unsparse(options={})
    ret = Hash.new
    sparse.each do |k,v|
      current = ret
      key = k.to_s.split( options.fetch( :separator, '.') )
      current = (current[key.shift] ||= Hash.new) until (key.size<=1)
      current[key.first] = v
    end
    return ret
  end
  def unsparse!(options={})
    self.replace(unsparse)
  end

  def self.sparse(hsh,options={})
    hsh.dup.extend(self).sparse(options)
  end

  def self.unsparse(hsh,options={})
    hsh.dup.extend(self).unsparse(options)
  end

  def self.extended(base)
    raise ArgumentError, "<#{base.inspect}> must be a Hash" unless base.is_a? Hash
  end
end

class Hash
  include Sparsify
end

