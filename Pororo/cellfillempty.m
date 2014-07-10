%% Fill empty cells with a given value.
function c = cellfillempty(c, fill)
  ix = cellfun('isempty', c);
  c(ix) = {fill};
end