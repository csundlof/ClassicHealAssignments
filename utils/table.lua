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


-- merge source table into target table
function table.merge(target, source)
   for _, n in pairs(source) do
      table.insert(target, n)
   end
 end


 -- flattens table to an array of the table keys.
function table.getKeys(table)
   local keys = {}
   for k, _ in pairs(table) do
      tinsert(keys, k)
   end
   return keys
end


-- Returns true if the table is empty
function table.isEmpty(table)
   return next(table) == nil
end