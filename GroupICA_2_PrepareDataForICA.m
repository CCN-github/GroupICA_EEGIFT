%% Prepare the filtered EEG data for the Group ICA

parentfolder    = [pwd, '/1 DataFilteredAndEpoched/'];
newfolder       = [pwd, '/2 DataForGroupICA/'];

%% load EEG data
cd(parentfolder)
eeglab
EEG = pop_loadset('filename', 'swahili epoched PP01_filt for ICA.set');            % just loading a random data set to get the trial information

%% Declare variables
subject_list    = {'PP01','PP02'};
num_subjects    = length(subject_list);     % 41 proefpersonen
ntrials         = 60;
nchan           = 64;

%% loop over proefpersonen
for s = 1:num_subjects
    
    fprintf('\n\n\n***subject %d***\n\n\n',s);              % print what subject is being processed in command window
    
    % load data for this subject
    cd(parentfolder)    
    EEG = pop_loadset('filename', ['swahili epoched ' subject_list{s} '_filt for ICA.set'], 'filepath', parentfolder);

    % select the EEG data stretch we want
    EEG = pop_select(EEG, 'time', [1.25 6.50]);
    
    % select only the relevant channels
    EEG.data                    = EEG.data(1:nchan,:,:);
    EEG.nbchan                  = size(EEG,3);
    EEG.chanlocs                = EEG.chanlocs(nchan);
    EEG.chaninfo.icachansind    = EEG.chaninfo.icachansind(nchan);
    EEG.icawinv                 = EEG.icawinv(nchan,:);
    EEG.icasphere               = EEG.icasphere(nchan,nchan);
    EEG.icaweights              = EEG.icaweights(:,nchan);
    EEG.icachansind             = EEG.icachansind(nchan);
    
    % clear the urevents
    EEG.urevent = [];
    
    % remove spurious triggers
    allevents   = [EEG.epoch.event];                        % make a backup
    alltypes    = [EEG.epoch.eventtype];                    % make a backup
    tokeepEvent = allevents(strcmp(alltypes, '-99')==0);    % select events
    
    if length(tokeepEvent) < length(allevents)
        if length(tokeepEvent) == EEG.trials
            event_storage = EEG.event;                      % make a backup
            epoch_storage = EEG.epoch;                      % make a backup
            EEG.event = EEG.event(1);                       % reset
            EEG.epoch = EEG.epoch(1);                       % reset
            for i = 1:length(tokeepEvent)
                EEG.event(i) = event_storage(tokeepEvent(i));   % store event info, then proceed to epoch information
                if length(epoch_storage(i).event) > 1
                    EEG.epoch(i).event          =          epoch_storage(i).event(           epoch_storage(i).event==tokeepEvent(i));
                    EEG.epoch(i).eventbepoch    = cell2mat(epoch_storage(i).eventbepoch(     epoch_storage(i).event==tokeepEvent(i)));
                    EEG.epoch(i).eventbini      = cell2mat(epoch_storage(i).eventbini(       epoch_storage(i).event==tokeepEvent(i)));
                    EEG.epoch(i).eventbinlabel  = cell2mat(epoch_storage(i).eventbinlabel(   epoch_storage(i).event==tokeepEvent(i)));
                    EEG.epoch(i).eventcodelabel = cell2mat(epoch_storage(i).eventcodelabel(  epoch_storage(i).event==tokeepEvent(i)));
                    EEG.epoch(i).eventduration  = cell2mat(epoch_storage(i).eventduration(   epoch_storage(i).event==tokeepEvent(i)));
                    EEG.epoch(i).eventenable    = cell2mat(epoch_storage(i).eventenable(     epoch_storage(i).event==tokeepEvent(i)));
                    EEG.epoch(i).eventflag      = cell2mat(epoch_storage(i).eventflag(       epoch_storage(i).event==tokeepEvent(i)));
                    EEG.epoch(i).eventitem      = cell2mat(epoch_storage(i).eventitem(       epoch_storage(i).event==tokeepEvent(i)));
                    EEG.epoch(i).eventlatency   = cell2mat(epoch_storage(i).eventlatency(    epoch_storage(i).event==tokeepEvent(i)));
                    EEG.epoch(i).eventtype      = cell2mat(epoch_storage(i).eventtype(       epoch_storage(i).event==tokeepEvent(i)));
                    EEG.epoch(i).eventurevent   = cell2mat(epoch_storage(i).eventurevent(    epoch_storage(i).event==tokeepEvent(i)));
                else
                    EEG.epoch(i) = epoch_storage(i);
                end
            end
        end
    end

    % if needed, insert average trials when not all trials were present
    if EEG.trials < ntrials
        for i = 1:(ntrials - EEG.trials)
            EEG.data(:,:,	EEG.trials+i)               = mean(EEG.data(:,:,1:EEG.trials),3);                           % insert average time course
            EEG.event(    	EEG.trials+i)               = EEG.event(EEG.trials);                                        % insert the missing event information (see also next lines)
            EEG.epoch(     	EEG.trials+i)               = EEG.epoch(EEG.trials);                                        
            EEG.event(      EEG.trials+i).bepoch        = EEG.trials+i;
            EEG.event(      EEG.trials+i).epoch         = EEG.trials+i;
            EEG.epoch(      EEG.trials+i).event         = EEG.trials+i;
            EEG.epoch(      EEG.trials+i).eventbepoch   = EEG.trials+i;
            if iscell(EEG.epoch(1).eventlatency)                                                                        % fill in average latency
                EEG.event(      EEG.trials+i).latency       = mean(cell2mat([EEG.epoch(1:EEG.trials).eventlatency]));
                EEG.epoch(      EEG.trials+i).eventlatency  = mean(cell2mat([EEG.epoch(1:EEG.trials).eventlatency]));
            else
                EEG.event(      EEG.trials+i).latency       = mean(         [EEG.epoch(1:EEG.trials).eventlatency]);
                EEG.epoch(      EEG.trials+i).eventlatency  = mean(         [EEG.epoch(1:EEG.trials).eventlatency]);
            end
            EEG.event(      EEG.trials+i).item          = 1000;                                                         % fill in nonrealistic data
            EEG.epoch(      EEG.trials+i).eventitem     = 1000;
            EEG.event(      EEG.trials+i).urevent       = 1000;
            EEG.epoch(      EEG.trials+i).eventurevent  = 1000;
            EEG.event(      EEG.trials+i).type          = '99';
            EEG.epoch(      EEG.trials+i).eventtype     = '99';
        end
    end
    EEG.trials = ntrials;       % update the number of trials
    
    % store the selected data
    cd(newfolder)  
    EEG = pop_editset(EEG, 'setname',  ['swahili epoched ' subject_list{s} '_selected for ICA']);
    EEG = pop_saveset(EEG, 'filename', ['swahili epoched ' subject_list{s} '_selected for ICA.set'],'filepath', newfolder);

end         % end loop over subjects

clear all