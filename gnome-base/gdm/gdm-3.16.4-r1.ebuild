# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit autotools gnome2 pam readme.gentoo-r1 systemd versionator

DESCRIPTION="GNOME Display Manager for managing graphical display servers and user logins"
HOMEPAGE="https://wiki.gnome.org/Projects/GDM"
SRC_URI="${SRC_URI}
	branding? ( https://www.mail-archive.com/tango-artists@lists.freedesktop.org/msg00043/tango-gentoo-v1.1.tar.gz )
"

LICENSE="
	GPL-2+
	branding? ( CC-BY-SA-4.0 )
"
SLOT="0"
KEYWORDS="*"

IUSE="accessibility audit branding ck elogind fprint +introspection plymouth selinux smartcard systemd tcpd test wayland xinerama"
REQUIRED_USE="
	?? ( ck elogind systemd )
	wayland? ( || ( elogind systemd ) )
"

RESTRICT="!test? ( test )"

# NOTE: x11-base/xorg-server dep is for X_SERVER_PATH etc, bug #295686
# nspr used by smartcard extension
# dconf, dbus and g-s-d are needed at install time for dconf update
# We need either systemd or >=openrc-0.12 to restart gdm properly, bug #463784
COMMON_DEPEND="
	app-text/iso-codes
	>=dev-libs/glib-2.36:2[dbus]
	>=x11-libs/gtk+-2.91.1:3
	>=gnome-base/dconf-0.20
	>=gnome-base/gnome-settings-daemon-3.1.4
	gnome-base/gsettings-desktop-schemas
	>=media-libs/fontconfig-2.5.0:1.0
	>=media-libs/libcanberra-0.4[gtk3]
	sys-apps/dbus
	>=sys-apps/accountsservice-0.6.12

	x11-apps/sessreg
	x11-base/xorg-server
	x11-libs/libXi
	x11-libs/libXau
	x11-libs/libX11
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXft
	>=x11-misc/xdg-utils-1.0.2-r3

	sys-libs/pam

	ck? ( >=sys-power/upower-0.99:=[ck] )
	elogind? ( sys-auth/elogind )
	systemd? ( >=sys-apps/systemd-186:0=[pam] )

	sys-auth/pambase[ck?,elogind?,systemd?]

	audit? ( sys-process/audit )
	introspection? ( >=dev-libs/gobject-introspection-0.9.12:= )
	plymouth? ( sys-boot/plymouth )
	selinux? ( sys-libs/libselinux )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )
	xinerama? ( x11-libs/libXinerama )
"
# XXX: These deps are from session and desktop files in data/ directory
# fprintd is used via dbus by gdm-fingerprint-extension
# gnome-session-3.6 needed to avoid freezing with orca
RDEPEND="${COMMON_DEPEND}
	acct-group/gdm
	acct-user/gdm
	>=gnome-base/gnome-session-3.6
	>=gnome-base/gnome-shell-3.1.90
	gnome-extra/polkit-gnome:0
	x11-apps/xhost

	accessibility? (
		>=app-accessibility/orca-3.10
		gnome-extra/mousetweaks )
	fprint? ( sys-auth/fprintd[pam] )

	!gnome-extra/fast-user-switch-applet
"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xml-dtd:4.1.2
	dev-util/gdbus-codegen
	>=dev-util/intltool-0.40.0
	dev-util/itstool
	virtual/pkgconfig
	x11-base/xorg-proto
	test? ( >=dev-libs/check-0.9.4 )
"

DOC_CONTENTS="
	To make GDM start at boot, run:\n
	# systemctl enable gdm.service\n
	\n
	For passwordless login to unlock your keyring, you need to install
	sys-auth/pambase with USE=gnome-keyring and set an empty password
	on your keyring. Use app-crypt/seahorse for that.\n
	\n
	You may need to install app-crypt/coolkey and sys-auth/pam_pkcs11
	for smartcard support
"

src_prepare() {
	# make custom session work, bug #216984, upstream bug #737578
	eapply "${FILESDIR}"/${PN}-3.2.1.1-custom-session.patch

	# ssh-agent handling must be done at xinitrc.d, bug #220603
	eapply "${FILESDIR}"/${PN}-2.32.0-xinitrc-ssh-agent.patch

	# Gentoo does not have a fingerprint-auth pam stack
	eapply "${FILESDIR}"/${PN}-3.8.4-fingerprint-auth.patch

	# Show logo when branding is enabled
	use branding && eapply "${FILESDIR}"/${PN}-3.8.4-logo.patch

	if use elogind; then
		eapply "${FILESDIR}"/${PN}-3.16.4-remove-deprecated-consolekit-code.patch
		eapply "${FILESDIR}"/${PN}-3.24.2-support-elogind.patch
		eapply "${FILESDIR}"/${PN}-3.24.2-enable-elogind.patch
	fi

	if ! use wayland; then
		eapply "${FILESDIR}"/${PN}-3.24.2-prioritize-xorg.patch
	fi

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	local myconf=()

	# PAM is the only auth scheme supported
	# even though configure lists shadow and crypt
	# they don't have any corresponding code.
	# --with-at-spi-registryd-directory= needs to be passed explicitly because
	# of https://bugzilla.gnome.org/show_bug.cgi?id=607643#c4
	# Xevie is obsolete, bug #482304
	# --with-initial-vt=7 conflicts with plymouth, bug #453392
	! use plymouth && myconf+=( --with-initial-vt=7 )

	if use ck; then
		myconf+=(
			--with-consolekit-directory="${EPREFIX}"/usr/lib/ConsoleKit
			--without-systemd
			$(use_with ck console-kit)
		)
	fi

	gnome2_src_configure \
		--with-run-dir=/run/gdm \
		--localstatedir="${EPREFIX}"/var \
		--disable-static \
		--with-xdmcp=yes \
		--enable-authentication-scheme=pam \
		--with-default-pam-config=exherbo \
		--with-at-spi-registryd-directory="${EPREFIX}"/usr/libexec \
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)" \
		--without-xevie \
		$(use_with audit libaudit) \
		--enable-ipv6 \
		$(use_with plymouth) \
		$(use_with selinux) \
		$(use_enable systemd systemd-journal) \
		$(use_with tcpd tcp-wrappers) \
		$(use_enable wayland wayland-support) \
		$(use_with xinerama) \
		"${myconf[@]}"
}

src_install() {
	gnome2_src_install

	if ! use accessibility ; then
		rm "${ED}"/usr/share/gdm/greeter/autostart/orca-autostart.desktop || die
	fi

	exeinto /etc/X11/xinit/xinitrc.d
	newexe "${FILESDIR}"/49-keychain-r1 49-keychain
	newexe "${FILESDIR}"/50-ssh-agent-r1 50-ssh-agent

	# install XDG_DATA_DIRS gdm changes
	echo 'XDG_DATA_DIRS="/usr/share/gdm"' > 99xdg-gdm
	doenvd 99xdg-gdm

	use branding && newicon "${WORKDIR}/tango-gentoo-v1.1/scalable/gentoo.svg" gentoo-gdm.svg

	readme.gentoo_create_doc
}

pkg_postinst() {
	local d ret

	gnome2_pkg_postinst

	# bug #436456; gdm crashes if /var/lib/gdm subdirs are not owned by gdm:gdm
	ret=0
	ebegin "Fixing ${EROOT}/var/lib/gdm ownership"
	chown gdm:gdm "${EROOT}var/lib/gdm" || ret=1
	for d in "${EROOT}var/lib/gdm/"{.cache,.config,.local}; do
		[[ ! -e "${d}" ]] || chown -R gdm:gdm "${d}" || ret=1
	done
	eend ${ret}

	if use systemd ; then
		systemd_reenable gdm.service
	fi

	readme.gentoo_print_elog

	local v
	for v in ${REPLACING_VERSIONS}; do
		if ! version_is_at_least 3.16.0 ${v}; then
			ewarn "GDM will now use a new TTY per logged user as explained at:"
			ewarn "https://wiki.gentoo.org/wiki/Project:GNOME/GNOME3-Troubleshooting#GDM_.3E.3D_3.16_opens_one_graphical_session_per_user"
			break
		fi
	done
}
