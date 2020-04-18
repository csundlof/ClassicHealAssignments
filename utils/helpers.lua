-- Collection of miscellaneous helper functions

-- Prints the text if debug is set to true
function DebugPrint(text)
   if debug then
      print(text)
   end
end


-- Executes the provided function if debug is set to true
function DebugFunction(func)
   if debug then
      func()
   end
end