% function [xshiftA yshiftA] = find_best_part(Ia,Ib)

pointsa = detectSIFTFeatures(Ia,'EdgeThreshold',2,'Sigma',1.3);
pointsb = detectSIFTFeatures(Ib,'EdgeThreshold',2,'Sigma',1.3);
matchedPoints1 = [];
matchedPoints2 = [];

for indexa = 1:length(pointsa.Location)
    for indexb = 1:length(pointsb.Location)
        match1 = abs(pointsa.Scale(indexa) - pointsb.Scale(indexb));
        match2 = abs(pointsa.Metric(indexa) - pointsb.Metric(indexb));
        matchedPoints1(indexa,indexb) = match1+match2;
    end
end


% end