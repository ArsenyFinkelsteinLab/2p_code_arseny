function random_sequence_cross_shape(hSI, repeat_consequative)

max_daq=45000;
% max_daq=20000; %205 targets

%% Generate a random sequence
global dat
num_roi= length(dat.roi);
seq=[];
num = floor(max_daq/(num_roi*repeat_consequative));
for i = 1:num % will generate a sequence with length 120 X num_roi
    g_repeated=[];
    g = randperm(num_roi);
    for i_g = 1:1: numel(g)
        g_repeated = [g_repeated repmat(g(i_g),1,repeat_consequative)];
    end
    seq = [seq g_repeated];
end
% figure
% histogram(seq,[1:1:num_roi+1])


hSI.hPhotostim.sequenceSelectedStimuli = seq;

% hSI.hScan_LinScanner.scannerToRefTransform -


% for i = 1:num % will generate a sequence with length 120 X num_roi
%   g = randperm(num_roi);
%   seq = [seq g];
% end