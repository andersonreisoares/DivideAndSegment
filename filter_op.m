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
        
                 
        image_h=imfilter(input_image,filter_hp);
        all = squeeze(sum(image_h,3));
        image_h = (all-min(all(:)))*1/(max(all(:))-min(all(:)));
                
        input_image = permute(input_image,[2 1 3]);     
                
        image_v = imfilter(input_image,filter_hp);
        allv = squeeze(sum(edges_v,3));
        image_v = (allv-min(allv(:)))*1/(max(allv(:))-min(allv(:)));

      
    end
    
    %Mean filter - Solve local problems
        filter_m = [1 1 1; 
                    1 1 1; 
                    1 1 1;];       
        image_h = imfilter(image_h,filter_m);
        image_v = imfilter(image_v,filter_m);

        %filtros ---- fim

end
