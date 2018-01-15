function wf = truncbound(wf, params)
%TRUNCBOUND Truncate the bound part of the wavefunction.
%
%   Input:
%       wf: the wave function
%       params: the parameters from the output file
%   Output:
%       wf: the wave function with its bound part removed


  
  for l = 0:params.lmax

    f = fopen(sprintf('/data2/finite/mbaghery/SCID_%d_%.1f/cache/H-L=%05d', ...
             params.nradial, params.dr, l));

    % read the header that fortran puts at the beginning of files
    fread(f, 1, 'uint32');

    % read eigenvalues
    energies = fread(f, 2 * params.nradial, 'float64');
    % get rid of the imaginary part
    energies = energies(1:2:end);
    
    noBound = sum(energies < 0);
    
    lefteigenvector = complex(zeros(params.nradial, noBound));
    righteigenvector = complex(zeros(params.nradial, noBound));

    % read wf_l
    for i = 1:noBound
      temp = fread(f, 2 * params.nradial, 'float64');
      lefteigenvector(:,i) = complex(temp(1:2:end), temp(2:2:end));
    end
    
    % skip the rest of the states
    % float64 takes up 8 bytes
    fseek(f, (params.nradial - i) * 2 * params.nradial * 8, 'cof');
    
    % read wf_r: these start at nradial+1 all the way to EOF
    for i = 1:noBound
      temp = fread(f, 2 * params.nradial, 'float64');
      righteigenvector(:,i) = complex(temp(1:2:end), temp(2:2:end));
    end
    
    fclose(f);
    
    
    for m = max(-l, params.mmin):min(l, params.mmax)
      index3d = scid.util.d3index(params, l, m);

      for i = 1:noBound
        overlap = sum(lefteigenvector(:,i) .* wf(:,3,index3d));
        wf(:,3,index3d) = wf(:,3,index3d) - overlap * righteigenvector(:,i);

        overlap = sum(righteigenvector(:,i) .* wf(:,2,index3d));
        wf(:,2,index3d) = wf(:,2,index3d) - overlap * lefteigenvector(:,i);
      end
    end
    
    
  end

end
