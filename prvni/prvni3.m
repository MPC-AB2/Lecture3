function [merged_im] = prvni3(J,init_panorama,settings)

if (isempty(settings))
    settings.MetricThreshold = 1000;
    settings.NumOctaves = 3;
    settings.NumScaleLevels = 4;    
end


numImages = length(J);
gray_init_panorama = im2gray(init_panorama);

data = cell(1,numImages);
imageSize = zeros(numImages,2);

points_init = detectSURFFeatures(gray_init_panorama, settings);    
[features_init, points_init] = extractFeatures(gray_init_panorama, points_init);
features_mat = cell(1,numImages);
sizes = zeros(1,numImages);
for k = 1:numImages   
    I = J{1,k};
    grayImage = im2gray(I);
    imageSize(k,:) = size(grayImage);

    points = detectSURFFeatures(grayImage, settings);    
    [features, points] = extractFeatures(grayImage, points);

    data{1,k}.points = points;
    data{1,k}.features = features;
    indexPairs = matchFeatures(data{1,k}.features, features_init, 'Unique', true);
    features_mat{1,k} = indexPairs;
    sizes(k) = size(features_mat{1,k},1);
end
[val, index] = max(sizes);
matchedPointsPrev = points_init(features_mat{1,index}(:,2), :);
matchedPoints = data{1,index}.points(features_mat{1,index}(:,1), :);

offset_x_vec = zeros(1,length(matchedPoints));
offset_y_vec = zeros(1,length(matchedPoints));
for k = 1:length(matchedPoints)
    offset_x_vec(k) = double(matchedPointsPrev.Location(1,1)-matchedPoints.Location(1,1));
    offset_y_vec(k) = double(matchedPointsPrev.Location(1,2)-matchedPoints.Location(1,2));
end
offset_x = round(mean(offset_x_vec));
offset_y = round(mean(offset_y_vec));

[im_y, im_x, im_dim] = size(J{1,index});
%init_panorama(offset_y(1):offset_y(1)+im_y-1,offset_x(1):offset_x(1)+im_x-1, :) = init_panorama(offset_y(1):offset_y(1)+im_y-1,offset_x(1):offset_x(1)+im_x-1, :)-J{1,index};
%J = {J{1:index-1},J{index+1:end}};

posun = 40;
x_posun = -20;
mat_posun = zeros(posun,posun);
panorama_pom_F = init_panorama;
for x = 1:posun
    y_posun = -20;
    for y = 1:posun
        panorama_temp = init_panorama;
        panorama_pom = init_panorama;
        panorama_pom(offset_y(1)+y_posun:offset_y(1)+im_y-1+y_posun,offset_x(1)+x_posun:offset_x(1)+im_x-1+x_posun, :) = panorama_pom(offset_y(1)+y_posun:offset_y(1)+im_y-1+y_posun,offset_x(1)+x_posun:offset_x(1)+im_x-1+x_posun, :)-J{1,index};
        
        panorama_temp = panorama_temp(offset_y(1)+y_posun:offset_y(1)+im_y-1+y_posun,offset_x(1)+x_posun:offset_x(1)+im_x-1+x_posun, :) - J{1,index}; 
        mat_posun(x,y) = sum(sum(sum(panorama_temp(:,:,:)==0)));

        y_posun = y_posun+1;
    end
    x_posun = x_posun+1;
end
x_posun = -20;
y_posun = -20;
minimum = max(max(mat_posun));

[F_posun_x,F_posun_y] = find(mat_posun==minimum);
F_posun_x = F_posun_x + x_posun - 1;
F_posun_y = F_posun_y + y_posun - 1;
init_panorama(offset_y(1)+F_posun_y:offset_y(1)+im_y-1+F_posun_y,offset_x(1)+F_posun_x:offset_x(1)+im_x-1+F_posun_x, :) = J{1,index};

if length(J) == 1
    merged_im = init_panorama;
    return
else
    J = {J{1:index-1},J{index+1:end}};
end

merged_im = prvni(J, init_panorama, []);

end