load('image_splitted.mat')
panorama = imread("panorama.png");

panoramis = prvni(J, panorama);

[PIQE, mError] = evalPanorama(panoramis);

str_e = sprintf('PIQE: %0.5f, mError: %0.5f', PIQE, mError)

figure
imshow(panoramis)

imwrite(panoramis, "panoramis.tiff")