function im = KDimread(file,dim,num,strt,skp);

im = zeros(dim(1),dim(2),round(num));
hTif = Tiff(file);
idx = strt;jdx = 1;
good = 1;
while good == 1
%     jdx
    if jdx == num
        good = 0;
    end
    try
        hTif.setDirectory(idx);
        im(:,:,jdx) = hTif.read();
        idx = idx + skp;
        jdx = jdx + 1;
    catch
        good = 0;
    end
end

