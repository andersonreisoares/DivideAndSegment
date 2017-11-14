function [image_h, image_v] = filter_op(input_image, filterOption)
    
    %input_image = img;
    [l,c,d] = size(input_image);
         
    edges_h = zeros(l,c,d);
    edges_v = zeros(c,l,d);
   
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
        image_h = imfilter(input_image,filter_hp);
        
        input_image = permute(input_image,[2 1 3]);
        
        image_v = imfilter(input_image,filter_hp);
      
    end
    
    %Mean filter - Solve local problems
        filter_m = [0 0 0; 
                    1 1 1; 
                    0 0 0;];       
        image_h = imfilter(image_h,filter_m);
        image_v = imfilter(image_v,filter_m);

        %filtros ---- fim

end
