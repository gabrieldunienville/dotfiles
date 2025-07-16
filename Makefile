PACKAGES := zsh git vim tmux

# Dictionary-like structure: package:target pairs
STOW_PACKAGES := \
	claude:${HOME}/.claude \
	git:${HOME} \
	httpie:${HOME}/.config/httpie \
	mcphub:${HOME}/.config/mcphub \
	ipython:${HOME}/.ipython \
	obsidian:${HOME} \
	tmux:${HOME} \
	custom-scripts:${HOME}/.local/bin \
	zsh:${HOME} \

.PHONY: debug install uninstall

debug:
	# Test iteration over STOW_PACKAGES
	@$(foreach pkg_target,$(STOW_PACKAGES), \
		$(eval pkg := $(word 1,$(subst :, ,$(pkg_target)))) \
		$(eval target := $(word 2,$(subst :, ,$(pkg_target)))) \
		echo "Package: $(pkg), Target: $(target)" ; \
	)


install:
	@$(foreach pkg_target,$(STOW_PACKAGES), \
		$(eval pkg := $(word 1,$(subst :, ,$(pkg_target)))) \
		$(eval target := $(word 2,$(subst :, ,$(pkg_target)))) \
		mkdir -p "$(target)" && \
		echo "Installing $(pkg) to $(target)" ; \
		stow --target="$(target)" $(pkg) ; \
	)

uninstall:
	@$(foreach pkg_target,$(STOW_PACKAGES), \
		$(eval pkg := $(word 1,$(subst :, ,$(pkg_target)))) \
		$(eval target := $(word 2,$(subst :, ,$(pkg_target)))) \
		echo "Uninstalling $(pkg) from $(target)" ; \
		stow --target="$(target)" --del $(pkg) ; \
	)

