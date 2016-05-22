addpath([fileparts(mfilename('fullpath')),filesep,'src',filesep,'ui']);

base_path = [fileparts(mfilename('fullpath')),filesep];
external_libraries_path = [base_path,'external',filesep];

% Make sure directory for external libraries exists.
if ~exist([base_path,'external'],'dir'),
	mkdir(base_path,'external');
end


% RASTAMAT by Dan Ellis
if(~exist([external_libraries_path,filesep,'rastamat'],'dir')),
	section_header('Install::Rastamat');
	rastamat_path = [external_libraries_path,'rastamat'];
	url = 'http://labrosa.ee.columbia.edu/matlab/rastamat/rastamat.tgz';
	if exist(rastamat_path, 'file') == 0,
		files = untar(url,external_libraries_path);
	end
	foot();
end

% VOICEBOX by Mike Brookes
if(~exist([external_libraries_path,filesep,'voicebox'],'dir')),
	section_header('Install::Voicebox');
	voicebox_path = [external_libraries_path,'voicebox'];
	url = 'http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.zip';
	if exist(voicebox_path, 'file') == 0,
		files = unzip(url,voicebox_path);
	end
	foot();
end

% YAMLMatlab by Yauhen Yakimovich
if(~exist([external_libraries_path,filesep,'YAMLMatlab'],'dir')),
	section_header('Install::YAMLMatlab');
	yamlmatlab_path = [external_libraries_path,'YAMLMatlab'];
	url = 'https://github.com/ewiger/yamlmatlab/archive/master.zip';
	if exist(yamlmatlab_path, 'file') == 0,
		files = unzip(url,yamlmatlab_path);
		movefile([yamlmatlab_path,filesep,'yamlmatlab-master',filesep,'+yaml'],[yamlmatlab_path,filesep,'yamlmatlab-master',filesep,'yaml']);
	end
	foot();
end


% GetFullPath by Jan Simon
if(~exist([external_libraries_path,filesep,'GetFullPath'],'dir')),
	section_header('Install::GetFullPath');
	getfullpath_path = [external_libraries_path,'GetFullPath'];
	url = 'http://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/28249/versions/8/download/zip';
	
	if exist(getfullpath_path, 'file') == 0,		
		urlwrite(url,[external_libraries_path,'GetFullPath.zip']);
		files = unzip([external_libraries_path,'GetFullPath.zip'],getfullpath_path);
		delete([external_libraries_path,'GetFullPath.zip']);
	end
	foot();
end


% DataHash by Jan Simon
if(~exist([external_libraries_path,'DataHash'],'dir')),
	section_header('Install::DataHash');
	datahash_path = [external_libraries_path,'DataHash'];
	url = 'http://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/31272/versions/7/download/zip';
	
	if exist(datahash_path, 'file') == 0,		
		urlwrite(url,[external_libraries_path,'DataHash.zip']);
		files = unzip([external_libraries_path,'DataHash.zip'],datahash_path);
		delete([external_libraries_path,'DataHash.zip']);
	end
	foot();
end


% scattering.m by Vincent Lostanlen
if (~exist([external_libraries_path,'scattering.m'],'dir'))
    section_header('Install::scattering.m');
    scattering_path = [external_libraries_path,'scattering.m'];
	url = 'https://github.com/lostanlen/scattering.m/archive/master.zip';
    
	if exist(scattering_path, 'file') == 0		
		urlwrite(url,[external_libraries_path,'scattering.m.zip']);
		files = unzip([external_libraries_path,'scattering.m.zip'], ...
            scattering_path);
		delete([external_libraries_path,'scattering.m.zip']);
	end
	foot();
end


% LIBLINEAR by Chih-Jeng Lin
if (~exist([external_libraries_path,'LIBLINEAR'], 'dir'))
    section_header('Install::LIBLINEAR');
    liblinear_path = [external_libraries_path,'LIBLINEAR'];
    url = 'https://github.com/cjlin1/liblinear/archive/v210.zip';
    if exist(liblinear_path, 'file') == 0		
		urlwrite(url,[external_libraries_path,'v210.zip']);
		files = unzip([external_libraries_path,'v210.zip'],liblinear_path);
		delete([external_libraries_path,'v210.zip']);
        addpath(genpath([fileparts(mfilename('fullpath')), ...
            filesep,'external',filesep,'LIBLINEAR']));
        % Auto-compilation for UNIX systems
        system(['make -C ', liblinear_path, '/liblinear-210']);
	end
	foot();
end

% MatConvNet by Andrea Vedaldi
if (~exist([external_libraries_path,'MatConvNet'], 'dir'))
    section_header('Install::MatConvNet');
    matconvnet_path = [external_libraries_path, 'MatConvNet'];
    version = 'autodiff-stable.zip';
    url = ['https://github.com/vlfeat/matconvnet/archive', filesep, version];
    if exist(matconvnet_path, 'file') == 0
        urlwrite(url, [external_libraries_path, version]);
        files = unzip([external_libraries_path, version], matconvnet_path);
        delete([external_libraries_path, version]);
    end
    addpath([matconvnet_path, filesep, ...
        'matconvnet-autodiff-stable', filesep, 'matlab']);
    vl_setupnn();
    vl_compilenn('EnableImreadJpeg', false);
    foot();
end