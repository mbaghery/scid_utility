function wavefunction = wf(outputfile)
%WF Read the wave function files and combine them into a 3d matrix.
%Save the wave function in a .mat file next to the original file.
%
%   Input:
%     outputfile
%   Output:
%     wave function matrix:
%       1st and 2nd dimensions: r, left wfn (complex), right wfn (complex)
%       3rd dimension is determined by lmax, mmin, and mmax.


  [path,name,~] = fileparts(outputfile);
  matfile = fullfile(path, [name, '.mat']);
  
  if exist(matfile, 'file')
    load(matfile, 'wavefunction');
    
    if exist('wavefunction', 'var')
      return;
    end
  end
  

  % load the parameters
  params = scid.extract.params(outputfile);
  
  wfPrefix = fullfile(path, params.final_wf_prefix);

  
  d3size = scid.util.d3index(params);


  % second dimension has three components because:
  %   r, left wfn (complex), right wfn (complex)
  wavefunction = complex(zeros(params.nradial, 3, d3size));
  
  
  for l = 0:params.lmax
    d3indexbase = scid.util.d3index(params, l, 0);
    
    for m = max(-l, params.mmin):min(l, params.mmax)
      
    tmp = importdata(sprintf('%s-L%03d-M%+05d', wfPrefix, l, m), ' ', 1);
    
    d3index = d3indexbase + m;
    
    wavefunction(:,1,d3index) = tmp.data(:,2);
    wavefunction(:,2,d3index) = complex(tmp.data(:,3), tmp.data(:,4));
    wavefunction(:,3,d3index) = complex(tmp.data(:,5), tmp.data(:,6));
    
    end
  end
  
  
  if exist(matfile, 'file')
    save(matfile, 'wavefunction', '-append');
  else
    save(matfile, 'wavefunction');
  end
  
end

