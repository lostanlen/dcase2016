function task1_scene_classification(varargin)
%%
download_external_libraries(); % Download external libraries
add_paths();   % Add file paths

rng(123456); % let's make randomization predictable

parser = inputParser;
parser.addOptional('mode', 'development', @isstr);
%parser.addOptional('yaml_path', 'task1_scattering.yaml', @isstr);
parser.addOptional('yaml_path', 'task1_baseline.yaml', @isstr);
parse(parser, varargin{:});

params = load_parameters(parser.Results.yaml_path);
params = process_parameters(params);

title('DCASE 2016::Acoustic Scene Classification');

% Check if mode is defined
if(strcmp(parser.Results.mode, 'development')),
    args.development = true;
    args.challenge = false;
elseif(strcmp(parser.Results.mode, 'challenge')),
    args.development = false;
    args.challenge = true;
end

dataset_evaluation_mode = 'folds';
if(args.development && ~args.challenge),
    disp('Running system in development mode');
    dataset_evaluation_mode = 'folds';
elseif(~args.development && args.challenge),
    disp('Running system in challenge mode');
    dataset_evaluation_mode = 'full';
end

% Get dataset container class
if strcmp(params.general.development_dataset, ...
        'TUTAcousticScenes_2016_DevelopmentSet')
    dataset = TUTAcousticScenes_2016_DevelopmentSet(params.path.data);
else
    error(['Unknown development dataset [', ...
        params.general.development_dataset, ']']);
end

% Fetch data over internet and setup the data
% ==================================================
if params.flow.initialize
    dataset.fetch();
end

% Extract features for all audio files in the dataset
% ==================================================
if params.flow.extract_features
    section_header('Feature extraction');
    
    % Collect files in train sets
    files = [];
    for fold = dataset.folds(dataset_evaluation_mode)
        train_items = dataset.train(fold);
        for item_id = 1:length(train_items)
            item = train_items(item_id);
            if sum(strcmp(item.file,files)) == 0
                files = cat(1, files, {item.file});
            end
        end
        test_items = dataset.test(fold);
        for item_id = 1:length(test_items)
            item = test_items(item_id);
            if sum(strcmp(item.file,files)) == 0
                files = cat(1, files, {item.file});
            end
        end
    end
    files = sort(files);
    
    % Go through files and make sure all features are extracted
    do_feature_extraction(files, ...
        dataset, ...
        params.path.features, ...
        params.features, ...
        params.general.overwrite);
    
    foot();
end
%% Prepare feature normalizers
% ==================================================
if params.flow.feature_normalizer
    section_header('Feature normalizer');
    do_feature_normalization(dataset,...
        params.path.feature_normalizers,...
        params.path.features,...
        dataset_evaluation_mode,...
        params.general.overwrite);
    foot();
end

% System training
% ==================================================
if params.flow.train_system
    section_header('System training');
    model_path = params.path.models;
    feature_normalizer_path = params.path.feature_normalizers;
    feature_path = params.path.features;
    classifier_params = params.classifier.parameters;
    classifier_method = params.classifier.method;
    overwrite = params.general.overwrite;
    do_system_training(dataset, model_path, feature_normalizer_path, ...
        feature_path, classifier_params, dataset_evaluation_mode, ...
        classifier_method, overwrite);
    
    foot();
end

% System evaluation in development mode
if(args.development && ~args.challenge)
    % System testing
    % ==================================================
    if params.flow.test_system
        section_header('System testing     [Development data]');
        
        do_system_testing(dataset,...
            params.path.features,...
            params.path.results,...
            params.path.models,...
            params.features,...
            dataset_evaluation_mode,...
            params.classifier.method,...
            params.general.overwrite);
        foot();
    end
    
    % System evaluation
    % ==================================================
    if params.flow.evaluate_system
        section_header('System evaluation');
        
        do_system_evaluation(dataset,...
            params.path.results,...
            dataset_evaluation_mode);
        
        foot();
    end
    % System evaluation with challenge data
elseif(~args.development && args.challenge)
    % Get dataset container class
    if strcmp(params.general.challenge_dataset, 'TUTAcousticScenes_2016_EvaluationSet')
        challenge_dataset = TUTAcousticScenes_2016_EvaluationSet(params.path.data);
    else
        error(['Unknown development dataset [', params.general.evaluation_dataset, ']']);
    end
    
    if params.flow.initialize
        challenge_dataset.fetch();
    end
    
    % System testing
    if params.flow.test_system
        section_header('System testing     [Challenge data]');
        
        do_system_testing(challenge_dataset,...
            params.path.features,...
            params.path.challenge_results,...
            params.path.models,...
            params.features,...
            dataset_evaluation_mode,...
            params.classifier.method,...
            1);
        foot();
        
        disp(' ');
        disp(['Your results for the challenge data are stored at [',params.path.challenge_results,']']);
        disp(' ');
    end
end
end