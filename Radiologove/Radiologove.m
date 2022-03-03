function [output_panorama] = Radiologove( J, init_panorama)
%% INICIALIZACE R
img_rgb = init_panorama;
img = im2gray(init_panorama);
% img_R = img_R(:,:,1);
J_stitch=J;
for j = 1:size(J,2)
    
%% PANORAMA DETEKCE BODU A EXTRAKCE PRIZNAKU
points_img = detectSURFFeatures(img);
[features, points] = extractFeatures(img,points_img);

num = zeros(1,size(J,2));
%% SPLIT DETEKCE BODU A EXTRAKCE PRIZNAKU
for i = 1:size(J,2)
    num(i) = count_num(J{1,i},features);
end
[~,index_max] = max(num);
merge = J{1,index_max};
J{1,index_max} = NaN(size(J{1,index_max},2));
merge = im2gray(merge);
points_split = detectSURFFeatures(merge);
[features_split, p_split] = extractFeatures(merge,points_split);
indexPairs = matchFeatures(features,features_split,'Method','Approximate');

matchedPoints_split=p_split(indexPairs(:,2),:);
% end
matchedPoints=points(indexPairs(:,1),:);
[tform,~] = estimateGeometricTransform2D(matchedPoints_split,matchedPoints,'similarity');
tform.T=round(tform.T);
outputView = imref2d(size(img));
img_stitch = imwarp(merge,tform,'OutputView',outputView);
mask = img_stitch>0;
img(mask) = img_stitch(mask);

% figure 
% imshow(img); 
% title('Recovered Image');

%% RGB TRANSFORM
mask = cat(3,mask,mask,mask);
outputView = imref2d(size(img_rgb));
img_stitch = imwarp(J_stitch{1,index_max},tform,'OutputView',outputView);
img_rgb(mask) = img_stitch(mask);
end

% figure;imshow(img_rgb)
output_panorama=img_rgb;

end