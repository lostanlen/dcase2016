function result = do_classification_gmm(feature_data, model_container)
    % GMM classification for give feature matrix
    % 
    % model container format (struct):
    %   model.normalizer = normalizer_class;
    %   model.models = containers.Map();
    %   model.models(scene_label) = model_struct;  
    % 
    % Parameters
    % ----------
    % feature_data : matrix [shape=(feature vector length, t)]
    %     feature matrix
    % 
    % model_container : struct
    %     model container
    % 
    % Returns
    % -------
    % result : str
    %     classification result as scene label
    % 

    % Initialize log-likelihood matrix to -inf
    logls = ones(length(model_container.models), 1);
    logls = logls .* -inf;
    
    label_id = 1;
    for label = model_container.models.keys
        [lp, rp, kh, kp] = gaussmixp(feature_data',...
                                     model_container.models(char(label)).mu,...
                                     model_container.models(char(label)).Sigma,...
                                     model_container.models(char(label)).w);
        logls(label_id) = sum(lp);
        label_id = label_id + 1;
    end
    [max_value,classification_result_id] = max(logls);
    k = model_container.models.keys;
    result = k{classification_result_id};
end