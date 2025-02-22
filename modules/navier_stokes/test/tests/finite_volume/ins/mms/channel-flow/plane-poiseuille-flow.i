mu=0.5
rho=1.1
advected_interp_method='average'
velocity_interp_method='average'
two_term_boundary_expansion=true

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 10
    ymin = -1
    ymax = 1
    nx = 10
    ny = 2
  []
[]

[Problem]
  fv_bcs_integrity_check = true
[]

[Variables]
  [u]
    type = INSFVVelocityVariable
    initial_condition = 1
    two_term_boundary_expansion = ${two_term_boundary_expansion}
  []
  [v]
    type = INSFVVelocityVariable
    initial_condition = 1
    two_term_boundary_expansion = ${two_term_boundary_expansion}
  []
  [pressure]
    type = INSFVPressureVariable
    two_term_boundary_expansion = ${two_term_boundary_expansion}
  []
[]

[FVKernels]
  [mass]
    type = INSFVMassAdvection
    variable = pressure
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    vel = 'velocity'
    pressure = pressure
    u = u
    v = v
    mu = ${mu}
    rho = ${rho}
  []
  [mass_forcing]
    type = FVBodyForce
    variable = pressure
    function = forcing_p
  []

  [u_advection]
    type = INSFVMomentumAdvection
    variable = u
    advected_quantity = 'rhou'
    vel = 'velocity'
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    pressure = pressure
    u = u
    v = v
    mu = ${mu}
    rho = ${rho}
  []
  [u_viscosity]
    type = FVDiffusion
    variable = u
    coeff = ${mu}
  []
  [u_pressure]
    type = INSFVMomentumPressure
    variable = u
    momentum_component = 'x'
    p = pressure
  []
  [u_forcing]
    type = FVBodyForce
    variable = u
    function = forcing_u
  []

  [v_advection]
    type = INSFVMomentumAdvection
    variable = v
    advected_quantity = 'rhov'
    vel = 'velocity'
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    pressure = pressure
    u = u
    v = v
    mu = ${mu}
    rho = ${rho}
  []
  [v_viscosity]
    type = FVDiffusion
    variable = v
    coeff = ${mu}
  []
  [v_pressure]
    type = INSFVMomentumPressure
    variable = v
    momentum_component = 'y'
    p = pressure
  []
  [v_forcing]
    type = FVBodyForce
    variable = v
    function = forcing_v
  []
[]

[FVBCs]
  [inlet-u]
    type = INSFVInletVelocityBC
    boundary = 'left'
    variable = u
    function = 'exact_u'
  []
  [inlet-v]
    type = INSFVInletVelocityBC
    boundary = 'left'
    variable = v
    function = 'exact_v'
  []
  [walls-u]
    type = INSFVNoSlipWallBC
    variable = u
    boundary = 'top bottom'
    function = 'exact_u'
  []
  [walls-v]
    type = INSFVNoSlipWallBC
    variable = v
    boundary = 'top bottom'
    function = 'exact_v'
  []
  [outlet_p]
    type = INSFVOutletPressureBC
    boundary = 'right'
    variable = pressure
    function = 'exact_p'
  []
[]

[Materials]
  [ins_fv]
    type = INSFVMaterial
    u = 'u'
    v = 'v'
    pressure = 'pressure'
    rho = ${rho}
  []
[]

[Functions]
[exact_u]
  type = ParsedFunction
  value = '0.5*(1.0 - y^2)/mu'
  vars = 'mu'
  vals = '${mu}'
[]
[exact_rhou]
  type = ParsedFunction
  value = '0.5*rho*(1.0 - y^2)/mu'
  vars = 'mu rho'
  vals = '${mu} ${rho}'
[]
[forcing_u]
  type = ParsedFunction
  value = '0'
  vars = 'mu rho'
  vals = '${mu} ${rho}'
[]
[exact_v]
  type = ParsedFunction
  value = '0.0'
[]
[exact_rhov]
  type = ParsedFunction
  value = '0'
  vars = 'mu rho'
  vals = '${mu} ${rho}'
[]
[forcing_v]
  type = ParsedFunction
  value = '0'
  vars = 'mu rho'
  vals = '${mu} ${rho}'
[]
[exact_p]
  type = ParsedFunction
  value = '10.0 - x'
[]
[forcing_p]
  type = ParsedFunction
  value = '0'
  vars = 'rho mu'
  vals = '${rho} ${mu}'
[]
[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_pc_type -sub_pc_factor_shift_type'
  petsc_options_value = 'asm      100                lu           NONZERO'
  line_search = 'none'
[]

[Outputs]
  exodus = true
  csv = true
  [dof]
    type = DOFMap
    execute_on = 'initial'
  []
[]

[Postprocessors]
  [h]
    type = AverageElementSize
    outputs = 'console csv'
    execute_on = 'timestep_end'
  []
  [./L2u]
    type = ElementL2Error
    variable = u
    function = exact_u
    outputs = 'console csv'
    execute_on = 'timestep_end'
  [../]
  [./L2v]
    type = ElementL2Error
    variable = v
    function = exact_v
    outputs = 'console csv'
    execute_on = 'timestep_end'
  [../]
  [./L2p]
    variable = pressure
    function = exact_p
    type = ElementL2Error
    outputs = 'console csv'
    execute_on = 'timestep_end'
  [../]
[]
