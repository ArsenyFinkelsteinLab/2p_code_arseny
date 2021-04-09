function [img_mean, newDir] = register_all2(folder,siFiles,template,phase,frames,decimationFactor)
%%
if nargin < 6
    decimationFactor = 1;
end
if ~exist('phase');
    phase = 0;
end
newDir = [folder,'\registered\'];
if ~isdir(newDir)
    mkdir(folder,'registered');
end
ui = 'uniformoutput';
regFiles = dir(newDir);regFiles = {regFiles.name};
regFiles = cellfun(@(x) [newDir,x],regFiles,ui,0);

file = [folder,char(siFiles{1})];
% [header]=scanimage.util.opentif(file);
% [hMroiRoiGroup hStimRoiGroups] = scanimage.util.readTiffRoiData(file);
img_mean=zeros(size(template));
for fi = 1:length(siFiles)
    tic
    fi
    file = [folder,char(siFiles{fi})];
    file2 = [newDir,char(siFiles{fi})];
    a = max(find(file2 == '.'));
    name = [file2(1:a-1),'shift.tif'];
    already_done = cellfun(@(x) strcmp(x,name),regFiles,ui,0);
    ~sum([already_done{:}]);
    if ~sum([already_done{:}])
        strt_frame = 1;%green channel
        dim = size(template);%[header.SI.hRoiManager.linesPerFrame header.SI.hRoiManager.pixelsPerLine];
        skp = 1;%length(header.SI.hChannels.channelSave);
        im = (KDimread(file,dim,frames,strt_frame,skp));
        im = (phase_shift(im,phase));
        im = im(:,1+phase:phase+dim(2),:);
        %         im = squeeze(im(:,:,1,:));
        im = shiftIm(im,template,decimationFactor);
%         im = double(im);        
%         im = phase_shift(im,phase);
% addpath('Y:\users\Kayvon\MATLAB\photostim\saveastiff_4.3')
% addpath('C:\Users\daiek\Documents\MATLAB\photostim\saveastiff_4.3\')
saveastiff(uint16(im),name);

        img_mean=img_mean + mean(im,3)/length(siFiles);
%         save(name,'im');
        
%             if ~isnan(im)
%             pp=0;
%             while pp==0;
%                 pp=0;
%                 try
%                     imwrite(im(:,:,1), name,'tif')
%                     for i=2:size(im,3)
%                         if i==2;pause(1);end;
%                         imwrite(im(:,:,i), name,'tif', 'writemode',...
%                             'append');
%                         i;
%                     end;
%                     pp=1;
%                 catch
%                     pp=0;
%                 end
%             end
%         end
        toc
        
        
        
    else
        if nargout > 0
            load(name);
            vargout{1} = im;
        end
    end
    [fi/length(siFiles) toc]
end



