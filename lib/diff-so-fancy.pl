use utf8;
binmode STDOUT,':utf8';

my $change_hunk_indicators    = git_config_boolean("diff-so-fancy.changeHunkIndicators","true");
my $strip_leading_indicators  = git_config_boolean("diff-so-fancy.stripLeadingSymbols","true");
my $mark_empty_lines          = git_config_boolean("diff-so-fancy.markEmptyLines","true");
my $horizontal_color = "";
my $in_hunk = 0;
	# Pre-process the line before we do any other markup #
	# End pre-processing #
	####################################################################
	# Look for git index and replace it horizontal line (header later) #
	####################################################################
	if ($line =~ /^${ansi_color_regex}index /) {
		# Print the line color and then the actual line
		$horizontal_color = $1;
		print horizontal_rule($horizontal_color);
	} elsif ($line =~ /^${ansi_color_regex}diff --(git|cc) (.*?)(\s|\e|$)/) {
		$last_file_seen =~ s|^\w/||; # Remove a/ (and handle diff.mnemonicPrefix).
		$in_hunk = 0;
	} elsif (!$in_hunk && $line =~ /^$ansi_color_regex--- (\w\/)?(.+?)(\e|\t|$)/) {
		$next    =~ /^$ansi_color_regex\+\+\+ (\w\/)?(.+?)(\e|\t|$)/;

		# Print out the bottom horizontal line of the header
		print horizontal_rule($horizontal_color);
		$in_hunk = 1;
	######################################
	# Look for binary file changes
	######################################
	} elsif ($line =~ /Binary files \w\/(.+?) and \w\/(.+?) differ/) {
		print "${horizontal_color}modified: $2 (binary)\n";
		print horizontal_rule($horizontal_color);
		# Mark empty line with a red/green box indicating addition/removal
		if ($mark_empty_lines) {
			$line = mark_empty_line($line);
		}

		# Remove the correct number of leading " " or "+" or "-"
		if ($strip_leading_indicators) {
			$line = strip_leading_indicators($line,$columns_to_remove);
		}
# Mark the first char of an empty line
# String to boolean
sub boolean {
	my $str = shift();
	$str    = trim($str);

	if ($str eq "" || $str =~ /^(no|false|0)$/i) {
		return 0;
	} else {
		return 1;
	}
}

# Memoize getting the git config
{
	my $static_config;

	sub git_config_raw {
		if ($static_config) {
			# If we already have the config return that
			return $static_config;
		}

		my $cmd = "git config --list";
		my @out = `$cmd`;

		$static_config = \@out;

		return \@out;
	}
}

# Fetch a textual item from the git config
sub git_config {
	my $search_key    = lc($_[0] // "");
	my $default_value = lc($_[1] // "");

	my $out = git_config_raw();

	# If we're in a unit test, use the default (don't read the users config)
	if (in_unit_test()) {
		return $default_value;
	}

	my $raw = {};
	foreach my $line (@$out) {
		if ($line =~ /=/) {
			my ($key,$value) = split("=",$line,2);
			$value =~ s/\s+$//;
			$raw->{$key} = $value;
		}
	}

	# If we're given a search key return that, else return the hash
	if ($search_key) {
		return $raw->{$search_key} // $default_value;
	} else {
		return $raw;
	}
}

# Fetch a boolean item from the git config
sub git_config_boolean {
	my $search_key    = lc($_[0] // "");
	my $default_value = lc($_[1] // 0); # Default to false

	# If we're in a unit test, use the default (don't read the users config)
	if (in_unit_test()) {
		return $default_value;
	}

	my $result = git_config($search_key,$default_value);
	my $ret    = boolean($result);

	return $ret;
}

# Check if we're inside of BATS
sub in_unit_test {
	if ($ENV{BATS_CWD}) {
		return 1;
	} else {
		return 0;
	}
}

sub get_git_config_hash {
	my $out = git_config_raw();
	foreach my $line (@$out) {
# Remove all ANSI codes from a string

# Remove all trailing and leading spaces
sub trim {
	my $s = shift();
	if (!$s) { return ""; }
	$s =~ s/^\s*|\s*$//g;

	return $s;
}

# Print a line of em-dash or line-drawing chars the full width of the screen
sub horizontal_rule {
	my $color = $_[0] || "";
	my $width = `tput cols`;
	my $uname = `uname -s`;

	if ($uname =~ /MINGW32|MSYS/) {
		$width--;
	}

	# em-dash http://www.fileformat.info/info/unicode/char/2014/index.htm
	#my $dash = "\x{2014}";
	# BOX DRAWINGS LIGHT HORIZONTAL http://www.fileformat.info/info/unicode/char/2500/index.htm
	my $dash = "\x{2500}";

	# Draw the line
	my $ret = $color . ($dash x $width) . "\n";

	return $ret;
}