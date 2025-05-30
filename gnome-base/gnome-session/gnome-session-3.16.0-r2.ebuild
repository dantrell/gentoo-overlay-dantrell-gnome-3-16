# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools gnome2

DESCRIPTION="Gnome session manager"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-session"

LICENSE="GPL-2 LGPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="*"

IUSE="ck consolekit doc elogind gconf systemd wayland"
REQUIRED_USE="
	?? ( ck consolekit elogind systemd )
	wayland? ( || ( elogind systemd ) )
"

# x11-misc/xdg-user-dirs{,-gtk} are needed to create the various XDG_*_DIRs, and
# create .config/user-dirs.dirs which is read by glib to get G_USER_DIRECTORY_*
# xdg-user-dirs-update is run during login (see 10-user-dirs-update-gnome below).
# gdk-pixbuf used in the inhibit dialog
COMMON_DEPEND="
	>=dev-libs/glib-2.40.0:2[dbus]
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-2.90.7:3
	>=dev-libs/json-glib-0.10
	>=gnome-base/gnome-desktop-3.9.91:3=
	gconf? ( >=gnome-base/gconf-2:2 )
	wayland? ( media-libs/mesa[egl(+),gles2] )
	!wayland? ( media-libs/mesa[gles2,X(+)] )

	x11-libs/libSM
	x11-libs/libICE
	x11-libs/libXau
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXext
	x11-libs/libXrender
	x11-libs/libXtst
	x11-misc/xdg-user-dirs
	x11-misc/xdg-user-dirs-gtk
	x11-apps/xdpyinfo

	ck? ( <sys-auth/consolekit-0.9 )
	consolekit? ( >=sys-auth/consolekit-0.9 )
	elogind? ( sys-auth/elogind )
	systemd? ( >=sys-apps/systemd-186:0= )
"
# Pure-runtime deps from the session files should *NOT* be added here
# Otherwise, things like gdm pull in gnome-shell
# gnome-themes-standard is needed for the failwhale dialog themeing
# sys-apps/dbus[X] is needed for session management
RDEPEND="${COMMON_DEPEND}
	gnome-base/gnome-settings-daemon
	>=gnome-base/gsettings-desktop-schemas-0.1.7
	x11-themes/adwaita-icon-theme
	sys-apps/dbus[X]
"
DEPEND="${COMMON_DEPEND}
	>=dev-lang/perl-5
	dev-libs/libxslt
	>=dev-util/intltool-0.40.6
	>=sys-devel/gettext-0.10.40
	virtual/pkgconfig
	!<gnome-base/gdm-2.20.4
	doc? (
		app-text/xmlto
		dev-libs/libxslt )
"
# gnome-common needed for eautoreconf
# gnome-base/gdm does not provide gnome.desktop anymore

src_prepare() {
	eapply "${FILESDIR}"/${PN}-3.24.1-support-elogind.patch

	if use ck; then
		# From Funtoo:
		# 	https://bugs.funtoo.org/browse/FL-1329
		eapply "${FILESDIR}"/${PN}-3.16.0-restore-deprecated-code.patch
	fi

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	local myconf=()

	# 1. Avoid automagic on old upower releases
	# 2. xsltproc is always checked due to man configure
	#    switch, even if USE=-doc
	# 3. Enable old gconf support
	if use ck; then
		myconf+=(
			$(use_enable ck consolekit)
			$(use_enable ck deprecated)
		)
	fi

	if ! use ck; then
		myconf+=(
			$(use_enable consolekit)
			UPOWER_CFLAGS=""
			UPOWER_LIBS=""
		)
	fi

	gnome2_src_configure \
		--enable-session-selector \
		$(use_enable doc docbook-docs) \
		$(use_enable elogind) \
		$(use_enable gconf) \
		--enable-ipv6 \
		$(use_enable systemd) \
		"${myconf[@]}"
}

src_install() {
	gnome2_src_install

	dodir /etc/X11/Sessions
	exeinto /etc/X11/Sessions
	doexe "${FILESDIR}"/Gnome

	insinto /usr/share/applications
	newins "${FILESDIR}"/${PN}-3.16.0-defaults.list gnome-mimeapps.list

	dodir /etc/X11/xinit/xinitrc.d/
	exeinto /etc/X11/xinit/xinitrc.d/
	newexe "${FILESDIR}"/15-xdg-data-gnome-r1 15-xdg-data-gnome

	# This should be done here as discussed in bug #270852
	newexe "${FILESDIR}"/10-user-dirs-update-gnome-r1 10-user-dirs-update-gnome

	# Set XCURSOR_THEME from current dconf setting instead of installing
	# default cursor symlink globally and affecting other DEs (bug #543488)
	# https://bugzilla.gnome.org/show_bug.cgi?id=711703
	newexe "${FILESDIR}"/90-xcursor-theme-gnome 90-xcursor-theme-gnome
}

pkg_postinst() {
	gnome2_pkg_postinst

	if ! has_version gnome-base/gdm && ! has_version x11-misc/sddm; then
		ewarn "If you use a custom .xinitrc for your X session,"
		ewarn "make sure that the commands in the xinitrc.d scripts are run."
	fi
}
