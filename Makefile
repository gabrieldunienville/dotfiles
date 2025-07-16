PACKAGES := zsh git vim tmux

USER_STOW_PACKAGES := \
	claude:${HOME}/.claude \
	git:${HOME} \
	httpie:${HOME}/.config/httpie \
	mcphub:${HOME}/.config/mcphub \
	ipython:${HOME}/.ipython \
	obsidian:${HOME} \
	tmux:${HOME} \
	custom-scripts:${HOME}/.local/bin \
	zsh:${HOME} \
	wezterm:${HOME} \
	desktop:${HOME}/.local/share/applications \
	sway:${HOME}/.config \
	nvim:${HOME}/.config/nvim

# Require sudo
SYSTEM_STOW_PACKAGES := \
	zsa-rules:/etc/udev/rules.d
	

.PHONY: install-user install-system install uninstall-user uninstall-system uninstall

install: install-user install-system

uninstall: uninstall-user uninstall-system

install-user:
	@$(foreach pkg_target,$(USER_STOW_PACKAGES), \
		$(eval pkg := $(word 1,$(subst :, ,$(pkg_target)))) \
		$(eval target := $(word 2,$(subst :, ,$(pkg_target)))) \
		mkdir -p "$(target)" && \
		echo "Installing $(pkg) to $(target)" ; \
		stow --target="$(target)" $(pkg) ; \
	)

install-system:
	@$(foreach pkg_target,$(SYSTEM_STOW_PACKAGES), \
		$(eval pkg := $(word 1,$(subst :, ,$(pkg_target)))) \
		$(eval target := $(word 2,$(subst :, ,$(pkg_target)))) \
		echo "Installing $(pkg) to $(target)" ; \
		sudo stow --target="$(target)" $(pkg) ; \
	)

uninstall-user:
	@$(foreach pkg_target,$(USER_STOW_PACKAGES), \
		$(eval pkg := $(word 1,$(subst :, ,$(pkg_target)))) \
		$(eval target := $(word 2,$(subst :, ,$(pkg_target)))) \
		echo "Uninstalling $(pkg) from $(target)" ; \
		stow --target="$(target)" --del $(pkg) ; \
	)

uninstall-system:
	@$(foreach pkg_target,$(SYSTEM_STOW_PACKAGES), \
		$(eval pkg := $(word 1,$(subst :, ,$(pkg_target)))) \
		$(eval target := $(word 2,$(subst :, ,$(pkg_target)))) \
		echo "Uninstalling $(pkg) from $(target)" ; \
		sudo stow --target="$(target)" --del $(pkg) ; \
	)

