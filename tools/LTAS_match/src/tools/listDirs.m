%LISTDIRS  List all sub-directories of directory and its sub-directories.
%   LISTDIRS('a_directory') lists the sub-directories in a directory and
%   its sub-directories up to a depth of four sub-directories. Pathnames
%   and wildcards may be used.
%   LISTDIRS('a_directory', 6) lists the sub-directories of a directory
%   and its sub-directories up to a depth of six sub-directories. Whereas
%   LISTDIRS('a_directory',-1) lists the sub-directories of all
%   existing sub-directories with infinite recursion. The default
%   recursion depth is to list files of up to four sub-directories.
%
%   D = LISTDIRS('a_directory') returns the results in an M-by-1
%   structure with the fields: 
%       name  -- filename (incl. the 'a_directory' path)
%       date  -- modification date
%       bytes -- number of bytes allocated to the file
%       isdir -- 1 if name is a directory and 0 if not
%
%   See also DIR, LISTFILES.

% Auth: Sven Fischer
% Vers: v0.821
function [ stDirList ] = listDirs(szCurDir, iRecursionDepth)

%-------------------------------------------------------------------------%
% Check input arguments.
error(nargchk(0,2,nargin));
% Check output arguments.
error(nargoutchk(0,1,nargout));
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% Check function arguments and set default values, if necessary.
%-------------------------------------------------------------------------%
if( (nargin<1) || (isempty(szCurDir       )) ), szCurDir        =  ''; end
if( (nargin<2) || (isempty(iRecursionDepth)) ), iRecursionDepth =   4; end
%-------------------------------------------------------------------------%

stDirList = dir( fullfile( szCurDir, '*' ) );
stDirList = stDirList( find( [stDirList.isdir] ) );
if( ~isempty(stDirList) )
    if( strcmp(stDirList(1).name,  '.') ), stDirList(1) = []; end
    if( strcmp(stDirList(1).name, '..') ), stDirList(1) = []; end
    for( k = [ 1 : length(stDirList) ] )
      stDirList(k).name = fullfile( szCurDir, stDirList(k).name );
    end
end

% If we have to process sub-directories recursively...
if( (iRecursionDepth > 0) || (iRecursionDepth == -1) )
    % Decrease recursion counter by one, if not set to infinite...
    if( iRecursionDepth > 0 ), iRecursionDepth = iRecursionDepth - 1; end

    % Get a list of all existing sub-directories (exclusive '.' and '..').
    stSubDirs = dir( szCurDir );
    stSubDirs = stSubDirs( find( [stSubDirs.isdir] ) );
    if( ~isempty(stSubDirs) )
        if( strcmp(stSubDirs(1).name,  '.') ), stSubDirs(1) = []; end
        if( strcmp(stSubDirs(1).name, '..') ), stSubDirs(1) = []; end

        % Process all subdirectories and append all each file list to the
        % list created above.
        for( k = [ 1 : length(stSubDirs) ] )
        	szSubDir = fullfile( szCurDir, stSubDirs(k).name);
            stDirList = [ stDirList; ...
                listDirs( szSubDir, iRecursionDepth) ];
        end
    end
end