function output_panorama = ToNebudeFungovat( J, init_panorama)
    %% "FUNGUJÍCÍ" MAGIE
%     panorama = imread("panorama.png");
%     load('image_splitted.mat');
    panorama = init_panorama;
    while(numel(J)~=0)
        
        panorama_G = rgb2gray(panorama);
        points =  detectKAZEFeatures(panorama_G,NumOctaves=1);
        [features, valid_points] = extractFeatures(panorama_G,points);
        maximum = 0;
        index = 0; 
        for i = 1:numel(J)
            obr2 = J{i};
            
            points2 =  detectKAZEFeatures(rgb2gray(obr2),NumOctaves=1);
            [features2, ~] = extractFeatures(rgb2gray(obr2),points2);
            
            indexPairs = matchFeatures(features, features2);
            if(size(indexPairs,1)>maximum)   
                maximum = size(indexPairs,1);
                index = i;
            end
        end
       
        obr2 = J{index};
        points2 =  detectKAZEFeatures(rgb2gray(obr2),NumOctaves=1);
        [features2, valid_points2] = extractFeatures(rgb2gray(obr2),points2);
    
        indexPairs = matchFeatures(features, features2);
               
        matchedPoints1 = valid_points(indexPairs(:,1), :);
        matchedPoints2 = valid_points2(indexPairs(:,2), :);  
        
    %     figure; 
    %     showMatchedFeatures(panorama_G,obr2,matchedPoints1,matchedPoints2);
        
        tform = estimateGeometricTransform(matchedPoints2, matchedPoints1, 'similarity');
        outputView = imref2d(size(panorama));
        Ir = imwarp(obr2, tform, 'OutputView', outputView);
        
        panorama(panorama==0)= Ir(panorama==0);
        
        %imshow(panorama)
       
        
        J(index) = [];
    end
    output_panorama = panorama;
    %addpath('C:\Users\xsando01\Documents\AB2\Lecture3')

end

