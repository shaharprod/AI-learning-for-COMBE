#!/usr/bin/perl
# Rebrand content copied from AI-learning-for-ALL to the COMBE site (V1.3).
# Run from the repo root (Git Bash):  perl tools/rebrand_from_all.pl
use strict;
use warnings;
use utf8;
use File::Find;

my $HE = 'מחלקת ההדרכות של חברת קומבה - COMBE';
my $EN = 'the COMBE Training Department';
my $AR = 'قسم التدريب في شركة COMBE';
my $HI = 'COMBE कंपनी के प्रशिक्षण विभाग';
my $RU = 'отдела обучения компании COMBE';

my @R = (
    # Full sentences in legal pages (most specific first)
    ['साइट हर किसी के लिए बनी है जो सीखना चाहता है', "साइट $HI के लिए बनी है"],
    ['بُني الموقع لكل من يريد أن يتعلم', "بُني الموقع ل$AR"],
    ['Сайт создан для всех, кто хочет учиться', "Сайт создан для $RU"],
    ['The site was built for anyone who wants to learn', "The site was built for $EN"],
    # Dedication line (header, footer, <title>, meta)
    ['נבנה עבור כל מי שרוצה ללמוד', "נבנה עבור $HE"],
    ['Built for anyone who wants to learn', "Built for $EN"],
    ['built for anyone who wants to learn', "built for $EN"],
    ['بُني لكل من يريد أن يتعلم', "بُني ل$AR"],
    ['हर किसी के लिए जो सीखना चाहता है', "$HI के लिए निर्मित"],
    ['Создано для всех, кто хочет учиться', "Создано для $RU"],
    # Site name + URLs
    ['AI-learning-for-ALL', 'AI-learning-for-COMBE'],
);

my %skip_file = map { $_ => 1 } qw(rebrand_from_all.pl rebrand_combe.py CLAUDE.MD AGENTS.md TASKS.md);
my $changed = 0;

find({ no_chdir => 1, wanted => sub {
    my $p = $File::Find::name;
    if (-d $p) {
        $File::Find::prune = 1 if $p =~ m{/(\.git|\.snapshots)$} || $p =~ m{בסיס קוורק ב$};
        return;
    }
    return unless $p =~ /\.(html|js|css|xml|ya?ml|py|md|txt|json)$/i;
    my ($name) = $p =~ m{([^/]+)$};
    return if $skip_file{$name} || $name =~ /^VERSION-/;
    open my $fh, '<:raw', $p or die "$p: $!";
    local $/; my $raw = <$fh>; close $fh;
    my $t = $raw; utf8::decode($t);
    my $o = $t;
    $t =~ s/\Q$_->[0]\E/$_->[1]/g for @R;
    $t =~ s/\bV0\.1\b/V1.3/g;
    if ($t ne $o) {
        utf8::encode($t);
        open my $out, '>:raw', $p or die "$p: $!"; print $out $t; close $out;
        $changed++;
    }
}}, '.');
print "Updated $changed files\n";
