function [image_h, image_v] = filter_op(input_image, filterOption)
    
    %input_image = img;
    [l,c,d] = size(input_image);
    %input_image = input_image(:,:,d);
           
    %Border detection
    if filterOption==1
        % computing image of borders (magnitude of the gradient)
        [dx, dy] = gradient(double(input_image));
        image = sqrt(double(dx .* dx + dy .* dy));
        image_h = image;
        image_v = image';
    else
        %directional high pass-filter
        filter_hp = [-1 -1 -1; 
                     1 -2 1;
                     1 1 1;];
        
                 
        for w=1:d
            Gmag = imfilter(input_image(:,:,w),filter_hp);
            edges(:,:,w) = (Gmag-min(Gmag(:)))*1/(max(Gmag(:))-min(Gmag(:)));
            clearvars Gmag
        end
        all = squeeze(sum(edges,3));
        image_h = (all-min(all(:)))*1/(max(all(:))-min(all(:)));
        
        %image_h = imfilter(input_image,filter_hp);
        
        input_image = permute(input_image,[2 1 3]);     
                 
        for w=1:d
            Gmag = imfilter(input_image(:,:,w),filter_hp);
            edges_v(:,:,w) = (Gmag-min(Gmag(:)))*1/(max(Gmag(:))-min(Gmag(:)));
            clearvars Gmag
        end
        allv = squeeze(sum(edges_v,3));
        image_v = (allv-min(allv(:)))*1/(max(allv(:))-min(allv(:)));
        
        %image_v = imfilter(input_image,filter_hp);
      
    end
    
    %Mean filter - Solve local problems
        filter_m = [1 1 1; 
                    1 1 1; 
                    1 1 1;];       
        image_h = imfilter(image_h,filter_m);
        image_v = imfilter(image_v,filter_m);

        %filtros ---- fim

end
