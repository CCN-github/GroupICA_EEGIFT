%% Data to feed manually into esther_locs.locs for the Group ICA

parentfolder    = [pwd, '/1 DataFilteredAndEpoched/'];

%% load EEG data
cd(parentfolder)
eeglab
EEG = pop_loadset('filename', 'swahili epoched PP01_filt for ICA.set');            % just loading a random data set to get the trial information

%% select the channel information
lab     = {EEG.chanlocs.labels};
theta   = {EEG.chanlocs.theta};
radius  = {EEG.chanlocs.radius};

%% display the channel information
[lab' theta' radius']

clear all