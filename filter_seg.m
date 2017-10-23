function r = filter_seg(curve, window_size)
  r = [];
  for i = 1:window_size
    r = [r, curve(i)];
  end;
  
  for i = window_size+1:length(curve)-window_size-1
    r = [r, mean(curve(i-window_size:i+window_size))];
  end;

  for i = length(curve)-window_size:length(curve)
    r = [r, curve(i)];
  end;
  
  r = floor(r);
end
