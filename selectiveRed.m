img = imread('image.jpg');

img_hsv = rgb2hsv(img);

red_hue_threshold = 30 / 360; 

saturation_weight = 0.5;
brightness_weight = 0.5;

[rows, cols, ~] = size(img);

for row = 1:rows
    for col = 1:cols
       
        H = img_hsv(row, col, 1);
        S = img_hsv(row, col, 2);
        V = img_hsv(row, col, 3);
        
      
        hue_range = red_hue_threshold * (1 - S * saturation_weight) * (1 - V * brightness_weight);
        
       
        if (H <= red_hue_threshold + hue_range) || (H >= 1 - red_hue_threshold - hue_range)
 
            img_hsv(row, col, 2) = 1; 
            img_hsv(row, col, 3) = 1; 
        else
          
            img_hsv(row, col, 2) = 0; 
        end
    end
end

img_processed = hsv2rgb(img_hsv);

figure;
subplot(1, 2, 1);
imshow(img);
title('Original Image');
subplot(1, 2, 2);
imshow(img_processed);
title('Processed Image');
