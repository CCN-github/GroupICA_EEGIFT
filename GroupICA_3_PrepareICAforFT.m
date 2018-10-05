%% Prepare Group ICA output for TimeFrequency analysis

EEGfolder       = [pwd, '/3 DataReadyForGroupICA/swahili epoched PP01_selected for ICA/'];
parentfolder    = [pwd, '/4 ResultsGroupICA/'];

%% load EEG data
cd(EEGfolder)
EEG             = load('swahili.mat');     % 4864 x 60 x 64
cd(parentfolder)

%% Declare variables
Components      = [8 10 14 18];     % selected after visual inspection

ntimepoints     = size(EEG.data, 1);
ntrials         = 60;
nchan           = 64;
nsubjects       = 2;
ncomponents     = length(Components);

CompTimeCourse  = NaN(ntimepoints, ntrials, ncomponents, nsubjects);    % time points by trials by components by subjects
CompChannels    = NaN(nchan,                20         , nsubjects);    % channels              by components by subjects

%% Extract component information
for s = 1:nsubjects
    
    % load the data
    data        = load(['swahili_ica_c' num2str(s) '-1.mat']);
    timecourse  = data.timecourse;
    topography  = data.topography;
    
    % extract all the 60 trials
    for i = 1:ntrials
        CompTimeCourse(:,i,:,s) = timecourse(Components,((i-1)*ntimepoints+1):(i*ntimepoints))';
        fprintf('\n\n\n***subject %d trial %d***\n\n\n',s,i);   
    end
    CompChannels(:,:,s) = topography;
    
    clear data timecourse topography
end

%% Store the output
filename = strcat('GroupICA_timecourse.mat');
save(filename, 'CompTimeCourse')
filename = strcat('GroupICA_topography.mat');
save(filename, 'CompChannels')

clear all