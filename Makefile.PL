use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'PM' => {
       'Base.pm' => '$(INST_LIBDIR)/Base.pm',
       'Length.pm' => '$(INST_LIBDIR)/Length.pm'  
     },
    'NAME'	=> 'Units::Length',
    'VERSION_FROM' => 'Length.pm'
);

