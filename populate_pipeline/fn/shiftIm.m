function [im output] = shiftIm(im,ref,decimationFactor)
if nargin == 1
    ref = mean(squeeze(im),3);
end
if nargin < 3
    decimationFactor = 1;
end
sz = size(im,1);
ind1 = round(sz/decimationFactor);
ind1 = 1+round((sz-ind1)/2):sz-round((sz-ind1)/2);
sz = size(im,2);
ind2 = round(sz/decimationFactor);
ind2 = 1+round((sz-ind2)/2):sz-round((sz-ind2)/2);
% x = 0*im;

ref=ref(ind1,ind2);
im = im(ind1,ind2,:);
parfor frame = 1:size(im,3)
%     [num2str(frame), '/',num2str(size(im,3))]
%     tic
    [~, G] = dftregistration(fft2(ref),fft2(double(im(:,:,frame))),1);
    im(:,:,frame)=(abs(ifft2(G)));

    
%     if decimationFactor == 1
%         x(:,:,frame)=(abs(ifft2(G)));
%     else
% %         x(:,:,frame) = imtranslate(im(:,:,frame),output([4 3]));
%         x(:,:,frame) = KDtranslate(im(:,:,frame),output([3 4]));
%     end
%     toc
end