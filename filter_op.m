function [image_h, image_v] = filter_op(input_image, filterOption)
    
    [l,c,d] = size(input_image);
       
    input_image = input_image(:,:,d);
    
    %Border detection
    if filterOption==1
        % computing image of borders (magnitude of the gradient)
        [dx, dy] = gradient(input_image);
        image = sqrt(double(dx .* dx + dy .* dy));
        image_h = image;
        image_v = image';
    else   
        %Directional high pass-filter
        filter_hp = [-1 -1 -1; 
                     1 -2 1;
                     1 1 1;];
        image_h = imfilter(input_image,filter_hp);

        input_image = input_image';

        image_v = imfilter(input_image,filter_hp);

        %Mean filter - Solve local problems
        filter_m = [1 1 1; 
                    1 1 1; 
                    1 1 1;];       
        image_h = imfilter(image_h,filter_m);
        image_v = imfilter(image_v,filter_m);

        %filtros ---- fim

end
