function spectrum = pes(outputfile)
%PES Return the photo-electron spectrum
%and save the results in a .mat file next to the output file.
%
%   Input:
%     outputfile
%   Output:
%     A 3D matrix, whose 3rd dimension is determined by lmax, mmin, and mmax.
%     The size of the first dimension is determined by nradial.
%     The second dimension consists of:
%       (Re[E],Im[E]),(Re[Wgt],Im[Wgt]),(Re[<I|wf>],Im[<I|wf>]),(Re[<wf|I>],Im[<wf|I>])


  [path, name, ~] = fileparts(outputfile);
  matfile = fullfile(path, [name, '.mat']);
  
  if exist(matfile, 'file')
    load(matfile, 'spectrum');
    
    if exist('spectrum', 'var')
      return;
    end
  end
  
  
  % load the parameters
  params = scid.extract.params(outputfile);
  

  f = fopen(outputfile);
  
  while ~feof(f)
    line = upper(fgetl(f));
    
    if (contains(line, 'LARGE AMPLITUDES OF INDIVIDUAL FIELD-FREE STATES'))
      for i = 1:3
        fgetl(f);
      end
      
      break;
    end
  end
  
  

  % size of the third dimension.
  d3size = scid.util.d3index(params);
  
  % preallocate
  spectrum = complex(zeros(params.nradial, 4, d3size));
  
  
  formatSpec = '%d %d %d %f %f %f %f %f %f %f %f';
  
  
  l = -1;
  line = fgetl(f);
  while ~isempty(line)
    a = sscanf(line, formatSpec);

    if (l ~= a(1))
      l = a(1);
      d3indexbase = scid.util.d3index(params, l, 0);
    end
    
    m = a(2);
    i = a(3);
    
    d3index = d3indexbase + m;
    spectrum(i, 1, d3index) = complex(a(4),a(5));
    spectrum(i, 2, d3index) = complex(a(6),a(7));
    spectrum(i, 3, d3index) = complex(a(8),a(9));
    spectrum(i, 4, d3index) = complex(a(10),a(11));
    
    line = fgetl(f);
  end
  
  fclose(f);
  
  
  
  % The states that aren't populated won't appear in Patchkowskii's
  % spectrum written in the output file. Therefore, I should add the
  % missing energies manually from the eigenvalue eigenvector files stored
  % under /data2/finite/mbaghery/SCID_****_***
  
  for l = 0:params.lmax

    f = fopen(sprintf('/data2/finite/mbaghery/SCID_%d_%.1f/cache/H-L=%05d', ...
          params.nradial, params.dr, l));

    % read the header that fortran puts at the beginning of files
    fread(f, 1, 'uint32');

    % read the eigenvalues
    energiesRaw = fread(f, 2 * params.nradial, 'float64');
    
    % combine the real and imaginary parts
    energies = complex(energiesRaw(1:2:end), energiesRaw(2:2:end));
    
    
    % The eigenfunctions of the hamiltonian are unique up to a phase. I know
    % that the SCID eigenfunctions are real (for whatever reason), and now I
    % want to make sure they are all positive at the origin. I do that by
    % multiplying the corrsponding value in the spectrum with the sign of the
    % eigenfunction at the origin.
    signs = zeros(params.nradial, 1);
    
    for i = 1:params.nradial
      eigenvector = fread(f, 1, 'float64');
      fseek(f, (2 * params.nradial - 1) * 8, 'cof'); % float64 takes up 8 bytes
      signs(i) = sign(eigenvector(1));
    end
    
    fclose(f);
    
    
    d3indexbase = scid.util.d3index(params, l, 0);
    
    for m = max(-l, params.mmin):min(l, params.mmax)
      spectrum(:,1,d3indexbase+m) = energies;
      spectrum(:,3:4,d3indexbase+m) = spectrum(:,3:4,d3indexbase+m) .* signs;
    end
    
  end
  
  
  % for the continuum part the density should be used
  for d3index = 1:d3size
    % excluding the bound part:
    indeces = real(spectrum(:,1,d3index))>=0;
    energyDensity = [ones(sum(~indeces,1),1);
           diff(real(spectrum( indeces,1,d3index)))];
    
    energyDensity = [energyDensity; energyDensity(end)];
    
    spectrum(:,2,d3index) = spectrum(:,2,d3index) ./ energyDensity;
    spectrum(:,3,d3index) = spectrum(:,3,d3index) ./ sqrt(energyDensity);
    spectrum(:,4,d3index) = spectrum(:,4,d3index) ./ sqrt(energyDensity);
  end
  
  
  
  if exist(matfile, 'file')
    save(matfile, 'spectrum', '-append');
  else
    save(matfile, 'spectrum');
  end

end
