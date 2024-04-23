#
#  NOTE: Makefile's target name should not be the same as one of the file or directory in the current directory, 
#    otherwise the target will not be executed!
#

############################################################################
#
#  Darwin related commands
#
############################################################################

deploy:
	$(MAKE) darwin

darwin:
	nix build .#darwinConfigurations.mercury.system \
		--extra-experimental-features 'nix-command flakes'

	./result/sw/bin/darwin-rebuild switch --flake .#mercury

darwin-debug:
	nix build .#darwinConfigurations.mercury.system --show-trace --verbose \
		--extra-experimental-features 'nix-command flakes'

	./result/sw/bin/darwin-rebuild switch --flake .#mercury --show-trace --verbose

############################################################################
#
#  nix related commands
#
############################################################################

update:
	nix flake update

update-commit: 
	nix flake update --commit-lock-file

history:
	nix profile history --profile /nix/var/nix/profiles/system

gc:
	# remove all generations older than 7 days
	sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

	# garbage collect all unused nix store entries
	sudo nix store gc --debug

# https://github.com/NixOS/nix/issues/7273#issuecomment-1450809740
optimise:
	nix store optimise

fmt:
	# format the nix files in this repo
	nix fmt

.PHONY: clean  
clean:  
	rm -rf result
