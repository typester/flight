use inc::Module::Install;
name 'FCGI-Server-Lighttpd';
all_from 'lib/FCGI/Server/Lighttpd.pm';

test_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
