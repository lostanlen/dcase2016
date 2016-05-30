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
elseif isfield(params.features, 'scattering')
    p = params.features.scattering;
    opts{1}.time.T = pow2(round(log2(params.features.win_length_seconds * ...
        params.features.fs)));
    log2_oversampling = round(log2(params.features.win_length_seconds) - ...
        log2(params.features.hop_length_seconds)) - 1;
    opts{1}.time.is_chunked = false;
    opts{1}.time.max_Q = p.Q1;
    opts{1}.time.gamma_bounds = [1 p.Q1*p.J1];
    opts{1}.time.S_log2_oversampling = log2_oversampling;
    opts{1}.time.size = 2^19;
    opts{2}.time.max_Q = p.Q2_time;
    opts{2}.time.gamma_bounds = [4*p.Q2_time p.Q2_time*p.J2_time];
    opts{2}.time.sibling_mask_factor = 2^5;
    opts{2}.time.S_log2_oversampling = log2_oversampling;
    if isfield(p, 'J2_freq') && isfield(p, 'Q2_freq')
        opts{2}.gamma.max_Q = p.Q2_freq;
        opts{2}.gamma.T = 2^(p.J2_freq);
        opts{2}.gamma.gamma_bounds = [1 p.Q2_freq*p.J2_freq];
        opts{2}.gamma.U_log2_oversampling = Inf;
    end
    params.features.scattering.archs = sc_setup(opts);
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

if ~isfield(params.flow, 'feature_transformation')
    params.flow.feature_transformation = false;
end
end