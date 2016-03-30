function do_system_training(dataset, model_path, feature_normalizer_path, ...
    feature_path, classifier_params, dataset_evaluation_mode, ...
    classifier_method, overwrite)
% System training
%
% model container format (struct):
%   model.normalizer = normalizer_class;
%   model.models = containers.Map();
%   model.models(scene_label) = model_struct;    
%
% Parameters
% ----------
% dataset : class
%     dataset class
%
% model_path : str
%     path where the models are saved.
%
% feature_normalizer_path : str
%     path where the feature normalizers are saved.
%
% feature_path : str
%     path where the features are saved.
%
% classifier_params : struct
%     parameter struct
%
% dataset_evaluation_mode : str ['folds', 'full']
%     evaluation mode, 'full' all material available is considered to
%     belong to one fold.
%
% classifier_method : str ['gmm']
%     classifier method, currently only GMM supported
%
% overwrite : bool
%     overwrite existing models
%
% Returns
% -------
% nothing
%
% Raises
% -------
% error
%     classifier_method is unknown.
%     Feature normalizer not found.
%     Feature file not found.
%

if ~strcmp(classifier_method, 'gmm')
    error(['Unknown classifier method [', classifier_method, ']']);
end

% Check that target path exists, create if not
check_path(model_path);
progress(1, 'Collecting data', 0, '');
for fold=dataset.folds(dataset_evaluation_mode)        
    current_model_file = get_model_filename(fold, model_path);
    if or(~exist(current_model_file, 'file'), overwrite)
        % Load normalizer
        feature_normalizer_filename = ...
            get_feature_normalizer_filename(fold, feature_normalizer_path);
        if exist(feature_normalizer_filename, 'file')
            normalizer = load_data(feature_normalizer_filename);
        else
            error(['Feature normalizer not found [', ...
                feature_normalizer_filename, ']']);
        end

        % Initialize model container
        model_container = struct('normalizer', normalizer, ...
            'models', containers.Map() );

        % Collect training examples            
        train_items = dataset.train(fold);
        data = containers.Map();
        for item_id=1:length(train_items)
            item = train_items(item_id);
            progress(0, 'Collecting data', ...
                (item_id / length(train_items)), item.file, fold);

            % Load features
            feature_filename = ...
                get_feature_filename(item.file, feature_path);
            if exist(feature_filename, 'file')
                feature_data = load_data(feature_filename);
                feature_data = feature_data.feat;
            else
                error(['Features not found [', item.file, ']']);
            end

            % Normalize features
            feature_data = ...
                model_container.normalizer.normalize(feature_data);

            % Store features per class label
            if ~isKey(data,item.scene_label)
                data(item.scene_label) = feature_data;
            else
                data(item.scene_label) = ...
                    [data(item.scene_label), feature_data];
            end

        end

        % Train models for each class
        label_id = 1;
        for label=data.keys
            progress(0, 'Train models', ...
                (label_id / length(data.keys)), char(label), fold);

            if strcmp(classifier_method,'gmm')                                       
                [gmm.mu, gmm.Sigma, gmm.w , gmm.avglogl, ...
                    gmm.f, gmm.normlogl, gmm.avglogl_iter] = ...
                    gaussmix(data(char(label))', [], ...
                    classifier_params.n_iter+classifier_params.min_covar, ...
                    classifier_params.n_components, 'hf');
                model_container.models(char(label)) = gmm;
            else
               error(['Unknown classifier method ', ...
                   classifier_method, ']']);                
            end
            label_id = label_id + 1;
        end

        % Save models
        save_data(current_model_file, model_container);
    end
end
disp('  ');
end