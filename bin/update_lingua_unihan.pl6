#!/usr/bin/env perl6

use v6;
use DBIish;

## build SQLite
unlink("unihan.sqlite3") if "unihan.sqlite3".IO ~~ :e;
my $dbh = DBIish.connect("SQLite", :database<unihan.sqlite3>, :RaiseError);

my $sth = $dbh.do(q:to/STATEMENT/);
    CREATE TABLE unihan (
        code_point  varchar(5),
        field_type  varchar(30),
        value    text,
        PRIMARY KEY (code_point, field_type)
    )
    STATEMENT

$sth = $dbh.prepare(q:to/STATEMENT/);
    INSERT INTO unihan (code_point, field_type, value)
    VALUES ( ?, ?, ? )
    STATEMENT

my @files = <Unihan_Readings.txt Unihan_DictionaryLikeData.txt>;
for @files -> $file {
    my $fh = open($file, :r)
        or die "Could not open $file for reading $!\n";
    for $fh.lines -> $line {
        next if $line ~~ /^\#/; # skip comment line
        next unless $line ~~ /\w/;
        # U+3400  kMandarin       qiū
        my @parts = $line.split(/\s+/, 3);
        next if @parts.elems < 3;
        $parts[0].subst(/^U\+/, '');
        say @parts.perl;
        $sth.execute(@parts);
    }
}

$sth.finish;
$dbh.disconnect;
