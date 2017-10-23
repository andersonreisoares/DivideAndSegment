tic;

example = 1;

if (example == 1)
  input = imread('C:\Users\Anderson\Desktop\divide_and_segment\divide_and_segment\cbers\input.tif');
  result_name = 'cbers-hrc';
elseif (example == 2)
        original_image = imread('C:\Users\Anderson\Desktop\divide_and_segment\divide_and_segment\sp\input.tif');
        input = rgb2hsv(original_image);
        result_name = 'sp'; 
elseif (example == 3)
            original_image = imread('C:\Users\Anderson\Desktop\divide_and_segment\divide_and_segment\basic\input.tif');
            input = max(original_image(:,:,1:3));
            result_name = 'basic';
end

%Realce 1
im = imadjust(input);

%filtros
filter_hp = [-1 -1 -1; 
            1 -2 1;
            1 1 1;];
        
im_hp = imfilter(im,filter_hp);

%Resolver mínimos locais
filter_m = [1 1 1; 
            1 1 1; 
            1 1 1;];
        
im = imfilter(im_hp,filter_m); 
%filtros ---- fim

%Pega dados da imagem
[h w] = size(im);
z = round(w/2);
l_m = round(h/2);

%define buffer de busca
buffer = 150;    

%Escolhe o melhor pixel
k = im(l_m-buffer:l_m+buffer,1:100);
%pos = find(k == max(k));
%tmp = abs((pos-buffer));
%[idx idx] = min(tmp); %index of closest value
%closest = pos(idx); %closest value
%l = (l_m-buffer)+closest;

%Armazena coordenadas
line_cut = [l,1;];
line_cut_x = [l];
buffer_up = [l_m-buffer,1;];
buffer_low = [l_m+buffer,1;];
middle = [l_m,1;];

%Loop
%for c=1:w-1
%
    %teste  
%    pix_1 = im(l-1,c);
%    pix_2 = im(l+1,c);
%    pix_3 = im(l-1,c+1);
%    pix_4 = im(l,c+1);
%    pix_5 = im(l+1,c+1);
%    
%    dif = [pix_1;pix_2;pix_3;pix_4;pix_5];
%    
%		if (pix_1 >= pix_2 && pix_1 >= pix_3 && pix_1 >= pix_4 && pix_1 >= pix_5)
%            l_n = l-1;
%            c = c;
%        elseif (pix_2 >= pix_3 && pix_2 >= pix_4 && pix_2 >= pix_5)
%                 l_n = l+1;
%                 c = c;                 
%        elseif (pix_3 >= pix_4 && pix_3 >= pix_5)
%                     l_n = l-1;
%                     c = c+1;                 
%        elseif (pix_4 >= pix_5)
%                         l_n = l;
%                         c = c+1;                 
%        else
%                         l_n = l+1;
%                         c = c+1;
%                     end
                 
                
%        if (l_n>=(h/2)-buffer && l_n<=(h/2)+buffer)
%		    l = l_n;           
%        else
%		    l = l;   
%        end
        
%        buffer_up = [buffer_up;l_m-buffer c];
%        buffer_low = [buffer_low;l_m+buffer c];
%        middle = [middle;l_m,c;];
%        line_cut = [line_cut;[l c];];
%        line_cut_x = [line_cut_x; l];
%end
 
[yrows, xcolumns] = find_cut(k,54,1,54,w);



upper_im = input;
low_im = input;

for u = 1:w
    for r = line_cut_x(u,1):h      
        if r > line_cut_x(u,1)
            upper_im(r,u) = 0;
        end      
    end
end

for u = 1:w
    for r = 1:line_cut_x(u,1)     
        if r < line_cut_x(u,1)
            low_im(r,u) = 0;
        end  
    end
end


figure(1);
imshow(input);
hold on;
set (gca, 'ydir', 'reverse');
plot(line_cut(:,1), 'linewidth', 2);
print([result_name, '_input_image_with_cutting_line.eps'], '-depsc');

figure(2);
clf;
imshow(upper_im);
set (gca, 'ydir', 'reverse');
print([result_name, '_upper_cut.eps'], '-depsc');
imwrite(upper_im, [result_name, '_upper_cut.tif']);

figure(3);
clf;
imshow(low_im);
set (gca, 'ydir', 'reverse');
print([result_name, '_lower_cut.eps'], '-depsc');
imwrite(low_im, [result_name, '_lower_cut.tif']);

%imwrite(input, [result_name, '_original_image.tif']);


toc
