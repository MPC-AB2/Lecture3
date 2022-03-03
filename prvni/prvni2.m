function [merged_im] = prvni2(J,init_panorama)
numImages = length(J);
gray_init_panorama = im2gray(init_panorama);

data = cell(1,numImages);
imageSize = zeros(numImages,2);

points_init = detectSURFFeatures(gray_init_panorama);    
[features_init, points_init] = extractFeatures(gray_init_panorama, points_init);
features_mat = cell(1,numImages);
sizes = zeros(1,numImages);
for k = 1:numImages   
    I = J{1,k};
    grayImage = im2gray(I);
    imageSize(k,:) = size(grayImage);

    points = detectSURFFeatures(grayImage);    
    [features, points] = extractFeatures(grayImage, points);

%     figure; imshow(I); hold on
%     plot(points);

    data{1,k}.points = points;
    data{1,k}.features = features;
    indexPairs = matchFeatures(data{1,k}.features, features_init, 'Unique', true);
    features_mat{1,k} = indexPairs;
    sizes(k) = size(features_mat{1,k},1);
end
[val, index] = max(sizes);
matchedPointsPrev = points_init(features_mat{1,index}(:,2), :);
matchedPoints = data{1,index}.points(features_mat{1,index}(:,1), :);

% figure; showMatchedFeatures(init_panorama,J{index},matchedPointsPrev,matchedPoints);
% legend('matched points 1','matched points 2');

offset_x = zeros(1,length(matchedPoints));
offset_y = zeros(1,length(matchedPoints));
for k = 1:length(matchedPoints)
    offset_x(k) = ceil(matchedPointsPrev.Location(1,1)-matchedPoints.Location(1,1)+0.5);
    offset_y(k) = ceil(matchedPointsPrev.Location(1,2)-matchedPoints.Location(1,2)+0.5);
end

[im_y, im_x, ~] = size(J{1,index});
init_panorama(offset_y(1):offset_y(1)+im_y-1,offset_x(1):offset_x(1)+im_x-1, :) = J{1,index};


if length(J) == 1
    merged_im = init_panorama;
    return
else
    J = {J{1:index-1},J{index+1:end}};
end

merged_im = prvni2(J, init_panorama);

end
