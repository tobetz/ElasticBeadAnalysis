function out = calcStress(E,nu,rho,radius,file_displacement,modelname)
%
% calcStress.m
%
% Model exported on Apr 24 2018, 15:19 by COMSOL 5.3.1.201.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create(modelname);

model.modelPath('/home/comsol/Documents/bernhard');

model.component.create('comp1', true);

model.component('comp1').geom.create('geom1', 3);

model.component('comp1').mesh.create('mesh1');

model.component('comp1').physics.create('solid', 'SolidMechanics', 'geom1');

model.study.create('std1');
model.study('std1').create('stat', 'Stationary');
model.study('std1').feature('stat').activate('solid', true);

model.component('comp1').geom('geom1').create('sph1', 'Sphere');
model.component('comp1').geom('geom1').lengthUnit([native2unicode(hex2dec({'00' 'b5'}), 'unicode') 'm']);
model.component('comp1').geom('geom1').feature('sph1').set('r', radius);
model.component('comp1').geom('geom1').runPre('fin');
model.component('comp1').geom('geom1').run('fin');

model.component('comp1').material.create('mat1', 'Common');
model.component('comp1').material('mat1').label('PAAGel');
model.component('comp1').material('mat1').propertyGroup('def').set('youngsmodulus', {num2str(E)});
model.component('comp1').material('mat1').propertyGroup('def').set('poissonsratio', {num2str(nu)});
model.component('comp1').material('mat1').propertyGroup('def').set('density', {num2str(rho)});

model.func.create('int1', 'Interpolation');
model.func('int1').set('source', 'file');
model.func('int1').set('filename', file_displacement);
model.func('int1').setIndex('funcs', 'f1', 0, 0);
model.func('int1').setIndex('funcs', 'f2', 1, 0);
model.func('int1').setIndex('funcs', 'f3', 2, 0);
model.func('int1').setIndex('funcs', 2, 1, 1);
model.func('int1').setIndex('funcs', 3, 2, 1);
model.func('int1').importData;

model.component('comp1').physics('solid').create('disp1', 'Displacement2', 2);
model.component('comp1').physics('solid').feature('disp1').setIndex('Direction', true, 0);
model.component('comp1').physics('solid').feature('disp1').setIndex('U0', 'f1(x,yz,)', 0);
model.component('comp1').physics('solid').feature('disp1').setIndex('U0', 'f1(x,y,z)', 0);
model.component('comp1').physics('solid').feature('disp1').setIndex('Direction', true, 1);
model.component('comp1').physics('solid').feature('disp1').setIndex('U0', 'f2(x,y,z)', 1);
model.component('comp1').physics('solid').feature('disp1').setIndex('Direction', true, 2);
model.component('comp1').physics('solid').feature('disp1').setIndex('U0', 'f3(x,y,z)', 2);

model.func('int1').set('argunit', [native2unicode(hex2dec({'00' 'b5'}), 'unicode') 'm']);
model.func('int1').set('fununit', [native2unicode(hex2dec({'00' 'b5'}), 'unicode') 'm']);

model.component('comp1').physics('solid').feature('disp1').selection.all;
model.component('comp1').mesh('mesh1').autoMeshSize(3);
model.component('comp1').mesh('mesh1').run;

model.sol.create('sol1');
model.sol('sol1').study('std1');

model.study('std1').feature('stat').set('notlistsolnum', 1);
model.study('std1').feature('stat').set('notsolnum', '1');
model.study('std1').feature('stat').set('listsolnum', 1);
model.study('std1').feature('stat').set('solnum', '1');

model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').feature('st1').set('study', 'std1');
model.sol('sol1').feature('st1').set('studystep', 'stat');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').feature('v1').set('control', 'stat');
model.sol('sol1').create('s1', 'Stationary');
model.sol('sol1').feature('s1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').feature('fc1').set('termonres', 'auto');
model.sol('sol1').feature('s1').feature('fc1').set('reserrfact', 1000);
model.sol('sol1').feature('s1').create('d1', 'Direct');
model.sol('sol1').feature('s1').feature('d1').set('linsolver', 'mumps');
model.sol('sol1').feature('s1').feature('d1').label('Suggested Direct Solver (solid)');
model.sol('sol1').feature('s1').create('i1', 'Iterative');
model.sol('sol1').feature('s1').feature('i1').set('linsolver', 'gmres');
model.sol('sol1').feature('s1').feature('i1').set('rhob', 400);
model.sol('sol1').feature('s1').feature('i1').set('nlinnormuse', true);
model.sol('sol1').feature('s1').feature('i1').label('Suggested Iterative Solver (solid)');
model.sol('sol1').feature('s1').feature('i1').create('mg1', 'Multigrid');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').set('prefun', 'gmg');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('pr').create('so1', 'SOR');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('pr').feature('so1').set('relax', 0.8);
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('po').create('so1', 'SOR');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('po').feature('so1').set('relax', 0.8);
model.sol('sol1').feature('s1').feature('fc1').set('linsolver', 'd1');
model.sol('sol1').feature('s1').feature('fc1').set('termonres', 'auto');
model.sol('sol1').feature('s1').feature('fc1').set('reserrfact', 1000);
model.sol('sol1').feature('s1').feature.remove('fcDef');
model.sol('sol1').attach('std1');

model.result.create('pg1', 'PlotGroup3D');
model.result('pg1').set('data', 'dset1');
model.result('pg1').create('surf1', 'Surface');
model.result('pg1').feature('surf1').set('expr', {'solid.mises'});
model.result('pg1').label('Stress (solid)');
model.result('pg1').feature('surf1').set('colortable', 'RainbowLight');
model.result('pg1').feature('surf1').set('resolution', 'normal');
model.result('pg1').feature('surf1').create('def', 'Deform');
model.result('pg1').feature('surf1').feature('def').set('expr', {'u' 'v' 'w'});
model.result('pg1').feature('surf1').feature('def').set('descr', 'Displacement field');

model.sol('sol1').runAll;

model.result('pg1').run;

model.label('calcStress.mph');

model.result('pg1').run;
model.result('pg1').run;
model.result('pg1').feature('surf1').set('data', 'none');
model.result('pg1').run;
model.result('pg1').set('edgecolor', 'custom');

out = model;
