--- table extension functions

--- Flatten table such that an array of all values is returned
function table.flatten(table)
   res = {}

   if table == nil then
      return res
   end

   for k,v in pairs(table) do
      if type(v) == "table" then
         tinsert(res, table.flatten(v))
      else
         tinsert(res(v))
      end
   end

   return res
end


--- Get index of value in table, and nil if value non-existent
function table.indexOf(table, value)
   for i, v in ipairs(table) do
      if v == value then
         return i
      end
   end
   return nil
end

--contains value in table
function table.myHasValue(table, value)
  for i, v in ipairs(table) do
    if v == value then
      return true
    end
  end

  return false
end
