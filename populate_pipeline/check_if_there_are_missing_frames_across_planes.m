function check_if_there_are_missing_frames_across_planes()

% key.subject_id = 463189;
% key.session = 5;
% EXP2.Session & key
% IMG.Plane & key
%%
clc
data_dir = 'F:\Arseny\2p\data\anm463190_AF26\20200212_registered\suite2p';

num_planes = 6;
frames_per_folder=[];
for p = 0:1:num_planes
    S2P=load([data_dir '\plane' num2str(p) '\Fall.mat'],'ops');
    frames_per_folder(p+1,:) = S2P.ops.frames_per_folder;
end
frames_per_folder
