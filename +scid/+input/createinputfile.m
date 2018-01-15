function createinputfile(inputfile, params)
%CREATEINPUTFILE create the input file for SCID.
%
%   Input:
%     inputfile, params
%   Output:
%     nothing. The input file is saved at the given adress, i.e. inputfile.
%
%
% Here are the fields of the input structure:
%  params.no_cpu = 4;
%  
%  params.nradial = 10000;
%  params.dr = 0.4;
%  params.lmax = 25;
%  
%  
%  *initial state*
%  params.init_l = 0;
%  params.init_m = 0;
%  params.init_i = 1;
%  
%  
%  *first pulse*
%  params.A0 = ;
%  params.omega = ;
%  params.FWHM = ;
%  params.phase = ;
%  params.midlaser = 2.5 * params.FWHM;
%  params.weights = ;
%  
%  
%  *second pulse*
%  params.A0_x = ;
%  params.omega_x = ;
%  params.FWHM_x = ;
%  params.phase_x = ;
%  params.midlaser_x = 2.5 * params.FWHM_x;
%  params.weights_x = ;
%  
%  
%  *Multicolor parameters*
%  params.amplitudes = ;
%  params.phases = ;
%  params.omegas = ;
%  
%  
%  params.dt = 0.01;
%  params.pulseshape = 'z 2QHOStates';
%  params.simlength = 5 * max(params.FWHM, params.FWHM_x);
%  
%  
%  *complex apsorbing potential*
%  params.cap_name = 'manolopoulos'; % or 'none'
%  params.cap_param = [0.2, 0.2]; % k_min, delta
%  
%  
%  params.wf_dump_prefix = 'wfn/wf';



  if ~isfield(params, 'amplitudes')
    params.amplitudes = 0;
  end
  
  if ~isfield(params, 'weights')
    params.weights = 0;
  end
  
  if ~isfield(params, 'weights_x')
    params.weights_x = 0;
  end
  
  if (length(params.amplitudes) < 5)
    params.amplitudes(5) = 0;
    params.omegas(5) = 0;
    params.phases(5) = 0;
  end
  
  if (length(params.weights) < 10)
    params.weights(10) = 0;
  end
  
  if (length(params.weights_x) < 10)
    params.weights_x(10) = 0;
  end
  
  
  
  
  inputfilestream = {
    '&sph_tdse'
    'comment = "linear polarization, linear grid"'
    'verbose = 1,'
    sprintf('omp_num_threads = %d,', params.no_cpu)
    sprintf('dt = %f,', params.dt)
    sprintf('timesteps = %d,', round(params.simlength / params.dt))
    'initial_wfn = ''atomic'','
    sprintf('initial_wfn_index = %d, %d, %d,', ...
            params.init_l, params.init_m, params.init_i)
    sprintf('sd_lmax = %d,', params.lmax)
    sprintf('sd_nradial = %d,', params.nradial)
    sprintf('sd_rgrid_dr = %f,', params.dr)
    sprintf('sd_mmin = %d,', params.mmin)
    sprintf('sd_mmax = %d,', params.mmax)
    'sd_rgrid = ''uniform'','
    'sd_rgrid_zeta = 1.0,'
    'field_unwrap = .true.'
    'rotation_mode = ''auto'','
    'dt_subdivision = ''off'','
    'vp_as_is = .true.,'
    'pot_name = ''hydrogenic'','
    'pot_param = 1.0,'
    'task = ''real time'','
    sprintf('cap_name = ''%s'',', params.cap_name)
    sprintf('cap_param = (%f, %f)', params.cap_param(1), params.cap_param(2))
    'pt_mix_solver = ''default'','
    'bicg_epsilon = 0,'
    'skip_tests = .T.'
    'output_each = 20,'
    'composition_threshold = 1e-10,'
    'initial_wf_dump_prefix = '' '','
    'field_preview = '' '','
    sprintf('detail_output = ''%s'',', params.detail_output)
    sprintf('final_wf_dump_prefix = ''%s'',', params.wf_dump_prefix)
    sprintf('wt_atomic_cache_prefix = ''/data2/finite/mbaghery/SCID_%d_%.1f/cache/H'',', ...
            params.nradial, params.dr)
    sprintf('vp_shape = ''%s'',', params.pulseshape)
    sprintf('vp_scale = %f,', params.A0)
    };
  
  
  if strcmp(params.pulseshape, 'z QHOStates')
    inputfilestream = [inputfilestream;
      sprintf('vp_param(1:4) = %f, %f, %f, %f', ...
      params.omega, params.phase, params.midlaser, params.FWHM)
      ['vp_param(11:20) = ', sprintf('%f, ', params.weights)]];

  elseif any(strcmp(params.pulseshape, {'z 2QHOStates', 'z 2Sin4', ...
                                        'xy Sin4Cir-Lin', 'xy Sin4Cir-Cir'}))
    inputfilestream = [inputfilestream;
      sprintf('vp_param(1:4) = %f, %f, %f, %f', ...
      params.omega, params.phase, params.midlaser, params.FWHM)
      ['vp_param(11:20) = ', sprintf('%f, ', params.weights)]
      sprintf('vp_scale_x = %f,', params.A0_x)
      sprintf('vp_param_x(1:4) = %f, %f, %f, %f', ...
      params.omega_x, params.phase_x, params.midlaser_x, params.FWHM_x)
      ['vp_param_x(11:20) = ', sprintf('%f, ', params.weights_x)]];
  
  elseif strcmp(params.pulseshape, 'z Multicolor')
    inputfilestream = [inputfilestream;
      sprintf('vp_param(1:4) = 0, 0, %f, %f', params.midlaser, params.FWHM)
      ['vp_param(6:10) = ', sprintf('%f, ', params.amplitudes)]
      ['vp_param(11:15) = ', sprintf('%f, ', params.omegas)]
      ['vp_param(16:20) = ', sprintf('%f, ', params.phases)]];
  end


  inputfilestream = [inputfilestream; '/'];
  inputfilestream = strjoin(inputfilestream, '\n');
  
  
  f = fopen(inputfile, 'w');
  fprintf(f, '%s', inputfilestream);
  fclose(f);

end
