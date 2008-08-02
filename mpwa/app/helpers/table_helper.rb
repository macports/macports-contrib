
require 'enumerator'

module TableHelper
    
    def columnize(a, ccnt = 2, rowMajor = true)

        # Turn the array into a series of rows and columns
        len = a.length
        return a if len == 0
        
        rcnt = (len + ccnt - 1) / ccnt
        
        if rowMajor
            cols = []
            a.each_slice(rcnt) do |s|
            	s.fill(nil, s.length, rcnt - s.length) if (s.length < rcnt)
            	cols.push(s)
            end
            rows = cols.transpose
        else
            rows = []
            a.each_slice(rcnt) do |s|
            	s.fill(nil, s.length, rcnt - s.length) if (s.length < rcnt)
            	rows.push(s)
            end
        end
        
        return rows
    end
end

