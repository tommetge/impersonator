# http://www.rubyquiz.com/quiz74.html
class MarkovChain
   attr_reader :order, :beginnings, :freq
   def initialize(text, order = 2, max = 22)
     @order = order
     @max = max
     @beginnings = []
     @freq = {}
     add_text(text)
   end

   def add_text(text)
     # make sure each paragraph ends with some sentence terminator
     text.gsub!(/\n\s*\n/m, ".")
     text << "."
     seps = /([.!?])/
     sentence = ""
     text.split(seps).each { |p|
       if seps =~ p
         add_sentence(sentence, p)
         sentence = ""
       else
         sentence = p
       end
     }
   end

   def generate_sentence(seed = nil)
     res = nil
     if seed
       possibles = @beginnings.map {|b| b if b.include?(seed.split.first)}
       res = possibles[rand(possibles.size)]
     end
     if !res
       res = @beginnings[rand(@beginnings.size)]
     end

     loop {
       unless nw = next_word_for(res[-order, order])
         return res[0..-2].join(" ") + res.last
       end
       res << nw
       return res[0..-2].join(" ") if should_stop(res, nw)
     }
   end

   private
   
   def should_stop(sentence, word)
     return true if sentence.length >= @max
     @beginnings.each do |v|
       return true if v.include?(word) && rand(20) == 0
     end
     false
   end

   def add_sentence(str, terminator)
     words = str.scan(/[\w']+/)
     return unless words.size > order # ignore short sentences
     words << terminator
     buf = []
     words.each { |w|
       buf << w
       if buf.size == order + 1
         (@freq[buf[0..-2]] ||= []) << buf[-1]
         buf.shift
       end
     }
     @beginnings << words[0, order]
   end

   def next_word_for(words)
     arr = @freq[words]
     return nil unless arr
     arr && arr[rand(arr.size)]
   end

end