animal = 'Dog'
region = 'SC'
date   = '20161025'
datafolder = '/Users/taduv_admin/data/test2/s_20161025_tung_dogspinalcord_rescan1';
%%
%%-------------------------------------------------------------------------
%%-------------------------------------------------------------------------
% FORMAT: {'FOLDER',{'SUBFOLDER',{'keyword','value','param','value/rename'},'SUBFOLDER',{'keyword','value','param','value'}},{'keyword','value','param','value'},...}
copytype = {'qMT',{'SIRFSE',{'keyword','*sirfse*'   ,'param',{'ti'}},...
                     'SPGR',{'keyword','qMT_*'      ,'param',{'mtfrq','flipmt/mtflip','tr','te'}},...
                  },...
      'fieldsmap',    {'B0',{'keyword','b0_mapping*','param',{'te/te1','te2'}},...
                       'B1',{'keyword','*b1map_MFA*','param',{'flip1/flipangle'}}
                      },...
	         'T1',          {'keyword','*t1map*'    ,'param',{'ti'}},...
  'ProtonDensity',          {'keyword','*MTV*'      ,'param',{'flip1/flipangle','tr','te'}},...
             'T2',          {'keyword','*MWF*'      ,'param',{'flip1/flipangle','tr','te','ne/nechos','nt/averages'}},...
           };

%%
%%-------------------------------------------------------------------------
% create folder
mkdir(animal)
cd(animal)
mkdir(region)
cd(region)
mkdir(date)
cd(date)

% organize
organizeqmr(copytype,datafolder)

cd ../../../
