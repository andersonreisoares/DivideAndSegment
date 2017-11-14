function [line_cut_xcolumns_h, line_cut_yrows_h,line_cut_xcolumns_v,line_cut_yrows_v] = line_cut(image_h, image_v,line_number,vchunk,hchunk,max_displacement)

chunk_H_size = vchunk;
chunk_W_size = hchunk;

%Vector to store linecut coords
horizontal_xcolumns = [];
horizontal_yrows = [];
vertical_xcolumns = [];
vertical_yrows = [];


for p=1:2
    image = image_h;
    
    if p==1
        text = ' horizontal ';
    else
        image = image_v;
        text = ' vertical ';
    end
    
    % Get image information 
    full_H = size(image, 1);
    full_W = size(image, 2);
         
    line_cut_xcolumns_h{1} = (1) * ones(1,full_W);
    line_cut_yrows_h{1} = (1) * ones(1,full_W);
    line_cut_xcolumns_v{1} = (1) * ones(1,full_H);
    line_cut_yrows_v{1} = (1) * ones(1,full_H);
    
    line_cut_xcolumns_h{line_number+1} = (full_W) * ones(1,full_W);
    line_cut_yrows_h{line_number+1} = (full_W) * ones(1,full_W);
    line_cut_xcolumns_v{line_number+1} = (full_W) * ones(1,full_H);
    line_cut_yrows_v{line_number+1} = (full_H) * ones(1,full_H);
    
    q=[];
    % compute chunks
    for line=1:line_number-1
        si = floor(full_H / line_number);
        q = [q;si*line;];
    end
    sp = [];
    smax = [];
    border_position = [];
    
    for i=1:size(q,1)
        sp = [image((q(i,1) - max_displacement):(q(i,1) + max_displacement), 1)];
        [smax, border_position] = max(abs(sp(:,1)));
        first_H_chunk = floor(q(i,1) - max_displacement + border_position - chunk_H_size / 2);
        
        for c = 1:ceil(full_W / chunk_W_size)
            % compute chunk in H direction
          if (c == 1)
            start_H_chunk = first_H_chunk;
          else
            start_H_chunk = floor((start_H_chunk + finishing_row) - chunk_H_size / 2);
          end;
          finish_H_chunk = start_H_chunk + chunk_H_size - 1;
          % check if chunk in H direction is inside the limits (maximum displacement)
          if (start_H_chunk < q(i,1) - max_displacement)
            start_H_chunk = q(i,1) - max_displacement;
            finish_H_chunk = start_H_chunk + chunk_H_size - 1;
          end;
          if (finish_H_chunk > q(i,1) + max_displacement)
            finish_H_chunk = q(i,1) + max_displacement;
            start_H_chunk = finish_H_chunk - chunk_H_size + 1;
          end;

          % compute chunk in W direction
          start_W_chunk = (c - 1) * chunk_W_size + 1;
          finish_W_chunk = c * chunk_W_size;
          if (finish_W_chunk > full_W)
            finish_W_chunk = full_W;
          end;
              % crop the input image
              chunk = image(start_H_chunk:finish_H_chunk, start_W_chunk:finish_W_chunk, :);

              % compute sizes
              H = size(chunk, 1);
              W = size(chunk, 2);

              % compute starting/finishing points
              sp = chunk(:, 1);
              fp = chunk(:, W);
              starting_profile = [];
              finishing_profile = [];

              for t = 1:size(sp, 3)
                starting_profile = [starting_profile, sp(:, :, t)];
                finishing_profile = [finishing_profile, fp(:, :, t)];
              end;

              mean_starting_profile = starting_profile;
              mean_finishing_profile = finishing_profile;

              if (size(starting_profile, 2) > 1)
                mean_starting_profile = mean(starting_profile')';
                mean_finishing_profile = mean(finishing_profile')';
              end;

              peacks_in_starting_profile = slope(mean_starting_profile);
              peacks_in_finishing_profile = slope(mean_finishing_profile);

              % except for first chunk, starting_row is always equal to the previous finishing_row
              if (c == 1)
                [smax, starting_row] = max(abs(sp)); % peacks_in_starting_profile));
              else
                starting_row = original_finishing_row - start_H_chunk;
              end;

              [fmax, finishing_row] = max(abs(fp)); % peacks_in_finishing_profile));
              original_finishing_row = finishing_row + start_H_chunk;

              % find line cut
              %fflush(stdout);
              [yrows,xcolumns] = find_cut(chunk,starting_row,1,finishing_row,W);
              
              disp(['Computing', text, 'chunks']);% ', num2str(c), '/', num2str(ceil(full_W / chunk_W_size))]);
              if p==1
                  horizontal_xcolumns = [horizontal_xcolumns, xcolumns + start_W_chunk - 1];
                  horizontal_yrows = [horizontal_yrows, yrows + start_H_chunk - 1];

              else
                  vertical_xcolumns = [vertical_xcolumns, xcolumns + start_W_chunk - 1];
                  vertical_yrows = [vertical_yrows, yrows + start_H_chunk - 1];
              end

    end
         
        if p==1
         line_cut_xcolumns_h{i+1} = [horizontal_xcolumns];
         line_cut_yrows_h{i+1} = [horizontal_yrows];
         
         horizontal_xcolumns = [];
         horizontal_yrows = [];
        else
            
         line_cut_xcolumns_v{i+1} = [vertical_xcolumns];
         line_cut_yrows_v{i+1} = [vertical_yrows];

         vertical_xcolumns = [];
         vertical_yrows = [];
        end
    end
    
end
