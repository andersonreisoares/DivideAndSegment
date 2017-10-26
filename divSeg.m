function divSeg(img,line_number,filterOption,vchunk,hchunk,max_displacement)

% ---INPUT---
% img              - input image
% filterOption     - 1 for standard magnitude approach, 2 for directional
% approach (recommended)
% line_number      - Nummber of lines to split the image (4 - divide in 16 tiles)
% vchunk           - Vertical chunk size
% hchunk           - horizontal chuck size
% max_displacement - maximum displacement to the crop line
% epsg             - EPSG of image

% Anderson Soares, Thales Körting and Emiliano Castejon - 23/10/17
% 
% The divide and segment method appears in
% Divide And Segment - An Alternative For Parallel Segmentation. TS Korting,
% EF Castejon, LMG Fonseca - GeoInfo, 97-104
% Improvements of the divide and segment method for parallel image segmentation
% AR Soares, TS Körting, LMG Fonseca - Revista Brasileira de Cartografia 68 (6)

% load and crop image
tic
disp('Loading input image');
 file = 'rapid.tif';
% filterOption =2
% vchunk = 20
% hchunk = 20
% max_displacement = 50
name = strsplit(img,'.');


%Check if is a valid geotiff
info = imfinfo(img);
tag = isfield(info,'GeoKeyDirectoryTag');
geoinfo = info.GeoKeyDirectoryTag;

if tag == 1
    [img, R] = geotiffread(img);
    depth = info.BitsPerSample(1);
else
    [img,~] = imread(img);
end

[image_h, image_v] = filter_op(img, filterOption);
chunk_H_size = vchunk;
chunk_W_size = hchunk;

%Vector to store linecut coords
horizontal_xcolumns = [];
horizontal_yrows = [];
vertical_xcolumns = [];
vertical_yrows = [];

text = ' horizontal ';

for p=1:2
    image = image_h;
    if p==2
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
    line_cut_yrows_h{line_number+1} = (full_H) * ones(1,full_W);
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

%Show results
figure(2);
clf;
imshow(imadjust(img(:,:,1:3)));
hold on;
for i=1:line_number
  plot(line_cut_xcolumns_h{i}, line_cut_yrows_h{i},'linewidth', 2, 'Color', 'y');
  plot(line_cut_yrows_v{i+1}, line_cut_xcolumns_v{i+1},'linewidth', 2, 'Color', 'y');
end

%Cropping
i = 1;

for h=1:line_number
    linha_hx = cell2mat(line_cut_xcolumns_h(h+1));
    linha_hy = cell2mat(line_cut_yrows_h(h+1));

    if h==1
        [temp, temp2] = divide(img, linha_hy, linha_hx);
    else
        [temp, temp2] = divide(temph, linha_hy, linha_hx);
    end
    for v=1:line_number

        linha_vx = cell2mat(line_cut_xcolumns_v(v+1));
        linha_vy = cell2mat(line_cut_yrows_v(v+1));

        temp  = permute(temp, [2 1 3]);
        [cut1, temp3] = divide(temp, linha_vy, linha_vx);                    
        cut1 = permute(cut1,[2 1 3]);
        temp3 = permute(temp3,[2 1 3]);
        if tag==1
            geotiffwrite([name{1}, '_cut',int2str(i),'.tif'],cut1,R,'CoordRefSysCode',geoinfo(20)); i=i+1;
        else
            imwrite(cut1, [name{1}, '_cut',int2str(i),'.tif'],'WriteMode', 'append'); i=i+1;
        end
        temp = temp3;
    end
    temph=temp2;

end

toc
 