function dist = distance(a, b)
  a = double(reshape(a, size(a, 3), 1));
  b = double(reshape(b, size(b, 3), 1));

  dist = sqrt ( (a - b)' * (a - b) );
end