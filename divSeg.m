function divSeg(img,line_number,filterOption,vchunk,hchunk,max_displacement,epsg)

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

if nargin < 6 
  disp('error: you have to provide at least 6 parameters')
  return;
end
if nargin == 6
  epsg = 32723;
  disp('warning: epsg defined as 32723')
end

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

[line_cut_xcolumns_h, line_cut_yrows_h,line_cut_xcolumns_v,line_cut_yrows_v] = line_cut(image_h, image_v,line_number,vchunk,hchunk,max_displacement);

%Show results
figure(2);
clf;
imshow(img(:,:,1:3));
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
    
    lim_hy = cell2mat(line_cut_yrows_h(h));
    if h==1
        [temp, temp2] = divide(img, linha_hy, linha_hx);
    else
        [temp, temp2] = divide(temph, linha_hy, linha_hx);
    end
    for v=1:line_number
        disp(['Creating tile: ',int2str(i)]);
        %Get line cut
        linha_vx = cell2mat(line_cut_xcolumns_v(v+1));
        linha_vy = cell2mat(line_cut_yrows_v(v+1));
        lim_vy = cell2mat(line_cut_yrows_v(v));
        
        
        temp  = permute(temp, [2 1 3]);
        [cut1, temp3] = divide(temp, linha_vy, linha_vx);                    
        cut1 = permute(cut1,[2 1 3]);
        temp3 = permute(temp3,[2 1 3]);
        
        %Subset image
        firstrow = min(lim_hy);
        lastrow = max(linha_hy);
        firstcol = min(lim_vy);
        lastcol = max(linha_vy);
        subImage = cut1(firstrow:lastrow, firstcol:lastcol, :);
        xi = [firstcol - .5, lastcol + .5];
        yi = [firstrow - .5, lastrow + .5];
        [xlimits, ylimits] = intrinsicToWorld(R, xi, yi);
        subR = R;
        subR.RasterSize = size(subImage);
        subR.XLimWorld = sort(xlimits);
        subR.YLimWorld = sort(ylimits);      

        %Write image
        if tag==1
            geotiffwrite([name{1}, '_cut',int2str(i),'.tif'],subImage,subR,'CoordRefSysCode',epsg); i=i+1;
        else
            imwrite(cut1, [name{1}, '_cut',int2str(i),'.tif'],'WriteMode', 'append'); i=i+1;
        end
        temp = temp3;
    end
    temph=temp2;

end

toc
 