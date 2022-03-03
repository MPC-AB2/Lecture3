function [panorama_RGB] = kafickari(J,init_panorama)
% load('image_splitted.mat')
% load('evaluatePanorama.mat')
panorama_RGB = init_panorama;
panorama = im2double(rgb2gray(panorama_RGB));

threshold = 1000;


%% detekce
% detected_panorama = detectHarrisFeatures(panorama);
% [features_panorama, valid_corners_panorama] = extractFeatures(panorama, detected_panorama);
detected_panorama = detectSURFFeatures(panorama,"MetricThreshold",threshold);
[features_panorama, valid_corners_panorama] = extractFeatures(panorama, detected_panorama,'Method','SURF');


%   figure; imshow(panorama); hold on
%   plot(detected_panorama.selectStrongest(50));
%%
J_detected = cell(1, 8);
features = cell(1, 8);
valid_corners = cell(1, 8);

J_detected_H = cell(1, 8);
features_H = cell(1, 8);
valid_corners_H = cell(1, 8);

for i=1:length(J)
    img_temp = im2double(rgb2gray(J{1,i}));
    J_detected{1, i} = detectSURFFeatures(img_temp,"MetricThreshold",threshold);
    [features{1, i}, valid_corners{1, i}] = extractFeatures(img_temp, J_detected{1, i},'Method','SURF');

    J_detected_H{1, i} = detectHarrisFeatures(img_temp);
    [features_H{1, i}, valid_corners_H{1, i}] = extractFeatures(img_temp, J_detected_H{1, i});

end
%% Pair
% nemeni sa
vektor_ind = 1:length(J);


while vektor_ind>0

        
        maxim = 0;
        max_ind = [];
        panorama = im2double(rgb2gray(panorama_RGB));
%         detected_panorama = detectHarrisFeatures(panorama);
%         [features_panorama, valid_corners_panorama] = extractFeatures(panorama, detected_panorama);
        detected_panorama = detectSURFFeatures(panorama,"MetricThreshold",threshold);
        [features_panorama, valid_corners_panorama] = extractFeatures(panorama, detected_panorama,'Method','SURF');
            
        
        for i=1:length(vektor_ind)
            % common points
            indexPairs = matchFeatures(features_panorama,features{1,vektor_ind(i)});
            % find max
            if length(indexPairs)>maxim
                maxim = length(indexPairs);
                max_ind = vektor_ind(i);
            end
        end


        if maxim == 0
%             max_ind = vektor_ind(1);
            detected_panorama = detectHarrisFeatures(panorama);
            [features_panorama, valid_corners_panorama] = extractFeatures(panorama, detected_panorama);

            for i=1:length(vektor_ind)
            % common points
            indexPairs = matchFeatures(features_panorama,features_H{1,vektor_ind(i)});
            % find max
            if length(indexPairs)>maxim
                maxim = length(indexPairs);
                max_ind = vektor_ind(i);
            end
            end
            [indexPairs_merging, best] = matchFeatures(features_panorama,features_H{1,max_ind});
            matchedPoints1 = valid_corners_panorama(indexPairs_merging(:,1),:);
            matchedPoints2 = valid_corners_H{1, max_ind}(indexPairs_merging(:,2),:);
        else 

        

        % merge img: use one point
        [indexPairs_merging, best] = matchFeatures(features_panorama,features{1,max_ind});
        matchedPoints1 = valid_corners_panorama(indexPairs_merging(:,1),:);
        matchedPoints2 = valid_corners{1, max_ind}(indexPairs_merging(:,2),:);
        
        end

        slope = matchedPoints1.Location(:,1) - matchedPoints2.Location(:,1) ./ matchedPoints1.Location(:,2) - matchedPoints2.Location(:,2);

        
        [B,outli] = rmoutliers(slope,'median');
        index = find(slope==B(1));


        % replace panorama img with merged img and remove img
        point_panorama = round(matchedPoints1.Location(index,:));
        point_best_match = round(matchedPoints2.Location(index,:));
        
        translation = point_panorama - point_best_match;
        
        panorama_RGB(translation(2):translation(2)+size(J{1,max_ind},1)-1,translation(1):translation(1)+size(J{1,max_ind},2)-1, :) = J{1,max_ind};
        
%         figure;
%         imshow(panorama_RGB)
 
        % remove marged img
        vektor_ind(vektor_ind == max_ind) = [];

end

        figure;
        imshow(panorama_RGB)
        title('PIQE = 35.0867, mError = 31.4691')

end

