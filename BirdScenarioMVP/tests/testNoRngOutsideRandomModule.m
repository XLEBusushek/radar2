% testNoRngOutsideRandomModule - Production code must not seed RNG directly.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

allowedFolders = {
    fullfile(projectRoot, 'random')
    fullfile(projectRoot, 'tests')
};

files = dir(fullfile(projectRoot, '**', '*.m'));
violations = strings(0, 1);
for i = 1:numel(files)
    filePath = fullfile(files(i).folder, files(i).name);
    if isAllowedPath(filePath, allowedFolders)
        continue;
    end

    text = fileread(filePath);
    if contains(text, 'rng(')
        violations(end + 1) = string(filePath); %#ok<SAGROW>
    end
end

assert(isempty(violations), ...
    'Found unmanaged rng calls outside random/tests: %s', strjoin(violations, ', '));

disp('testNoRngOutsideRandomModule passed.');

function allowed = isAllowedPath(filePath, allowedFolders)
allowed = false;
for j = 1:numel(allowedFolders)
    folder = allowedFolders{j};
    if startsWith(filePath, folder)
        allowed = true;
        return;
    end
end
end
