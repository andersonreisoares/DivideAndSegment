function s = slope(c)
  curve = double(c);
  s(1) = 0.0;
  for i = 2:length(curve)
    s(i) = curve(i) - curve(i - 1);
  end;
end
