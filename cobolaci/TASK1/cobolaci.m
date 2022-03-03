function [I_ref_rgb] = cobolaci(J, init_panorama)

MP = {};
% load('image_splitted.mat');
I_ref = rgb2gray(imread('panorama.png'));
I_ref_rgb = imread('panorama.png');
I_ref = rgb2gray(init_panorama);
I_ref_rgb = init_panorama;
all_matched = 0;
NumOfIter = length(J);
step = 0;

while step < NumOfIter;
MP = {};

        for i = 1:NumOfIter-step
        pointsa = detectSIFTFeatures(rgb2gray(J{i}),'EdgeThreshold',1.3,'Sigma',1.3);
        pointsb = detectSIFTFeatures(I_ref,'EdgeThreshold',1.3,'Sigma',1.3);
        matchedPoints1 = [];
        matchedPoints2 = [];
        matchedPoints_all = [];
            for indexa = 1:length(pointsa.Location)
                for indexb = 1:length(pointsb.Location)
                    match1 = abs(pointsa.Scale(indexa) - pointsb.Scale(indexb));
                    match2 = abs(pointsa.Metric(indexa) - pointsb.Metric(indexb));
                    matchedPoints_all(indexa,indexb) = match1+match2;
                end
            end
        
        [val pos] = min(matchedPoints_all');
        val0 = find(val == 0);
        
            if length(val0) ~= 0
                matchedPoints1 = pointsa.Location(val0,:);
                matchedPoints2 = pointsb.Location(pos(val0),:);
                
                MP{i,1} = matchedPoints1;
                MP{i,2} = matchedPoints2;
            else
                MP{i,1} = 0;
                MP{i,2} = 0;
            end
        end

        max_pairs = [];
            for index = 1:length(MP)
                max_pairs(index) = length(MP{index});
            end
        [MP_val MP_pos] = max(max_pairs);
        t = median(MP{MP_pos,1} - MP{MP_pos,2});
        I_ref(-t(2):-t(2)-1+size(J{MP_pos},1),-t(1):-t(1)-1+size(J{MP_pos},2)) = rgb2gray(J{MP_pos});
        I_ref_rgb(-t(2):-t(2)-1+size(J{MP_pos},1),-t(1):-t(1)-1+size(J{MP_pos},2),:) = J{MP_pos};
        J(MP_pos) = [];
        
        
step = step+1;
end

end


