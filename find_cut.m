function [division_rows, division_columns] = find_cut(input_image, starting_row, starting_column, finishing_row, finishing_column)

  weights_from_gradient = true;
  weights_forward = false;
  weights_8 = false;
  
  % compute sizes
  H = size(input_image, 1);
  W = size(input_image, 2);
  B = size(input_image, 3);

  % create matrix of weights
  wmatrix = zeros(H * W, H * W);
  zeros_of_wmatrix = zeros(size(wmatrix));

  starting_pixel = mean(input_image(starting_row, starting_column, :));
  finishing_pixel = mean(input_image(finishing_row, finishing_column, :));

  % compute weights based on the gradient
  if (weights_from_gradient)
    for r = 1:H
      for c = 1:(W - 1)
        if (r == 1)
          pixels = [0,
                    0,
                    squeeze(input_image(r, c + 1, :)), 
                    squeeze(input_image(r + 1, c + 1, :)),
                    squeeze(input_image(r + 1, c, :))];
        elseif (r == H)
          pixels = [squeeze(input_image(r - 1, c, :)),
                    squeeze(input_image(r - 1, c + 1, :)),
                    squeeze(input_image(r, c + 1, :)), 
                    0
                    0];
        else
          pixels = [squeeze(input_image(r - 1, c, :)),
                    squeeze(input_image(r - 1, c + 1, :)),
                    squeeze(input_image(r, c + 1, :)), 
                    squeeze(input_image(r + 1, c + 1, :)),
                    squeeze(input_image(r + 1, c, :))];
        end;
        
        [a, max_position] = max(pixels);
        [a, min_position] = min(pixels);
        weights = [3 3 3 3 3];
        weights(max_position) = 1;
        weights(min_position) = 5;

        if (r ~= 1)
          % top pixel
          wmatrix(position(r, c, W), position(r - 1, c, W)) = weights(1);
          % top-right pixel
          wmatrix(position(r, c, W), position(r - 1, c + 1, W)) = weights(2);
        end;
        % right pixel
        wmatrix(position(r, c, W), position(r, c + 1, W)) = weights(3);
        if (r ~= H)
          % bottom-right pixel
          wmatrix(position(r, c, W), position(r + 1, c + 1, W)) = weights(4);
          % bottom pixel
          wmatrix(position(r, c, W), position(r + 1, c, W)) = weights(5);
        end;
      end;
    end;
  end;
  
  % compute weights in all image
  if (weights_forward)
    for r = 1:H
      for c = 1:(W - 1)
        % compute the average pixel value
        average_pixel = ((W - c) * starting_pixel + c * finishing_pixel) / W;

        if (r ~= 1)
          % top-right pixel
          trdistance = distance(input_image(r, c, :), input_image(r - 1, c + 1, :)) - average_pixel;
          wmatrix(position(r, c, W), position(r - 1, c + 1, W)) = trdistance;
          % wmatrix(position(r - 1, c + 1, W), position(r, c, W)) = trdistance;
          zeros_of_wmatrix(position(r, c, W), position(r - 1, c + 1, W)) = 1;
          % zeros_of_wmatrix(position(r - 1, c + 1, W), position(r, c, W)) = 1;
        end;
        % right pixel
        rdistance = distance(input_image(r, c, :), input_image(r, c + 1, :)) - average_pixel;
        wmatrix(position(r, c, W), position(r, c + 1, W)) = rdistance;
        % wmatrix(position(r, c + 1, W), position(r, c, W)) = rdistance;
        zeros_of_wmatrix(position(r, c, W), position(r, c + 1, W)) = 1;
        % zeros_of_wmatrix(position(r, c + 1, W), position(r, c, W)) = 1;
        if (r ~= H)
          % bottom-right pixel
          brdistance = distance(input_image(r, c, :), input_image(r + 1, c + 1, :)) - average_pixel;
          wmatrix(position(r, c, W), position(r + 1, c + 1, W)) = brdistance;
          % wmatrix(position(r + 1, c + 1, W), position(r, c, W)) = brdistance;
          zeros_of_wmatrix(position(r, c, W), position(r + 1, c + 1, W)) = 1;
          % zeros_of_wmatrix(position(r + 1, c + 1, W), position(r, c, W)) = 1;
        end;
      end;
    end;
    
    minweight = min(min(wmatrix)) - 1
    wmatrix = wmatrix - minweight
    wmatrix = wmatrix .* zeros_of_wmatrix

  end;  

  if (weights_8)
    for r = 1:(H - 1)
      for c = 1:(W - 1)
        % compute the average pixel value
        average_pixel = ((W - c) * starting_pixel + c * finishing_pixel) / W;

        % right pixel
        rdistance = distance(input_image(r, c, :), input_image(r, c + 1, :)) - average_pixel;
        wmatrix(position(r, c, W), position(r, c + 1, W)) = rdistance;
        wmatrix(position(r, c + 1, W), position(r, c, W)) = rdistance;
        % bottom pixel
        bdistance = distance(input_image(r, c, :), input_image(r + 1, c, :)) - average_pixel;
        wmatrix(position(r, c, W), position(r + 1, c, W)) = bdistance;
        wmatrix(position(r + 1, c, W), position(r, c, W)) = bdistance;
        % bottom-right pixel
        brdistance = distance(input_image(r, c, :), input_image(r + 1, c + 1, :)) - average_pixel;
        wmatrix(position(r, c, W), position(r + 1, c + 1, W)) = brdistance;
        wmatrix(position(r + 1, c + 1, W), position(r, c, W)) = brdistance;

      end;
    end;

    % compute weights in borders
    for c = 1:(W - 1)
      % compute the average pixel value
      average_pixel = ((W - c) * starting_pixel + c * finishing_pixel) / W;

      % last line
      rdistance = distance(input_image(H, c, :), input_image(H, c + 1, :)) - average_pixel;
      wmatrix(position(H, c, W), position(H, c + 1, W)) = rdistance;
      wmatrix(position(H, c + 1, W), position(H, c, W)) = rdistance;
    end;
    for r = 1:(H - 1)
      % compute the average pixel value
      average_pixel = (starting_pixel + finishing_pixel) / 2;

      % last column
      bdistance = distance(input_image(r, W, :), input_image(r + 1, W, :)) - average_pixel;
      wmatrix(position(r, W, W), position(r + 1, W, W)) = bdistance;
      wmatrix(position(r + 1, W, W), position(r, W, W)) = bdistance;
    end;
  end;
  
  for r = 1:H
    for c = 1:W
      myrows(position(r, c, W)) = r;
      mycolumns(position(r, c, W)) = c;
    end;
  end;
  
  % compute shortest path
  starting_point = position(starting_row, starting_column, W);
  finishing_point = position(finishing_row, finishing_column, W);
  [bestweight, linecut] = dijkstra(wmatrix, starting_point, finishing_point);
 
  % create line cut for displaying
  division_rows = [];
  division_columns = [];
  for i = 1:length(linecut)
    division_rows = [division_rows, myrows(linecut(i))];
    division_columns = [division_columns, mycolumns(linecut(i))];
  end

end
