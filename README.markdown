# Outback - a transactional shell runner

Outback is a simple ruby library for running transactional pairs of shell commands ("rollout/rollback") in a known sequence. It's useful for running a set of dependent commands one after another with the ability to stop, find out what's gone wrong, and rollback all the steps so far if something goes awry.
