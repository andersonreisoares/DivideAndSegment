function [polygon_rows, polygon_columns] = get_polygon(y1, x1, y2, x2)
  polygon_rows = [y1, y1, y2, y2, y1];
  polygon_columns = [x1, x2, x2, x1, x1];
end
