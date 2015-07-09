package Confidence::Interval;

=head1 NAME

=head1 DESCRIPTION

Pure perl implementations of good binomial proportion confidence intervals.
Good means, not the naive bayesian confidence interval, which is usually used.

=head1 SEE ALSO

L<http://www.evanmiller.org/how-not-to-sort-by-average-rating.html>,
L<https://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval#Wilson_score_interval>,
L<http://stackoverflow.com/questions/1687497/objective-c-implementation-of-the-wilson-score-interval>

=head1 FUNCTIONS

=head2 pnormaldist(qn)

Poisson binomial distribution

qn [0.0 .. 1.0] — success probabilities for each of the n trials.

The probability distribution of the number of successes in a sequence
of n independent yes/no experiments with success probabilities p1,
p2 .. pn. The ordinary binomial distribution is a special case
of the Poisson binomial distribution, when all success probabilities
are the same, that is p1 = p2 = ... = pn.

L<https://en.wikipedia.org/wiki/Poisson_binomial_distribution>

=cut
  
sub pnormaldist {
  my $qn = shift or die "Usage: pnormaldist([0.0 - 1.0])";
  if ($qn < 0.0 or $qn > 1.0) {
    die ("Error: qn <= 0 or qn >= 1 in pnormaldist()");
  }
  return 0.0 if $qn == 0.5;

  my @b = (1.570796288, 0.03706987906, -0.8364353589e-3, 
           -0.2250947176e-3, 0.6841218299e-5, 0.5824238515e-5, 
           -0.104527497e-5, 0.8360937017e-7, -0.3231081277e-8, 
           0.3657763036e-10, 0.6936233982e-12);
  my $w1 = $qn;
  if ($qn > 0.5) {
    $w1 = 1.0 - $w1;
  }
  my $w3 = -log(4.0 * $w1 * (1.0 - $w1));
  $w1 = $b[0];
  for (1..10) {
    $w1 += $b[$_] * ($w3 ** $_);
  }
  if ($qn > 0.5) {
    return sqrt($w1*$w3);
  }
  return -sqrt($w1*$w3); 
}

=head2 wilson_lower_bound(pos, n, power)

A good binomial proportion confidence interval, found 1927 by Edwin
B. Wilson.  This interval has good properties even for a small number
of trials and/or an extreme probability.

It is useful whenever you want to know with confidence what percentage
of people took some sort of action, e.g. to display "top ratings".

This is by far better than naive baysian with low number of trials.
The reddit people have no idea, that's why you can trick them so easily.
IMDB ditto, but this works better, because there are so many people, and they cut at <25000.
In my cases I need better confidence with ~5 trials.
The Jeffreys interval would be a bit better.

See L<https://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval#Wilson_score_interva>

=cut

sub wilson_lower_bound {
  die "Usage: wilson_lower_bound(\$pos, \$n, \$power)" unless @_ == 3;
  my ($pos, $n, $power) = @_;
  return 0 if $n == 0;
  my $z = pnormaldist(1-$power/2);
  my $phat = $pos/$n;
  ($phat + $z*$z/(2*$n) - $z * sqrt(($phat*(1-$phat)+$z*$z/(4*$n))/$n))/(1+$z*$z/$n);
}

1;
