#!/usr/bin/env perl
# Set the input (STDIN) as UTF8, but don't give warnings about unknown chars
use open qw(:std :utf8); # http://stackoverflow.com/a/519359
no warnings 'utf8';

# Set the output to always be UTF8
binmode STDOUT,':encoding(UTF-8)';
		print file_change_string($file_1,$file_2) . "\n";
	################################
	# Look for binary file changes #
	################################
	} elsif ($line =~ /^Binary files (\w\/)?(.+?) and (\w\/)?(.+?) differ/) {
		my $change = file_change_string($2,$4);
		print "$horizontal_color$change (binary)\n";
	my ($o_ofs, $o_cnt, $n_ofs, $n_cnt) = $line =~ /^\@\@+(?: -(\d+)(?:,(\d+))?)+ \+(\d+)(?:,(\d+))? \@\@+/;
	my $search_key    = lc($_[0] || "");
	my $default_value = lc($_[1] || "");
		return $raw->{$search_key} || $default_value;
	my $search_key    = lc($_[0] || "");
	my $default_value = lc($_[1] || 0); # Default to false
sub get_less_charset {
	my @less_char_vars = ("LESSCHARSET", "LESSCHARDEF", "LC_ALL", "LC_CTYPE", "LANG");
	foreach (@less_char_vars) {
		return $ENV{$_} if defined $ENV{$_};
	}

	return "";
}

sub should_print_unicode {
	if (-t STDOUT) {
		# Always print unicode chars if we're not piping stuff, e.g. to less(1)
		return 1;
	}

	# Otherwise, assume we're piping to less(1)
	my $less_charset = get_less_charset();
	if ($less_charset =~ /utf-?8/i) {
		return 1;
	}

	return 0;
}

		$p = $p->{$_} ||= {} for @path;
	my $dash;
	if (should_print_unicode()) {
		$dash = "\x{2500}";
	} else {
		$dash = "-";
	}

sub file_change_string {
	my $file_1 = shift();
	my $file_2 = shift();

	# If they're the same it's a modify
	if ($file_1 eq $file_2) {
		return "modified: $file_1";
	# If the first is /dev/null it's a new file
	} elsif ($file_1 eq "/dev/null") {
		return "added: $file_2";
	# If the second is /dev/null it's a deletion
	} elsif ($file_2 eq "/dev/null") {
		return "deleted: $file_1";
	# If the files aren't the same it's a rename
	} elsif ($file_1 ne $file_2) {
		return "renamed: $file_1 to $file_2";
	# Something we haven't thought of yet
	} else {
		return "$file_1 -> $file_2";
	}
}