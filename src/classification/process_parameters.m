function params = process_parameters(params)
% Parameter post-processing.
%
% Parameters
% ----------
% params : struct
%    parameters in struct
%
% Returns
% -------
% params : struct
%    processed parameters
%

if isfield(params.features, 'mfcc')
    params.features.mfcc.win_length_seconds = ...
        params.features.win_length_seconds;
    params.features.mfcc.hop_length_seconds = ...
        params.features.hop_length_seconds;
    params.features.mfcc.win_length = ...
        round(params.features.win_length_seconds * params.features.fs);
    params.features.mfcc.hop_length = ...
        round(params.features.hop_length_seconds * params.features.fs);
end

params.classifier.parameters = ...
    getfield(params.classifier_parameters, params.classifier.method);

params.features.hash = get_parameter_hash(params.features);
params.classifier.hash = get_parameter_hash(params.classifier);

params.path.features = fullfile(params.path.base, ...
    params.path.features, params.features.hash);
params.path.feature_normalizers = fullfile(params.path.base, ...
    params.path.feature_normalizers, params.features.hash);
params.path.models = fullfile(params.path.base, ...
    params.path.models, params.features.hash, params.classifier.hash);
params.path.results = fullfile(params.path.base, ...
    params.path.results, params.features.hash, params.classifier.hash);
end