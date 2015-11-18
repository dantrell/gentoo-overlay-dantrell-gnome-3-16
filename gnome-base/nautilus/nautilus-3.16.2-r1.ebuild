# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes" # Needed with USE 'sendto'

inherit eutils gnome2 readme.gentoo virtualx

DESCRIPTION="A file manager for the GNOME desktop"
HOMEPAGE="https://wiki.gnome.org/Apps/Nautilus"

LICENSE="GPL-2+ LGPL-2+ FDL-1.1"
SLOT="0"

# profiling?
IUSE="exif gnome +introspection packagekit +previewer sendto tracker xmp +vanilla"
KEYWORDS="*"

# FIXME: tests fails under Xvfb, but pass when building manually
# "FAIL: check failed in nautilus-file.c, line 8307"
RESTRICT="test"

# FIXME: selinux support is automagic
# Require {glib,gdbus-codegen}-2.30.0 due to GDBus API changes between 2.29.92
# and 2.30.0
COMMON_DEPEND="
	>=dev-libs/glib-2.43.4:2[dbus]
	>=x11-libs/pango-1.28.3
	>=x11-libs/gtk+-3.15.2:3[introspection?]
	>=dev-libs/libxml2-2.7.8:2
	>=gnome-base/gnome-desktop-3:3=

	gnome-base/dconf
	>=gnome-base/gsettings-desktop-schemas-3.8.0
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrender

	exif? ( >=media-libs/libexif-0.6.20 )
	introspection? ( >=dev-libs/gobject-introspection-0.6.4 )
	tracker? ( >=app-misc/tracker-0.16:= )
	xmp? ( >=media-libs/exempi-2.1.0 )
"
DEPEND="${COMMON_DEPEND}
	>=dev-lang/perl-5
	>=dev-util/gdbus-codegen-2.33
	>=dev-util/gtk-doc-am-1.4
	>=dev-util/intltool-0.40.1
	sys-devel/gettext
	virtual/pkgconfig
	x11-proto/xproto
"
RDEPEND="${COMMON_DEPEND}
	packagekit? ( app-admin/packagekit-base )
	sendto? ( !<gnome-extra/nautilus-sendto-3.0.1 )
"

# For eautoreconf
#	gnome-base/gnome-common
#	dev-util/gtk-doc-am"

PDEPEND="
	gnome? (
		>=x11-themes/gnome-icon-theme-1.1.91
		x11-themes/gnome-icon-theme-symbolic )
	tracker? ( >=gnome-extra/nautilus-tracker-tags-0.12 )
	previewer? ( >=gnome-extra/sushi-0.1.9 )
	sendto? ( >=gnome-extra/nautilus-sendto-3.0.1 )
	>=gnome-base/gvfs-1.14[gtk]
"
# Need gvfs[gtk] for recent:/// support

src_prepare() {
	if use previewer; then
		DOC_CONTENTS="nautilus uses gnome-extra/sushi to preview media files.
			To activate the previewer, select a file and press space; to
			close the previewer, press space again."
	fi

	if ! use vanilla; then
		epatch "${FILESDIR}"/${P}-support-click-to-rename.patch
	fi

	# From GNOME
	# 	https://git.gnome.org/browse/nautilus/commit/?id=4c56f31c0ad6c94a5851ef8b9f0142acfdabf4ad
	# 	https://git.gnome.org/browse/nautilus/commit/?id=10ca6eed2a6ef80cae2a0649bfe682a6c02fed9f
	# 	https://git.gnome.org/browse/nautilus/commit/?id=dfaad5ea3de9c55922ecd369c81a861efddb349b
	# 	https://git.gnome.org/browse/nautilus/commit/?id=a4ef903f2302bdc96798d843f369eef432160e11
	# 	https://git.gnome.org/browse/nautilus/commit/?id=bfe878e4313e21b4c539d95a88d243065d30fc2c
	epatch "${FILESDIR}"/${P}-nautilus-bookmark-dont-crash-if-file-is-gone.patch
	epatch "${FILESDIR}"/${P}-toolbar-show-modified-time-for-all-places-except-recent.patch
	epatch "${FILESDIR}"/${P}-application-actions-use-valid-window-list.patch
	epatch "${FILESDIR}"/${P}-nautilus-file-peek-display-name-dont-return-null.patch
	epatch "${FILESDIR}"/${PN}-3.17.3-ignore-no-desktop-if-not-first-launch.patch

	# Remove -D*DEPRECATED flags. Don't leave this for eclass! (bug #448822)
	sed -e 's/DISABLE_DEPRECATED_CFLAGS=.*/DISABLE_DEPRECATED_CFLAGS=/' \
		-i configure || die "sed failed"

	gnome2_src_prepare
}

src_configure() {
	DOCS="AUTHORS HACKING MAINTAINERS NEWS README* THANKS"
	gnome2_src_configure \
		--disable-profiling \
		--disable-update-mimedb \
		$(use_enable exif libexif) \
		$(use_enable introspection) \
		$(use_enable packagekit) \
		$(use_enable sendto nst-extension) \
		$(use_enable tracker) \
		$(use_enable xmp)
}

src_test() {
	gnome2_environment_reset
	unset DBUS_SESSION_BUS_ADDRESS
	export GSETTINGS_BACKEND="memory"
	Xemake check
	unset GSETTINGS_BACKEND
}

src_install() {
	use previewer && readme.gentoo_create_doc
	gnome2_src_install
}

pkg_postinst() {
	gnome2_pkg_postinst

	if use previewer; then
		readme.gentoo_print_elog
	else
		elog "To preview media files, emerge nautilus with USE=previewer"
	fi
}
