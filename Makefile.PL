use inc::Module::Install;
name 'FCGI-Server-Lighttpd';
all_from 'lib/FCGI/Server/Lighttpd.pm';

test_requires 'Test::More';
test_requires 'CGI::Fast';

requires 'Moose';
requires 'MooseX::Getopt';

requires 'File::Which';
requires 'String::TT';
requires 'MIME::Types';

use_test_base;
auto_include;

install_script 'flight';

WriteAll;
