function [image_h, image_v] = filter_op(input_image, filterOption,weight)
    
    %input_image = img;
%     input_image = input_image(:,:,5);
    [l,c,d] = size(input_image);
%     input_image = uint16(input_image);
    %Border detection
    if filterOption == 1
        % computing image of borders (magnitude of the gradient)
        [dx, dy] = gradient(double(input_image));
        image = sqrt(double(dx .* dx + dy .* dy));
        image_h = sum(image,3);
        
        image_v = permute(sum(image,3),[2 1 3]);
        
    elseif filterOption == 2
        
        for w=1:d
            image(:,:,w)=edge(input_image(:,:,w),'Canny')*weight(w);
        end
        
        image_h = sum(image,3);
        image_v = permute(sum(image,3),[2 1 3]);
        
    else
        %directional high pass-filter
        filter_hp = [-1 -1 -1; 
                     1 -2 1;
                     1 1 1;];

        for w=1:d
           temp = imfilter(input_image(:,:,w),filter_hp)*weight(w);
           h_1(:,:,w) = (temp-min(temp(:)))*1/(max(temp(:))-min(temp(:)));
        end
        
        image_h = squeeze(sum(h_1,3));
        
        %Flip
        
        input_image = permute(input_image,[2 1 3]);     
        
        for w=1:d
           temp = imfilter(input_image(:,:,w),filter_hp)*weight(w);
           h_2(:,:,w) = (temp-min(temp(:)))*1/(max(temp(:))-min(temp(:)));
        end
        
       image_v = squeeze(sum(h_2,3));
      
    end
    
    %Mean filter - Solve local problems
        filter_m = [1 1 1; 
                    1 1 1; 
                    1 1 1;];       
        image_h = imfilter(image_h,filter_m);
        image_v = imfilter(image_v,filter_m);

        %filtros ---- fim

end
