function [upper_cut, lower_cut] = divide(input_image, division_rows, division_columns)

  % compute sizes
  H = size(input_image, 1);
  W = size(input_image, 2);

  upper_cut = input_image;
  lower_cut = input_image;

  filtered_division_rows = [];
  filtered_division_columns = [];
  
  % filtering line
  i = 0;
  size_divisions = length(division_columns);
  while (i < size_divisions - 1)
    i = i + 1;
    if (division_columns(i) == division_columns(i + 1))
      filtered_division_rows = [filtered_division_rows, min(division_rows(i), division_rows(i + 1))];
      filtered_division_columns = [filtered_division_columns, division_columns(i)];
      while (division_columns(i) == division_columns(i + 1))
        i = i + 1;
        if (i + 1 > size_divisions)
          break;
        end;
      end;
    else
      filtered_division_rows = [filtered_division_rows, division_rows(i)];
      filtered_division_columns = [filtered_division_columns, division_columns(i)];
    end;
  end;

  if (division_columns(size_divisions) ~= division_columns(size_divisions - 1))
    filtered_division_rows = [filtered_division_rows, division_rows(size_divisions)];
    filtered_division_columns = [filtered_division_columns, division_columns(size_divisions)];
  end;
 
  for i = 1:length(filtered_division_rows)
    upper_cut(filtered_division_rows(i):H, filtered_division_columns(i), :) = 0;
    lower_cut(1:filtered_division_rows(i) - 1, filtered_division_columns(i), :) = 0;
  end;

end
