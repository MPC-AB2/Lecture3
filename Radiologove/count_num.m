function [max] = count_num(split,features)
    split = im2gray(split);
    points_split = detectSURFFeatures(split);
    [features_split] = extractFeatures(split,points_split);
    indexPairs = matchFeatures(features,features_split,'Method','Approximate');
    max = size(indexPairs,1);
end