%% ICA Extraction of Network States
%	This script computes the neural assemblies and assembly time courses
% from the data processed by the extraction script and computes the Shannon
% entropies of each assembly's time course.  In addition, it computes the
% total Shannon entropy of each condition.


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% ASSEMBLY PIPELINE


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%	SETUP

%% Set paths & filenames

% Shuffle random seed.  Necessary in array parallelization to avoid
% repeating same random seed across arrays.
rng('shuffle');

% Find general path (enclosing folder of current directory)
path{1} = strsplit(pwd, '/');
path{2,1} = strjoin(path{1}(1:end-2),'/');
path{3,1} = strjoin(path{1}(1:end-1),'/');
path{1,1} = strjoin(path{1}(1:end-3),'/');

% Set required subdirectories
path{4,1} = fullfile(path{2},'Data');
path{5,1} = fullfile(path{2},'Results');
path{6,1} = fullfile(path{1},'MATLAB','FastICA');
path{7,1} = fullfile(path{3},'Functions');
path{8,1} = fullfile(path{2},'Results','LEICA');

% Add relevant paths
for k = 6:numel(path)-1
	addpath(genpath(path{k}));
end
clear k


%% Set file names & load data

% Define files to load
loadFile = 'LEiDA90_Data_OCDvHealth';

% Load data
load(fullfile(path{8}, loadFile));
clear loadFile

% File to save
fileName = 'LEiDA90_Assemblies_OCDvHealth';


%% Reset paths (in case original paths overwritten by loaded file)

% Find general path (enclosing folder of current directory)
path{1} = strsplit(pwd, '/');
path{2,1} = strjoin(path{1}(1:end-2),'/');
path{3,1} = strjoin(path{1}(1:end-1),'/');
path{1,1} = strjoin(path{1}(1:end-3),'/');

% Set required subdirectories
path{4,1} = fullfile(path{2},'Data');
path{5,1} = fullfile(path{2},'Results');
path{6,1} = fullfile(path{1},'MATLAB','FastICA');
path{7,1} = fullfile(path{3},'Functions');
path{8,1} = fullfile(path{2},'Results','LEICA');


%% 1) Compute the assemblies

disp('Processing the ICs from BOLD data')

% Set field names for structures
datatype = {'BOLD','Z','PH'};
N.datatype = numel(datatype);

% Loop through data types
for d = 1:N.datatype
	for c = 1:N.condition
		% Extract number of assemblies
		N.assemblies(d,1) = NumberofIC(timeseries.(datatype{d}));

		% Compute assembly activation timecourses and memberships
		[activations.(datatype{d}){1}, memberships.(datatype{d}){1}, W.(datatype{d})] = fastica(timeseries.(datatype{d}), 'numOfIC', N.assemblies(d), 'verbose','off');

		% Normalize memberships
		memberships.(datatype{d}){1} = memberships.(datatype{d}){1}./max(abs(memberships.(datatype{d}){1}));
	end
end


%% 2) Compute Shannon entropy for each assembly in each subject and each condition

% Compute activation entropy and timecourse for each assembly
for d = 1:N.datatype
	[entro.(datatype{d}){1}, meanvalue.(datatype{d}){1}, activations.(datatype{d}){2,1}] = HShannon_segmented(activations.(datatype{d}){1}, T.index, N.condition, N.subjects, N.assemblies(d), co);
end
clear d loadFile

% Save interim results
save(fullfile(path{8}, fileName));

